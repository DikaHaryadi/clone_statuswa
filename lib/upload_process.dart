import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:statuswa/image_controller.dart';
import 'package:video_player/video_player.dart';

class UploadProcess extends GetView<ImageController> {
  const UploadProcess({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: Stack(
            children: [
              Positioned.fill(
                child: Obx(() {
                  final selectedMedia = controller.selectedMediaData.value;
                  if (selectedMedia != null) {
                    if (selectedMedia.type == MediaType.video) {
                      final videoController =
                          controller.selectedVideoPlayerController.value;
                      if (videoController != null &&
                          videoController.value.isInitialized) {
                        return Stack(
                          children: [
                            Positioned.fill(
                              top: 15,
                              child: VideoPlayer(videoController),
                            ),
                            Positioned(
                              top: 0,
                              right: 0,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  IconButton(
                                    onPressed: () {
                                      final selectedIndex = controller.mediaData
                                          .indexOf(controller
                                              .selectedMediaData.value!);
                                      // Hentikan pemutaran video jika sedang diputar
                                      if (controller.isPlaying.value) {
                                        final videoController = controller
                                            .selectedVideoPlayerController
                                            .value;
                                        if (videoController != null &&
                                            videoController.value.isPlaying) {
                                          videoController.pause();
                                          controller.isPlaying.value = false;
                                        }
                                      }
                                      // Edit media
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
                                onPressed: () {
                                  if (videoController.value.isPlaying) {
                                    videoController.pause();
                                    controller.isPlaying.value = false;
                                  } else {
                                    videoController.play();
                                    controller.isPlaying.value = true;
                                  }
                                },
                              ),
                            ),
                          ],
                        );
                      } else {
                        // Inisialisasi belum selesai, tampilkan progress indicator
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                    } else if (selectedMedia.type == MediaType.image) {
                      return Column(
                        children: [
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
                              fit: BoxFit.fitWidth,
                            ),
                          ),
                        ],
                      );
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
                                  onTap: () async {
                                    controller.selectedMediaData.value = media;
                                    controller.description.text =
                                        media.description;
                                    if (media.type == MediaType.video) {
                                      final videoController = controller
                                          .videoPlayerControllers[index];
                                      if (videoController != null) {
                                        if (videoController !=
                                            controller
                                                .selectedVideoPlayerController
                                                .value) {
                                          // Hanya inisialisasi jika video yang dipilih berbeda dengan yang sedang diputar
                                          await videoController.initialize();
                                          controller
                                              .selectedVideoPlayerController
                                              .value = videoController;
                                          controller.isPlaying.value = false;
                                        }
                                      }
                                    }
                                    controller.update(); // Ensure UI updates
                                  },
                                  child: Container(
                                    width: 50,
                                    height: 50,
                                    margin: const EdgeInsets.only(right: 5.0),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: isSelected
                                            ? const Color.fromARGB(
                                                184, 186, 162, 5)
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
                                                child: Text('Processing'),
                                              ), // Placeholder for thumbnail loading
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
                              controller.clearImages();
                              Get.snackbar(
                                  'Berhasil', 'oke mantap udah di save');
                            },
                            child: const Text('UPLOAD'),
                          ),
                        ],
                      ),
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
