import 'formatters.dart';

/// GetNode functions should accept a [RegExpMatch] and return an [XmlNode].
typedef GetNode<T> = T? Function(RegExpMatch node);

/// A class containing [fromString] and [parseString] methods to be
/// used by [XmlNode]s that follow the same pattern for parsing.
class StringParser {
  StringParser._();

  /// Returns the first node of type [T] found
  /// in [input] matched by [delimiter].
  static T? from<T>({
    required String input,
    required RegExp delimiter,
    required GetNode<T> getNode,
    bool parseComments = false,
    required bool trimWhitespace,
  }) {
    if (!parseComments) input = input.removeComments();
    if (trimWhitespace) input = input.trimWhitespace();
    final node = delimiter.firstMatch(input);
    if (node == null) return null;
    return getNode(node);
  }

  /// Returns a list of nodes of type [T] found in [input]
  /// that can be matched by [delimiter].
  static List<T>? parse<T>({
    required String input,
    required RegExp delimiter,
    required GetNode getNode,
    bool parseComments = false,
    required bool trimWhitespace,
    required int start,
    required int? stop,
  }) {
    assert(start >= 0);
    assert(stop == null || stop >= start);

    if (!parseComments) input = input.removeComments();
    if (trimWhitespace) input = input.trimWhitespace();

    final matches = delimiter.allMatches(input);
    if (matches.isEmpty || start >= matches.length) return null;

    final nodes = <T>[];
    var nodeCount = 0;

    for (var match in matches) {
      final T node = getNode(match);
      if (nodeCount >= start) nodes.add(node);
      nodeCount++;
      if (stop != null && nodeCount > stop) break;
    }

    if (nodes.isEmpty) return null;

    return nodes;
  }
}
