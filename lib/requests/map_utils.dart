import 'package:url_launcher/url_launcher.dart';

class MapUtils {
  MapUtils._();

  static Future<void> openMap (double lat, double long) async {
    Uri googleMapUrl = Uri.parse("https://www.google.com/maps/search/?api=1&query=$lat,$long");
    if (await canLaunchUrl(googleMapUrl)) {
      await launchUrl(googleMapUrl);
    } else {
      throw 'Could not open the map.';
    }
  }
}