import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:get/get.dart';
import 'package:imagesproject/Model/imagemodel.dart';
import 'package:imagesproject/controller/imagecontroller.dart';
import 'package:imagesproject/controller/quotecontroller.dart';

class HomeScreen extends StatelessWidget {
  final ImageController imageController = Get.put(ImageController());
  final QuoteController quoteController = Get.put(QuoteController());

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    imageController.loadImages();

    return Scaffold(
      appBar: AppBar(
        title: Text("Image Manager"),
        backgroundColor: Colors.blueAccent,
        elevation: 4.0,
      ),
      body: Padding(
        padding: EdgeInsets.all(width * 0.05),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: width * 0.05),
              child: TextField(
                onChanged: (query) {
                  imageController.searchImages(query);
                },
                decoration: InputDecoration(
                  hintText: "Search by name, type, or date",
                  prefixIcon: Icon(Icons.search, color: Colors.blue),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
            SizedBox(height: height * 0.02),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: GetBuilder<QuoteController>(
                    init: quoteController,
                    builder: (controller) {
                      return Text(
                        "Quote of the Day: ${controller.quote}",
                        style: TextStyle(
                          fontStyle: FontStyle.italic,
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      );
                    },
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.refresh, color: Colors.blue),
                  onPressed: () {
                    quoteController.fetchQuote();
                  },
                ),
              ],
            ),
            SizedBox(height: height * 0.02),
            Expanded(
              child: GetBuilder<ImageController>(
                init: imageController,
                builder: (controller) {
                  return ListView.builder(
                    itemCount: controller.filteredImageList.length,
                    itemBuilder: (context, index) {
                      var image = controller.filteredImageList[index];
                      return Card(
                        margin: EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 4,
                        child: ListTile(
                          contentPadding: EdgeInsets.all(12),
                          title: Text(
                            image.name,
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            '${image.type} - ${image.date}',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(8.0),
                            child: Image.file(
                              File(image.image),
                              width: width * 0.12,
                              height: width * 0.12,
                              fit: BoxFit.cover,
                            ),
                          ),
                          trailing: IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              imageController.deleteImage(image.id!);
                            },
                          ),
                          onTap: () async {
                            _showUpdateDialog(context, image);
                          },
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: width * 0.05),
              child: ElevatedButton.icon(
                onPressed: () async {
                  final ImagePicker picker = ImagePicker();
                  final XFile? pickedImage =
                      await picker.pickImage(source: ImageSource.gallery);
                  if (pickedImage != null) {
                    _showAddImageDialog(context, pickedImage);
                  }
                },
                icon: Icon(Icons.add_a_photo, color: Colors.white),
                label: Text("Add Image", style: TextStyle(fontSize: 16)),
                style: ElevatedButton.styleFrom(
                  primary: Colors.blueAccent,
                  padding: EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddImageDialog(BuildContext context, XFile pickedImage) {
    final nameController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Enter Image Name"),
          content: TextField(
            controller: nameController,
            decoration: InputDecoration(hintText: "Enter name"),
          ),
          actions: [
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.isNotEmpty) {
                  await imageController.addImage(
                      pickedImage, nameController.text, 'JPG');
                  Navigator.of(context).pop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Name is required")));
                }
              },
              child: Text("Add"),
              style: ElevatedButton.styleFrom(
                primary: Colors.blueAccent,
              ),
            ),
          ],
        );
      },
    );
  }

  void _showUpdateDialog(BuildContext context, ImageEntry image) {
    final nameController = TextEditingController(text: image.name);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Update Image Name"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(hintText: "Enter new name"),
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: () async {
                  final ImagePicker picker = ImagePicker();
                  final XFile? pickedImage =
                      await picker.pickImage(source: ImageSource.gallery);
                  if (pickedImage != null) {
                    await imageController.updateImage(
                      image.id!,
                      nameController.text,
                      image.type,
                      image.date,
                      pickedImage.path,
                    );
                    Navigator.of(context).pop();
                  }
                },
                child: Text("Update Image"),
                style: ElevatedButton.styleFrom(
                  primary: Colors.blueAccent,
                ),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                if (nameController.text.isNotEmpty) {
                  imageController.updateImage(
                    image.id!,
                    nameController.text,
                    image.type,
                    image.date,
                    image.image,
                  );
                  Navigator.of(context).pop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Name is required")));
                }
              },
              child: Text("Update Name"),
              style: ElevatedButton.styleFrom(
                primary: Colors.blueAccent,
              ),
            ),
          ],
        );
      },
    );
  }
}
