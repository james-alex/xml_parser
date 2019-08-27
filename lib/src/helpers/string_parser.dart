import 'package:meta/meta.dart';
import './helpers.dart' as helpers;

/// GetNode functions should accept a [RegExpMatch] and return an [XmlNode].
///
/// Because Dart doesn't allow the return type [T] to be set
/// for typedefs, the return type is left as [dynamic].
typedef GetNode(RegExpMatch node);

/// A class containing [fromString] and [parseString] methods to be
/// used by [XmlNode]s that follow the same pattern for parsing.
class StringParser<T> {
  /// Returns the first node of type [T] found
  /// in [input] matched by [delimiter].
  T fromString({
    @required String input,
    @required RegExp delimiter,
    @required GetNode getNode,
    bool parseComments = false,
    @required bool trimWhitespace,
  }) {
    assert(input != null);
    assert(parseComments != null);
    assert(trimWhitespace != null);

    if (!parseComments) input = helpers.removeComments(input);

    if (trimWhitespace) input = helpers.trimWhitespace(input);

    final RegExpMatch node = delimiter.firstMatch(input);

    if (node == null) return null;

    return getNode(node);
  }

  /// Returns a list of nodes of type [T] found in [input]
  /// that can be matched by [delimiter].
  List<T> parseString({
    @required String input,
    @required RegExp delimiter,
    @required GetNode getNode,
    bool parseComments = false,
    @required bool trimWhitespace,
    @required int start,
    @required int stop,
  }) {
    assert(input != null);
    assert(delimiter != null);
    assert(getNode != null);
    assert(parseComments != null);
    assert(trimWhitespace != null);
    assert(start != null && start >= 0);
    assert(stop == null || stop >= start);

    if (!parseComments) input = helpers.removeComments(input);

    if (trimWhitespace) input = helpers.trimWhitespace(input);

    final Iterable<RegExpMatch> matches = delimiter.allMatches(input);

    if (matches.isEmpty || start >= matches.length) return null;

    final List<T> nodes = List<T>();

    int nodeCount = 0;

    for (RegExpMatch match in matches) {
      final T node = getNode(match);

      if (match == null) continue;

      if (nodeCount >= start) nodes.add(node);

      nodeCount++;

      if (stop != null && nodeCount > stop) break;
    }

    if (nodes.isEmpty) return null;

    return nodes;
  }
}