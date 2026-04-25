import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

class EmailService {
  static Future<void> sendSosEmail(double lat, double lon) async {
    // 1. Setup the SMTP Server (using Gmail as an example)
    String username = 'shailendraqutex@gmail.com';
    String password = 'ycgmfolibtwhwhuw';

    final smtpServer = gmail(username, password);

    final message = Message()
      ..from = Address(username, 'women security')
      ..recipients.add(
        'coderpro94@gmail.com',
      ) // Replace with actual guardian email
      ..subject = '🚨 EMERGENCY: SOS Triggered!'
      ..text =
          'An SOS has been triggered. My current location is: \n\n'
          'Latitude: $lat \n'
          'Longitude: $lon \n\n'
          'View on Maps: https://www.google.com/maps/search/?api=1&query=$lat,$lon';

    try {
      await send(message, smtpServer);
    } catch (e) {
      print('SMTP Error: $e');
    }
  }
}
