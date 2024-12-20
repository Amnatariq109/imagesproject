import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:imagesproject/Database/database.dart';
import 'package:imagesproject/Model/imagemodel.dart';

class ImageController extends GetxController {
  List<ImageEntry> imageList = [];
  List<ImageEntry> filteredImageList = [];
  @override
  void onInit() {
    super.onInit();
    loadImages();
  }

  void loadImages() async {
    List<Map<String, dynamic>> imagesData =
        await DatabaseHelper.instance.queryAllImages();
    imageList = imagesData.map((e) => ImageEntry.fromMap(e)).toList();
    filteredImageList = List.from(imageList);
    update();
  }

  Future<void> addImage(XFile image, String name, String type) async {
    String date = DateTime.now().toIso8601String();
    Map<String, dynamic> row = {
      'name': name,
      'type': type,
      'date': date,
      'image': image.path,
    };
    await DatabaseHelper.instance.insertImage(row);
    loadImages();
  }

  Future<void> updateImage(
      int id, String name, String type, String date, String image) async {
    Map<String, dynamic> row = {
      '_id': id,
      'name': name,
      'type': type,
      'date': date,
      'image': image,
    };
    await DatabaseHelper.instance.updateImage(row);
    loadImages();
  }

  Future<void> deleteImage(int id) async {
    await DatabaseHelper.instance.deleteImage(id);
    loadImages();
  }

  void searchImages(String query) {
    if (query.isEmpty) {
      filteredImageList = List.from(imageList);
    } else {
      filteredImageList = imageList.where((image) {
        return image.name.toLowerCase().contains(query.toLowerCase()) ||
            image.type.toLowerCase().contains(query.toLowerCase()) ||
            image.date.contains(query);
      }).toList();
    }
    update();
  }
}
