import 'dart:io';
import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import '../config/backend_config.dart';

class PickedImageResult {
  const PickedImageResult({required this.bytes, required this.downloadUrl});

  /// البيانات المضغوطة — تُستخدم للمعاينة الفورية في الواجهة (Image.memory)
  /// بغض النظر عن نجاح الرفع.
  final Uint8List bytes;

  /// رابط Firebase Storage النهائي بعد الرفع، أو null في وضع Mock (بدون
  /// خادم فعلي لرفع الصور إليه).
  final String? downloadUrl;
}

/// يختار صورة من المعرض، **يضغطها بشكل كبير قبل الرفع** (تصغير الأبعاد
/// وجودة JPEG معتدلة) — هذا فعلياً هو المطلوب من "إنشاء صور مصغّرة
/// (Thumbnails)": بدل رفع صورة كاميرا خام قد تتجاوز 5-10 ميجابايت، نرفع
/// نسخة لا تتجاوز عادة بضع مئات من الكيلوبايت، أسرع تحميلاً لكل مستخدمي
/// المتجر لاحقاً. ثم يرفعها لـ Firebase Storage (فقط إن كان kUseFirebase
/// مفعّلاً؛ في وضع Mock تُعاد البيانات للمعاينة المحلية فقط بدون رفع فعلي).
class ImageUploadService {
  ImageUploadService._();

  static final _picker = ImagePicker();

  static Future<PickedImageResult?> pickCompressAndUpload({required String storagePath}) async {
    final xfile = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 90);
    if (xfile == null) return null;

    final compressed = await FlutterImageCompress.compressWithFile(
      xfile.path,
      minWidth: 1080,
      minHeight: 1080,
      quality: 75,
      format: CompressFormat.jpeg,
    );
    final bytes = compressed ?? await File(xfile.path).readAsBytes();

    if (!kUseFirebase) {
      // لا خادم فعلياً بعد — نعرض المعاينة المحلية فقط دون رفع.
      return PickedImageResult(bytes: bytes, downloadUrl: null);
    }

    final ref = FirebaseStorage.instance.ref(storagePath);
    await ref.putData(bytes, SettableMetadata(contentType: 'image/jpeg'));
    final url = await ref.getDownloadURL();
    return PickedImageResult(bytes: bytes, downloadUrl: url);
  }
}
