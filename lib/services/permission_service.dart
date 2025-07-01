import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  Future<void> requestStoragePermissions() async {
    if (await Permission.storage.isDenied ||
        await Permission.storage.isPermanentlyDenied) {
      await Permission.storage.request();
    }

    if (await Permission.manageExternalStorage.isDenied) {
      await Permission.manageExternalStorage.request();
    }

    var status = await Permission.storage.status;
    if (status.isDenied || status.isPermanentlyDenied) {
      // You can uncomment this to open app settings if needed
      // await openAppSettings();
    }
  }

  Future<bool> hasStoragePermission() async {
    var storageStatus = await Permission.storage.status;
    var externalStorageStatus = await Permission.manageExternalStorage.status;
    
    return storageStatus.isGranted || externalStorageStatus.isGranted;
  }
} 