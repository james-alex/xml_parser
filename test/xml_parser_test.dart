import 'dart:io';
import 'package:test/test.dart';
import 'package:xml_parser/xml_parser.dart';
import 'package:xml_parser/src/helpers/formatters.dart' show StringFormatters;
import './test_values/hacker_news.dart' as hacker_news_values;
import './test_values/library.dart' as library_values;
import './test_values/verbose.dart' as verbose_values;

void main() async {
  // Get the contents of the 'hacker_news.rss' test document.
  final hackerNewsXml =
      await File('test/test_documents/hacker_news.rss').readAsString();

  // Parse the `hacker_news.rss` test document and compare the
  // extracted values to a list of the expected values.
  test('Document Parsing (HackerNews)', () {
    // Parse the test document.
    final hackerNews =
        XmlDocument.from(hackerNewsXml, parseCharacterEntities: false)!;

    // Check if the comment at the top of the document was ignored.
    expect(hackerNews.children.first, equals(hackerNews.root));

    // Check if the root element is an `rss` element.
    expect(hackerNews.root?.name, equals('rss'));

    expect(hackerNews.root?.getAttribute('version'), equals('2.0'));

    // Check if the channel elements match their expected values.
    final channel = hackerNews.getElement('channel');

    expect(channel?.getChild('title')?.text, equals('Hacker News'));

    expect(
      channel?.getChild('link')?.text,
      equals('https://news.ycombinator.com/'),
    );

    expect(
      channel?.getChild('description')?.text,
      equals('Links for the intellectually curious, ranked by readers.'),
    );

    // Check if the items match their expected values.
    final items = channel?.getChildren('item');

    expect(hacker_news_values.validateItems(items), equals(true));

    // Check if the string outputted by the [toString]
    // method matches the original document.
    expect(hackerNews.toString(encodeCharacterEntities: false),
        equals(hackerNewsXml.split('\n').last));
  });

  test('Node Extraction (HackerNews)', () {
    // Extract all `book` elements and compare them to their expected values.
    final items = XmlElement.parseString(
      hackerNewsXml,
      parseCharacterEntities: false,
      returnElementsNamed: ['item'],
    );

    expect(hacker_news_values.validateItems(items), equals(true));

    // Extract the first `title` element found, and
    // compare its value to the expected value.
    final title =
        XmlElement.from(hackerNewsXml, returnElementsNamed: ['title']);

    expect(title?.text, equals('Hacker News'));

    // Extract the first `link` element found, and
    // compare its value to the expected value.
    final link = XmlElement.from(hackerNewsXml, returnElementsNamed: ['link']);

    expect(link?.text, equals('https://news.ycombinator.com/'));

    // Extract the first `description` element found,
    // and compare its value to the expected value.
    final description =
        XmlElement.from(hackerNewsXml, returnElementsNamed: ['description']);

    expect(description?.text,
        equals('Links for the intellectually curious, ranked by readers.'));

    // Extract all of the `title` elements, excluding the first one.
    final titles = XmlElement.parseString(
      hackerNewsXml,
      parseCharacterEntities: false,
      returnElementsNamed: ['title'],
      start: 1,
    );

    // Extract all of the `link` elements, excluding the first one.
    final links = XmlElement.parseString(hackerNewsXml,
        returnElementsNamed: ['link'], start: 1);

    // Extract all of the `pubDate` elements.
    final pubDates =
        XmlElement.parseString(hackerNewsXml, returnElementsNamed: ['pubDate']);

    // Extract all of the `comments` elements.
    final comments = XmlElement.parseString(hackerNewsXml,
        returnElementsNamed: ['comments']);

    // Extract all of the `description` elements, excluding the first one.
    final descriptions = XmlElement.parseString(hackerNewsXml,
        returnElementsNamed: ['description'], start: 1);

    // Extract all of the CDATA nodes.
    final cdata = XmlCdata.parseString(hackerNewsXml)!;

    // Get the expected values of all of the extracted nodes
    final titleValues = <String>[];
    final linkValues = <String>[];
    final pubDateValues = <String>[];
    final commentsValues = <String>[];
    final descriptionValues = <String>[];

    for (var item in hacker_news_values.itemValues) {
      titleValues.add(item['title']!);
      linkValues.add(item['link']!);
      pubDateValues.add(item['pubDate']!);
      commentsValues.add(item['comments']!);
      descriptionValues.add(item['description']!);
    }

    expect(titles?.length, equals(titleValues.length));
    expect(links?.length, equals(linkValues.length));
    expect(pubDateValues.length, equals(pubDateValues.length));
    expect(commentsValues.length, equals(commentsValues.length));
    expect(descriptions?.length, equals(descriptionValues.length));
    expect(cdata.length, equals(descriptionValues.length));

    // Compare all of the extracted nodes to their expected values.
    for (var i = 0; i < cdata.length; i++) {
      expect(titles![i].text, equals(titleValues[i]));
      expect(links![i].text, equals(linkValues[i]));
      expect(pubDates![i].text, equals(pubDateValues[i]));
      expect(comments![i].text, equals(commentsValues[i]));
      expect(descriptions![i].children!.first.toString(),
          equals(descriptionValues[i]));
      expect(cdata[i].toString(), equals(descriptionValues[i]));
    }

    // Extract the RSS element by its 'version' attribute
    // and confirm the correct element was captured.
    final versioned = XmlElement.from(
      hackerNewsXml,
      returnElementsWithAttributesNamed: ['version'],
    )!;

    expect(versioned.name, equals('rss'));
    expect(versioned.getAttribute('version'), equals('2.0'));
  });

  // Get the contents of the 'library.xml' test document.
  final libraryXml =
      await File('test/test_documents/library.xml').readAsString();

  // Parse the `library.xml` test document and compare the
  // extracted values to a map of the expected values.
  test('Document Parsing (Library)', () {
    // Parse the test document.
    final library = XmlDocument.from(libraryXml, parseComments: true)!;

    // Check if the correct number of root level nodes were parsed.
    expect(library.children.length, equals(4));

    // Check if the XML Declaration was parsed as expected.
    expect(library.xmlDeclaration.toString(),
        equals('<?xml version="1.0" encoding="UTF-8" standalone="yes" ?>'));

    // Check if the XML DocType Declaration was parsed as expected.
    final doctype = RegExp(r'<!DOCTYPE.*?]>', dotAll: true)
        .stringMatch(libraryXml)!
        .trimWhitespace();

    expect(library.doctype.toString(), equals(doctype));

    // Check if the document's elements were parsed as expected.
    final books = library.root!.getChildren('book')!;

    expect(library_values.validateBooks(books), equals(true));
  });

  // Test the node extraction methods and compare the extracted
  // values against a map of the expected values.
  test('Node Extraction (Library)', () {
    // Extract all 'book' elements and compare them to their expected values.
    final books =
        XmlElement.parseString(libraryXml, returnElementsNamed: ['book'])!;

    expect(library_values.validateBooks(books), equals(true));

    // Extract all text nodes and compare them to their expected values.
    final textValues = <String>[];

    for (var book in library_values.bookValues.values) {
      textValues.add(book['summary']);
      book['quotes'].forEach(textValues.add);
    }

    final textNodes = XmlText.parseString(libraryXml)!;

    expect(textNodes.length, equals(textValues.length));

    for (var i = 0; i < textValues.length; i++) {
      expect(textNodes[i].value, equals(textValues[i]));
    }
  });

  // Get the contents of the 'verbose.xml' test document.
  final verboseXml =
      await File('test/test_documents/verbose.xml').readAsString();

  final verboseDoctype = RegExp(r'<!DOCTYPE.*?]>', dotAll: true)
      .stringMatch(verboseXml)!
      .trimWhitespace();

  test('Document Parsing (Verbose)', () {
    // Parse the test document.
    final verbose = XmlDocument.from(verboseXml,
        parseComments: true, parseCdataAsText: false)!;

    // Check if the correct number of root level nodes were parsed.
    expect(verbose.children.length, equals(5));

    // Check if the XML Declaration was parsed as expected.
    expect(verbose.xmlDeclaration.toString(),
        equals(verbose_values.xmlDeclaration));

    // Check if the Processing Instruction was parsed as expected.
    expect(verbose.children[1].toString(),
        equals(verbose_values.processingInstruction));

    // Check if the XML DocType Declaration was parsed as expected.
    expect(verbose.doctype.toString(), equals(verboseDoctype));

    expect(verbose.doctype!.internalDtd!.length,
        equals(verbose_values.internalDtd.length));

    for (var i = 0; i < verbose.doctype!.internalDtd!.length; i++) {
      final node = verbose.doctype!.internalDtd![i];

      expect(node.runtimeType, equals(verbose_values.internalDtdTypes[i]));

      expect(node.toString(), equals(verbose_values.internalDtd[i]));
    }

    // Check if the root level comment was parsed as expected.
    expect(
        verbose.children[3].toString(), equals(verbose_values.comments.first));

    // Check if the documents elements were parsed as expected.
    final root = verbose.root!;

    expect(root.hasAttributeWhere('author', '&author;'), equals(true));

    expect(verbose_values.validateChildren(root.children!), equals(true));
  });

  final verboseRootElementValue = '<root${verboseXml.split('<root').last}'
      .trimWhitespace()
      .replaceAll(RegExp(r'(?<=(?<!!)\[) (?=\S)|(?<=\S) (?=])'), '');

  test('Node Extraction (Verbose)', () {
    // Extract and validate the XML Declaration.
    expect(XmlDeclaration.from(verboseXml).toString(),
        equals(verbose_values.xmlDeclaration));

    expect(XmlDeclaration.parseString(verboseXml)?.first.toString(),
        equals(verbose_values.xmlDeclaration));

    // Extract and validate the Processing Instruction Declaration.
    expect(XmlProcessingInstruction.from(verboseXml).toString(),
        equals(verbose_values.processingInstruction));

    expect(XmlProcessingInstruction.parseString(verboseXml)?.first.toString(),
        equals(verbose_values.processingInstruction));

    // Extract and validate the DocType Declaration.
    expect(XmlDoctype.from(verboseXml).toString(), equals(verboseDoctype));

    expect(XmlDoctype.parseString(verboseXml)?.first.toString(),
        equals(verboseDoctype));

    // Extract and validate the `root` element.
    expect(
      XmlElement.from(
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
      )?.first.toString(),
      equals(verboseRootElementValue),
    );

    // Extract and validate all `text` elements.
    final textElements = XmlElement.parseString(verboseXml,
        returnElementsNamed: ['text'], global: true)!;

    expect(textElements.length, equals(verbose_values.textValues.length));

    for (var i = 0; i < textElements.length; i++) {
      expect(
          textElements[i].text == verbose_values.textValues[i], equals(true));
    }

    // Extract and validate all `image` elements.
    final imageElements = XmlElement.parseString(verboseXml,
        returnElementsNamed: ['image'], global: true)!;

    expect(imageElements.length, equals(verbose_values.imageElements.length));

    for (var i = 0; i < imageElements.length; i++) {
      expect(imageElements[i].hasAttribute('width'), equals(true));
      expect(int.tryParse(imageElements[i].getAttribute('width')!) != null,
          equals(true));
      expect(imageElements[i].hasAttribute('height'), equals(true));
      expect(int.tryParse(imageElements[i].getAttribute('height')!) != null,
          equals(true));
      expect(imageElements[i].hasAttribute('src'), equals(true));

      expect(
        imageElements[i]
            .getAttribute('src')
            ?.contains(RegExp(r'test[1-3].(gif|png)')),
        equals(true),
      );

      expect(
          imageElements[i].toString(), equals(verbose_values.imageElements[i]));
    }

    // Extract and validate all comments.
    expect(XmlComment.from(verboseXml)?.value,
        equals(verbose_values.commentValues.first));

    final comments = XmlComment.parseString(verboseXml)!;

    expect(comments.length, equals(verbose_values.commentValues.length));

    for (var i = 0; i < comments.length; i++) {
      expect(comments[i].value, equals(verbose_values.commentValues[i]));
    }

    // Extract and validate all Conditional Sections.
    expect(XmlConditional.from(verboseXml).toString(),
        equals(verbose_values.conditionalSections.last));

    expect(XmlConditional.parseString(verboseXml)?.length, equals(1));

    final conditionals = XmlConditional.parseString(verboseXml, global: true)!;

    expect(
        conditionals.length, equals(verbose_values.conditionalSections.length));

    for (var i = 0; i < conditionals.length; i++) {
      expect(conditionals[i].toString(),
          equals(verbose_values.conditionalSections[i]));
    }

    // Extract and validate all Entity Declarations.
    expect(XmlEntity.from(verboseXml).toString(),
        equals(verbose_values.entities.first));

    final entities = XmlEntity.parseString(verboseXml)!;

    expect(entities.length, equals(verbose_values.entities.length));

    for (var i = 0; i < entities.length; i++) {
      expect(entities[i].toString(), equals(verbose_values.entities[i]));
    }

    // Extract and validate all Element Type Definitions.
    expect(
        XmlEtd.from(verboseXml).toString(), equals(verbose_values.etds.first));

    final etds = XmlEtd.parseString(verboseXml)!;

    expect(etds.length, equals(verbose_values.etds.length));

    for (var i = 0; i < etds.length; i++) {
      expect(etds[i].toString(), equals(verbose_values.etds[i]));
    }

    // Extract and validate all ATTLIST Declarations.
    expect(XmlAttlist.from(verboseXml).toString(),
        equals(verbose_values.attlists.first));

    final attlists = XmlAttlist.parseString(verboseXml)!;

    expect(attlists.length, equals(verbose_values.attlists.length));

    for (var i = 0; i < attlists.length; i++) {
      expect(attlists[i].toString(), equals(verbose_values.attlists[i]));
    }

    // Extract and validate all Notation Declarations.
    expect(XmlNotation.from(verboseXml).toString(),
        equals(verbose_values.notations.first));

    final notations = XmlNotation.parseString(verboseXml)!;

    expect(notations.length, equals(verbose_values.notations.length));

    for (var i = 0; i < notations.length; i++) {
      expect(notations[i].toString(), equals(verbose_values.notations[i]));
    }
  });
}
