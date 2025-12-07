// main.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:injera/app/injera_app.dart';

void main() {
  runApp(const ProviderScope(child: InjeraApp()));
}
