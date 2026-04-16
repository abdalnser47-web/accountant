import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'dart:io';
import '../../../data/datasources/local/app_database.dart';

class DriftService {
  DriftService._();
  static final DriftService instance = DriftService._();
  late AppDatabase _db;

  Future<void> init() async {
    final dir = await getApplicationDocumentsDirectory();
    final path = p.join(dir.path, '${DbConstants.dbName}.sqlite');
    _db = AppDatabase(_nativeConnection(File(path)));
  }

  AppDatabase get db => _db;

  NativeDatabase _nativeConnection(File file) {
    return NativeDatabase.createInBackground(file);
  }

  Future<void> close() async => await _db.close();
}
