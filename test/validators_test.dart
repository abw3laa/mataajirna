import 'package:flutter_test/flutter_test.dart';
import 'package:mataajirna/core/utils/validators.dart';

void main() {
  group('Validators.price', () {
    test('يرفض القيم السالبة', () {
      expect(Validators.price('-10'), isNotNull);
    });
    test('يرفض النص غير الرقمي', () {
      expect(Validators.price('abc'), isNotNull);
    });
    test('يرفض الحقل الفارغ', () {
      expect(Validators.price(''), isNotNull);
      expect(Validators.price(null), isNotNull);
    });
    test('يقبل سعراً صحيحاً', () {
      expect(Validators.price('250'), isNull);
      expect(Validators.price('0'), isNull);
    });
    test('يرفض تجاوز الحد الأقصى', () {
      expect(Validators.price('99999999', max: 1000000), isNotNull);
    });
  });

  group('Validators.discountPercent', () {
    test('الحقل الفارغ اختياري ومقبول', () {
      expect(Validators.discountPercent(''), isNull);
      expect(Validators.discountPercent(null), isNull);
    });
    test('يرفض ما فوق 100', () {
      expect(Validators.discountPercent('150'), isNotNull);
    });
    test('يرفض السالب', () {
      expect(Validators.discountPercent('-5'), isNotNull);
    });
    test('يقبل نسبة صحيحة', () {
      expect(Validators.discountPercent('20'), isNull);
    });
  });

  group('Validators.email', () {
    test('يرفض صيغة غير صحيحة', () {
      expect(Validators.email('not-an-email'), isNotNull);
      expect(Validators.email('a@b'), isNotNull);
    });
    test('يقبل بريداً صحيحاً', () {
      expect(Validators.email('user@example.com'), isNull);
    });
  });

  group('Validators.password', () {
    test('يرفض كلمة مرور قصيرة', () {
      expect(Validators.password('123'), isNotNull);
    });
    test('يقبل كلمة مرور بالحد الأدنى', () {
      expect(Validators.password('123456'), isNull);
    });
  });

  group('Validators.address', () {
    test('يرفض عنواناً قصيراً جداً', () {
      expect(Validators.address('قصير'), isNotNull);
    });
    test('يقبل عنواناً مفصَّلاً', () {
      expect(Validators.address('الرياض، حي النخيل، شارع الأمير، مبنى 12'), isNull);
    });
  });

  group('Validators.sanitize', () {
    test('يزيل الفراغات الزائدة من الطرفين والداخل', () {
      expect(Validators.sanitize('  مرحباً   بالعالم  '), 'مرحباً بالعالم');
    });
  });
}
