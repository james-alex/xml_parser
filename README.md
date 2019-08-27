# xml_parser

An unopinionated XML parser that can read, traverse, and write XML documents.

__Documentation (API Reference):__
https://pub.dev/documentation/xml_parser/latest/

# Usage

```dart
import 'package:xml_parser/xml_parser.dart';
```

# Parsing

## Documents

XML documents can be parsed from a string with the [XmlDocument.fromString]
method, or from a URI with the [XmlDocument.fromUri] method.

```dart
String xmlString = '''
<?xml version="1.0" encoding="UTF-8" standalone="yes" ?>
<!DOCTYPE root SYSTEM "rootDtd" "dtd/root.dtd">
<root>
    <element>Child 1</element>
    <element>Child 2</element>
    <element>Child 3</element>
</root>
''';

XmlDocument xmlDocument = XmlDocument.fromString(xmlString);

print(xmlDocument.xmlDeclaration.version); // 1.0
print(xmlDocument.xmlDeclaration.encoding); // UTF-8
print(xmlDocument.xmlDeclaration.standalone); // true

print(xmlDocument.doctype.element); // root
print(xmlDocument.doctype.externalDtdUri); // dtd/root.dtd

print(xmlDocument.root.children.length); // 3
```

```dart
// Parse this package's pub.dev page as a XML document.
XmlDocument xmlDocument = await
    XmlDocument.fromUri('http://pub.dev/packages/xml_parser');

// Get the first `h2` element with a class of `title`.
XmlElement title = xmlDocument
    .getElementWhere(
       XmlElement(
        name: 'h2',
        attributes: [XmlAttribute('class', 'title')],
      ),
    );

print(title.text); // xml_parser 0.1.0
```

__Note:__ HTML documents, as long as their empty tags are self-closing,
can be parsed as XML. See the example for a more in-depth look at parsing
this page.

## Extracting Nodes

For many use cases there isn't a need to parse the entire XML document. In
cases where you know the structure of the document and where the data you
need to retrieve can be found you can extract just the nodes you need without
parsing any more of the document than necessary.

Each XML node class has the static methods [fromString] and [parseString].
[fromString] will parse the inputted string and return the first node
found of its type, while [parseString] will return a list of every node
of that type found. These are methods are explained in more detail for
each of their respective nodes below.

The base [XmlNode] class also has the [fromString] and [parseString]
static methods with an option, [returnNodesOfType], for retrieving nodes
of multiple types.

```dart
/// Returns all XML declarations, DOCTYPE declarations, and elements
/// found within [xmlString], ignoring all other node types.
///
/// Only the highest level nodes will be returned. If any of the returned
/// nodes have children, all children will be parsed regardless of type.
List<XmlNode> nodes = XmlNode.parseString(
  xmlString,
  returnNodesOfType: <Type>[XmlDeclaration, XmlDoctype, XmlElement],
);
```

# Navigating Documents

[XmlDocument]s and every type of node that can have children store their
children in lists of [XmlNode]s.

Because XML nodes have varying properties, the only [toString] and
[toFormattedString] methods are available every node (more on those at
the bottom.) As such, all other getters and methods are specific to
each node.

To access the properties of a node, test its type with the `is` operator:

```dart
String xmlString = '''
<?xml version="1.0" encoding="UTF-8" standalone="yes" ?>
<!DOCTYPE root SYSTEM "rootDtd" "dtd/root.dtd">
<root>
    <element>Child 1</element>
    <element>Child 2</element>
    <element>Child 3</element>
</root>
''';

XmlDocument document = XmlDocument.fromString(xmlString);

for (XmlNode child in document.children) {
  if (child is XmlDeclaration) {
    print(child.version); // 1.0
  } else if (child is XmlDoctype) {
    print(child.externalDtdName); // rootDtd
  } else if (child is XmlElement) {
    print(child.name); // root
  }
}
```

For convenience, all nodes that have a [children] property ([XmlDocument],
[XmlElement], and [XmlConditional]), have the following getters and methods
for retrieving nested [XmlElement]s.

__Note:__ Check the API reference for more detailed information regarding
each method's parameters.

