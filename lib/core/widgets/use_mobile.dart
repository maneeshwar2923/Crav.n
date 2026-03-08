// utility that exposes a small helper to detect mobile width in Flutter

import 'package:flutter/widgets.dart';

bool isMobile(BuildContext context) => MediaQuery.of(context).size.width < 600;
