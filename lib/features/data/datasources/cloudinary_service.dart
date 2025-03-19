import 'package:cloudinary_public/cloudinary_public.dart';

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
