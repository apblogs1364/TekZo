import 'package:flutter/material.dart';

import '../services/app_config_service.dart';

class AppNameText extends StatelessWidget {
  final TextStyle? style;
  final String fallback;
  final TextAlign textAlign;

  const AppNameText({
    Key? key,
    this.style,
    this.fallback = AppConfigService.defaultAppName,
    this.textAlign = TextAlign.start,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<String>(
      stream: AppConfigService.appNameStream(fallback: fallback),
      builder: (context, snapshot) {
        final appName = snapshot.data ?? fallback;
        return Text(appName, style: style, textAlign: textAlign);
      },
    );
  }
}
