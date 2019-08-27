import 'package:meta/meta.dart';
import 'package:recursive_regex/recursive_regex.dart';
import '../helpers/delimiters.dart';
import '../helpers/helpers.dart' as helpers;
import '../xml_node.dart';

/// A XML DocType declaration.
///
/// See: https://www.w3.org/TR/xml/#NT-doctypedecl
class XmlDoctype implements XmlNode {
  /// A XML DocType declaration.
  ///
  /// [element] is required, must not be `null`, and must be `> 0` in length.
  ///
  /// [isSystem] and [isPublic] must not be `null`, and only
  /// one of them may be `true`.
  const XmlDoctype({
    @required this.element,
    this.isSystem,
    this.isPublic,
    this.externalDtdName,
    this.externalDtdUri,
    this.externalDtd,
    this.internalDtd,
  })  : assert(element != null && element.length > 0),
        assert(isSystem != null),
        assert(!(isPublic && isSystem));

  /// The name of the DocType declaration.
  final String element;

  /// Whether the `SYSTEM` flag is declared.
  final bool isSystem;

  /// Whether the `PUBLIC` flag is declared.
  final bool isPublic;

  /// The optional name of the external DTD file.
  final String externalDtdName;

  /// The URI to the external DTD file.
  final String externalDtdUri;

  /// The parsed DTD elements from the external DTD file.
  final List<XmlNode> externalDtd;

  /// The parsed DTD elements nested within this DocType.
  final List<XmlNode> internalDtd;

  /// Attempts to load the external DTD file from [externalDtdUri] and
  /// parse the DTD elements contained within. A new [XmlDoctype] will
  /// be returned with the parsed DTD elements in the [externalDtd] value.
  ///
  /// If the URI couldn't be reached or no DTD elements could be identified,
  /// Returns `null`.
  Future<XmlDoctype> loadExternalDtd() async {
    if (externalDtdUri == null) return null;

    final List<XmlNode> externalEntities =
        await XmlNode.fromUri(externalDtdUri);

    if (externalEntities == null) return null;

    return copyWith(externalDtd: externalEntities);
  }

  /// Copies this DocType declaration with the provided values.
  ///
  /// [name] must be `> 0` in length if not `null`.
  ///
  /// Either [isSystem] or [isPublic] may be `true`, not both.
  ///
  /// If [copyNull] is `true`, [externalDtdName], [externalDtdUri],
  /// [externalDtd], and [internalDtd] will be copied with a value
  /// of `null` if they're not provided with another value, otherwise
  /// they will default to this element's values.
  XmlDoctype copyWith({
    String element,
    bool isSystem,
    bool isPublic,
    String externalDtdName,
    String externalDtdUri,
    List<XmlNode> externalDtd,
    List<XmlNode> internalDtd,
    bool copyNull = false,
  }) {
    assert(element == null || element.isNotEmpty);
    assert(!(isPublic && isSystem));
    assert(copyNull != null);

    if (!copyNull) {
      externalDtdName ??= this.externalDtdName;
      externalDtdUri ??= this.externalDtdUri;
      externalDtd ??= this.externalDtd;
      internalDtd ??= this.internalDtd;
    }

    return XmlDoctype(
      element: element ?? this.element,
      isSystem: isSystem ?? (isPublic != null)
          ? !isPublic
          : (this.isPublic != null) ? !this.isPublic : false,
      isPublic: isPublic ?? (isSystem != null)
          ? !isSystem
          : (this.isSystem != null) ? !this.isSystem : false,
      externalDtdName: externalDtdName,
      externalDtdUri: externalDtdUri,
      externalDtd: externalDtd,
      internalDtd: internalDtd,
    );
  }

