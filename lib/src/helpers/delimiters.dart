import 'package:recursive_regex/recursive_regex.dart';

/// Regexs for capturing each XML node and their properties.
class Delimiters {
  Delimiters._();

  /// Matches XML ATTLIST Declarations and captures their element name,
  /// attribute name and type, identifier, and default value.
  static RegExp attlist = RegExp(
      r'<\s*!\s*ATTLIST\s*(?<element>\S*)\s*(?<attribute>\S*)\s*(?<type>[^>#]*)\s*(?<identifier>#[^>\s]*)?\s*(?<defaultValue>[^>]*)?\s*>');

  /// Matches node attributes and captures their names and values.
  static final RegExp attribute = RegExp(
      '(?<name>\\S*?)\\s*?=\\s*?(?<value>(?:"(?:.|\\s)*?(?<!\\\\)")|(?:\'(?:.|\\s)*?(?<!\\\\)\'))');

  /// Matches CDATA sections and captures their values.
  static RegExp cdata = RecursiveRegex(
    startDelimiter: RegExp(r'<\s*!\s*\[\s*CDATA\s*\['),
    endDelimiter: RegExp(r']\s*]\s*>'),
    captureGroupName: 'value',
    isDotAll: true,
  );

  /// Matches comments delimited with `<!--` and `-->`
  /// and captures their contents.
  static final RegExp comment = RegExp(r'<!--(?<value>.*?)-->', dotAll: true);

  /// Matches XML Conditional Sections and captures their values.
  static final RecursiveRegex conditional = RecursiveRegex(
    startDelimiter: RegExp(
        r'<!\[\s*(?!(?:c|C)(?:d|D)(?:a|A)(?:t|T)(?:a|A))(?<condition>[^\s[]*)\s*\['),
    endDelimiter: RegExp(r']\s*]\s*>'),
    captureGroupName: 'value',
    isDotAll: true,
  );

  /// Matches XML Declarations and captures their attributes.
  static final RegExp xmlDeclaration = RegExp(r'<\?xml(?<attributes>.*?)\?>');

  /// Matches an XML DocType Declaration and captures its name, external
  /// DTD declaration, name and uri, and any nested DTD elements.
  ///
  /// __Note:__ This delimiter is applied to DocType nodes that have already
  /// been isolated. Using it on strings that contain nested `]>` delimiters
  /// will cause the match to end at the last found delimiter.
  static final RegExp doctype = RegExp(
    '<\\s*!\\s*DOCTYPE\\s*(?<name>[^\\s["]*)\\s*(?<identifier>SYSTEM|PUBLIC)?\\s*(?<externalDtd>(?:(?:".*?"|\'.?\')\\s*){0,2})?\\s*(\\[(?<internalDtd>.*?)])?>',
    dotAll: true,
  );

  /// Matches XML tags and captures their name, attributes,
  /// and empty-tag delimiter, if they have one.
  static final RegExp elementTag = RegExp(
    '<\\s*(?![?!])(?<tagName>[^\\s>="\'/]*)(?<attributes>.*?)(?<isEmpty>\\/?)\\s*?>',
    dotAll: true,
  );

  /// Matches an XML element from its opening tag to its
  /// closing tag and captures its children.
  static RecursiveRegex element(String elementName, {bool global = false}) {
    assert(elementName != null && elementName.isNotEmpty);
    assert(global != null);

    return RecursiveRegex(
      startDelimiter: RegExp('<\\s*$elementName.*?>'),
      endDelimiter: RegExp('<\\s*\\/$elementName\\s*?>'),
      captureGroupName: 'children',
      isDotAll: true,
      global: global,
    );
  }

  /// Matches any XML entity, and captures the parameter flag, name,
  /// identifier, default value, and NDATA values.
  static final RegExp entity = RegExp(
    '<!ENTITY\\s*(?<parameter>%)?\\s*(?<name>[^\\s"\'>]*)\\s*(?<identifier>SYSTEM|PUBLIC)?\\s*(?<value>(?:(?:\\s*?".*?"\\s*?)|(?:\\s*?\'.*?\'\\s*?)){0,2})\\s*(?<ndataFlag>NDATA)?\\s*(?<ndata>.*?)\\s*>',
    dotAll: true,
  );

  /// Matches an XML Element Type Declaration
  /// and captures its name and children.
  static final RegExp etd = RegExp(
    r'<\s*?!\s*?ELEMENT\s*(?<name>\S*)\s*(?<children>.*?)>',
    dotAll: true,
  );

  /// Matches XML Notation Declarations and captures their
  /// name, identifier, public ID, and URI values.
  static final RegExp notation = RegExp(
    '<!NOTATION\\s*(?<name>[^\\s"\'>]*)\\s*(?<identifier>SYSTEM|PUBLIC)?\\s*(?<value1>(?:(?:\\s*?".*?"\\s*?)|(?:\\s*?\'.*?\'\\s*?)))\\s*(?<value2>(?:(?:\\s*?".*?"\\s*?)|(?:\\s*?\'.*?\'\\s*?)))?\\s*>',
    dotAll: true,
  );

  /// Matches XML Processing Instructions and captures
  /// their target and content values.
  static final RegExp processingInstruction = RegExp(
    r'<\?(?!(?:x|X)(?:m|M)(?:l|L))(?<target>\S*)\s*(?<content>.*?)\?>',
  );

  /// Matches and captures all text found between
  /// nodes delimited with `<` and `>`.
  static final RegExp text = RegExp(
    r'>(?!\s*]\s*>)\s*(?<text>.*?)\s*<\s*(?!\s*!\s*\[\s*CDATA)',
    dotAll: true,
  );
}
