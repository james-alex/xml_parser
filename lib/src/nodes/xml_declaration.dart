import 'package:meta/meta.dart';
import '../helpers/delimiters.dart';
import '../helpers/helpers.dart' as helpers;
import '../helpers/string_parser.dart';
import '../xml_node.dart';

/// The XML declaration.
///
/// All valid XML documents should begin with an XML declaration.
///
/// See: https://www.w3.org/TR/xml/#sec-prolog-dtd
class XmlDeclaration implements XmlNode {
  /// The XML declaration.
  ///
  /// All valid XML documents should begin with an XML declaration.
  ///
  /// [version] is required and must not be null.
  const XmlDeclaration({
    @required this.version,
    this.encoding,
    this.standalone,
  }) : assert(version != null);

  /// The version of the XML standard this document conforms to.
  final String version;

  /// The encoding character set used by this document.
  ///
  /// This is typically an IANA character set.
  ///
  /// This value is optional.
  final String encoding;

  /// Should be `true` if this document only contains internal DTD,
  /// and `false` if this document contains external DTD.
  ///
  /// This value is optional.
  final bool standalone;

  @override
  String toString([bool doubleQuotes = true]) {
    assert(doubleQuotes != null);

    final String quotationMark = (doubleQuotes) ? '"' : '\'';

    final String encoding = (this.encoding != null)
        ? ' encoding=$quotationMark${this.encoding}$quotationMark'
        : '';

    final String standalone = (this.standalone != null)
        ? ' standalone=$quotationMark${(this.standalone) ? 'yes' : 'no'}$quotationMark'
        : '';

    return '<?xml version=$quotationMark$version$quotationMark$encoding$standalone ?>';
  }

  @override
  String toFormattedString({
    int nestingLevel = 0,
    String indent = '\t',
    // TODO: int lineLength = 80,
    bool doubleQuotes = true,
  }) {
    assert(nestingLevel != null && nestingLevel >= 0);
    assert(indent != null);
    // TODO: assert(lineLength == null || lineLength > 0);
    assert(doubleQuotes != null);

    String declaration =
        helpers.formatLine(toString(doubleQuotes), nestingLevel, indent);

    // TODO: Handle lineLength

    return declaration;
  }

  /// Returns the first XML declaration found in [string].
  /// [string] must not be `null`.
  ///
  /// If [trimWhitespace] is `true`, unnecessary whitespace between nodes
  /// will be removed and all remaining whitespace will be replaced with
  /// a single space. [trimWhitespace] must not be `null`.
  ///
  /// Returns `null` if no XML declaration was found.
  static XmlDeclaration fromString(
    String string, {
    bool trimWhitespace = true,
  }) {
    assert(string != null);
    assert(trimWhitespace != null);

    return _parser.fromString(
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
  static List<XmlDeclaration> parseString(
    String string, {
    bool trimWhitespace = true,
    int start = 0,
    int stop,
  }) {
    assert(string != null);
    assert(trimWhitespace != null);
    assert(start != null && start >= 0);
    assert(stop == null || stop >= start);

    return _parser.parseString(
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
  static XmlDeclaration _getDeclaration(RegExpMatch declaration) {
    assert(declaration != null);

    final String attributeData = declaration.namedGroup('attributes');

    String version;
    String encoding;
    bool standalone;

    if (attributeData != null) {
      final List<XmlAttribute> attributes = XmlAttribute.parseString(
        attributeData,
        parseCharacterEntities: false,
        trimWhitespace: false,
      );

      if (attributes.isEmpty) return null;

      attributes.forEach((XmlAttribute attribute) {
        switch (attribute.name.toLowerCase()) {
          case 'version':
            version = attribute.value;
            break;
          case 'encoding':
            encoding = attribute.value;
            break;
          case 'standalone':
            final String value = attribute.value.toLowerCase();
            standalone =
                (value == 'yes') ? true : (value == 'no') ? false : null;
            break;
        }
      });
    }

    if (version == null) return null;

    return XmlDeclaration(
      version: version,
      encoding: encoding,
      standalone: standalone,
    );
  }

  /// Contains methods to parse strings for [XmlDeclaration] nodes.
  static final StringParser<XmlDeclaration> _parser =
      StringParser<XmlDeclaration>();

  @override
  operator ==(o) =>
      o is XmlDeclaration &&
      version == o.version &&
      encoding == o.encoding &&
      standalone == o.standalone;

  @override
  int get hashCode =>
      version.hashCode ^ encoding.hashCode ^ standalone.hashCode;
}
