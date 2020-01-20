import 'package:meta/meta.dart';
import '../../helpers/delimiters.dart';
import '../../helpers/helpers.dart' as helpers;
import '../../helpers/string_parser.dart';
import '../../xml_node.dart';

/// The identifier for an Xml ATTLIST Declaration
enum XmlAttlistIdentifier {
  /// The Xml ATTLIST `#REQUIRED` delcaration.
  required,
  /// The Xml ATTLIST `#IMPLIED` declaration.
  implied,
  /// The Xml ATTLIST `#FIXED` declaration.
  fixed,
}

/// An Attribute-list Declaration.
///
/// Attribute-list declarations are used to define the set of attributes
/// an element should or may have, and set contstrains on the data type and
/// content of the attribute's values.
///
/// See: https://www.w3.org/TR/xml/#attdecls
@immutable
class XmlAttlist implements XmlNode {
  /// An Attribute-list Declaration.
  ///
  /// Attribute-list declarations are used to define the set of attributes
  /// an element should or may have, and set contstrains on the data type and
  /// content of the attribute's values.
  ///
  /// [element] and [attribute] both must not be `null` or empty.
  ///
  /// [type] and [defaultValue] both must not be empty if they are not `null`.
  ///
  /// [identifier] and [defaultValue] are both optional.
  const XmlAttlist({
    @required this.element,
    @required this.attribute,
    @required this.type,
    this.identifier,
    this.defaultValue,
  })  : assert(element != null && element.length > 0),
        assert(attribute != null && attribute.length > 0),
        assert(type == null || type.length > 0),
        assert(defaultValue == null || defaultValue.length > 0);

  /// The element the attribute applies to.
  final String element;

  /// The name of the attribute.
  final String attribute;

  /// The type of data the attribute accepts.
  final String type;

  /// Whether the attribute's value is required, optional (implied), or fixed.
  final XmlAttlistIdentifier identifier;

  /// The default value of the attribute.
  ///
  /// Only applies to attributes with a `#FIXED` identifier.
  final String defaultValue;

  @override
  String toString([bool doubleQuotes = true]) {
    assert(doubleQuotes != null);

    final type = (this.type != null) ? ' ${this.type}' : '';

    final identifier = (this.identifier != null)
        ? ' #${this.identifier.toString().split('.').last.toUpperCase()}'
        : '';

    final quotationMark = (doubleQuotes) ? '"' : '\'';

    final value = (defaultValue != null)
        ? ' $quotationMark$defaultValue$quotationMark'
        : '';

    return '<!ATTLIST $element $attribute$type$identifier$value>';
  }

  @override
  String toFormattedString({
    int nestingLevel = 0,
    String indent = '\t',
    // TODO: int lineLength = 80,
    bool doubleQuotes = true,
  }) {
    assert(nestingLevel != null && nestingLevel >= 0);
    assert(indent != null);
    // TODO: assert(lineLength == null || lineLength > 0);

    var attlist =
        helpers.formatLine(toString(doubleQuotes), nestingLevel, indent);

    // TODO: Handle lineLength

    return attlist;
  }

  /// Returns the first DTD Attlist Declaration found in [string].
  /// [string] must not be `null`.
  ///
  /// If [trimWhitespace] is `true`, unnecessary whitespace between nodes
  /// will be removed and all remaining whitespace will be replaced with
  /// a single space. [trimWhitespace] must not be `null`.
  ///
  /// Returns `null` if no valid Attlist Declaration was found.
  static XmlAttlist fromString(
    String string, {
    bool trimWhitespace = true,
  }) {
    assert(string != null);
    assert(trimWhitespace != null);

    final parser = StringParser<XmlAttlist>();

    return parser.fromString(
      input: string,
      delimiter: Delimiters.attlist,
      getNode: _getAttlist,
      trimWhitespace: trimWhitespace,
    );
  }

  /// Returns a list of every DTD Attlist Declaration found in [string].
  /// [string] must not be `null`.
  ///
  /// If [trimWhitespace] is `true`, unnecessary whitespace between nodes
  /// will be removed and all remaining whitespace will be replaced with
  /// a single space. [trimWhitespace] must not be `null`.
  ///
  /// [start] and [stop] refer to the indexes of the identified Attlist
  /// Declarations. Only matches found between [start] and [stop] will be
  /// returned. [start] must not be `null` and must be `>= 0`. [stop] may be
  /// `null`, but must be `>= start` if provided.
  ///
  /// Returns `null` if no valid Attlist Declarations were found.
  static List<XmlAttlist> parseString(
    String string, {
    bool trimWhitespace = true,
    int start = 0,
    int stop,
  }) {
    assert(string != null);
    assert(trimWhitespace != null);
    assert(start != null && start >= 0);
    assert(stop == null || stop >= start);

    final parser = StringParser<XmlAttlist>();

    return parser.parseString(
      input: string,
      delimiter: Delimiters.attlist,
      getNode: _getAttlist,
      trimWhitespace: trimWhitespace,
      start: start,
      stop: stop,
    );
  }

  /// Builds a [XmlAttlist] node from a [RegExpMatch] if the captured
  /// values are valid, otherwise returns `null`.
  static XmlAttlist _getAttlist(RegExpMatch attlist) {
    assert(attlist != null);

    final element = attlist.namedGroup('element');

    if (element == null) return null;

    final attribute = attlist.namedGroup('attribute');

    if (attribute == null) return null;

    final type = attlist.namedGroup('type')?.trimRight();

    final identifier = attlist.namedGroup('identifier')?.toUpperCase();

    final defaultValue = attlist.namedGroup('defaultValue')?.trim();

    return XmlAttlist(
      element: element,
      attribute: attribute,
      type: type.isNotEmpty ? type : null,
      identifier: (identifier == '#REQUIRED' || type == '#REQUIRED')
          ? XmlAttlistIdentifier.required
          : (identifier == '#IMPLIED' || type == '#IMPLIED')
              ? XmlAttlistIdentifier.implied
              : (identifier == '#FIXED' || type == '#FIXED')
                  ? XmlAttlistIdentifier.fixed
                  : null,
      defaultValue:
          (defaultValue == null) ? null : helpers.stripDelimiters(defaultValue),
    );
  }

  @override
  bool operator ==(Object o) =>
      o is XmlAttlist &&
      element == o.element &&
      attribute == o.attribute &&
      type == o.type &&
      identifier == o.identifier &&
      defaultValue == o.defaultValue;

  @override
  int get hashCode =>
      element.hashCode ^
      attribute.hashCode ^
      type.hashCode ^
      identifier.hashCode ^
      defaultValue.hashCode;
}
