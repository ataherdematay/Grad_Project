import java.util.Properties

plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// Release imzasi: android/key.properties (git'e eklenmez) veya ortam degiskenleri
// BITADILAT_KEYSTORE_FILE / _STORE_PASSWORD / _KEY_ALIAS / _KEY_PASSWORD.
val keyProps = Properties().apply {
    val f = rootProject.file("key.properties")
    if (f.exists()) f.inputStream().use { load(it) }
}

fun signingValue(propKey: String, envKey: String): String? =
    keyProps.getProperty(propKey) ?: System.getenv(envKey)

android {
    namespace = "com.bitadilat.app"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        applicationId = "com.bitadilat.app"
        // Eklentiler (flutter_secure_storage, webview_flutter, image_picker) icin 24 yeterli.
        minSdk = 24
        // Flutter'in guncel hedefi (su an 36).
        targetSdk = flutter.targetSdkVersion
        // Uses the version code from pubspec.yaml. When using split APKs, 1000 * ABI_VERSION
        // is added automatically by Flutter.
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        create("release") {
            val storePath = signingValue("storeFile", "BITADILAT_KEYSTORE_FILE")
            if (storePath != null) {
                storeFile = rootProject.file(storePath)
                storePassword = signingValue("storePassword", "BITADILAT_STORE_PASSWORD")
                keyAlias = signingValue("keyAlias", "BITADILAT_KEY_ALIAS")
                keyPassword = signingValue("keyPassword", "BITADILAT_KEY_PASSWORD")
            }
        }
    }

    buildTypes {
        release {
            // Anahtar yapilandirilmadiysa release derlemesi bilerek hata verir;
            // debug anahtariyla imzali release uretilmez. Debug derlemesi etkilenmez.
            val releaseSigning = signingConfigs.getByName("release")
            val releaseRequested = gradle.startParameter.taskNames.any {
                it.contains("release", ignoreCase = true) && !it.contains("lint", ignoreCase = true)
            }
            if (releaseSigning.storeFile == null && releaseRequested) {
                throw GradleException(
                    "Release imzasi yok: android/key.properties olusturun veya BITADILAT_* ortam degiskenlerini verin (docs/ANDROID.md).",
                )
            }
            signingConfig = releaseSigning
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}
