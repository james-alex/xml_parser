import 'package:html_character_entities/html_character_entities.dart';
import 'package:meta/meta.dart';
import '../helpers/delimiters.dart';
import '../helpers/helpers.dart' as helpers;
import '../xml_node.dart';

/// A plain text value.
///
/// This node is should be nested within an element,
/// but the parser doesn't require it.
@immutable
class XmlText implements XmlNode {
  /// A plain text value.
  ///
  /// This node is should be nested within an element,
  /// but the parser doesn't require it.
  ///
  /// If [isMarkup] is `true`, character entities contained
  /// within [value] will never be parsed and characters marked
  /// for encoding by the [toString] and [toFormattedString] methods
  /// will be ignored.
  ///
  /// Neither [value] or [isMarkup] may be `null`.
  const XmlText(this.value, {this.isMarkup = false})
      : assert(value != null),
        assert(isMarkup != null);

  /// Plain text value.
  final String value;

  /// Flagged `true` if this node was created as the
  /// result of markup that couldn't be parsed.
  ///
  /// Setting this to `true` prevents this node's
  /// value from being character encoded.
  final bool isMarkup;

  /// Returns this nodes plain text value.
  ///
  /// If [parseCharacterEntities] is `true`, the characters found
  /// in [characters] will be parsed for and encoded with their
  /// respective character entities.
  ///
  /// [characters] defaults to less-than (`<`), greater-than (`>`),
  /// and ampersand (`&`), the only 3 characters reserved in XML
  /// PCDATA values.
  ///
  /// If [characters] is `null` every character with a corresponding
  /// HTML 4.01 character code will be encoded.
  @override
  String toString({
    bool encodeCharacterEntities = true,
    String encodeCharacters = '&<>',
  }) {
    assert(encodeCharacterEntities != null);

    if (!isMarkup && encodeCharacterEntities) {
      return HtmlCharacterEntities.encode(value, characters: encodeCharacters);
    }

    return value;
  }

  @override
  String toFormattedString({
    int nestingLevel = 0,
    String indent = '\t',
    // TODO: int lineLength = 80,
    bool encodeCharacterEntities = true,
    String encodeCharacters = '&<>',
  }) {
    assert(nestingLevel != null && nestingLevel >= 0);
    assert(indent != null);
    // TODO: assert(lineLength == null || lineLength > 0);
    assert(encodeCharacterEntities != null);

    final value = toString(
      encodeCharacterEntities: encodeCharacterEntities,
      encodeCharacters: encodeCharacters,
    );

    var text = helpers.formatLine(value, nestingLevel, indent);

    // TODO: Handle lineLength

    return text;
  }

  /// Returns [string] as an XML text node.
  ///
  /// If [parseCharacterEntities] is `true`, text values will be parsed
  /// and replace all encoded character entities with their corresponding
  /// character. [parseCharacterEntities] must not be `null`.
  ///
  /// If [isMarkup] is `true`, the returned [XmlText] node will not be
  /// character encoded by this method, or the [toString] method, even
  /// if [parseCharacterEntities] is `true`. [isMarkup] must not be `null`.
  ///
  /// If [trimWhitespace] is `true`, unnecessary whitespace between nodes
  /// will be removed and all remaining whitespace will be replaced with
  /// a single space. [trimWhitespace] must not be `null`.
  static XmlText fromString(
    String string, {
    bool parseCharacterEntities = true,
    bool isMarkup = false,
    bool trimWhitespace = true,
  }) {
    assert(string != null);
    assert(parseCharacterEntities != null);
    assert(isMarkup != null);
    assert(trimWhitespace != null);

    string = helpers.removeComments(string);

    if (trimWhitespace) string = helpers.trimWhitespace(string);

    if (!isMarkup && parseCharacterEntities) {
      string = HtmlCharacterEntities.decode(string);
    }

    return XmlText(string, isMarkup: isMarkup);
  }

  /// Returns a list of every root level XML text node found in [string].
  /// [string] must not be `null`.
  ///
  /// If [parseCharacterEntities] is `true`, text values will be parsed
  /// and replace all encoded character entities with their corresponding
  /// character. [parseCharacterEntities] must not be `null`.
  ///
  /// If [trimWhitespace] is `true`, unnecessary whitespace between nodes
  /// will be removed and all remaining whitespace will be replaced with
  /// a single space. [trimWhitespace] must not be `null`.
  ///
  /// [start] and [stop] refer to the indexes of the identified text nodes.
  /// Only matches found between [start] and [stop] will be returned.
  /// [start] must not be `null` and must be `>= 0`. [stop] may be `null`,
  /// but must be `>= start` if provided.
  ///
  /// Returns `null` if no text nodes are found.
  static List<XmlText> parseString(
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

    if (!string.contains(RegExp(r'<.*>', dotAll: true))) {
      return <XmlText>[XmlText(string)];
    }

    final text = <XmlText>[];

    var textCount = 0;

    // Capture any text found before the first node.
    final firstNode = string.indexOf('<');

    if (firstNode >= 0) {
      var prependedText = string.substring(0, firstNode).trim();

      if (prependedText.isNotEmpty) {
        if (parseCharacterEntities) {
          prependedText = HtmlCharacterEntities.decode(prependedText);
        }

        if (start == 0) text.add(XmlText(prependedText));

        textCount++;

        if (stop != null && textCount > stop) {
          if (text.isEmpty) {
            return null;
          } else {
            return text;
          }
        }
      }
    }

    // Capture any text found in/between nodes.
    final matches = Delimiters.text.allMatches(string);

    for (var match in matches) {
      var matchedText = match.namedGroup('text');

      if (matchedText.isEmpty) continue;

      if (textCount >= start) {
        if (parseCharacterEntities) {
          matchedText = HtmlCharacterEntities.decode(matchedText);
        }

        text.add(XmlText(matchedText));
      }

      textCount++;

      if (stop != null && stop >= textCount) break;
    }

    // Capture any text found after the last node.
    if (stop == null || textCount < stop) {
      final lastNode = string.lastIndexOf('>');

      if (lastNode >= 0) {
        var appendedText = string.substring(lastNode + 1).trim();

        if (appendedText.isNotEmpty) {
          if (parseCharacterEntities) {
            appendedText = HtmlCharacterEntities.decode(appendedText);
          }

          text.add(XmlText(appendedText));
        }
      }
    }

    if (text.isEmpty) return null;

    return text;
  }

  @override
  bool operator ==(Object o) => o is XmlText && value == o.value;

  @override
  int get hashCode => toString().hashCode;
}
