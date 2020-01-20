import 'package:xml_parser/xml_parser.dart';

// Calling `main('xml_parser')` would print:
// xml_parser 0.1.1
// Description: An unopinionated XML parser that can
// read, traverse, and write XML documents.
// Repo: https://github.com/james-alex/xml_parser
// Issues: https://github.com/james-alex/xml_parser/issues
// Documentation: https://pub.dev/documentation/xml_parser/latest/
// Publisher: TODO:
// License: BSD (https://github.com/james-alex/xml_parser/blob/master/LICENSE)
// Dependencies: [html_character_entities, http, recursive_regex]
// 0 packages depend on xml_parser.
// Popularity: 0
// Health: 100
// Maintenance: 100
// Overall: 50

/// Retreives and prints a package's details and analytics data from pub.dev.
void main(String package) async {
  assert(package != null && package.isNotEmpty);

  // Get the package page's document and parse it.
  final packagePage =
      await XmlDocument.fromUri('https://pub.dev/packages/$package');

  if (packagePage == null) {
    throw ('Failed to load page.');
  }

  // Get the title of the page and check if the package exists.
  final pageTitle = packagePage.getElement('title').text;

  if (pageTitle.startsWith('Search results')) {
    throw ('$package doesn\'t exist.');
  }

  // Get the package title from the page.
  final title = packagePage.getElementWhere(
    name: 'h2',
    attributes: [XmlAttribute('class', 'title')],
  ).text;

  print(title);

  // Get the sidebar element.
  final sidebar = packagePage.getElementWhere(
    name: 'aside',
    attributes: [XmlAttribute('class', 'sidebar sidebar-content')],
  );

  // TODO: Get the publisher

  // Get the description text from the sidebar.
  final description = sidebar.getChild('p').text?.trim();

  if (description != null && description.isNotEmpty) print(description);

  // Get the links from the sidebar.
  final links = sidebar.getNthChild(2, 'p');

  final repository = links.getChild('a').getAttribute('href');

  print('Repo: $repository');

  final issues = links.getNthChild(1, 'a').getAttribute('href');

  print('Issues: $issues');

  final documentation =
      'https://pub.dev${links.getNthChild(2, 'a').getAttribute('href')}';

  print('Documentation $documentation');

  final author = sidebar.getElementWhere(
    name: 'span',
    attributes: [XmlAttribute('class', 'author')],
  );

  // The index of the next optional child (license and dependencies).
  var nextChild = (description != null) ? 3 : 2;

  // Get the license from the sidebar, if one exists.
  if (sidebar.hasElementWhere(
    name: 'h3',
    attributes: [XmlAttribute('class', 'title')],
    children: [XmlText('License')],
  )) {
    final license = sidebar.getNthElement(nextChild, 'p');

    final licenseType = license.text.split('(').first.trim();

    final licenseUrl = license.getChild('a')?.getAttribute('href');

    print('License: $licenseType${licenseUrl != null ? ' ($licenseUrl)' : ''}');

    nextChild++;
  }

  // Get the dependencies from the sidebar, if any exist.
  if (sidebar.hasElementWhere(
    name: 'h3',
    attributes: [XmlAttribute('class', 'title')],
    children: [XmlText('Dependencies')],
  )) {
    final dependencies = sidebar
        .getNthElement(nextChild, 'p')
        .getElements('a')
        .map((link) => link.text)
        .toList();

    print('Dependencies: $dependencies');
  }

  // Get the number of packages that depend on this package.
  final numberOfDependants = await _getNumberOfDependants(package);

  print('$numberOfDependants packages depend on $package.');

  // Get the divs containing the scores.
  final scores =
      packagePage.getElementWhere(id: 'scores-table').getElementsWhere(
    name: 'div',
    attributes: [XmlAttribute('class', 'score-percent')],
  );

  // Popularity Score
  final popularity = int.parse(scores[0].text);

  print('Popularity: $popularity');

  // Health Score
  final health = int.parse(scores[1].text);

  print('Health: $health');

  // Maintenance Score
  final maintenance = int.parse(scores[2].text);

  print('Maintenance: $maintenance');

  // Overall Score
  final overall = int.parse(scores[3].text);

  print('Overall: $overall');
}

/// Gets the number of results from the dependency search page.
Future<int> _getNumberOfDependants(String package) async {
  final searchPage = await XmlDocument.fromUri(
      'https://pub.dev/packages?q=dependency%3A$package');

  if (searchPage == null) {
    throw ('Failed to load dependency seach results.');
  }

  final numberOfResults = searchPage
      .getElementWhere(
        name: 'p',
        attributes: [XmlAttribute('class', 'package-count')],
      )
      .getChild('span')
      .text;

  return int.tryParse(numberOfResults);
}
