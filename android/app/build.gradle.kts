plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "io.github.jiangbyte.yuetu"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        applicationId = "io.github.jiangbyte.yuetu"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        create("release") {
            // 1. 优先读环境变量（CI / 本地可覆盖）
            // 2. 回退到仓库内分发签名密钥，保证 assembleRelease 可复现
            storeFile = file("yuetu-release.keystore")
            storePassword = System.getenv("YUETU_STORE_PASSWORD") ?: "yuetu-release"
            keyAlias = System.getenv("YUETU_KEY_ALIAS") ?: "yuetu"
            keyPassword = System.getenv("YUETU_KEY_PASSWORD") ?: "yuetu-release"
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
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
