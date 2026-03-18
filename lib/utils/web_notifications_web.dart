// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

void setupWebNotificationListener(void Function(Map<dynamic, dynamic>) onMessage) {
  html.window.addEventListener('message', (event) {
    final data = (event as html.MessageEvent).data;
    if (data is Map && data['type'] == 'NOTIFICATION_CLICK') {
      onMessage(data);
    }
  });
}
