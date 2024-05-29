import 'package:get/get.dart';
import 'package:statuswa/upload.dart';
import 'package:statuswa/video_trim_view.dart';
import 'package:statuswa/video_trimmer_controller.dart';

class AppPages {
  static List<GetPage> routes() => [
        GetPage(name: '/', page: () => FileUploadScreen()),
        GetPage(
            name: '/video-trim',
            page: () => VideoTrimView(),
            binding: BindingsBuilder(
              () {
                Get.put(VideoTrimController());
              },
            ))
      ];
}
