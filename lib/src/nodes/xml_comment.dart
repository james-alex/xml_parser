import 'package:html_character_entities/html_character_entities.dart';
import 'package:meta/meta.dart';
import '../helpers/delimiters.dart';
import '../helpers/formatters.dart';
import '../xml_node.dart';

/// A XML comment, delimited with `<!--` and `-->`.
///
/// See: https://www.w3.org/TR/xml/#sec-comments
@immutable
class XmlComment extends XmlNode {
  /// A XML comment, delimited with `<!--` and `-->`.
  ///
  /// [value] must not be `null`.
  const XmlComment(this.value);

  /// The contents of the comment.
  final String value;

  @override
  String toString() => '<!--$value-->';

  /// Parses a string for a XML comment.
  ///
  /// If [trimWhitespace] is `true`, unnecessary whitespace between nodes
  /// will be removed and all remaining whitespace will be replaced with
  /// a single space. [trimWhitespace] must not be `null`.
  ///
  /// Returns `null` if no comments are found.
  static XmlComment? from(
    String string, {
    bool trimWhitespace = true,
  }) {
    if (trimWhitespace) string = string.trimWhitespace();
    final comment = Delimiters.comment.firstMatch(string);
    if (comment == null) return null;
    return XmlComment(comment.namedGroup('value')!);
  }

  /// Parses a string and returns all found XML comments in a list.
  ///
  /// Returns `null` if no comments were found.
  static List<XmlComment>? parseString(
    String string, {
    bool parseCharacterEntities = true,
    bool trimWhitespace = true,
    int start = 0,
    int? stop,
  }) {
    assert(start >= 0);
    assert(stop == null || stop >= start);

    if (trimWhitespace) string = string.trimWhitespace();

    final matches = Delimiters.comment.allMatches(string).toList();
    if (matches.isEmpty) return null;

    final comments = <XmlComment>[];

    for (var i = start; i < matches.length; i++) {
      var comment = matches[i].namedGroup('value')!;
      if (parseCharacterEntities) {
        comment = HtmlCharacterEntities.decode(comment);
      }
      comments.add(XmlComment(comment));
      if (stop != null && i > stop) break;
    }

    return comments;
  }

  @override
  bool operator ==(Object o) => o is XmlComment && value == o.value;

  @override
  int get hashCode => toString().hashCode;
}
