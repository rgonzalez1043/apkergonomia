import 'package:flutter/foundation.dart';

/// The embedded viewers used by this app support web, Android and iOS.
bool get supportsEmbeddedViewers =>
    kIsWeb ||
    defaultTargetPlatform == TargetPlatform.android ||
    defaultTargetPlatform == TargetPlatform.iOS;
