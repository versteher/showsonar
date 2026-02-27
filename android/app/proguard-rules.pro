# Flutter wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# Dart API callbacks
-keep @interface io.flutter.embedding.engine.FlutterEngine

# Flutter engine rules
-dontwarn io.flutter.**
-keep class * implements io.flutter.plugin.common.PluginRegistry$PluginRegistrantCallback { *; }
-keep class * implements io.flutter.plugin.common.PluginRegistry$ActivityResultListener { *; }
-keep class * implements io.flutter.plugin.common.PluginRegistry$RequestPermissionsResultListener { *; }

# General
-dontwarn android.support.**
-keep class android.support.** { *; }

# Firebase (if needed)
-keep class com.google.firebase.** { *; }
-dontwarn com.google.firebase.**
