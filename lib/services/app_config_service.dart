import 'package:cloud_firestore/cloud_firestore.dart';

class AppConfigData {
  final String appName;
  final bool maintenanceMode;
  final String logoPath;

  const AppConfigData({
    required this.appName,
    required this.maintenanceMode,
    this.logoPath = '',
  });
}

class AppConfigService {
  static const String _collection = 'admin_config';
  static const String _docId = 'branding';
  static const String defaultAppName = 'Tekzo';

  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  static DocumentReference<Map<String, dynamic>> get _docRef =>
      _db.collection(_collection).doc(_docId);

  static AppConfigData _fromSnapshot(
    DocumentSnapshot<Map<String, dynamic>> snapshot, {
    String fallbackAppName = defaultAppName,
  }) {
    final data = snapshot.data() ?? const <String, dynamic>{};
    final appName = data['appName']?.toString().trim() ?? '';
    final maintenanceMode = data['maintenanceMode'] == true;
    final logoPath = data['logoPath']?.toString().trim() ?? '';
    return AppConfigData(
      appName: appName.isEmpty ? fallbackAppName : appName,
      maintenanceMode: maintenanceMode,
      logoPath: logoPath,
    );
  }

  static Stream<String> appNameStream({String fallback = defaultAppName}) {
    return _docRef.snapshots().map(
      (snapshot) => _fromSnapshot(snapshot, fallbackAppName: fallback).appName,
    );
  }

  static Stream<bool> maintenanceModeStream() {
    return _docRef.snapshots().map((snapshot) {
      return _fromSnapshot(snapshot).maintenanceMode;
    });
  }

  static Stream<AppConfigData> configStream() {
    return _docRef.snapshots().map(_fromSnapshot);
  }

  static Future<String> fetchAppName({String fallback = defaultAppName}) async {
    final snapshot = await _docRef.get();
    final value = snapshot.data()?['appName']?.toString().trim() ?? '';
    return value.isEmpty ? fallback : value;
  }

  static Future<void> saveAppName(String appName) async {
    await saveAppConfig(appName: appName);
  }

  static Future<void> saveMaintenanceMode(bool maintenanceMode) async {
    await saveAppConfig(maintenanceMode: maintenanceMode);
  }

  static Future<void> saveAppConfig({
    String? appName,
    bool? maintenanceMode,
    String? logoPath,
  }) async {
    final data = <String, dynamic>{'updatedAt': FieldValue.serverTimestamp()};

    if (appName != null) {
      data['appName'] = appName.trim();
    }

    if (maintenanceMode != null) {
      data['maintenanceMode'] = maintenanceMode;
    }

    if (logoPath != null) {
      data['logoPath'] = logoPath.trim();
    }

    await _docRef.set(data, SetOptions(merge: true));
  }
}
