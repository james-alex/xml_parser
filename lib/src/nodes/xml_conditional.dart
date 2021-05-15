import 'package:collection/collection.dart';
import 'package:meta/meta.dart';
import '../helpers/delimiters.dart';
import '../helpers/formatters.dart';
import '../xml_node.dart';

/// An XML Conditional Section.
///
/// See: https://www.w3.org/TR/xml/#sec-condition-sect
@immutable
class XmlConditional extends XmlNodeWithChildren {
  /// An XML Conditional Section.
  ///
  /// [condition] should equal `INCLUDE`, `IGNORE`, or a reference
  /// to an [XmlEntity]. It must not be `null` or empty.
  ///
  /// [children] must not be `null`.
  const XmlConditional({
    required this.condition,
    required this.children,
  }) : assert(condition.length > 0);

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
    if (children.isEmpty) return;

    for (var i = 0; i < children.length; i++) {
      final child = children[i];

      if (child is XmlConditional) {
        await child.loadExternalDtd();
      } else if (child is XmlDoctype) {
        final externalDtd = await child.loadExternalDtd();
        if (externalDtd != null) children[i] = externalDtd;
      } else if (child is XmlElement) {
        await child.loadExternalDtd();
      } else if (child is XmlEntity) {
        final externalEntities = await child.loadExternalEntities();
        if (externalEntities != null) children[i] = externalEntities;
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
    String? encodeCharacters,
    bool doubleQuotes = true,
  }) {
    final children = this.children.write(
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
    bool encodeCharacterEntities = true,
    String? encodeCharacters,
    bool doubleQuotes = true,
  }) {
    assert(nestingLevel >= 0);

    var conditional = '<![ $condition ['.formatLine(nestingLevel, indent);

    conditional += children.format(
      nestingLevel: nestingLevel,
      indent: indent,
      encodeCharacterEntities: encodeCharacterEntities,
      encodeCharacters: encodeCharacters,
      doubleQuotes: doubleQuotes,
    );

    conditional += ']]>'.formatLine(nestingLevel, indent);

    return conditional;
  }

  /// Returns an [XmlConditional] with the condition set to `INCLUDE`.
  static XmlConditional include(List<XmlNode> children) {
    return XmlConditional(
      condition: 'INCLUDE',
      children: children,
    );
  }

  /// Returns an [XmlConditional] with the condition set to `IGNORE`.
  static XmlConditional ignore(List<XmlNode> children) {
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
  ///
  /// If [parseCdataAsText] is `true`, all CDATA sections will be
  /// returned as [XmlText] nodes. [parseCdataAsText] must not be `null`.
  static XmlConditional? from(
    String string, {
    bool parseCharacterEntities = true,
    bool parseComments = false,
    bool trimWhitespace = true,
    bool parseCdataAsText = true,
  }) {
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
  /// If [parseCdataAsText] is `true`, all CDATA sections will be
  /// returned as [XmlText] nodes. [parseCdataAsText] must not be `null`.
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
  static List<XmlConditional>? parseString(
    String string, {
    bool parseCharacterEntities = true,
    bool parseComments = false,
    bool trimWhitespace = true,
    bool parseCdataAsText = true,
    bool global = false,
    int start = 0,
    int? stop,
  }) {
    assert(start >= 0);
    assert(stop == null || stop >= start);

    if (!parseComments) string = string.removeComments();
    if (trimWhitespace) string = string.trimWhitespace();

    final matches =
        Delimiters.conditional.copyWith(global: global).allMatches(string);
    if (start >= matches.length) return null;

    final conditionals = <XmlConditional>[];

    for (var i = start; i < matches.length; i++) {
      final match = matches[i];
      final condition = match.namedGroup('condition');
      if (condition == null) continue;
      final value = match.namedGroup('value')?.trim();
      if (value == null) continue;

      conditionals.add(
        XmlConditional(
          condition: condition,
          children: XmlNode.parseString(
            value,
            parseCharacterEntities: parseCharacterEntities,
            parseComments: true,
            trimWhitespace: false,
            parseCdataAsText: true,
          )!,
        ),
      );

      if (stop != null && i > stop) break;
    }

    if (conditionals.isEmpty) return null;

    return conditionals;
  }

  @override
  bool operator ==(Object o) =>
      o is XmlConditional &&
      condition == o.condition &&
      children.equals(o.children);

  @override
  int get hashCode => condition.hashCode ^ children.hashCode;
}
