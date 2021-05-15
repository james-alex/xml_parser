import 'package:meta/meta.dart';
import '../helpers/delimiters.dart';
import '../helpers/string_parser.dart';
import '../xml_node.dart';

/// A CDATA Section.
///
/// CDATA sections are used to escape blocks of text which contain
/// characters that would otherwise be recognized as markup.
///
/// See: https://www.w3.org/TR/xml/#sec-cdata-sect
@immutable
class XmlCdata extends XmlNode {
  /// A CDATA Section.
  ///
  /// CDATA sections are used to escape blocks of text which contain
  /// characters that would otherwise be recognized as markup.
  ///
  /// [value] must not be `null`.
  const XmlCdata(this.value);

  /// Plain text value.
  final String value;

  @override
  String toString() => '<![CDATA[$value]]>';

  /// Returns [string] as an CDATA node. [string] must not be `null`.
  ///
  /// If [trimWhitespace] is `true`, unnecessary whitespace between nodes
  /// will be removed and all remaining whitespace will be replaced with
  /// a single space. [trimWhitespace] must not be `null`.
  ///
  /// Returns `null` if no CDATA sections are found.
  static XmlCdata? from(
    String string, {
    bool trimWhitespace = true,
  }) {
    return StringParser.from<XmlCdata>(
      input: string,
      delimiter: Delimiters.cdata,
      getNode: _getCdata,
      trimWhitespace: trimWhitespace,
    );
  }

  /// Returns every CDATA section found in [string] in a list.
  /// [string] must not be `null`.
  ///
  /// If [trimWhitespace] is `true`, unnecessary whitespace between nodes
  /// will be removed and all remaining whitespace will be replaced with
  /// a single space. [trimWhitespace] must not be `null`.
  ///
  /// [start] and [stop] refer to the indexes of the CDATA sections.
  /// Only matches found between [start] and [stop] will be returned.
  /// [start] must not be `null` and must be `>= 0`. [stop] may be `null`,
  /// but must be `>= start` if provided.
  ///
  /// Returns `null` if no CDATA sections are found.
  static List<XmlCdata>? parseString(
    String string, {
    bool trimWhitespace = true,
    int start = 0,
    int? stop,
  }) {
    assert(start >= 0);
    assert(stop == null || stop >= start);
    return StringParser.parse<XmlCdata>(
      input: string,
      delimiter: Delimiters.cdata,
      getNode: _getCdata,
      trimWhitespace: trimWhitespace,
      start: start,
      stop: stop,
    );
  }

  /// Builds a [XmlCdata] node from a [RegExpMatch] if the value was
  /// properly captured, otherwise returns `null`.
  static XmlCdata? _getCdata(RegExpMatch cdata) {
    final value = cdata.namedGroup('value')?.trim();
    if (value == null) return null;
    return XmlCdata(value);
  }

  @override
  bool operator ==(Object o) => o is XmlCdata && value == o.value;

  @override
  int get hashCode => toString().hashCode;
}
