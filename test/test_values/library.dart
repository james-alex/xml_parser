import 'package:xml_parser/xml_parser.dart';

bool validateBooks(List<XmlElement> books) {
  assert(books != null);

  if (books.length != 10) return false;

  var valid = true;

  for (var book in books) {
    final title = book.getAttribute('title');

    final values = bookValues[title];

    final quotes =
        book.getChild('quotes').getChildren('quote');

    if ((book.getAttribute('author') != values['author']) ||
        (book.getAttribute('year') != values['year']) ||
        (book.getChild('summary').text != values['summary']) ||
        (quotes.length != values['quotes'].length)) {
      valid = false;
      break;
    }

    for (var i = 0; i < quotes.length; i++) {
      if (quotes[i].text != values['quotes'][i]) {
        valid = false;
        break;
      }
    }
  }

  return valid;
}


const Map<String, Map<String, dynamic>> bookValues =
  <String, Map<String, dynamic>>{
    'Song of Solomon': {
      'author': 'Toni Morrison',
      'year': '1977',
      'summary': 'Song of Solomon follows the life of '
          'Macon "Milkman" Dead III, an African-American man '
          'living in Michigan, from birth to adulthood.',
      'quotes': [
        '"You wanna fly, you got to give up the shit that weighs you down."',
        '"She was fierce in the presence of death, heroic even, '
            'as she was at no other time. Its threat gave her direction, '
            'clarity, audacity."',
        '"If you surrendered to the air, you could ride it."',
      ],
    },
    'The Pearl': {
      'author': 'John Steinbeck',
      'year': '1947',
      'summary': 'The Pearl is the story of a pearl diver, Kino, and '
          'explores man\'s nature as well as greed, defiance of societal '
          'norms, and evil.',
      'quotes': [
        '"He said, \'I am a man,\' and that meant certain things to Juana. '
            'It meant that he was half insane and half god."',
        '"We do know that we are cheated from birth to the overcharge on our '
            'coffins."',
        '"A plan is a real thing, and things projected are experienced. A '
            'plan once made and visualized becomes reality along with other '
            'realities—never to be destroyed but easily to be attacked."',
      ],
    },
    'Northanger Abbey': {
      'author': 'Jane Austen',
      'year': '1817',
      'summary': 'This coming-of-age story revolves around Catherine Morland, '
          'a young and naïve "heroine", who entertains the reader on her '
          'journey to a better understanding of the world and those around '
          'her.',
      'quotes': [
        '"The person, be it gentleman or lady, who has not pleasure in a good '
        'novel, must be intolerably stupid."',
        '"It is well to have as many holds upon happiness as possible."',
        '"I cannot speak well enough to be unintelligible."',
      ],
    },
    'Island': {
      'author': 'Aldous Huxley',
      'year': '1962',
      'summary': 'Island is the account of Will Farnaby, a cynical journalist '
          'who is shipwrecked on the fictional island of Pala.',
      'quotes': [
        '"It isn\'t a matter of forgetting. What one has to learn is how '
            'to remember and yet be free of the past."',
        '"We cannot reason ourselves out of our basic irrationality. All '
            'we can do is learn the art of being irrational in a reasonable '
            'way."',
        '"All gods are homemade, and it is we who pull their strings, '
            'and so, give them the power to pull ours."',
      ],
    },
    'Living My Life': {
      'author': 'Emma Goldman',
      'year': '1931',
      'summary': 'Living My Life is the autobiography of Lithuanian-born '
          'anarchist Emma Goldman, who became internationally renowned as '
          'an activist based in the United States.',
      'quotes': [
        '"I want freedom, the right to self-expression, everybody\'s right '
            'to beautiful, radiant things. Anarchism meant that to me, and '
            'I would live it in spite of the whole world."',
        '"I grew furious at the impudent interference of the boy. I told '
            'him to mind his own business."',
        '"I did not believe that a Cause which stood for a beautiful ideal, '
            'for anarchism, for release and freedom from convention and '
            'prejudice, should demand the denial of life and joy."',
      ],
    },
    'The Fall': {
      'author': 'Albert Camus',
      'year': '1942',
      'summary': 'Set in Amsterdam, The Fall consists of a series of '
          'dramatic monologues by the self-proclaimed "judge-penitent" '
          'Jean-Baptiste Clamence, as he reflects upon his life to a stranger.',
      'quotes': [
        '"You know what charm is: a way of getting the answer yes without '
            'having asked any clear question."',
        '"I used to advertise my loyalty and I don\'t believe there is a '
            'single person I loved that I didn\'t eventually betray."',
        '"People hasten to judge in order not to be judged themselves."',
      ],
    },
    'Villette': {
      'author': 'Charlotte Brontë',
      'year': '1853',
      'summary': 'After an unspecified family disaster, the protagonist '
          'Lucy Snowe travels from her native England to the fictional '
          'French-speaking city of Villette to teach at a girls\' school, '
          'where she is drawn into adventure and romance.',
      'quotes': [
        '"Life is so constructed, that the event does not, cannot, will not, '
            'match the expectation."',
        '"Silence is of different kinds, and breathes different meanings."',
        '"I believe in some blending of hope and sunshine sweetening the '
            'worst lots."',
      ],
    },
    'Little Women': {
      'author': 'Louisa May Alcott',
      'year': '1868',
      'summary': 'Following the lives of the four March sisters—Meg, Jo, '
          'Beth and Amy—the novel details their passage from childhood to '
          'womanhood and is loosely based on the author and her three sisters.',
      'quotes': [
        '"I like good strong words that mean something…"',
        '"I am not afraid of storms, for I am learning how to sail my ship."',
        '"I\'d rather take coffee than compliments just now."',
      ],
    },
    'Middlemarch': {
      'author': 'George Eliot (Mary Ann Evans)',
      'year': '1871',
      'summary': 'Middlemarch is set in the fictitious Midlands town of '
          'Middlemarch during 1829–1832, and follows several distinct, '
          'intersecting stories with a large cast of characters.',
      'quotes': [
        '"It is a narrow mind which cannot look at a subject from various '
            'points of view."',
        '"It is always fatal to have music or poetry interrupted."',
        '"But what we call our despair is often only the painful eagerness '
            'of unfed hope."',
      ],
    },
    'Nostromo': {
      'author': 'Joseph Conrad',
      'year': '1904',
      'summary': 'Nostromo follows an Italian expatriate who has risen to '
          'his position through his bravery and daring exploits. The story '
          'is set in the mining town of Sulaco, a port in the western region '
          'of an imaginary South American country, Costaguana.',
      'quotes': [
        '"Government in general, any government anywhere, is a thing of '
            'exquisite comicality to a discerning mind."',
        '"That man seems to have a particular talent for being on the spot '
            'whenever there is something picturesque to be done."',
        '"Action is consolatory. It is the enemy of thought and the friend '
            'of flattering illusions."',
      ],
    },
  };
