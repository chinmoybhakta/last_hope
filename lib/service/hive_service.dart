import 'dart:convert';
import 'dart:developer';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:last_hope_ai/data/model/conversation_message.dart';

// Hive Type Adapters
class ConversationAdapter extends TypeAdapter<Conversation> {
  @override
  final typeId = 0;

  @override
  Conversation read(BinaryReader reader) {
    return Conversation.fromMap(jsonDecode(reader.readString()));
  }

  @override
  void write(BinaryWriter writer, Conversation obj) {
    writer.writeString(jsonEncode(obj.toMap()));
  }
}

class ConversationMessageAdapter extends TypeAdapter<ConversationMessage> {
  @override
  final typeId = 1;

  @override
  ConversationMessage read(BinaryReader reader) {
    return ConversationMessage.fromMap(jsonDecode(reader.readString()));
  }

  @override
  void write(BinaryWriter writer, ConversationMessage obj) {
    writer.writeString(jsonEncode(obj.toMap()));
  }
}

class HiveService {
  static final HiveService _instance = HiveService._internal();
  factory HiveService() => _instance;
  HiveService._internal();

  bool _isInitialized = false;

  Future<void> init() async {
    if (_isInitialized) return;

    try {
      await Hive.initFlutter();
      
      // Register adapters only once
      if (!Hive.isAdapterRegistered(0)) {
        Hive.registerAdapter(ConversationAdapter());
      }
      if (!Hive.isAdapterRegistered(1)) {
        Hive.registerAdapter(ConversationMessageAdapter());
      }
      
      _isInitialized = true;
    } catch (e) {
      log('Error initializing Hive: $e');
      rethrow;
    }
  }

  Future<Box<T>> openBox<T>(String name) async {
    await init();
    return await Hive.openBox<T>(name);
  }

  Future<void> closeBox<T>(String name) async {
    if (Hive.isBoxOpen(name)) {
      await Hive.box<T>(name).close();
    }
  }

  Future<void> closeAll() async {
    await Hive.close();
  }
}
