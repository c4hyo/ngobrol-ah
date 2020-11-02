import 'dart:io';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  static StorageReference storage = FirebaseStorage.instance.ref();
  static Future<String> uploadUserPhotoImage(String url, File imageFile,
      {String category}) async {
    String photoId = Uuid().v4();
    File image = await compressImage(photoId, imageFile);
    if (url.isNotEmpty) {
      RegExp exp = RegExp(r'userProfile_(.*).jpg');
      photoId = exp.firstMatch(url)[1];
    }
    StorageUploadTask uploadTask =
        storage.child('$category/userProfile_$photoId.jpg').putFile(image);
    StorageTaskSnapshot storageTaskSnapshot = await uploadTask.onComplete;
    String downloadUrl = await storageTaskSnapshot.ref.getDownloadURL();
    return downloadUrl;
  }

  static compressImage(String photoId, File image) async {
    final tempDir = await getTemporaryDirectory();
    final path = tempDir.path;

    File compressedImageFile = await FlutterImageCompress.compressAndGetFile(
      image.absolute.path,
      '$path/img_$photoId.jpg',
      quality: 70,
    );
    return compressedImageFile;
  }
}