```dart
/// Returns the first [XmlElement] found in [children].
XmlElement get firstChild;

/// Returns the nth [XmlElement] found in [children].
XmlElement nthChild(int index);

/// Returns the last [XmlElement] found in [children].
XmlElement get lastChild;

/// Returns the first direct child named [elementName].
XmlElement getChild(String elementName);

/// Returns the nth direct child named [elementName].
XmlElement getNthChild(int index, String elementName);

/// Returns the last direct child named [elementName].
XmlElement getLastChild(String elementName);

/// Returns all direct children named [elementName] between [start] and [stop].
List<XmlElement> getChildren(String elementName, {int start = 0, int stop});

/// Returns the first direct child with properties matching those specified.
XmlElement getChildWhere({
  String name,
  String id,
  List<String> attributeNames,
  List<XmlAttribute> attributes,
  bool matchAllAttributes = false,
  bool attributesMustBeIdentical = false,
  List<XmlNode> children,
  bool matchAllChildren = false,
  bool childrenMustBeIdentical = false,
});

/// Returns the nth direct child with properties matching those specified.
XmlElement getNthChildWhere(
  int index, {
  String name,
  String id,
  List<String> attributeNames,
  List<XmlAttribute> attributes,
  bool matchAllAttributes = false,
  bool attributesMustBeIdentical = false,
  List<XmlNode> children,
  bool matchAllChildren = false,
  bool childrenMustBeIdentical = false,
})

/// Returns the last direct child with properties matching those specified.
XmlElement getLastChildWhere({
  String name,
  String id,
  List<String> attributeNames,
  List<XmlAttribute> attributes,
  bool matchAllAttributes = false,
  bool attributesMustBeIdentical = false,
  List<XmlNode> children,
  bool matchAllChildren = false,
  bool childrenMustBeIdentical = false,
});

/// Returns all direct children with properties matching those specified.
List<XmlElement> getChildrenWhere({
  String name,
  String id,
  List<String> attributeNames,
  List<XmlAttribute> attributes,
  bool matchAllAttributes = false,
  bool attributesMustBeIdentical = false,
  List<XmlNode> children,
  bool matchAllChildren = false,
  bool childrenMustBeIdentical = false,
  bool ignoreNestedMatches = true,
  int start = 0,
  int stop,
});
```

Each of the above [getChild] methods also have a corresponding [getElement]
method that recursively checks all elements and their children, all the  way
down the tree, and returns any matching elements.

```dart
/// Recursively checks all elements within the node tree and
/// returns the first element found named [elementName].
XmlElement getElement(String elementName);

/// Recursively checks all elements within the node tree and
/// returns the nth element found named [elementName].
XmlElement getNthElement(
  int index,
  String elementName, {
  bool ignoreNestedMatches = true
});

/// Recursively checks all elements within the node tree and
/// returns the last element found named [elementName].
XmlElement getLastElement(String elementName);

/// Recursively checks all elements within the node tree and returns
/// any elements found named [elementName] between [start] and [stop].
List<XmlElement> getElements(
  String elementName, {
  bool ignoreNestedMatches = true,
  int start = 0,
  int stop,
});

/// Recursively checks all elements within the node tree and returns
/// the first element found with properties matching those specified.
XmlElement getElementWhere({
  String name,
  String id,
  List<String> attributeNames,
  List<XmlAttribute> attributes,
  bool matchAllAttributes = false,
  bool attributesMustBeIdentical = false,
  List<XmlNode> children,
  bool matchAllChildren = false,
  bool childrenMustBeIdentical = false,
});

/// Recursively checks all elements within the node tree and returns
/// the nth element found with properties matching those specified.
XmlElement getNthElementWhere(
  int index, {
  String name,
  String id,
  List<String> attributeNames,
  List<XmlAttribute> attributes,
  bool matchAllAttributes = false,
  bool attributesMustBeIdentical = false,
  List<XmlNode> children,
  bool matchAllChildren = false,
  bool childrenMustBeIdentical = false,
});

/// Recursively checks all elements within the node tree and returns
/// the last element found with properties matching those specified.
XmlElement getLastElementWhere({
  String name,
  String id,
  List<String> attributeNames,
  List<XmlAttribute> attributes,
  bool matchAllAttributes = false,
  bool attributesMustBeIdentical = false,
  List<XmlNode> children,
  bool matchAllChildren = false,
  bool childrenMustBeIdentical = false,
});

/// Recursively checks all elements within the node tree and returns
/// any elements found with properties matching those specified.
List<XmlElement> getElementsWhere({
  String name,
  String id,
  List<String> attributeNames,
  List<XmlAttribute> attributes,
  bool matchAllAttributes = false,
  bool attributesMustBeIdentical = false,
  List<XmlNode> children,
  bool matchAllChildren = false,
  bool childrenMustBeIdentical = false,
  bool ignoreNestedMatches = true,
  int start = 0,
  int stop,
});
```

The following methods also exist for testing if a child exists:

