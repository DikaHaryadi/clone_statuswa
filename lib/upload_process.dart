import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:statuswa/image_controller.dart';
import 'dart:io';
import 'package:video_trimmer/video_trimmer.dart';

class UploadProcess extends GetView<ImageController> {
  const UploadProcess({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: Stack(
            children: [
              Align(
                alignment: Alignment.topLeft,
                child: IconButton(
                  onPressed: () {
                    controller.clearImages();
                    Get.back();
                  },
                  icon: const Icon(
                    Icons.arrow_back_ios,
                    color: Colors.white,
                  ),
                ),
              ),
              Positioned.fill(
                child: Obx(() {
                  final selectedMedia = controller.selectedMediaData.value;
                  if (selectedMedia != null) {
                    if (selectedMedia.type == MediaType.video) {
                      return Stack(
                        children: [
                          Positioned.fill(
                            child: VideoViewer(trimmer: controller.trimmer),
                          ),
                          Positioned(
                            top: 0,
                            left: 0,
                            right: 0,
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    IconButton(
                                      onPressed: () {
                                        final selectedIndex = controller
                                            .mediaData
                                            .indexOf(controller
                                                .selectedMediaData.value!);
                                        controller.editMedia(selectedIndex);
                                      },
                                      icon: const Icon(
                                        Icons.edit_square,
                                        color: Colors.white,
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: () {
                                        final selectedIndex = controller
                                            .mediaData
                                            .indexOf(controller
                                                .selectedMediaData.value!);
                                        controller.removeImage(selectedIndex);
                                      },
                                      icon: const Icon(
                                        Icons.delete,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
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
                                        size: 80.0, color: Colors.black)
                                    : Icon(Icons.play_arrow,
                                        size: 80.0, color: Colors.black);
                              }),
                              onPressed: () async {
                                final playbackState = await controller.trimmer
                                    .videoPlaybackControl(
                                  startValue: controller.startValue.value,
                                  endValue: controller.endValue.value,
                                );
                                controller.isPlaying.value = playbackState;
                              },
                            ),
                          ),
                        ],
                      );
                    } else if (selectedMedia.type == MediaType.image) {
                      return Column(children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            IconButton(
                              onPressed: () {
                                final selectedIndex = controller.mediaData
                                    .indexOf(
                                        controller.selectedMediaData.value!);
                                controller.editMedia(selectedIndex);
                              },
                              icon: const Icon(
                                Icons.edit_square,
                                color: Colors.white,
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                final selectedIndex = controller.mediaData
                                    .indexOf(
                                        controller.selectedMediaData.value!);
                                controller.removeImage(selectedIndex);
                              },
                              icon: const Icon(
                                Icons.delete,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        Expanded(
                          child: Image.file(
                            File(selectedMedia.path),
                            fit: BoxFit
                                .fitWidth, // Adjust fit based on your design
                          ),
                        )
                      ]);
                    } else {
                      return Center(
                        child: Text(
                            'Unsupported media type: ${selectedMedia.type}'),
                      );
                    }
                  } else {
                    return const Center(child: Text('No media selected'));
                  }
                }),
              ),
              Positioned(
                bottom: 20,
                right: 20,
                left: 20,
                child: Obx(
                  () => Column(
                    children: [
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Align(
                          alignment: Alignment.center,
                          child: Row(
                            children: List.generate(
                              controller.mediaData.length,
                              (index) {
                                final media = controller.mediaData[index];
                                final isSelected =
                                    controller.selectedMediaData.value == media;
                                return GestureDetector(
                                  onTap: () {
                                    controller.selectedMediaData.value = media;
                                    controller.description.text =
                                        media.description;
                                  },
                                  child: Container(
                                    width: 50,
                                    height: 50,
                                    margin: const EdgeInsets.only(right: 5.0),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: isSelected
                                            ? Color.fromARGB(184, 186, 162, 5)
                                            : Colors.transparent,
                                        width: isSelected ? 3.0 : 1.0,
                                      ),
                                    ),
                                    child: media.type == MediaType.image
                                        ? Image.file(File(media.path),
                                            fit: BoxFit.cover)
                                        : media.thumbnailPath != null
                                            ? Image.file(
                                                File(media.thumbnailPath!),
                                                fit: BoxFit.cover)
                                            : const Center(
                                                child: Text(
                                                    'Processing')), // Placeholder for thumbnail loading
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8.0),
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.green.shade200,
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                        child: Row(
                          children: [
                            IconButton(
                              onPressed: () {},
                              icon: const Icon(Icons.abc),
                            ),
                            Expanded(
                              child: TextFormField(
                                controller: controller.description,
                                decoration: const InputDecoration(
                                  hintText: 'Tambahkan keterangan...',
                                  border: InputBorder.none,
                                ),
                                onChanged: (value) {
                                  final selectedMedia =
                                      controller.selectedMediaData.value;
                                  if (selectedMedia != null) {
                                    selectedMedia.description = value;
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              Get.offNamed('/');
                              Get.snackbar(
                                  'Berhasil', 'oke mantap udah di save');
                            },
                            child: Text('UPLOAD'),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
