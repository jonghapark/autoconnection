import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

final String TableName = 'DeviceInfo';

class DeviceInfo {
  List<LogData> logDatas;

  String macAddress;
  DateTime lastUpdate;

  DeviceInfo({this.macAddress, this.lastUpdate});
}

class LogData {
  double temperature;
  double humidity;
  DateTime timestamp;
  LogData({this.humidity, this.temperature, this.timestamp});
}

class DBHelper {
  DBHelper._();
  static final DBHelper _db = DBHelper._();
  factory DBHelper() => _db;

  static Database _database;

  Future<Database> get database async {
    if (_database != null) return _database;

    _database = await initDB();
    return _database;
  }

  initDB() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'DeviceInfo2.db');
    print('init');

    return await openDatabase(path, version: 1, onCreate: (db, version) async {
      await db.execute('''
          CREATE TABLE $TableName(
            id INTEGER PRIMARY KEY,
            mac TEXT,
            lastUpdate TEXT
          )
        ''');
    }, onUpgrade: (db, oldVersion, newVersion) {});
  }

  //Create
  createData(DeviceInfo device) async {
    final db = await database;
    // print(device.macAddress);
    var res = await db.rawInsert(
        'INSERT INTO $TableName(mac, lastUpdate) VALUES(?,?)',
        [device.macAddress, device.lastUpdate.toString()]);
    return res;
  }

  //Read
  getDevice(String macAddress) async {
    final db = await database;
    print('이거 검색함 ' + macAddress.toUpperCase());
    var res = await db.rawQuery(
        'SELECT * FROM $TableName WHERE mac = ?', [macAddress.toUpperCase()]);
    return res.isNotEmpty
        ? DeviceInfo(
            macAddress: res.first['mac'],
            lastUpdate: DateTime.parse(res.first['lastUpdate']))
        : DeviceInfo(
            macAddress: '123',
            lastUpdate: DateTime.now().toLocal().subtract(Duration(days: 300)));
  }

  //Update-name
  updateLastUpdate(String macAddress, DateTime lastUpdate) async {
    final db = await database;
    print('lastUpdate !');
    var res = await db.rawUpdate(
        'UPDATE $TableName SET lastUpdate = ? WHERE mac = ?',
        [lastUpdate.toString(), macAddress.toUpperCase()]);
  }

  //Read All
  Future<List<DeviceInfo>> getAllDevices() async {
    final db = await database;
    // print('Get all Devices Data');
    var res = await db.rawQuery('SELECT * FROM $TableName');
    List<DeviceInfo> list = res.isNotEmpty
        ? res
            .map((c) => DeviceInfo(
                macAddress: res.first['mac'],
                lastUpdate: res.first['lastUpdate']))
            .toList()
        : [];
    // print(list[0].macAddress);
    return list;
  }

  //Delete
  deleteDevice(String macAddress) async {
    final db = await database;
    var res =
        db.rawDelete('DELETE FROM $TableName WHERE mac = ?', [macAddress]);
    // print('DeleteDevice');
    return res;
  }
}
