import 'package:xml_parser/xml_parser.dart';

bool validateItems(List<XmlElement> items) {
  assert(items != null);

  if (items.length != 30) return false;

  bool valid = true;

  for (int i = 0; i < 30; i++) {
    final XmlElement item = items[i];

    final Map<String, String> values = itemValues[i];

    if (item.getChild('title').text != values['title']) {
      print('[validateHackerNewsItems] item.getChild(\'title\').text != values[\'title\']');
      print('EXPECTED: ${values['title']}');
      print('ACTUAL: ${item.getChild('title').text}');
      valid = false;
      break;
    }

    if (item.getChild('link').text != values['link']) {
      print('[validateHackerNewsItems] item.getChild(\'link\').text != values[\'link\']');
      print('EXPECTED: ${values['link']}');
      print('ACTUAL: ${item.getChild('link').text}');
      valid = false;
      break;
    }

    if (item.getChild('pubDate').text != values['pubDate']) {
      print('[validateHackerNewsItems] item.getChild(\'pubDate\').text != values[\'pubDate\']');
      print('EXPECTED: ${values['pubDate']}');
      print('ACTUAL: ${item.getChild('pubDate').text}');
      valid = false;
      break;
    }

    if (item.getChild('comments').text != values['comments']) {
      print('[validateHackerNewsItems] item.getChild(\'comments\').text != values[\'comments\']');
      print('EXPECTED: ${values['comments']}');
      print('ACTUAL: ${item.getChild('comments').text}');
      valid = false;
      break;
    }

    if (item.getChild('description').children.first.toString() !=
        values['description']) {
      print('[validateHackerNewsItems] item.getChild(\'description\').text != values[\'description\']');
      print('EXPECTED: ${values['description']}');
      print('ACTUAL: ${item.getChild('description').children.first.toString()}');
      valid = false;
      break;
    }
  }

  return valid;
}

