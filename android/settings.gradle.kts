pluginManagement {
    val flutterSdkPath =
        run {
            val properties = java.util.Properties()
            file("local.properties").inputStream().use { properties.load(it) }
            val flutterSdkPath = properties.getProperty("flutter.sdk")
            require(flutterSdkPath != null) { "flutter.sdk not set in local.properties" }
            flutterSdkPath
        }

    includeBuild("$flutterSdkPath/packages/flutter_tools/gradle")

    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}

plugins {
    id("dev.flutter.flutter-plugin-loader") version "1.0.0"
    // AGP pinned to 8.7.3: AGP 9.x removed support for
    // getDefaultProguardFile('proguard-android.txt'), which
    // flutter_inappwebview_android 1.1.3 still relies on. 8.7.3 is a stable,
    // well-tested pairing with Flutter 3.44 + Gradle 8.11.1. Revisit when
    // flutter_inappwebview ships an AGP-9-compatible stable release.
    id("com.android.application") version "8.7.3" apply false
    id("org.jetbrains.kotlin.android") version "2.1.0" apply false
}

include(":app")