```dart
/// Returns `true` if [children] isn't `null` or empty.
bool get hasChildren;

/// Returns `true` if this element contains a direct child named [elementName].
bool hasChild(String elementName);

/// Returns `true` if this element contains a direct child with
/// properties matching those specified.
bool hasChildWhere({
  String name,
  String id,
  List<String> attributeNames,
  List<XmlAttribute> attributes,
  bool matchAllAttributes = false,
  bool attributesMustBeIdentical = false,
  List<XmlNode> children,
  bool matchAllChildren = false,
  bool childrenMustBeIdentical = false,
});

/// Recursively checks all nested elements and returns `true` if one
/// is found named [elementName].
bool hasElement(String elementName);

/// Recursively checks all nested elements and returns `true` if one
/// is found with properties matching those specified.
bool hasElementWhere({
  String name,
  String id,
  List<String> attributeNames,
  List<XmlAttribute> attributes,
  bool matchAllAttributes = false,
  bool attributesMustBeIdentical = false,
  List<XmlNode> children,
  bool matchAllChildren = false,
  bool childrenMustBeIdentical = false,
});
```

# Document Structure

Documents are parsed as [XmlDocument] nodes. [XmlDocument]s have a
single property, [children], a list of [XmlNode]s.

A document's XML and DOCTYPE declarations are parsed as [XmlDeclaration]
and [XmlDoctype] nodes respectively, and can be referenced with the
[xmlDeclaration] and [doctype] getters.

The document's root element is parsed as a [XmlElement] and can be
referenced with the [root] getter.

__Note:__ Valid XML documents only have a single XML declaration, DOCTYPE
declaration and root element. While [XmlDocument] doesn't limit [children] to
containing a single instance of each of these nodes, however only the first
found node of each type will be returned with their respective getters.

## XML Declarations

XML declarations are parsed as [XmlDeclaration] nodes.

The [XmlDeclaration] node has 3 parameters: [version], [encoding], and
[standalone]. All values are stored as [String]s, only [version] is required.

[XmlDeclaration]s can be parsed with the [XmlDeclaration.fromString]
method, or every instance of a XML declaration found within a string,
parsed, and extracted with the [XmlDeclaration.parseString] method.

```dart
String xmlDeclarationString =
    '<?xml version="1.0" encoding="UTF-8" standalone="yes" ?>';

XmlDeclaration xmlDeclaration =
    XmlDeclaration.fromString(xmlDeclarationString);

print(xmlDeclaration.version); // 1.0
print(xmlDeclaration.encoding); // UTF-8
print(xmlDeclaration.standalone) // true
```

__Note:__ Valid XML documents should only contain a single XML
declaration as the first root-level node, but are allowed to be
contained anywhere by the parser.

## DOCTYPE Declarations

DOCTYPE declarations are parsed as [XmlDoctype] nodes.

__Note:__ Valid XML documents should only contain DOCTYPE declarations
as a root-level node, but are allowed to be contained anywhere by the
parser.

[XmlDoctype]s with external DTD values, and a fully qualified URI linking to them, can be returned as a new [XmlDoctype] node containing their external
DTD nodes, by calling the [loadExternalDtd] method. `null` will be returned
if the URI couldn't be reached. All XML nodes found at the URI will be
retrieved, not just the valid DTD nodes.

```dart
XmlDoctype doctype = XmlDoctype.fromString(
    '<!DOCTYPE root PUBLIC "https://test.com/root.dtd">');

doctype = await doctype.loadExternalDtd();

print(doctype.externalDtd); // [<!ELEMENT author (#PCDATA)>, <!ELEMENT text (#PCDATA)>]
```

__Note:__ If the [XmlDoctype] node is contained within a [XmlDocument],
[XmlDocument]'s [loadExternalDtd] method can be called instead. All
[XmlDoctype] and [XmlEntity] nodes will be checked for external DTD
declarations and attempt to load each one.

## Elements

XmlElements are parsed as [XmlElement] nodes.

[XmlElement] has 3 parameters, [name], [attributes], and [children].

[children] can be referenced or traversed as described above.

[attributes] stores a list of [XmlAttribute]s, which contain a name and a
value. Valid XML documents may not posess attributes without a value but,
should the parser identify any attributes without a value, they will be
parsed with a `null` value, and written by the [toString] and
[toFormattedString] methods with an empty value.

[XmlElement] has several methods related to the [attributes] list.
Attribute names are not case sensitive, but the values are.

```dart
/// Returns true if this element has an attribute named [attributeName].
bool hasAttribute(String attributeName);

/// Returns true if this element has an attribute named
/// [attributeName] and a value of [attributeValue].
bool hasAttributeWhere(String attributeName, String attributeValue);

/// Returns the value of the first attribute named [attributeName].
String getAttribute(String attributeName);
```