  @override
  String toString({
    bool encodeCharacterEntities = true,
    String encodeCharacters,
    bool doubleQuotes = true,
  }) {
    assert(encodeCharacterEntities != null);
    assert(doubleQuotes != null);

    final String doctype = _getTag(doubleQuotes);

    String internalDtd = '';

    if (this.internalDtd != null) {
      internalDtd = ' [' +
          helpers.childrenToString(
            children: this.internalDtd,
            encodeCharacterEntities: encodeCharacterEntities,
            encodeCharacters: encodeCharacters,
            doubleQuotes: doubleQuotes,
          ) +
          ']';
    }

    return '$doctype$internalDtd>';
  }

  @override
  String toFormattedString({
    int nestingLevel = 0,
    String indent = '\t',
    // TODO: int lineLength = 80,
    bool encodeCharacterEntities = true,
    String encodeCharacters,
    bool doubleQuotes = true,
  }) {
    assert(nestingLevel != null && nestingLevel >= 0);
    assert(indent != null);
    // TODO: assert(lineLength == null || lineLength > 0);
    assert(encodeCharacterEntities != null);
    assert(doubleQuotes != null);

    String doctype = _getTag(doubleQuotes);

    if (this.internalDtd != null) {
      doctype += ' [\r\n';

      doctype += helpers.formatChildren(
        children: internalDtd,
        nestingLevel: nestingLevel,
        indent: indent,
        encodeCharacterEntities: encodeCharacterEntities,
        encodeCharacters: encodeCharacters,
        doubleQuotes: doubleQuotes,
      );

      doctype += (indent * nestingLevel) + ']';
    }

    doctype += '>\r\n';

    // TODO: Handle linelength

    return doctype;
  }

  String _getTag(bool doubleQuotes) {
    assert(doubleQuotes != null);

    final String quotationMark = (doubleQuotes) ? '"' : '\'';

    final String externalDtdDeclaration =
        (this.isSystem) ? ' SYSTEM' : (this.isPublic) ? ' PUBLIC' : '';

    final String externalDtdName = (this.externalDtdName != null)
        ? ' $quotationMark${this.externalDtdName}$quotationMark'
        : '';

    return '<!DOCTYPE $element$externalDtdDeclaration$externalDtdName';
  }

  /// Returns the first XML DocType declaration found in [string].
  /// [string] must not be `null`.
  ///
  /// If [parseCharacterEntities] is `true`, text values will be parsed
  /// and replace all encoded character entities with their corresponding
  /// character. [parseCharacterEntities] must not be `null`.
  ///
  /// If [parseComments] is `true`, commments will be scrubbed
  /// from [string] before parsing.
  ///
  /// If [trimWhitespace] is `true`, unnecessary whitespace between nodes
  /// will be removed and all remaining whitespace will be replaced with
  /// a single space. [trimWhitespace] must not be `null`.
  static XmlDoctype fromString(
    String string, {
    bool parseCharacterEntities = true,
    bool parseComments = false,
    bool trimWhitespace = true,
  }) {
    assert(string != null);
    assert(parseCharacterEntities != null);
    assert(parseComments != null);
    assert(trimWhitespace != null);

    return parseString(
      string,
      parseCharacterEntities: parseCharacterEntities,
      parseComments: parseComments,
      trimWhitespace: trimWhitespace,
      stop: 0,
    )?.first;
  }

