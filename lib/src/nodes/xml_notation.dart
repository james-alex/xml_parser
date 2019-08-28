import '../helpers/delimiters.dart';
import '../helpers/helpers.dart' as helpers;
import '../helpers/string_parser.dart';
import '../xml_node.dart';

/// A Notation Declaration, as known as an unparsed entity.
///
/// See: https://www.w3.org/TR/xml/#Notations
class XmlNotation implements XmlNode {
  /// A notation declaration, as known as an unparsed entity.
  ///
  /// [name] must not be `null` or empty.
  ///
  /// Either [isSystem] or [isPublic] must be `true`, but not both.
  ///
  /// [publicId] must be `null` if [isPublic] is `false`.
  ///
  /// [uri] must not be `null` if [isSystem] is `true`, but is optional
  /// if [isPublic] is `true`.
  const XmlNotation({
    this.name,
    this.isSystem = false,
    this.isPublic = false,
    this.publicId,
    this.uri,
  })  : assert(name != null && name.length > 0),
        assert((isSystem && !isPublic) || (!isSystem && isPublic)),
        assert(publicId == null || isPublic),
        assert(!isSystem || uri != null);

  /// The name of the notation.
  final String name;

  /// `ture` if the `SYSTEM` flag is declared.
  final bool isSystem;

  /// `true` if the `PUBLIC` flag is declared.
  final bool isPublic;

  /// A public ID may be used by the application to generate an alternative
  /// URI reference where an external notation may be found.
  final String publicId;

  /// The location of the external notation.
  final String uri;

  @override
  String toString([bool doubleQuotes = true]) {
    assert(doubleQuotes != null);

    final String quotationMark = (doubleQuotes) ? '"' : '\'';

    final String identifier = (isSystem) ? 'SYSTEM' : 'PUBLIC';

    final String publicId = (this.publicId != null)
        ? ' $quotationMark${this.publicId}$quotationMark'
        : '';

    final String uri =
        (this.uri != null) ? ' $quotationMark${this.uri}$quotationMark' : '';

    return '<!NOTATION $name $identifier$publicId$uri>';
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

    String notation =
        helpers.formatLine(toString(doubleQuotes), nestingLevel, indent);

    // TODO: Handle lineLength

    return notation;
  }

  /// Returns the first Notation Declaration found in [string].
  ///
  /// [string] must not be `null`.
  ///
  /// If [trimWhitespace] is `true`, unnecessary whitespace between nodes
  /// will be removed and all remaining whitespace will be replaced with
  /// a single space. [trimWhitespace] must not be `null`.
  ///
  /// Returns `null` if no valid Notation Declarations are found.
  static XmlNotation fromString(
    String string, {
    bool trimWhitespace = true,
  }) {
    assert(string != null);
    assert(trimWhitespace != null);

    return _parser.fromString(
      input: string,
      delimiter: Delimiters.notation,
      getNode: _getNotation,
      trimWhitespace: trimWhitespace,
    );
  }

  /// Returns all Notation Declarations found in [string].
  ///
  /// If [trimWhitespace] is `true`, unnecessary whitespace between nodes
  /// will be removed and all remaining whitespace will be replaced with
  /// a single space. [trimWhitespace] must not be `null`.
  ///
  /// [start] and [stop] refer to the indexes of the identified notation
  /// declarations. Only matches found between [start] and [stop] will be
  /// returned. [start] must not be `null` and must be `>= 0`. [stop] may
  /// be `null`, but must be `>= start` if provided.
  ///
  /// Returns `null` if no valid Notation Declarations are found.
  static List<XmlNotation> parseString(
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
      delimiter: Delimiters.notation,
      getNode: _getNotation,
      trimWhitespace: trimWhitespace,
      start: start,
      stop: stop,
    );
  }

  /// Builds an [XmlNotation] node from a [RegExpMatch] if the captured
  /// values are valid, otherwise returns `null`.
  static XmlNotation _getNotation(RegExpMatch notation) {
    assert(notation != null);

    final String name = notation.namedGroup('name');

    if (name == null) return null;

    final String identifier = notation.namedGroup('identifier').toUpperCase();

    final bool isPublic = identifier == 'PUBLIC';
    final bool isSystem = identifier == 'SYSTEM';

    if (!isPublic && !isSystem) return null;

    String publicId;

    String uri;

    if (isPublic) {
      publicId = notation.namedGroup('value1');

      if (publicId == null) return null;

      publicId = helpers.stripDelimiters(publicId);

      uri = notation.namedGroup('value2');

      uri = (uri.isEmpty) ? null : helpers.stripDelimiters(uri);
    } else {
      uri = notation.namedGroup('value1');

      if (uri == null) return null;

      uri = helpers.stripDelimiters(uri);
    }

    return XmlNotation(
      name: name,
      isPublic: isPublic,
      isSystem: isSystem,
      publicId: publicId,
      uri: uri,
    );
  }

  /// Contains methods to parse strings for [XmlNotation] nodes.
  static final StringParser<XmlNotation> _parser = StringParser<XmlNotation>();

  @override
  operator ==(o) =>
      o is XmlNotation &&
      name == o.name &&
      isSystem == o.isSystem &&
      isPublic == o.isPublic &&
      publicId == o.publicId &&
      uri == o.uri;

  @override
  int get hashCode =>
      name.hashCode ^
      isSystem.hashCode ^
      isPublic.hashCode ^
      publicId.hashCode ^
      uri.hashCode;
}
