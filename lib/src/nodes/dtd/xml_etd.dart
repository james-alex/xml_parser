import 'package:meta/meta.dart';
import '../../helpers/delimiters.dart';
import '../../helpers/formatters.dart' as helpers;
import '../../helpers/string_parser.dart';
import '../../xml_node.dart';

/// An Element Type Declaration.
///
/// See: https://www.w3.org/TR/xml/#elemdecls
@immutable
class XmlEtd extends XmlNode {
  /// An Element Type Declaration.
  ///
  /// [name] must not be `null` and must be `> 0` in length.
  ///
  /// [children] should contain the raw (unparsed) content of
  /// the ETD. [children] must not be `null`.
  const XmlEtd(this.name, this.children) : assert(name.length > 0);

  /// The name of the element this ETD pertains to.
  final String name;

  /// The raw and unparsed text value of the ETD.
  final String children;

  @override
  String toString() => '<!ELEMENT $name $children>';

  @override
  String toFormattedString({
    int nestingLevel = 0,
    String indent = '\t',
  }) {
    assert(nestingLevel >= 0);
    return toString().formatLine(nestingLevel, indent);
  }

  /// Returns the first DTD Element Type Declaration found in [string].
  /// [string] must not be `null`.
  ///
  /// If [trimWhitespace] is `true`, unnecessary whitespace between nodes
  /// will be removed and all remaining whitespace will be replaced with
  /// a single space. [trimWhitespace] must not be `null`.
  ///
  /// Returns `null` if no valid ETD was found.
  static XmlEtd? from(
    String string, {
    bool trimWhitespace = false,
  }) {
    return StringParser.from<XmlEtd>(
      input: string,
      delimiter: Delimiters.etd,
      getNode: _getEtd,
      trimWhitespace: trimWhitespace,
    );
  }

  /// Returns a list of every DTD Element Type Declaration found in [string].
  /// [string] must not be `null`.
  ///
  /// If [trimWhitespace] is `true`, unnecessary whitespace between nodes
  /// will be removed and all remaining whitespace will be replaced with
  /// a single space. [trimWhitespace] must not be `null`.
  ///
  /// [start] and [stop] refer to the indexes of the identified Element Type
  /// Declarations. Only matches found between [start] and [stop] will be
  /// returned. [start] must not be `null` and must be `>= 0`. [stop] may be
  /// `null`, but must be `>= start` if provided.
  ///
  /// Returns `null` if no valid ETDs were found.
  static List<XmlEtd>? parseString(
    String string, {
    bool trimWhitespace = true,
    int start = 0,
    int? stop,
  }) {
    assert(start >= 0);
    assert(stop == null || stop >= start);
    return StringParser.parse<XmlEtd>(
      input: string,
      delimiter: Delimiters.etd,
      getNode: _getEtd,
      trimWhitespace: trimWhitespace,
      start: start,
      stop: stop,
    );
  }

  /// Builds a [XmlEtd] from a [RegExpMatch] if the captured
  /// values are valid, otherwise returns `null`.
  static XmlEtd? _getEtd(RegExpMatch etd) {
    final name = etd.namedGroup('name');
    if (name == null) return null;
    final children = etd.namedGroup('children')?.trim();
    if (children == null || children.isEmpty) return null;
    return XmlEtd(name, children);
  }

  @override
  bool operator ==(Object o) =>
      o is XmlEtd && name == o.name && children == o.children;

  @override
  int get hashCode => name.hashCode ^ children.hashCode;
}
