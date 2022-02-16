import 'package:autoconnection/models/model_logdata.dart';
import 'package:flutter_ble_lib/flutter_ble_lib.dart';
import 'dart:typed_data';
import 'dart:convert';

//BLE 장치 정보 저장 클래스
class BleDeviceItem {
  bool sendState = true;
  DateTime lastUpdateTime;
  String deviceName;
  Peripheral peripheral;

  int rssi;
  // 이게 Broadcasting Data 온도/습도 저장
  AdvertisementData advertisementData;
  // advertisementData.manufacturerData 이게 진짜 브로드캐스팅 데이터

  String connectionState;
  // 저장된 데이터를 담는 변수
  List<LogData> logDatas = [];
  // 필요x
  String firstPath = '';
  String secondPath = '';
  // 칼리브레이션 저장
  // 온도 칼리
  int cali = 0;
  // 습도 칼리
  int humi_cali = 0;

  BleDeviceItem(this.deviceName, this.rssi, this.peripheral,
      this.advertisementData, this.connectionState);

  getTemperature() {
    int tmp = ByteData.sublistView(
            this.advertisementData.manufacturerData.sublist(12, 14))
        .getInt16(0, Endian.big);
    // print(tmp);
    // lastUpdateTime = DateTime.now();
    tmp += cali;
    return tmp / 100;
  }

  getHumidity() {
    int tmp = ByteData.sublistView(
            this.advertisementData.manufacturerData.sublist(14, 16))
        .getInt16(0, Endian.big);
    // print(tmp);
    tmp += humi_cali;
    return tmp / 100;
  }

  getBattery() {
    int tmp = ByteData.sublistView(
            this.advertisementData.manufacturerData.sublist(16, 17))
        .getUint8(0);
    return tmp;
  }

  getDeviceId() {
    if (this.deviceName != 'T301') {
      return this.deviceName;
    }
    String tmpString = this.getserialNumber();
    String tmp = ByteData.sublistView(
            this.advertisementData.manufacturerData.sublist(7, 9))
        .getUint16(0)
        .toString();
    String tmp2 = ByteData.sublistView(
            this.advertisementData.manufacturerData.sublist(9, 10))
        .getUint8(0)
        .toString();
    int tmps = int.parse(tmp);
    int tmps2 = int.parse(tmp2);
    String result = tmps.toRadixString(16);
    if (tmps2 < 10) {
      // 여섯자리 맞춰주려고  예를들어 F 로 반환되는 값을 0F 로 수정.
      result += '0' + tmps2.toRadixString(16);
    } else {
      result += tmps2.toRadixString(16);
    }
    // 서버에 보낼때 사용하는 이름.
    return 'Sensor_' + tmpString;
  }

  String getserialNumber() {
    String tmp = ByteData.sublistView(
            this.advertisementData.manufacturerData.sublist(7, 8))
        .getUint8(0)
        .toString();
    String tmp2 = ByteData.sublistView(
            this.advertisementData.manufacturerData.sublist(8, 9))
        .getUint8(0)
        .toString();
    String tmp3 = ByteData.sublistView(
            this.advertisementData.manufacturerData.sublist(9, 10))
        .getUint8(0)
        .toString();
    int tmps = int.parse(tmp);
    int tmps2 = int.parse(tmp2);
    int tmps3 = int.parse(tmp3);
    String result = '';

    if (tmps < 16) {
      result += '0' + tmps.toRadixString(16);
    } else {
      result += tmps.toRadixString(16);
    }
    if (tmps2 < 16) {
      result += '0' + tmps2.toRadixString(16);
    } else {
      result += tmps2.toRadixString(16);
    }
    if (tmps3 < 16) {
      result += '0' + tmps3.toRadixString(16);
    } else {
      result += tmps3.toRadixString(16);
    }
    // print(result.length.toString());
    return result.toUpperCase();
  }

  getMacAddress() {
    Uint8List macAddress =
        this.advertisementData.manufacturerData.sublist(4, 10);
    return macAddress;
  }
}

class Data {
  String lat;
  String lng;
  String deviceName;
  String temper;
  String humi;
  String time;
  String battery;
  String lex;

  Data(
      {this.deviceName,
      this.humi,
      this.lat,
      this.lng,
      this.temper,
      this.time,
      this.lex,
      this.battery});
}
