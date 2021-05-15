import 'package:meta/meta.dart';
import '../helpers/delimiters.dart';
import '../helpers/string_parser.dart';
import '../xml_node.dart';

/// An XML Processing Instruction.
///
/// XML Processing Instructions contain instructions for the
/// application parsing the document.
///
/// See: https://www.w3.org/TR/xml/#sec-pi
@immutable
class XmlProcessingInstruction extends XmlNode {
  /// An XML Processing Instruction.
  ///
  /// XML Processing Instructions contain instructions for the
  /// application parsing the document.
  ///
  /// [target] must not be `null` or empty.
  const XmlProcessingInstruction({
    required this.target,
    this.content,
  }) : assert(target.length > 0);

  /// Refers to the application or document type the
  /// processing instruction refers to.
  final String target;

  /// The optional content of the processing instruction.
  final String? content;

  @override
  String toString() => '<?$target${content != null ? ' $content ' : ''}?>';

  /// Returns the first XML Processing Instruction found in [string].
  /// [string] must not be `null`.
  ///
  /// If [trimWhitespace] is `true`, unnecessary whitespace between nodes
  /// will be removed and all remaining whitespace will be replaced with
  /// a single space. [trimWhitespace] must not be `null`.
  ///
  /// Returns `null` if no XML Processing Instruction was found.
  static XmlProcessingInstruction? from(
    String string, {
    bool trimWhitespace = true,
  }) {
    return StringParser.from<XmlProcessingInstruction>(
      input: string,
      delimiter: Delimiters.processingInstruction,
      getNode: _getProcessingInstruction,
      trimWhitespace: trimWhitespace,
    );
  }

  /// Returns a list of every XmlProcessingInstruction found in [string].
  /// [string] must not be `null`.
  ///
  /// If [trimWhitespace] is `true`, unnecessary whitespace between nodes
  /// will be removed and all remaining whitespace will be replaced with
  /// a single space. [trimWhitespace] must not be `null`.
  ///
  /// [start] and [stop] refer to the indexes of the identified XML Processing
  /// Instruction nodes. Only matches found between [start] and [stop] will be
  /// returned. [start] must not be `null` and must be `>= 0`. [stop] may be
  /// `null`, but must be `>= start` if provided.
  ///
  /// Returns `null` if no XML Processing Instructions were found.
  static List<XmlProcessingInstruction>? parseString(
    String string, {
    bool trimWhitespace = true,
    int start = 0,
    int? stop,
  }) {
    assert(start >= 0);
    assert(stop == null || stop >= start);
    return StringParser.parse<XmlProcessingInstruction>(
      input: string,
      delimiter: Delimiters.processingInstruction,
      getNode: _getProcessingInstruction,
      trimWhitespace: trimWhitespace,
      start: start,
      stop: stop,
    );
  }

  /// Builds a [XmlProcessingInstruction] from a [RegExpMatch] if
  /// the captured values are valid, otherwise returns `null`.
  static XmlProcessingInstruction? _getProcessingInstruction(
      RegExpMatch processingInstruction) {
    final target = processingInstruction.namedGroup('target')?.trim();

    if (target == null || target.isEmpty) return null;

    final content = processingInstruction.namedGroup('content')?.trim();

    return XmlProcessingInstruction(
      target: target,
      content: content,
    );
  }

  @override
  bool operator ==(Object o) =>
      o is XmlProcessingInstruction &&
      target == o.target &&
      content == o.content;

  @override
  int get hashCode => target.hashCode ^ content.hashCode;
}
