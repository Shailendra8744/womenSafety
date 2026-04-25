import 'package:flutter/foundation.dart';

/// Override at build time: `--dart-define=API_BASE=http://YOUR_IP/saftey/backend/api`
/// Android emulator: use `http://10.0.2.2/...` to reach the host machine's localhost.
const String kApiBase = String.fromEnvironment(
  'API_BASE',
  defaultValue: kIsWeb
      ? 'https://lime-grouse-758624.hostingersite.com/backend/api'
      : 'http://localhost/saftey/backend/api',
);
