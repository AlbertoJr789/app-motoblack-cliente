import 'package:http/http.dart' as http;
import 'package:webfeed_plus/webfeed_plus.dart';

class RssController {
  static const String _g1RssUrl = 'https://g1.globo.com/rss/g1/transito';

  Future<List<RssItem>> getG1News() async {
    try {
      final response = await http.get(Uri.parse(_g1RssUrl));
      if (response.statusCode == 200) {
        final feed = RssFeed.parse(response.body);
        return feed.items ?? [];
      }
      return [];
    } catch (e) {
      print('Error fetching RSS feed: $e');
      return [];
    }
  }
} 