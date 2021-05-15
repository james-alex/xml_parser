import 'package:meta/meta.dart';
import '../helpers/delimiters.dart';
import '../helpers/string_parser.dart';
import '../xml_node.dart';

/// The XML declaration.
///
/// All valid XML documents should begin with an XML declaration.
///
/// See: https://www.w3.org/TR/xml/#sec-prolog-dtd
@immutable
class XmlDeclaration extends XmlNodeWithAttributes {
  /// The XML declaration.
  ///
  /// All valid XML documents should begin with an XML declaration.
  ///
  /// [version] is required and must not be null.
  const XmlDeclaration({
    required this.version,
    this.encoding,
    this.standalone,
  });

  /// The version of the XML standard this document conforms to.
  final String version;

  /// The encoding character set used by this document.
  ///
  /// This is typically an IANA character set.
  ///
  /// This value is optional.
  final String? encoding;

  /// Should be `true` if this document only contains internal DTD,
  /// and `false` if this document contains external DTD.
  ///
  /// This value is optional.
  final bool? standalone;

  @override
  String toString({bool doubleQuotes = true}) {
    final quotationMark = (doubleQuotes) ? '"' : '\'';
    final encoding = (this.encoding != null)
        ? ' encoding=$quotationMark${this.encoding}$quotationMark'
        : '';
    final standalone = (this.standalone != null)
        ? ' standalone=$quotationMark${(this.standalone!) ? 'yes' : 'no'}'
            '$quotationMark'
        : '';
    return '<?xml version=$quotationMark$version'
        '$quotationMark$encoding$standalone ?>';
  }

  /// Returns the first XML declaration found in [string].
  /// [string] must not be `null`.
  ///
  /// If [trimWhitespace] is `true`, unnecessary whitespace between nodes
  /// will be removed and all remaining whitespace will be replaced with
  /// a single space. [trimWhitespace] must not be `null`.
  ///
  /// Returns `null` if no XML declaration was found.
  static XmlDeclaration? from(
    String string, {
    bool trimWhitespace = true,
  }) {
    return StringParser.from<XmlDeclaration>(
      input: string,
      delimiter: Delimiters.xmlDeclaration,
      getNode: _getDeclaration,
      trimWhitespace: trimWhitespace,
    );
  }

  /// Returns a list of every XML declaration found in [string].
  /// [string] must not be `null`.
  ///
  /// If [trimWhitespace] is `true`, unnecessary whitespace between nodes
  /// will be removed and all remaining whitespace will be replaced with
  /// a single space. [trimWhitespace] must not be `null`.
  ///
  /// [start] and [stop] refer to the indexes of the identified XML declarations
  /// Only matches found between [start] and [stop] will be returned.
  /// [start] must not be `null` and must be `>= 0`. [stop] may be `null`,
  /// but must be `>= start` if provided.
  ///
  /// Returns `null` if no XML declarations were found.
  static List<XmlDeclaration>? parseString(
    String string, {
    bool trimWhitespace = true,
    int start = 0,
    int? stop,
  }) {
    assert(start >= 0);
    assert(stop == null || stop >= start);

    return StringParser.parse<XmlDeclaration>(
      input: string,
      delimiter: Delimiters.xmlDeclaration,
      getNode: _getDeclaration,
      trimWhitespace: trimWhitespace,
      start: start,
      stop: stop,
    );
  }

  /// Builds a [XmlDeclaration] from a [RegExpMatch] if the
  /// captured values are valid, otherwise returns `null`.
  static XmlDeclaration? _getDeclaration(RegExpMatch declaration) {
    final attributeData = declaration.namedGroup('attributes');

    String? version;
    String? encoding;
    bool? standalone;

    if (attributeData != null) {
      final attributes = XmlAttribute.parseString(
        attributeData,
        parseCharacterEntities: false,
        trimWhitespace: false,
      );

      if (attributes!.isEmpty) return null;

      for (var attribute in attributes) {
        switch (attribute.name.toLowerCase()) {
          case 'version':
            version = attribute.value;
            break;
          case 'encoding':
            encoding = attribute.value;
            break;
          case 'standalone':
            final value = attribute.value.toLowerCase();
            standalone = (value == 'yes')
                ? true
                : (value == 'no')
                    ? false
                    : null;
            break;
        }
      }
    }

    if (version == null) return null;

    return XmlDeclaration(
      version: version,
      encoding: encoding,
      standalone: standalone,
    );
  }

  @override
  bool operator ==(Object o) =>
      o is XmlDeclaration &&
      version == o.version &&
      encoding == o.encoding &&
      standalone == o.standalone;

  @override
  int get hashCode =>
      version.hashCode ^ encoding.hashCode ^ standalone.hashCode;
}
