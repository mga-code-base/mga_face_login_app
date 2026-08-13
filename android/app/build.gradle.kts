plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.mga.mga_face_login_app"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    @Suppress("DEPRECATION")
    kotlinOptions {
        jvmTarget = "17"
    }

    defaultConfig {
        applicationId = "com.mygym.app"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion

        // FIX: Safe extraction of Flutter version configurations using standard property queries
        val localVersionCode = project.findProperty("flutterVersionCode") as? String
        val localVersionName = project.findProperty("flutterVersionName") as? String

        versionCode = localVersionCode?.toIntOrNull() ?: 1
        versionName = localVersionName ?: "1.0.0"

        // Your custom app name string mapping remains completely active
        resValue("string", "app_name", "MG Face")
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}