  /// Returns a list of every XML DocType declaration found in [string].
  /// [string] must not be `null`.
  ///
  /// If [parseCharacterEntities] is `true`, text values will be parsed
  /// and replace all encoded character entities with their corresponding
  /// character. [parseCharacterEntities] must not be `null`.
  ///
  /// If [parseComments] is `true`, commments will be scrubbed
  /// from [string] before parsing.
  ///
  /// If [trimWhitespace] is `true`, unnecessary whitespace between nodes
  /// will be removed and all remaining whitespace will be replaced with
  /// a single space. [trimWhitespace] must not be `null`.
  static List<XmlDoctype> parseString(
    String string, {
    bool parseCharacterEntities = true,
    bool parseComments = false,
    bool trimWhitespace = true,
    int start = 0,
    int stop,
  }) {
    assert(string != null);
    assert(parseCharacterEntities != null);
    assert(parseCharacterEntities != null);
    assert(parseComments != null);
    assert(trimWhitespace != null);

    if (!parseComments) string = helpers.removeComments(string);

    if (trimWhitespace) string = helpers.trimWhitespace(string);

    final List<XmlDoctype> doctypes = List<XmlDoctype>();

    final Iterable<RegExpMatch> tags = _delimiter.allMatches(string);

    if (tags == null || start >= tags.length) return null;

    for (RegExpMatch tag in tags) {
      if (tag.namedGroup('isMarkup') != '!') continue;

      if (tag.namedGroup('doctype') != 'DOCTYPE') continue;

      final RegExpMatch doctype =
          Delimiters.doctype.firstMatch(string.substring(tag.start, tag.end));

      final String element = doctype.namedGroup('name');

      if (element == null) continue;

      // Capture and parse the external DTD values, if thye exist.
      final String identifier = doctype.namedGroup('identifier');

      String externalDtdName;

      String externalDtd = doctype.namedGroup('externalDtd');

      if (externalDtd != null) {
        final List<RegExpMatch> externalDtdParts =
            RegExp('".*?"|\'.?\'').allMatches(externalDtd).toList();

        if (externalDtdParts.length > 1) {
          final RegExpMatch name = externalDtdParts.first;

          externalDtdName = externalDtd.substring(name.start + 1, name.end - 1);

          final RegExpMatch path = externalDtdParts[1];

          externalDtd = externalDtd.substring(path.start + 1, path.start - 1);
        } else {
          externalDtd = helpers.stripDelimiters(externalDtd);
        }
      }

      // Caputre and parse the internal DTD value, if it exists.
      final String internalDtdValue = doctype.namedGroup('internalDtd');

      List<XmlNode> internalDtd;

      if (internalDtdValue != null) {
        internalDtd = XmlNode.parseString(
          internalDtdValue,
          parseCharacterEntities: parseCharacterEntities,
          parseComments: true,
          trimWhitespace: false,
        );
      }

      doctypes.add(
        XmlDoctype(
          element: element,
          isPublic: identifier == 'PUBLIC',
          isSystem: identifier == 'SYSTEM',
          externalDtdName: externalDtdName,
          externalDtdUri: externalDtd,
          internalDtd: internalDtd,
        ),
      );
    }

    if (doctypes.isEmpty) return null;

    return doctypes;
  }

  static final RegExp _delimiter = RecursiveRegex(
    startDelimiter: RegExp(r'<\s*(?<isMarkup>!)?\s*(?<doctype>DOCTYPE)?'),
    endDelimiter: RegExp(r'>'),
  );

  @override
  operator ==(o) {
    // Compare types
    if (!(o is XmlDoctype)) return false;

    // Compare names
    if (element != o.element) return false;

    // Compare external flags.
    if (isSystem != o.isSystem) return false;

    if (isPublic != o.isPublic) return false;

    // Compare external DTD values.
    if (externalDtdName != o.externalDtdName) return false;

    if (externalDtdUri != o.externalDtdUri) return false;

    if (externalDtd == null && o.externalDtd != null) return false;

    if (externalDtd != null && o.externalDtd == null) return false;

    if (externalDtd != null) {
      if (externalDtd.length != o.externalDtd.length) return false;

      for (int i = 0; i < externalDtd.length; i++) {
        if (externalDtd[i] != o.externalDtd[i]) return false;
      }
    }

    // Compare internal DTD values.
    if (internalDtd != null && o.internalDtd == null) return false;

    if (internalDtd == null && o.internalDtd != null) return false;

    if (internalDtd != null) {
      for (int i = 0; i < internalDtd.length; i++) {
        if (internalDtd[i] != o.internalDtd[i]) return false;
      }
    }

    return true;
  }
}
