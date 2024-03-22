import 'package:flutter/material.dart';

class NavigatorService {
  static final navKey = GlobalKey<NavigatorState>();
  static NavigatorState get navigator => navKey.currentState!;
}