An element's ID can be retrieved with the getter [id], which will find
the first attribute named [id], if it exists, and return its value.

All [XmlElement]s without any children will be considered an empty element,
and will written with a self-closing tag by the [toString] and
[toFormattedString] methods.

By default, [XmlElement]'s [parseString] method will only return
top-level elements. Its [global] option can be set to `true` to return
all elements, nested or not.

[parseString] has four options for filtering the returned elements.
[returnElementsNamed], [returnElementsWithId],
[returnElementsWithAttributeNamed], and [returnElementsWithAttribute].

[parseString] and all get methods that return [List]s have [start] and
[stop] parameters to limit the elements returned to only the indexes found
that fall on or after [start] and before [stop], which may be `null`. Indexes
are counted from `0`.

```dart
String xmlString = '''
<?xml version="1.0" encoding="UTF-8" standalone="yes" ?>
<!DOCTYPE root SYSTEM "rootDtd" "dtd/root.dtd">
<root>
    <element>Child 1</element>
    <element>Child 2</element>
    <element>Child 3</element>
    <element>Child 4</element>
    <element>Child 5</element>
    <element>Child 6</element>
</root>
''';

List<XmlElement> elements = XmlElement.parseString(
  xmlString,
  returnElementsNamed: ['element'],
  start: 2,
  stop: 4,
);

print(elements); // [<element>Child 3</element>, <element>Child 4</element>, <element>Child 5</element>]
```

## Plain Text Values

Plain text values are parsed as [XmlText] nodes. [XmlText] can be instanced
directly, or parsed with the [XmlText.fromString] method, which has options
to parse for character entities and trim whitespace.

```dart
String text = 'The `&amp;`, `&lt;`, and `&gt;` characters are reserved in XML.';

print(XmlText(text)); // The `&amp;`, `&lt;`, and `&gt;` characters are reserved in XML.

print(XmlText.fromString(text)); // The `&`, `<`, and `>` characters are reserved in XML.
```

The [toString] and [toFormattedString] methods have options to encode
characters as character entities. By default, only the `&`, `<`, and `>`
characters will be encoded. [XmlNode]s with their [isMarkup] parameter
set to `true`, will never have their characters encoded even if the
[encodeCharacterEntities] option is set to `true`, (it is by default.)

```dart
String text = '<text>Just some text.</text>';

print(XmlText(text)); // &lt;text&gt;Just some text.&lt;/text&gt;

print(XmlText(text).toString(encodeCharacterEntities: false)); // <text>Just some text.</text>

print(XmlText(text, isMarkup: true)); // <text>Just some text.</text>
```

XML nodes that can't be identified while parsing are also stored as
[XmlText] nodes with the [isMarkup] parameter set to `true`. This way,
when writing the document unidentifiable nodes will always be returned
exactly as they were found.

__Extracting Text:__

Properly nested plain text values can be extracted from a XML string with
the [parseString] method.

```dart
String xmlString = '''
<?xml version="1.0" encoding="UTF-8" standalone="yes" ?>
<!DOCTYPE root SYSTEM "rootDtd" "dtd/root.dtd">
<root>
    <element>Child 1</element>
    <element>Child 2</element>
    <text>Child 3</text>
</root>
''';

print(XmlText.parseString(xmlString)); // [Child 1, Child 2, Child 3]
```

[XmlElement]'s [text] getter will retrieve all top-level [XmlText]
nodes from [children] and return their joined values as a string.

```dart
String xmlString = '''
<element>
  This text will
  <child>not be joined with this text.</child>
  be joined with this text.
</element>
''';

XmlElement element = XmlElement.fromString(xmlString);

print(element.text); // This text will be joined with this text.

print(element.firstChild.text); // not be joined with this text.
```

## CDATA Sections

CDATA sections are parsed as [XmlCdata] nodes.

[XmlCdata] only contains a single parameter, [value], a string which must not
`null`, but may be empty.

[XmlCdata]'s value is left unmodified by the parser, with the exception of
unnecessary whitespace if the [trimWhtiespace] option is `true`.

## Comments

Comments are parsed as [XmlComment] nodes.

By default, the parsing methods on [XmlDocument] and the nodes that can
contain children will remove comments, rather than parsing them. The
parsing methods that support it, have a [parseComments] option, if you'd
like comments to be captured, parsed, and instanced as a node.

__Note:__ Valid XML documents don't allow comments within element tags or
other node delimiters, outside of values that contain nested nodes. The parser
removes comments found within nodes that don't support them, they can not
be captured by any parsing methods besides [XmlComment]'s own [fromString]
and [parseString] methods.

