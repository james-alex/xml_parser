import 'package:html_character_entities/html_character_entities.dart';
import '../helpers/delimiters.dart';
import '../helpers/helpers.dart' as helpers;

/// An attribute of a XML element.
class XmlAttribute {
  /// An attribute of a XML element.
  ///
  /// [name] must not be `null` or empty.
  const XmlAttribute(
    this.name,
    this.value,
  ) : assert(name != null && name.length > 0);

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
    assert(doubleQuotes != null);
    assert(encodeCharacterEntities != null);

    final String quotationMark = (doubleQuotes) ? '"' : '\'';

    String value = this.value;

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
  static XmlAttribute fromString(
    String string, {
    bool parseCharacterEntities = true,
  }) {
    assert(string != null);
    assert(parseCharacterEntities != null);

    string = helpers.removeComments(string);

    final RegExpMatch attribute = Delimiters.attribute.firstMatch(string);

    if (attribute == null) return null;

    final String name = attribute.namedGroup('name');

    String value = attribute.namedGroup('value');

    if (parseCharacterEntities) value = HtmlCharacterEntities.decode(value);

    return XmlAttribute(name, value);
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
  static List<XmlAttribute> parseString(
    String string, {
    bool parseCharacterEntities = true,
    bool trimWhitespace = true,
    int start = 0,
    int stop,
  }) {
    assert(string != null);
    assert(parseCharacterEntities != null);
    assert(trimWhitespace != null);
    assert(start != null && start >= 0);
    assert(stop == null || stop >= start);

    string = helpers.removeComments(string);

    if (trimWhitespace) string = helpers.trimWhitespace(string);

    final Iterable<RegExpMatch> matches =
        Delimiters.attribute.allMatches(string);

    if (matches.isEmpty || start >= matches.length) return null;

    final List<XmlAttribute> attributes = List<XmlAttribute>();

    int attributeCount = 0;

    for (RegExpMatch match in matches) {
      final String name = match.namedGroup('name');

      if (name == null) continue;

      if (attributeCount >= start) {
        String value = match.namedGroup('value');

        if (value != null) value = helpers.stripDelimiters(value);

        if (parseCharacterEntities) value = HtmlCharacterEntities.decode(value);

        attributes.add(XmlAttribute(name, value));
      }

      attributeCount++;

      if (stop != null && attributeCount > stop) break;
    }

    if (attributes.isEmpty) return null;

    return attributes;
  }

  @override
  bool operator ==(o) =>
      o is XmlAttribute &&
      name.toLowerCase() == o.name.toLowerCase() &&
      value == o.value;

  @override
  int get hashCode => name.hashCode ^ value.hashCode;
}
