import 'dart:io';
import 'package:test/test.dart';
import 'package:xml_parser/xml_parser.dart';
import '../lib/src/helpers/helpers.dart' show trimWhitespace;
import './test_values/hacker_news.dart' as hackerNewsValues;
import './test_values/library.dart' as libraryValues;
import './test_values/verbose.dart' as verboseValues;

void main() async {
  // Get the contents of the 'hacker_news.rss' test document.
  final String hackerNewsXml =
      await File('test/test_documents/hacker_news.rss').readAsString();

  // Parse the `hacker_news.rss` test document and compare the
  // extracted values to a list of the expected values.
  test('Document Parsing (HackerNews)', () {
    // Parse the test document.
    final XmlDocument hackerNews =
        XmlDocument.fromString(hackerNewsXml, parseCharacterEntities: false);

    // Check if the comment at the top of the document was ignored.
    expect(hackerNews.children.first, equals(hackerNews.root));

    // Check if the root element is an `rss` element.
    expect(hackerNews.root.name, equals('rss'));

    expect(hackerNews.root.getAttribute('version'), equals('2.0'));

    // Check if the channel elements match their expected values.
    final XmlElement channel = hackerNews.getElement('channel');

    expect(channel.getChild('title').text, equals('Hacker News'));

    expect(
      channel.getChild('link').text,
      equals('https://news.ycombinator.com/'),
    );

    expect(
      channel.getChild('description').text,
      equals('Links for the intellectually curious, ranked by readers.'),
    );

    // Check if the items match their expected values.
    final List<XmlElement> items = channel.getChildren('item');

    expect(hackerNewsValues.validateItems(items), equals(true));

    // Check if the string outputted by the [toString]
    // method matches the original document.
    expect(hackerNews.toString(encodeCharacterEntities: false),
        equals(hackerNewsXml.split('\n').last));
  });

  test('Node Extraction (HackerNews)', () {
    // Extract all `book` elements and compare them to their expected values.
    final List<XmlElement> items = XmlElement.parseString(
      hackerNewsXml,
      parseCharacterEntities: false,
      returnElementsNamed: ['item'],
    );

    expect(hackerNewsValues.validateItems(items), equals(true));

    // Extract the first `title` element found, and
    // compare its value to the expected value.
    final XmlElement title =
        XmlElement.fromString(hackerNewsXml, returnElementsNamed: ['title']);

    expect(title.text, equals('Hacker News'));

    // Extract the first `link` element found, and
    // compare its value to the expected value.
    final XmlElement link =
        XmlElement.fromString(hackerNewsXml, returnElementsNamed: ['link']);

    expect(link.text, equals('https://news.ycombinator.com/'));

    // Extract the first `description` element found,
    // and compare its value to the expected value.
    final XmlElement description = XmlElement.fromString(hackerNewsXml,
        returnElementsNamed: ['description']);

    expect(description.text,
        equals('Links for the intellectually curious, ranked by readers.'));

    // Extract all of the `title` elements, excluding the first one.
    final List<XmlElement> titles = XmlElement.parseString(
      hackerNewsXml,
      parseCharacterEntities: false,
      returnElementsNamed: ['title'],
      start: 1,
    );

    // Extract all of the `link` elements, excluding the first one.
    final List<XmlElement> links = XmlElement.parseString(hackerNewsXml,
        returnElementsNamed: ['link'], start: 1);

    // Extract all of the `pubDate` elements.
    final List<XmlElement> pubDates =
        XmlElement.parseString(hackerNewsXml, returnElementsNamed: ['pubDate']);

    // Extract all of the `comments` elements.
    final List<XmlElement> comments = XmlElement.parseString(hackerNewsXml,
        returnElementsNamed: ['comments']);

    // Extract all of the `description` elements, excluding the first one.
    final List<XmlElement> descriptions = XmlElement.parseString(hackerNewsXml,
        returnElementsNamed: ['description'], start: 1);

    // Extract all of the CDATA nodes.
    final List<XmlCdata> cdata = XmlCdata.parseString(hackerNewsXml);

    // Get the expected values of all of the extracted nodes
    final List<String> titleValues = List<String>();

    final List<String> linkValues = List<String>();

    final List<String> pubDateValues = List<String>();

    final List<String> commentsValues = List<String>();

    final List<String> descriptionValues = List<String>();

    hackerNewsValues.itemValues.forEach((Map<String, String> item) {
      titleValues.add(item['title']);
      linkValues.add(item['link']);
      pubDateValues.add(item['pubDate']);
      commentsValues.add(item['comments']);
      descriptionValues.add(item['description']);
    });

    expect(titles.length, equals(titleValues.length));
    expect(links.length, equals(linkValues.length));
    expect(pubDateValues.length, equals(pubDateValues.length));
    expect(commentsValues.length, equals(commentsValues.length));
    expect(descriptions.length, equals(descriptionValues.length));
    expect(cdata.length, equals(descriptionValues.length));

    // Compare all of the extracted nodes to their expected values.
    for (int i = 0; i < cdata.length; i++) {
      expect(titles[i].text, equals(titleValues[i]));
      expect(links[i].text, equals(linkValues[i]));
      expect(pubDates[i].text, equals(pubDateValues[i]));
      expect(comments[i].text, equals(commentsValues[i]));
      expect(descriptions[i].children.first.toString(),
          equals(descriptionValues[i]));
      expect(cdata[i].toString(), equals(descriptionValues[i]));
    }

    // Extract the RSS element by its 'version' attribute
    // and confirm the correct element was captured.
    final XmlElement versioned = XmlElement.fromString(
      hackerNewsXml,
      returnElementsWithAttributesNamed: ['version'],
    );

    expect(versioned.name, equals('rss'));
    expect(versioned.getAttribute('version'), equals('2.0'));
  });

  // Get the contents of the 'library.xml' test document.
  final String libraryXml =
      await File('test/test_documents/library.xml').readAsString();

  // Parse the `library.xml` test document and compare the
  // extracted values to a map of the expected values.
  test('Document Parsing (Library)', () {
    // Parse the test document.
    final XmlDocument library =
        XmlDocument.fromString(libraryXml, parseComments: true);

    // Check if the correct number of root level nodes were parsed.
    expect(library.children.length, equals(4));

    // Check if the XML Declaration was parsed as expected.
    expect(library.xmlDeclaration.toString(),
        equals('<?xml version="1.0" encoding="UTF-8" standalone="yes" ?>'));

    // Check if the XML DocType Declaration was parsed as expected.
    final String doctype = trimWhitespace(
        RegExp(r'<!DOCTYPE.*?]>', dotAll: true).stringMatch(libraryXml));

    expect(library.doctype.toString(), equals(doctype));

    // Check if the document's elements were parsed as expected.
    final List<XmlElement> books = library.root.getChildren('book');

    expect(libraryValues.validateBooks(books), equals(true));

    // TODO: Once the `lineLength` option is added to the `toFormattedString()`
    // methods: expect(library.toFormattedString(), equals(libraryXml));
  });

  // Test the node extraction methods and compare the extracted
  // values against a map of the expected values.
  test('Node Extraction (Library)', () {
    // Extract all 'book' elements and compare them to their expected values.
    final List<XmlElement> books =
        XmlElement.parseString(libraryXml, returnElementsNamed: ['book']);

    expect(libraryValues.validateBooks(books), equals(true));

    // Extract all text nodes and compare them to their expected values.
    final List<String> textValues = List<String>();

    libraryValues.bookValues.values.forEach((Map<String, dynamic> book) {
      textValues.add(book['summary']);

      book['quotes'].forEach((String quote) {
        textValues.add(quote);
      });
    });

    final List<XmlText> textNodes = XmlText.parseString(libraryXml);

    expect(textNodes.length, equals(textValues.length));

    for (int i = 0; i < textValues.length; i++) {
      expect(textNodes[i].value, equals(textValues[i]));
    }
  });

  // Get the contents of the 'verbose.xml' test document.
  final String verboseXml =
      await File('test/test_documents/verbose.xml').readAsString();

  final String verboseDoctype = trimWhitespace(
      RegExp(r'<!DOCTYPE.*?]>', dotAll: true).stringMatch(verboseXml));

  test('Document Parsing (Verbose)', () {
    // Parse the test document.
    final XmlDocument verbose =
        XmlDocument.fromString(verboseXml, parseComments: true);

    // Check if the correct number of root level nodes were parsed.
    expect(verbose.children.length, equals(5));

    // Check if the XML Declaration was parsed as expected.
    expect(verbose.xmlDeclaration.toString(),
        equals(verboseValues.xmlDeclaration));

    // Check if the Processing Instruction was parsed as expected.
    expect(verbose.children[1].toString(),
        equals(verboseValues.processingInstruction));

    // Check if the XML DocType Declaration was parsed as expected.
    expect(verbose.doctype.toString(), equals(verboseDoctype));

    expect(verbose.doctype.internalDtd.length,
        equals(verboseValues.internalDtd.length));

    for (int i = 0; i < verbose.doctype.internalDtd.length; i++) {
      final XmlNode node = verbose.doctype.internalDtd[i];

      expect(node.runtimeType, equals(verboseValues.internalDtdTypes[i]));

      expect(node.toString(), equals(verboseValues.internalDtd[i]));
    }

    // Check if the root level comment was parsed as expected.
    expect(verbose.children[3].toString(), equals(verboseValues.comments.first));

    // Check if the documents elements were parsed as expected.
    final XmlElement root = verbose.root;

    expect(root.hasAttributeWhere('author', '&author;'), equals(true));

    expect(verboseValues.validateChildren(verbose.root.children), equals(true));
  });

  final String verboseRootElementValue = trimWhitespace(
    '<root' + verboseXml.split('<root').last,
  ).replaceAll(RegExp(r'(?<=(?<!!)\[) (?=\S)|(?<=\S) (?=])'), '');

  test('Node Extraction (Verbose)', () {
    // Extract and validate the XML Declaration.
    expect(XmlDeclaration.fromString(verboseXml).toString(),
        equals(verboseValues.xmlDeclaration));

    expect(XmlDeclaration.parseString(verboseXml).first.toString(),
        equals(verboseValues.xmlDeclaration));

    // Extract and validate the Processing Instruction Declaration.
    expect(XmlProcessingInstruction.fromString(verboseXml).toString(),
        equals(verboseValues.processingInstruction));

    expect(XmlProcessingInstruction.parseString(verboseXml).first.toString(),
        equals(verboseValues.processingInstruction));

    // Extract and validate the DocType Declaration.
    expect(
        XmlDoctype.fromString(verboseXml).toString(), equals(verboseDoctype));

    expect(XmlDoctype.parseString(verboseXml).first.toString(),
        equals(verboseDoctype));

    // Extract and validate the `root` element.
    expect(
      XmlElement.fromString(
        verboseXml,
        returnElementsNamed: ['root'],
        parseComments: true,
      ).toString(),
      equals(verboseRootElementValue),
    );

    expect(
      XmlElement.parseString(
        verboseXml,
        returnElementsNamed: ['root'],
        parseComments: true,
      ).first.toString(),
      equals(verboseRootElementValue),
    );

    // Extract and validate all `text` elements.
    final List<XmlElement> textElements = XmlElement.parseString(verboseXml,
        returnElementsNamed: ['text'], global: true);

    expect(textElements.length, equals(verboseValues.textValues.length));

    for (int i = 0; i < textElements.length; i++) {
      expect(textElements[i].text == verboseValues.textValues[i], equals(true));
    }

    // Extract and validate all `image` elements.
    final List<XmlElement> imageElements = XmlElement.parseString(verboseXml,
        returnElementsNamed: ['image'], global: true);

    expect(imageElements.length, equals(verboseValues.imageElements.length));

    for (int i = 0; i < imageElements.length; i++) {
      expect(imageElements[i].hasAttribute('width'), equals(true));

      expect(int.tryParse(imageElements[i].getAttribute('width')) != null,
          equals(true));

      expect(imageElements[i].hasAttribute('height'), equals(true));

      expect(int.tryParse(imageElements[i].getAttribute('height')) != null,
          equals(true));

      expect(imageElements[i].hasAttribute('src'), equals(true));

      expect(
        imageElements[i]
            .getAttribute('src')
            .contains(RegExp(r'test[1-3].(gif|png)')),
        equals(true),
      );

      expect(imageElements[i].toString(),
          equals(verboseValues.imageElements[i]));
    }

    // Extract and validate all comments.
    expect(XmlComment.fromString(verboseXml).value,
        equals(verboseValues.commentValues.first));

    final List<XmlComment> comments = XmlComment.parseString(verboseXml);

    expect(comments.length, equals(verboseValues.commentValues.length));

    for (int i = 0; i < comments.length; i++) {
      expect(comments[i].value, equals(verboseValues.commentValues[i]));
    }

    // Extract and validate all Conditional Sections.
    expect(XmlConditional.fromString(verboseXml).toString(),
        equals(verboseValues.conditionalSections.last));

    expect(XmlConditional.parseString(verboseXml).length, equals(1));

    final List<XmlConditional> conditionals =
        XmlConditional.parseString(verboseXml, global: true);

    expect(conditionals.length,
        equals(verboseValues.conditionalSections.length));

    for (int i = 0; i < conditionals.length; i++) {
      expect(conditionals[i].toString(),
          equals(verboseValues.conditionalSections[i]));
    }

    // Extract and validate all Entity Declarations.
    expect(XmlEntity.fromString(verboseXml).toString(),
        equals(verboseValues.entities.first));

    final List<XmlEntity> entities = XmlEntity.parseString(verboseXml);

    expect(entities.length, equals(verboseValues.entities.length));

    for (int i = 0; i < entities.length; i++) {
      expect(entities[i].toString(), equals(verboseValues.entities[i]));
    }

    // Extract and validate all Element Type Definitions.
    expect(XmlEtd.fromString(verboseXml).toString(),
        equals(verboseValues.etds.first));

    final List<XmlEtd> etds = XmlEtd.parseString(verboseXml);

    expect(etds.length, equals(verboseValues.etds.length));

    for (int i = 0; i < etds.length; i++) {
      expect(etds[i].toString(), equals(verboseValues.etds[i]));
    }

    // Extract and validate all ATTLIST Declarations.
    expect(XmlAttlist.fromString(verboseXml).toString(),
        equals(verboseValues.attlists.first));

    final List<XmlAttlist> attlists = XmlAttlist.parseString(verboseXml);

    expect(attlists.length, equals(verboseValues.attlists.length));

    for (int i = 0; i < attlists.length; i++) {
      expect(attlists[i].toString(), equals(verboseValues.attlists[i]));
    }

    // Extract and validate all Notation Declarations.
    expect(XmlNotation.fromString(verboseXml).toString(),
        equals(verboseValues.notations.first));

    final List<XmlNotation> notations = XmlNotation.parseString(verboseXml);

    expect(notations.length, equals(verboseValues.notations.length));

    for (int i = 0; i < notations.length; i++) {
      expect(notations[i].toString(), equals(verboseValues.notations[i]));
    }
  });
}
