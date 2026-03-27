import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'dart:typed_data';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox<Uint8List>('offline_tiles'); // box for tile bytes
  await Hive.openBox<Map>('tile_metadata'); // box for region metadata
  runApp(const ProviderScope(child: OfflineMapApp()));
}