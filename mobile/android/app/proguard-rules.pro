# Flutter's engine finds these through JNI, so the shrinker cannot see the references.
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# flutter_local_notifications schedules through the platform and is reached by name.
-keep class com.dexterous.** { *; }

# Nothing here is an obfuscation promise: the app holds no secret. Shrinking is for size,
# which matters on the phones and data plans this app is for.
