plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
    // فعّل هذا السطر بعد إضافة google-services.json عند ربط Firebase:
    // id("com.google.gms.google-services")
}

android {
    namespace = "com.matajirna.app"
    compileSdk = 35
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "com.matajirna.app"
        // متطلب المشروع: Android 11 (API 30) فما فوق
        minSdk = 30
        targetSdk = 35
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // TODO: أضف إعدادات توقيع (signingConfig) خاصة بك قبل نشر إصدار الإنتاج
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}
