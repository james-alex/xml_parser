import 'package:meta/meta.dart';
import '../helpers/delimiters.dart';
import '../helpers/helpers.dart' as helpers;
import '../helpers/node_with_children.dart';
import '../xml_node.dart';

/// An XML Conditional Section.
///
/// See: https://www.w3.org/TR/xml/#sec-condition-sect
class XmlConditional extends NodeWithChildren implements XmlNode {
  /// An XML Conditional Section.
  ///
  /// [condition] should equal `INCLUDE`, `IGNORE`, or a reference
  /// to an [XmlEntity]. It must not be `null` or empty.
  ///
  /// [children] must not be `null`.
  const XmlConditional({
    @required this.condition,
    @required this.children,
  })  : assert(condition != null && condition.length > 0),
        assert(children != null);

  /// The condition, it should equal `INCLUDE`, `IGNORE`,
  /// or a reference to an [XmlEntity].
  final String condition;

  /// The node(s) contained within this conditional section.
  @override
  final List<XmlNode> children;

  /// Attempts to load all external DTD references contained within
  /// any nested [XmlDoctype]s and [XmlEntity]s, load the pages
  /// they reference, and parse the DTD elements contained within.
  Future<void> loadExternalDtd() async {
    if (children == null || children.isEmpty) return;

    for (int i = 0; i < children.length; i++) {
      final XmlNode child = children[i];

      if (child is XmlConditional) {
        await child.loadExternalDtd();
      } else if (child is XmlDoctype) {
        children[i] = await child.loadExternalDtd();
      } else if (child is XmlElement) {
        await child.loadExternalDtd();
      } else if (child is XmlEntity) {
        children[i] = await child.loadExternalEntities();
      }
    }

    return;
  }

  /// Returns this conditional section as an unformatted XML string.
  ///
  /// If [doubleQuotes] is `true`, double-quotes will be used to wrap
  /// all attribute values, otherwise single-quotes will be used.
  ///
  /// If [encodeCharacterEntities] is `true`, text and attribute values
  /// will be parsed and have the characters included in [encodeCharacters]
  /// encoded as character entities.
  ///
  /// If [encodeCharacters] is `null`, attribute values will be parsed
  /// for less-than (`<`), greater-than (`>`), ampersand (`&`), apostrophe
  /// or single quote (`'`) and double-quote (`"`). And, [XmlText] nodes will
  /// be encoded for less-than (`<`), greater-than (`>`), and ampersand (`&`).
  @override
  String toString({
    bool encodeCharacterEntities = true,
    String encodeCharacters,
    bool doubleQuotes = true,
  }) {
    assert(encodeCharacterEntities != null);
    assert(doubleQuotes != null);

    final String children = helpers.childrenToString(
      children: this.children,
      encodeCharacterEntities: encodeCharacterEntities,
      encodeCharacters: encodeCharacters,
      doubleQuotes: doubleQuotes,
    );

    return '<![ $condition [$children]]>';
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

    String conditional =
        helpers.formatLine('<![ $condition [', nestingLevel, indent);

    conditional += helpers.formatChildren(
      children: children,
      nestingLevel: nestingLevel,
      indent: indent,
      encodeCharacterEntities: encodeCharacterEntities,
      encodeCharacters: encodeCharacters,
      doubleQuotes: doubleQuotes,
    );

    conditional += helpers.formatLine(']]>', nestingLevel, indent);

    // TODO: Handle lineLength

    return conditional;
  }

  /// Returns an [XmlConditional] with the condition set to `INCLUDE`.
  static XmlConditional include(List<XmlNode> children) {
    assert(children != null);

    return XmlConditional(
      condition: 'INCLUDE',
      children: children,
    );
  }

  /// Returns an [XmlConditional] with the condition set to `IGNORE`.
  static XmlConditional ignore(List<XmlNode> children) {
    assert(children != null);

    return XmlConditional(
      condition: 'IGNORE',
      children: children,
    );
  }

  /// Returns the first XML conditional section found in [string].
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
  static XmlConditional fromString(
    String string, {
    bool parseCharacterEntities = true,
    bool parseComments = false,
    bool trimWhitespace = true,
    bool parseCdataAsText = true,
  }) {
    assert(string != null);
    assert(parseCharacterEntities != null);
    assert(parseComments != null);
    assert(trimWhitespace != null);
    assert(parseCdataAsText != null);

    return parseString(
      string,
      parseCharacterEntities: parseCharacterEntities,
      parseComments: parseComments,
      trimWhitespace: trimWhitespace,
      parseCdataAsText: parseCdataAsText,
      stop: 0,
    )?.first;
  }

  /// Returns a list of all XML conditional sections found in [string].
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
  ///
  /// If [global] is `true`, all conditional sections will be returned
  /// regardless of whether they're nested within other conditional
  /// sections. If `false`, only the root level conditional sections
  /// will be returned.
  ///
  /// [start] and [stop] refer to the indexes of the identified conditional
  /// sections. Only matches found between [start] and [stop] will be returned.
  /// [start] must not be `null` and must be `>= 0`. [stop] may be `null`,
  /// but must be `>= start` if provided.
  ///
  /// Returns `null` if no conditional sections were found.
  static List<XmlConditional> parseString(
    String string, {
    bool parseCharacterEntities = true,
    bool parseComments = false,
    bool trimWhitespace = true,
    bool parseCdataAsText = true,
    bool global = false,
    int start = 0,
    int stop,
  }) {
    assert(string != null);
    assert(parseCharacterEntities != null);
    assert(parseComments != null);
    assert(parseCdataAsText != null);
    assert(trimWhitespace != null);
    assert(global != null);
    assert(start != null && start >= 0);
    assert(stop == null || stop >= start);

    if (!parseComments) string = helpers.removeComments(string);

    if (trimWhitespace) string = helpers.trimWhitespace(string);

    final List<RegExpMatch> matches =
        Delimiters.conditional.copyWith(global: global).allMatches(string);

    if (start >= matches.length) return null;

    final List<XmlConditional> conditionals = List<XmlConditional>();

    for (int i = start; i < matches.length; i++) {
      final RegExpMatch match = matches[i];

      final String condition = match.namedGroup('condition');

      final String value = match.namedGroup('value')?.trim();

      conditionals.add(
        XmlConditional(
          condition: condition,
          children: XmlNode.parseString(
            value,
            parseCharacterEntities: parseCharacterEntities,
            parseComments: true,
            trimWhitespace: false,
            parseCdataAsText: true,
          ),
        ),
      );

      if (stop != null && i > stop) break;
    }

    if (conditionals.isEmpty) return null;

    return conditionals;
  }

  @override
  operator ==(o) {
    // Compare types
    if (o.runtimeType != XmlConditional) return false;

    // Compare conditions
    if (condition != o.condition) return false;

    // Compare children
    if (children == null && o.children != null) return false;

    if (children != null && o.children == null) return false;

    if (children != null) {
      if (children.length != o.children.length) return false;

      for (int i = 0; i < children.length; i++) {
        if (children[i] != o.children[i]) return false;
      }
    }

    return true;
  }

  @override
  int get hashCode => condition.hashCode ^ children.hashCode;
}
