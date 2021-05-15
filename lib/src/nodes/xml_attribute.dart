import 'package:html_character_entities/html_character_entities.dart';
import 'package:meta/meta.dart';
import '../helpers/delimiters.dart';
import '../helpers/formatters.dart';

/// An attribute of a XML element.
@immutable
class XmlAttribute {
  /// An attribute of a XML element.
  ///
  /// [name] must not be `null` or empty.
  const XmlAttribute(this.name, this.value) : assert(name.length > 0);

  /// The name of the attribute.
  final String name;

  /// The value of the attribute.
  final String value;

  @override
  String toString({
    bool doubleQuotes = true,
    bool encodeCharacterEntities = true,
    String encodeCharacters = '&<>"\'',
  }) {
    final quotationMark = (doubleQuotes) ? '"' : '\'';
    var value = this.value;
    if (encodeCharacterEntities) {
      value = HtmlCharacterEntities.encode(value, checkAmpsForEntities: true);
    }
    value = quotationMark + value + quotationMark;
    return '$name=$value';
  }

  /// Returns the first attribute found in [string].
  /// [string] must not be `null`.
  ///
  /// If [parseCharacterEntities] is `true`, attribute values will be parsed
  /// and replace all encoded character entities with their corresponding
  /// character. [parseCharacterEntities] must not be `null`.
  ///
  /// Returns `null` if no attributes are found.
  static XmlAttribute? from(
    String string, {
    bool parseCharacterEntities = true,
  }) {
    string = string.removeComments();
    final attribute = Delimiters.attribute.firstMatch(string);
    if (attribute == null) return null;
    final name = attribute.namedGroup('name');
    var value = attribute.namedGroup('value');
    if (parseCharacterEntities) value = HtmlCharacterEntities.decode(value!);
    return XmlAttribute(name!, value!);
  }

  /// Returns a list of every attribute found in [string].
  /// [string] must not be `null`.
  ///
  /// If [trimWhitespace] is `true`, unnecessary whitespace between nodes
  /// will be removed and all remaining whitespace will be replaced with
  /// a single space. [trimWhitespace] must not be `null`.
  ///
  /// If [parseCharacterEntities] is `true`, attribute values will be parsed
  /// and replace all encoded character entities with their corresponding
  /// character. [parseCharacterEntities] must not be `null`.
  ///
  /// [start] and [stop] refer to the indexes of the identified Attlist
  /// Declarations. Only matches found between [start] and [stop] will be
  /// returned. [start] must not be `null` and must be `>= 0`. [stop] may be
  /// `null`, but must be `>= start` if provided.
  ///
  /// Returns `null` if no attributes are found.
  static List<XmlAttribute>? parseString(
    String string, {
    bool parseCharacterEntities = true,
    bool trimWhitespace = true,
    int start = 0,
    int? stop,
  }) {
    assert(start >= 0);
    assert(stop == null || stop >= start);

    string = string.removeComments();
    if (trimWhitespace) string = string.trimWhitespace();

    final matches = Delimiters.attribute.allMatches(string);
    if (matches.isEmpty || start >= matches.length) return null;

    final attributes = <XmlAttribute>[];
    var attributeCount = 0;

    for (var match in matches) {
      final name = match.namedGroup('name');
      if (name == null) continue;
      if (attributeCount >= start) {
        var value = match.namedGroup('value');
        if (value != null) value = value.stripDelimiters();
        if (parseCharacterEntities) {
          value = HtmlCharacterEntities.decode(value!);
        }
        attributes.add(XmlAttribute(name, value!));
      }
      attributeCount++;
      if (stop != null && attributeCount > stop) break;
    }

    if (attributes.isEmpty) return null;

    return attributes;
  }

  @override
  bool operator ==(Object o) =>
      o is XmlAttribute &&
      name.toLowerCase() == o.name.toLowerCase() &&
      value == o.value;

  @override
  int get hashCode => name.hashCode ^ value.hashCode;
}