const List<Map<String, String>> itemValues = <Map<String, String>>[
  <String, String>{
    'title': 'Who Owns Huawei?',
    'link': 'https://papers.ssrn.com/sol3/papers.cfm?abstract_id=3372669',
    'pubDate': 'Fri, 9 Aug 2019 22:33:16 +0000',
    'comments': 'https://news.ycombinator.com/item?id=20658739',
    'description': '<![CDATA[<a href="https://news.ycombinator.com/item?id=20658739">Comments</a>]]>',
  },
  <String, String>{
    'title': 'Home Chip Fab',
    'link': 'http://sam.zeloof.xyz/category/semiconductor/',
    'pubDate': 'Fri, 9 Aug 2019 19:09:33 +0000',
    'comments': 'https://news.ycombinator.com/item?id=20657398',
    'description': '<![CDATA[<a href="https://news.ycombinator.com/item?id=20657398">Comments</a>]]>',
  },
  <String, String>{
    'title': 'Alan Kay&#x27;s answer to ‘what are some forgotten books programmers should read?’',
    'link': 'https://www.quora.com/Experienced-programmers-and-computer-scientists-what-are-some-really-old-or-even-nearly-forgotten-books-you-think-every-new-programmer-should-read/answer/Alan-Kay-11?share=1',
    'pubDate': 'Fri, 9 Aug 2019 11:55:20 +0000',
    'comments': 'https://news.ycombinator.com/item?id=20653453',
    'description': '<![CDATA[<a href="https://news.ycombinator.com/item?id=20653453">Comments</a>]]>',
  },
  <String, String>{
    'title': 'Google to Offer a Best Price Guarantee on Certain Flights',
    'link': 'https://www.blog.google/products/flights-hotels/best-prices-for-your-trips/',
    'pubDate': 'Fri, 9 Aug 2019 16:17:05 +0000',
    'comments': 'https://news.ycombinator.com/item?id=20655710',
    'description': '<![CDATA[<a href="https://news.ycombinator.com/item?id=20655710">Comments</a>]]>',
  },
  <String, String>{
    'title': 'Emperor Norton',
    'link': 'https://en.wikipedia.org/wiki/Emperor_Norton',
    'pubDate': 'Fri, 9 Aug 2019 08:49:37 +0000',
    'comments': 'https://news.ycombinator.com/item?id=20652399',
    'description': '<![CDATA[<a href="https://news.ycombinator.com/item?id=20652399">Comments</a>]]>',
  },
  <String, String>{
    'title': 'Coinbase: Responding to Firefox 0-days in the wild',
    'link': 'https://blog.coinbase.com/responding-to-firefox-0-days-in-the-wild-d9c85a57f15b',
    'pubDate': 'Fri, 9 Aug 2019 17:48:11 +0000',
    'comments': 'https://news.ycombinator.com/item?id=20656680',
    'description': '<![CDATA[<a href="https://news.ycombinator.com/item?id=20656680">Comments</a>]]>',
  },
  <String, String>{
    'title': 'Hundreds of exposed Amazon cloud backups found leaking sensitive data',
    'link': 'https://techcrunch.com/2019/08/09/aws-ebs-cloud-backups-leak',
    'pubDate': 'Fri, 9 Aug 2019 18:57:52 +0000',
    'comments': 'https://news.ycombinator.com/item?id=20657308',
    'description': '<![CDATA[<a href="https://news.ycombinator.com/item?id=20657308">Comments</a>]]>',
  },
  <String, String>{
    'title': 'Black Hat: GDPR privacy law exploited to reveal personal data',
    'link': 'https://www.bbc.co.uk/news/technology-49252501',
    'pubDate': 'Thu, 8 Aug 2019 17:29:25 +0000',
    'comments': 'https://news.ycombinator.com/item?id=20646540',
    'description': '<![CDATA[<a href="https://news.ycombinator.com/item?id=20646540">Comments</a>]]>',
  },
  <String, String>{
    'title': 'Huntington Park’s “RoboCop” stores pedestrians’ faces, scans license plates',
    'link': 'https://www.muckrock.com/news/archives/2019/aug/05/california-hp-robocop/',
    'pubDate': 'Fri, 9 Aug 2019 11:59:32 +0000',
    'comments': 'https://news.ycombinator.com/item?id=20653485',
    'description': '<![CDATA[<a href="https://news.ycombinator.com/item?id=20653485">Comments</a>]]>',
  },
  <String, String>{
    'title': 'The World’s Smartest Chimp Has Died',
    'link': 'https://www.nytimes.com/2019/08/09/opinion/chimpanzee-sarah.html',
    'pubDate': 'Fri, 9 Aug 2019 21:55:36 +0000',
    'comments': 'https://news.ycombinator.com/item?id=20658529',
    'description': '<![CDATA[<a href="https://news.ycombinator.com/item?id=20658529">Comments</a>]]>',
  },
  <String, String>{
    'title': 'War on the rocks: The coming automation of propaganda',
    'link': 'https://warontherocks.com/2019/08/the-coming-automation-of-propaganda/',
    'pubDate': 'Fri, 9 Aug 2019 09:13:41 +0000',
    'comments': 'https://news.ycombinator.com/item?id=20652572',
    'description': '<![CDATA[<a href="https://news.ycombinator.com/item?id=20652572">Comments</a>]]>',
  },
  <String, String>{
    'title': 'The Erlang Rationale',
    'link': 'https://rvirding.blogspot.com/2019/01/the-erlang-rationale.html',
    'pubDate': 'Fri, 9 Aug 2019 11:46:42 +0000',
    'comments': 'https://news.ycombinator.com/item?id=20653394',
    'description': '<![CDATA[<a href="https://news.ycombinator.com/item?id=20653394">Comments</a>]]>',
  },
  <String, String>{
    'title': 'Buckminster Fuller might be just the vision we need',
    'link': 'https://cdm.link/2019/08/42-hours-of-buckminster-fuller/',
    'pubDate': 'Fri, 9 Aug 2019 22:46:00 +0000',
    'comments': 'https://news.ycombinator.com/item?id=20658816',
    'description': '<![CDATA[<a href="https://news.ycombinator.com/item?id=20658816">Comments</a>]]>',
  },
  <String, String>{
    'title': 'Kubernetes Security Assessment [pdf]',
    'link': 'https://github.com/kubernetes/community/blob/master/wg-security-audit/findings/Kubernetes%20Final%20Report.pdf',
    'pubDate': 'Fri, 9 Aug 2019 15:05:17 +0000',
    'comments': 'https://news.ycombinator.com/item?id=20655017',
    'description': '<![CDATA[<a href="https://news.ycombinator.com/item?id=20655017">Comments</a>]]>',
  },
  <String, String>{
    'title': 'Solar Powered Raspberry Pi Camera',
    'link': 'https://kaspars.net/blog/solar-raspberry-pi-camera',
    'pubDate': 'Fri, 9 Aug 2019 18:47:17 +0000',
    'comments': 'https://news.ycombinator.com/item?id=20657224',
    'description': '<![CDATA[<a href="https://news.ycombinator.com/item?id=20657224">Comments</a>]]>',
  },
  <String, String>{
    'title': 'Holidays are good for workers and companies alike',
    'link': 'https://www.economist.com/business/2019/08/08/holidays-are-good-for-workers-and-companies-alike',
    'pubDate': 'Fri, 9 Aug 2019 20:59:28 +0000',
    'comments': 'https://news.ycombinator.com/item?id=20658214',
    'description': '<![CDATA[<a href="https://news.ycombinator.com/item?id=20658214">Comments</a>]]>',
  },
  <String, String>{
    'title': 'The Suicides in South Korea, and the Suicide of South Korea',
    'link': 'http://blog.lareviewofbooks.org/the-korea-blog/suicides-south-korea-suicide-south-korea/',
    'pubDate': 'Fri, 9 Aug 2019 20:41:16 +0000',
    'comments': 'https://news.ycombinator.com/item?id=20658090',
    'description': '<![CDATA[<a href="https://news.ycombinator.com/item?id=20658090">Comments</a>]]>',
  },
  <String, String>{
    'title': 'A journalist discovered and reunited identical twins',
    'link': 'https://www.latimes.com/world-nation/story/2019-08-07/how-a-journalist-discovered-and-reunited-identical-twins',
    'pubDate': 'Fri, 9 Aug 2019 16:22:50 +0000',
    'comments': 'https://news.ycombinator.com/item?id=20655766',
    'description': '<![CDATA[<a href="https://news.ycombinator.com/item?id=20655766">Comments</a>]]>',
  },
  <String, String>{
    'title': '‘No One Saw a Thing’: When a Midwest Town Banded Together to Kill the Town Bully',
    'link': 'https://www.thedailybeast.com/no-one-saw-a-thing-when-a-small-midwest-town-banded-together-to-kill-the-town-bully',
    'pubDate': 'Fri, 9 Aug 2019 17:05:03 +0000',
    'comments': 'https://news.ycombinator.com/item?id=20656241',
    'description': '<![CDATA[<a href="https://news.ycombinator.com/item?id=20656241">Comments</a>]]>',
  },
  <String, String>{
    'title': 'Summer camps use facial recognition so parents can watch from home',
    'link': 'https://www.sfgate.com/news/article/Summer-camps-use-facial-recognition-so-parents-14291272.php',
    'pubDate': 'Thu, 8 Aug 2019 22:26:06 +0000',
    'comments': 'https://news.ycombinator.com/item?id=20649504',
    'description': '<![CDATA[<a href="https://news.ycombinator.com/item?id=20649504">Comments</a>]]>',
  },
  <String, String>{
    'title': '“Carpe Diem” Got Lost in Translation',
    'link': 'https://daily.jstor.org/how-carpe-diem-got-lost-in-translation/',
    'pubDate': 'Thu, 8 Aug 2019 17:00:33 +0000',
    'comments': 'https://news.ycombinator.com/item?id=20646249',
    'description': '<![CDATA[<a href="https://news.ycombinator.com/item?id=20646249">Comments</a>]]>',
  },
  <String, String>{
    'title': 'Rice University researchers propose a way to boost solar efficiency',
    'link': 'https://polyarch.co/rice-university-research-heat-into-light/',
    'pubDate': 'Fri, 9 Aug 2019 18:12:22 +0000',
    'comments': 'https://news.ycombinator.com/item?id=20656929',
    'description': '<![CDATA[<a href="https://news.ycombinator.com/item?id=20656929">Comments</a>]]>',
  },
  <String, String>{
    'title': 'A Mexican Hospital, an American Surgeon, and a \$5k Check',
    'link': 'https://www.nytimes.com/2019/08/09/business/medical-tourism-mexico.html',
    'pubDate': 'Fri, 9 Aug 2019 21:12:39 +0000',
    'comments': 'https://news.ycombinator.com/item?id=20658291',
    'description': '<![CDATA[<a href="https://news.ycombinator.com/item?id=20658291">Comments</a>]]>',
  },
  <String, String>{
    'title': 'OneSignal raised a \$25M Series B and is hiring a Distributed Systems Architect',
    'link': 'https://onesignal.com/careers#distributed_systems_architect',
    'pubDate': 'Sat, 10 Aug 2019 00:11:37 +0000',
    'comments': 'https://news.ycombinator.com/item?id=20659286',
    'description': '<![CDATA[<a href="https://news.ycombinator.com/item?id=20659286">Comments</a>]]>',
  },
  <String, String>{
    'title': 'The New Lion King trailer style transformed to resemble the animated version',
    'link': 'http://geekdommovies.com/heres-what-the-live-action-lion-king-would-look-like-if-the-cgi-was-closer-to-the-original-animated-movie/',
    'pubDate': 'Fri, 9 Aug 2019 23:00:46 +0000',
    'comments': 'https://news.ycombinator.com/item?id=20658901',
    'description': '<![CDATA[<a href="https://news.ycombinator.com/item?id=20658901">Comments</a>]]>',
  },
  <String, String>{
    'title': 'Climate change: Marine heatwaves kill coral instantly',
    'link': 'https://www.bbc.com/news/science-environment-49255642',
    'pubDate': 'Fri, 9 Aug 2019 14:34:39 +0000',
    'comments': 'https://news.ycombinator.com/item?id=20654706',
    'description': '<![CDATA[<a href="https://news.ycombinator.com/item?id=20654706">Comments</a>]]>',
  },
  <String, String>{
    'title': '‘To Get Things More Real’: An Interview with Ira Glass',
    'link': 'https://www.nybooks.com/daily/2019/08/08/to-get-things-more-real-an-interview-with-ira-glass/',
    'pubDate': 'Thu, 8 Aug 2019 22:37:09 +0000',
    'comments': 'https://news.ycombinator.com/item?id=20649600',
    'description': '<![CDATA[<a href="https://news.ycombinator.com/item?id=20649600">Comments</a>]]>',
  },
  <String, String>{
    'title': 'Open-source firmware',
    'link': 'https://mullvad.net/ja/blog/2019/8/7/open-source-firmware-future/',
    'pubDate': 'Fri, 9 Aug 2019 11:32:42 +0000',
    'comments': 'https://news.ycombinator.com/item?id=20653316',
    'description': '<![CDATA[<a href="https://news.ycombinator.com/item?id=20653316">Comments</a>]]>',
  },
  <String, String>{
    'title': 'Free Software network services and web applications which can be hosted locally',
    'link': 'https://github.com/Kickball/awesome-selfhosted',
    'pubDate': 'Fri, 9 Aug 2019 22:37:14 +0000',
    'comments': 'https://news.ycombinator.com/item?id=20658765',
    'description': '<![CDATA[<a href="https://news.ycombinator.com/item?id=20658765">Comments</a>]]>',
  },
  <String, String>{
    'title': 'Show HN: Tailwind.run – An Online Playground for Tailwind CSS',
    'link': 'https://tailwind.run',
    'pubDate': 'Fri, 9 Aug 2019 13:12:30 +0000',
    'comments': 'https://news.ycombinator.com/item?id=20653942',
    'description': '<![CDATA[<a href="https://news.ycombinator.com/item?id=20653942">Comments</a>]]>',
  },
];
