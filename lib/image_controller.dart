import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:statuswa/upload_process.dart';
import 'package:video_player/video_player.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:image_editor_plus/image_editor_plus.dart';
import 'package:video_trimmer/video_trimmer.dart';
import 'package:path/path.dart' as path;

class ImageController extends GetxController {
  var mediaData = <MediaData>[].obs;
  var selectedMediaData = Rxn<MediaData>();
  var videoPlayerControllers = <VideoPlayerController?>[].obs;
  var selectedVideoPlayerController = Rxn<VideoPlayerController>();
  var isPlaying = false.obs;

  final pageController = PageController();
  final description = TextEditingController();

  final Trimmer trimmer = Trimmer();
  var startValue = 0.0.obs;
  var endValue = 0.0.obs;
  var progressVisibility = false.obs;

  VideoPlayerController? videoPlayerController;

  Future<void> selectMedia() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.media,
        allowMultiple: true,
        allowCompression: false,
      );

      if (result != null) {
        // Membersihkan mediaData sebelum menambahkan media yang baru
        clearImages();

        List<MediaData> selectedMedia = [];
        List<Future<void>> initializationFutures = [];

        for (var file in result.files) {
          if (file.path != null) {
            MediaType type =
                file.extension == 'mp4' ? MediaType.video : MediaType.image;
            String? thumbnailPath;

            try {
              if (type == MediaType.video) {
                thumbnailPath = await VideoThumbnail.thumbnailFile(
                  video: file.path!,
                  thumbnailPath: (await getTemporaryDirectory()).path,
                  imageFormat: ImageFormat.PNG,
                  maxHeight: 50,
                  quality: 75,
                );

                var controller = VideoPlayerController.file(File(file.path!));
                initializationFutures.add(controller.initialize().then((_) {
                  videoPlayerControllers.add(controller);
                }));
              }
            } catch (e) {
              print('Error generating thumbnail or loading video: $e');
            }

            selectedMedia.add(
              MediaData(file.path!, '', type, thumbnailPath: thumbnailPath),
            );
          }
        }

        // Setelah membersihkan, tambahkan media yang baru
        mediaData.addAll(selectedMedia);

        // Tunggu inisialisasi controller video jika ada
        await Future.wait(initializationFutures);
        update();

        // Set media yang dipilih menjadi media pertama dalam list
        selectedMediaData.value = mediaData.isNotEmpty ? mediaData[0] : null;
        if (selectedMediaData.value?.type == MediaType.video) {
          selectedVideoPlayerController.value =
              videoPlayerControllers.isNotEmpty
                  ? videoPlayerControllers[0]
                  : null;
        }

        // Pindah ke halaman UploadProcess
        await Get.to(() => const UploadProcess());
      }
    } catch (e) {
      print('Error picking media: $e');
    }
  }

  void clearImages() {
    mediaData.clear();
    videoPlayerControllers.forEach((controller) {
      controller
          ?.dispose(); // Memanggil dispose() dengan safe navigation operator
    });
    videoPlayerControllers.clear();
    selectedMediaData.value = null;
    selectedVideoPlayerController.value = null;
    update();
  }

  Future<void> editDescription(BuildContext context, int index) async {
    selectedMediaData.value = mediaData[index];
    description.text = mediaData[index].description;

    await Get.to(() => const UploadProcess());

    final updatedMedia = selectedMediaData.value;
    if (updatedMedia != null && updatedMedia.description.isEmpty) {
      updatedMedia.description = 'Enter Description';
    }

    mediaData[index] = updatedMedia ?? mediaData[index];
    update(); // Update the UI
  }

  void removeImage(int index) {
    if (index < mediaData.length) {
      mediaData.removeAt(index);
      if (mediaData.isNotEmpty) {
        selectedMediaData.value = mediaData[0];
        if (selectedMediaData.value?.type == MediaType.video) {
          selectedVideoPlayerController.value = videoPlayerControllers[0];
        }
      } else {
        selectedMediaData.value = null;
        selectedVideoPlayerController.value = null;
      }
      update();
    }
    // Pastikan untuk memanggil dispose() pada kontroler video yang sesuai
    if (index < videoPlayerControllers.length) {
      videoPlayerControllers[index]!.dispose();
      videoPlayerControllers.removeAt(index);
      if (selectedVideoPlayerController.value != null &&
          index ==
              videoPlayerControllers
                  .indexOf(selectedVideoPlayerController.value!)) {
        selectedVideoPlayerController.value = null;
      }
      update();
    }
  }

  void editMedia(int index) async {
    final media = mediaData[index];
    if (media.type == MediaType.image) {
      try {
        final editedImageBytes = await Get.to(
            () => ImageEditor(image: File(media.path).readAsBytesSync()));
        if (editedImageBytes != null && editedImageBytes is Uint8List) {
          final editedImagePath =
              await saveEditedImage(editedImageBytes, media.path);
          if (File(editedImagePath).existsSync()) {
            print('Edited image file exists.');
            mediaData[index] =
                MediaData(editedImagePath, media.description, MediaType.image);
            selectedMediaData.value = mediaData[index];
            update(); // Update the UI with the edited image
          } else {
            print('Edited image file does not exist.');
          }
        } else {
          print('Edited image is null or not a Uint8List');
        }
      } catch (e) {
        print('Error editing image: $e');
      }
    } else if (media.type == MediaType.video) {
      debugPrint('before');
      final editedVideoFile =
          await Get.toNamed('/video-trim', arguments: File(media.path));
      debugPrint('after');
      if (editedVideoFile != null && editedVideoFile is File) {
        debugPrint('sudah Edit');
        mediaData[index] =
            MediaData(editedVideoFile.path, media.description, MediaType.video);

        // Update thumbnailPath after editing video
        mediaData[index].thumbnailPath =
            await generateVideoThumbnail(editedVideoFile.path);

        selectedMediaData.value = mediaData[index];
        update(); // Update the UI with the edited video

        // Reload VideoPlayerController for the updated video
        if (selectedMediaData.value?.type == MediaType.video) {
          final videoPath = selectedMediaData.value!.path;
          final videoController = VideoPlayerController.file(File(videoPath));
          await videoController.initialize();
          videoPlayerControllers[index]
              ?.dispose(); // Dispose the old controller
          videoPlayerControllers[index] = videoController;
          selectedVideoPlayerController.value = videoController;
          update(); // Ensure UI updates after reloading the video
        }
      }
    }
  }

  void uploadImages() {
    // Implement the functionality to handle uploading the images
    print('Images would be uploaded here');
  }

  Future<String> saveEditedImage(
      Uint8List imageBytes, String originalPath) async {
    final directory = await getApplicationDocumentsDirectory();
    final fileName = path.basename(originalPath);
    final editedImagePath = '${directory.path}/edited_$fileName';
    final file = File(editedImagePath);
    await file.writeAsBytes(imageBytes);
    return editedImagePath;
  }

  Future<String?> generateVideoThumbnail(String videoPath) async {
    try {
      final thumbnailPath = await VideoThumbnail.thumbnailFile(
        video: videoPath,
        thumbnailPath: (await getTemporaryDirectory()).path,
        imageFormat: ImageFormat.PNG,
        maxHeight: 50,
        quality: 75,
      );
      return thumbnailPath;
    } catch (e) {
      print('Error generating video thumbnail: $e');
      return null;
    }
  }

  void _disposeVideoPlayer() {
    if (videoPlayerController != null) {
      videoPlayerController!.pause();
      videoPlayerController!.dispose();
      videoPlayerController = null;
      print('Video player disposed');
    }
  }

  @override
  void onClose() {
    _disposeVideoPlayer();
    mediaData.clear();
    description.dispose();
    super.onClose();
  }
}

class MediaData {
  final String path;
  String description;
  final MediaType type;
  String? thumbnailPath;

  MediaData(this.path, this.description, this.type, {this.thumbnailPath});
}

enum MediaType { image, video }
