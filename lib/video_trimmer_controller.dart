import 'dart:io';

import 'package:get/get.dart';
import 'package:video_trimmer/video_trimmer.dart';

class VideoTrimController extends GetxController {
  static VideoTrimController get instance => Get.find();
  final Trimmer trimmer = Trimmer();
  RxString result = ''.obs;
  var startValue = 0.0.obs;
  var endValue = 0.0.obs;
  var isPlaying = false.obs;
  var progressVisibility = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadVideo();
  }

  @override
  void onClose() {}

  loadVideo() {
    trimmer.loadVideo(videoFile: Get.arguments);
  }

  saveVideo() async {
    print('Saving video...');
    progressVisibility.value = true;
    await trimmer.saveTrimmedVideo(
      startValue: startValue.value,
      endValue: endValue.value,
      onSave: (value) {
        progressVisibility.value = false;
        if (value != null) {
          result.value = value;
          print('Video successfully saved');
          print('Video saved at: $value');

          print('Showing snackbar...');

          // Kembali ke layar sebelumnya dengan hasil berupa File
          Get.back(result: File(result.value));
          Get.snackbar(
            "Video Saved",
            "Video saved successfully at: $value",
          );
          print('Navigating back...');
          print('ini argument : ${result.value}');
        } else {
          print('Failed to save video');
          Get.snackbar("Error", "Failed to save video");
        }
      },
    );
  }
}
