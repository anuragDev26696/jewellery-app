# Flutter default ProGuard rules
# Keep the Flutter engine
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-keep class io.flutter.embedding.** { *; }

# Keep classes used by reflection (safe default)
-keepattributes *Annotation*
-keep class androidx.** { *; }
-keep class com.google.** { *; }
-keep class kotlinx.** { *; }

# Remove unused code aggressively
-dontnote
-dontwarn
