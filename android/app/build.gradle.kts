plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
}

dependencies {
    implementation(platform("com.google.firebase:firebase-bom:33.13.0"))
    implementation("com.google.firebase:firebase-analytics")
    // Pastikan semua dependencies yang diperlukan sudah ada, seperti Flutter SDK dan lainnya
    implementation("androidx.appcompat:appcompat:1.3.1") // Pastikan library ini ada jika menggunakan AppCompatActivity
    implementation("androidx.constraintlayout:constraintlayout:2.0.4") // Jika menggunakan ConstraintLayout
}

android {
    namespace = "com.example.nutrisense"  // Gunakan namespace sesuai dengan nama aplikasi Anda
    compileSdk = 36  // Gunakan nilai compileSdk yang sesuai, misalnya 33
    ndkVersion = "29.0.13113456"  // Sesuaikan versi NDK yang dibutuhkan

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.example.nutrisense"  // Pastikan applicationId sesuai dengan ID aplikasi yang unik
        minSdk = 23  // Gantilah dengan versi minSdk yang sesuai
        targetSdk = 36  // Gantilah dengan versi targetSdk yang sesuai
        versionCode = 1  // Tentukan versionCode yang sesuai
        versionName = "1.0"  // Tentukan versionName yang sesuai
    }


    buildTypes {
        getByName("release") {
            isMinifyEnabled = false // Gunakan 'isMinifyEnabled' daripada 'minifyEnabled'
            isShrinkResources = false // Gunakan 'isShrinkResources' daripada 'shrinkResources'
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."  // Pastikan path ini menunjuk ke direktori root dari proyek Flutter
}
