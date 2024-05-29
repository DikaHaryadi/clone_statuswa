import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:statuswa/image_controller.dart';
import 'package:statuswa/theme_controller.dart';
import 'package:video_trimmer/video_trimmer.dart';

class FileUploadScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final ThemeController themeController = Get.put(ThemeController());
    final controller = Get.put(ImageController());
    return Scaffold(
      backgroundColor:
          themeController.isDarkTheme() ? Color(0xFF252525) : Color(0xFFFFFFFF),
      appBar: AppBar(
        title: Text(
          'File Upload',
          style: TextStyle(
              fontSize: 18,
              fontFamily: 'Poppins',
              color: themeController.isDarkTheme()
                  ? Color(0xFFFFFFFF)
                  : Color(0xFF272727)),
        ),
        backgroundColor: themeController.isDarkTheme()
            ? Color(0xFF252525)
            : Color(0xFFFFFFFF),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(4.0),
          child: Container(
            color: Colors.grey, // Set the color of the underline
            height: 1.0, // Set the height of the underline
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              _buildUploadSection(),
              SizedBox(height: 20),
              _buildFileTile('File Sedang Diverifikasi', 138, false),
              SizedBox(height: 20),
              Obx(() => ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: controller.mediaData.length,
                    itemBuilder: (context, index) {
                      MediaData media = controller.mediaData[index];
                      return Stack(children: [
                        Column(
                          children: [
                            media.type == MediaType.image
                                ? Image.file(
                                    File(media.path),
                                    fit: BoxFit.cover,
                                  )
                                : Stack(
                                    children: [
                                      Positioned.fill(
                                        child: VideoViewer(
                                            trimmer: controller.trimmer),
                                      ),
                                      Positioned(
                                        top: 0,
                                        left: 0,
                                        right: 0,
                                        child: Column(
                                          children: [
                                            Align(
                                              alignment: Alignment.centerLeft,
                                              child: IconButton(
                                                onPressed: () {
                                                  controller.clearImages();
                                                  Get.back();
                                                },
                                                icon: const Icon(
                                                  Icons.close,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Align(
                                        alignment: Alignment.center,
                                        child: TextButton(
                                          child: Obx(() {
                                            return controller.isPlaying.value
                                                ? Icon(Icons.pause,
                                                    size: 80.0,
                                                    color: Colors.black)
                                                : Icon(Icons.play_arrow,
                                                    size: 80.0,
                                                    color: Colors.black);
                                          }),
                                          onPressed: () async {
                                            final playbackState =
                                                await controller.trimmer
                                                    .videoPlaybackControl(
                                              startValue:
                                                  controller.startValue.value,
                                              endValue:
                                                  controller.endValue.value,
                                            );
                                            controller.isPlaying.value =
                                                playbackState;
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(child: Text(media.description)),
                                  IconButton(
                                    icon: Icon(Icons.edit, color: Colors.blue),
                                    onPressed: () {},
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        Positioned(
                          top: 10,
                          right: 10,
                          child: IconButton(
                              icon:
                                  Icon(Icons.delete_forever, color: Colors.red),
                              onPressed: () {}),
                        ),
                      ]);
                    },
                    separatorBuilder: (BuildContext context, int index) =>
                        const Divider(),
                  ))
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUploadSection() {
    final ThemeController themeController = Get.put(ThemeController());
    final controller = Get.put(ImageController());
    return Container(
      padding: EdgeInsets.only(
        left: 26,
        right: 26,
        top: 20,
        bottom: 20,
      ),
      decoration: BoxDecoration(
        color: themeController.isDarkTheme() ? Colors.white : Color(0xFF2d2d2d),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              children: <Widget>[
                SizedBox(
                  width: double.infinity,
                  child: Container(
                    // color: Colors.red,
                    child: Text(
                      "Upload Files",
                      textAlign: TextAlign.left,
                      style: TextStyle(
                          fontSize: 16,
                          fontFamily: 'Poppins',
                          color: themeController.isDarkTheme()
                              ? Color(0xFF272727)
                              : Color(0xFFFFFFFF),
                          fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                SizedBox(
                  width: double.infinity,
                  child: Container(
                    // color: Colors.red,
                    child: Text(
                      "Foto atau Video Karyamu",
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        fontSize: 14,
                        fontFamily: 'Poppins',
                        color: themeController.isDarkTheme()
                            ? Color(0xFF272727)
                            : Color(0xFFFFFFFF),
                        // fontWeight: FontWeight.w500),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // SizedBox(width: 16.0),

          Expanded(
            child: GestureDetector(
              onTap: () => controller.selectMedia(),
              child: CustomPaint(
                painter: DashedRectPainter(),
                child: Center(
                  child: Container(
                    // color: themeController.isDarkTheme()
                    //     ? Color(0xFFFFE27D)
                    //     : Color(0xFF997700),
                    height: 90,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          color: themeController.isDarkTheme()
                              ? Color(0xFF272727)
                              : Color(0xFFFFFFFF),
                          Icons.drive_file_move,
                          size: 70,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFileTile(String fileName, int fileSize, bool uploadSuccess) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: uploadSuccess ? Color(0xFF4FCF3A) : Color(0xFFCF3A3A),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(Icons.insert_drive_file),
              SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    fileName,
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                  Text(
                    'Total Karya Yang Sedang \n Diverifikasi Admin MBtech: $fileSize',
                    style: TextStyle(fontSize: 14),
                  ),
                  if (!uploadSuccess)
                    Text(
                      '',
                      style: TextStyle(fontSize: 14, color: Colors.black),
                    ),
                ],
              ),
            ],
          ),
          IconButton(
            icon: Icon(Icons.next_plan),
            onPressed: () {
              // Handle remove file action
            },
          ),
        ],
      ),
    );
  }
}

class DashedRectPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..color = Color(0xFF997700)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    var dashWidth = 5.0;
    var dashSpace = 5.0;
    double startX = 0;
    double startY = 0;

    while (startX < size.width) {
      canvas.drawLine(
        Offset(startX, 0),
        Offset(startX + dashWidth, 0),
        paint,
      );
      startX += dashWidth + dashSpace;
    }

    while (startY < size.height) {
      canvas.drawLine(
        Offset(size.width, startY),
        Offset(size.width, startY + dashWidth),
        paint,
      );
      startY += dashWidth + dashSpace;
    }

    double endX = size.width;
    double endY = size.height;

    while (endX > 0) {
      canvas.drawLine(
        Offset(endX, size.height),
        Offset(endX - dashWidth, size.height),
        paint,
      );
      endX -= dashWidth + dashSpace;
    }

    while (endY > 0) {
      canvas.drawLine(
        Offset(0, endY),
        Offset(0, endY - dashWidth),
        paint,
      );
      endY -= dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
