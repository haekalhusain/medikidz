import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:imgbb/imgbb.dart';

class ImageUploadService {
  static const String _apiKey = '0d9ce7f81c1fa57cd2850485c63df52d';

  static Future<XFile?> pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    return image;
  }

  static Future<String?> uploadImageToImgBB(XFile imageFile) async {
    try {
      final compressedBytes = await FlutterImageCompress.compressWithFile(
        imageFile.path,
        quality: 70,
      );

      if (compressedBytes == null) {
        return null;
      }

      final tempFile = await File('${Directory.systemTemp.path}/imgbb_${DateTime.now().millisecondsSinceEpoch}.jpg').create();
      await tempFile.writeAsBytes(compressedBytes);

      final imgbb = Imgbb(_apiKey);
      final response = await imgbb.uploadImageFile(
        imageFile: tempFile,
        expiration: 999999,
      );

      await tempFile.delete();

      if (response != null && response.url != null) {
        return response.url.replaceAll('.co/', '.co.com/');
      } else {
        if (kDebugMode) {
          print('Upload gagal: response null');
        }
        return null;
      }
    } catch (e, stack) {
      if (kDebugMode) {
        print('eror upload ke imageBB: $e');
        print(stack.toString());
      }
      return null;
    }
  }
}