## Conditional Sections

Conditional sections are parsed as [XmlConditional] nodes. They have two
parameters, [condition] and [children].

Because conditionals can accept an entity for the condition, and the parser
doesn't decode XML entities (it has an option to parse for HTML, hex, and
ascii entities,) [condition] is stored as a [String]. For convienence, the
[XmlConditional] class has 2 static methods, [include] and [ignore] for
building [XmlConditional]s with the [condition] set to `INCLUDE` and `IGNORE`,
respectively.

## ENTITY Declarations

XML entities and DTD parameter entities are both parsed as [XmlEntity], with
the latter having the [isParameter] option set to `true`. [XmlEntity] has 6
other parameters, [name], [value], [isSystem], [isPublic], [externalEntities],
and [ndata].

[name] and [value] are accepted as positional parameters and must be provided.

[isSystem] and [isPublic] define whether `SYSTEM` or `PUBLIC` flags were
declared on the entity. Only one may be `true`.

[externalEntities] isn't captured by the parser when parsing an entity
declaration, but can be loaded with the [loadExternalEntities] method, which
returns a new [XmlEntity] instance with [externalEntities] set, assuming
the URI stored in [value] can be reached, otherwise `null` is returned.
If [XmlDocument]'s [loadExternalEntities] method is called, any [XmlEntity]s
with external entity declarations will have their external entities loaded
and replaced within the document with the new [XmlEntity] instance.

[ndata] is identified by the parser by the `NDATA` flag. Any content
found after the flag is captured as the [ndata] value.

## NOTATION Declarations

Notation declarations are parsed as [XmlNotation] nodes. [XmlNotation] has
5 parameters, [name], [isSystem], [isPublic], [publicId], and [uri].

## Processing Instructions

Processing instructions are parsed as [XmlProcessingInstruction] nodes.
[XmlProcessingInstruction] has 2 parameters, [target] and [content].

As processing instructions vary by application, their [content] is left
unmodified, with the exception of any unnecessary whitespace if the
[trimWhitespace] option is `true`.

## ELEMENT Type Declarations

DTD element type declarations are parsed as [XmlEtd] nodes.

As the parser doesn't validate XML code, [XmlEtd]s are captured in the same
way [XmlProcessingInstruction]s are, but with [name] and [children] parameters.
No distinction is made by the parser between parent and child element type
declarations, and their [children] values are left unparsed.

## ATTLIST Declarations

DTD ATTLIST declarations are parsed as [XmlAttlist] nodes. [XmlAttlist]s have
5 parameters: [element], [attribute], [type], [identifier], and [defaultValue].

[element], [attribute], and [type] are required, or parsing will fail, and
the node will be parsed as text. [identifier] is optional and is parsed as
an enum value, [XmlAttlistIdentifier]. [defaultValue] should only be provided
with [XmlAttlistIdentifier.FIXED] values.

# Building Documents/Nodes

xml_parser takes a hands-off approach to building documents and nodes.
No building methods are provided. Instead, [XmlDocument], and all nodes that
can contain children, store their nested nodes in modifiable [List]s.

Because every node is constant, to modify them, you must overwrite their
reference within the list that contains them.

```dart
XmlDocument xmlDocument = XmlDocument([
  XmlDeclaration(version: '1.0', encoding: 'UTF-8'),
  XmlElement(name: 'root', children: [
    XmlElement(name: 'child', children: [XmlText('Child 1')]),
    XmlElement(name: 'child', children: [XmlText('Child 2')]),
    XmlElement(name: 'child', children: [XmlText('Child 3')]),
    XmlElement(name: 'child', children: [XmlText('Child 4')]),
  ]),
]);

xmlDocument.root.children[2] = XmlComment('Child 3');

print(xmlDocument.writeToFile('document.xml'));
```

The above code would write `document.xml` to the project root as:

```xml
<?xml version="1.0" encoding="UTF-8" ?>
<root>
    <child>Child 1</child>
    <child>Child 2</child>
    <!--Child 3-->
    <child>Child 4</child>
</root>
```

# Writing Documents/Nodes

[XmlDocument], and every node, have [toString] and [toFormattedString]
methods.

* [toString] will output unformatted XML code without any line breaks.

* [toFormattedString] will format the XML code, breaking the line with each
node/element, indenting each line as necessary. (Note: toFormattedString is
rather rudimentary at the moment and I'd like to add additional formatting
options to it at some point.)

[XmlDocument] has two additional methods, [writeToFile] and [writeToFileSync]
which utilize Dart's [File] class's methods of the same name. Both methods
write [toString] or [toFormattedString]'s output directly to a file.
