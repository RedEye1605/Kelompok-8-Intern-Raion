import 'package:cloudinary_api/src/response/upload_result.dart';
import 'package:cloudinary_api/uploader/cloudinary_uploader.dart';
import 'package:cloudinary_api/uploader/uploader_response.dart';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:cloudinary_url_gen/cloudinary.dart';
import 'package:cloudinary_api/src/request/model/uploader_params.dart';

class CloudinaryService {
  final CloudinaryPublic cloudinary;

   CloudinaryService()
      : cloudinary = CloudinaryPublic(
        'dak6uyba7', // Cloud name
          'ml_default',
      );

  Future<String?> uploadImage(String filePath) async {
    try {
      CloudinaryResponse response = await cloudinary.uploadFile(
        CloudinaryFile.fromFile(filePath, resourceType: CloudinaryResourceType.Image),
      );
      return response.secureUrl; // Pastikan URL valid
    } catch (e) {
      print("Upload Error: $e");
      return null;
    }
  }
}
