import 'package:html_character_entities/html_character_entities.dart';
import '../helpers/delimiters.dart';
import '../helpers/helpers.dart' as helpers;
import '../xml_node.dart';

/// A XML comment, delimited with `<!--` and `-->`.
///
/// See: https://www.w3.org/TR/xml/#sec-comments
class XmlComment implements XmlNode {
  /// A XML comment, delimited with `<!--` and `-->`.
  ///
  /// [value] must not be `null`.
  const XmlComment(this.value) : assert(value != null);

  /// The contents of the comment.
  final String value;

  @override
  String toString() => '<!--$value-->';

  @override
  String toFormattedString({
    int nestingLevel = 0,
    String indent = '\t',
    // TODO: int lineLength = 80,
  }) {
    assert(nestingLevel != null && nestingLevel >= 0);
    assert(indent != null);
    // TODO: assert(lineLength == null || lineLength > 0);

    String comment = helpers.formatLine(toString(), nestingLevel, indent);

    // TODO: Handle lineLength

    return comment;
  }

  /// Parses a string for a XML comment.
  ///
  /// If [trimWhitespace] is `true`, unnecessary whitespace between nodes
  /// will be removed and all remaining whitespace will be replaced with
  /// a single space. [trimWhitespace] must not be `null`.
  static XmlComment fromString(
    String string, {
    bool trimWhitespace = true,
  }) {
    assert(string != null);
    assert(trimWhitespace != null);

    if (trimWhitespace) string = helpers.trimWhitespace(string);

    final RegExpMatch comment = Delimiters.comment.firstMatch(string);

    if (comment == null) return null;

    return XmlComment(
        Delimiters.comment.firstMatch(string).namedGroup('value'));
  }

  /// Parses a string and returns all found XML comments in a list.
  ///
  /// Returns `null` if no comments were found.
  static List<XmlComment> parseString(
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

    if (trimWhitespace) string = helpers.trimWhitespace(string);

    final List<RegExpMatch> matches =
        Delimiters.comment.allMatches(string).toList();

    if (matches.isEmpty) return null;

    final List<XmlComment> comments = List<XmlComment>();

    for (int i = start; i < matches.length; i++) {
      String comment = matches[i].namedGroup('value');

      if (parseCharacterEntities) {
        comment = HtmlCharacterEntities.decode(comment);
      }

      comments.add(XmlComment(comment));

      if (stop != null && i > stop) break;
    }

    return comments;
  }

  @override
  operator ==(o) => o is XmlComment && value == o.value;

  @override
  int get hashCode => toString().hashCode;
}
