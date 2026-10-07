# Ignore missing ML Kit text recognition language classes
-dontwarn com.google.mlkit.vision.text.chinese.**
-dontwarn com.google.mlkit.vision.text.devanagari.**
-dontwarn com.google.mlkit.vision.text.japanese.**
-dontwarn com.google.mlkit.vision.text.korean.**

# Optionally keep the core plugin classes from being stripped
-keep class com.google_mlkit_text_recognition.** { *; }

# ML Kit registrars are created by reflection from manifest meta-data.
# Without this, R8 strips their no-arg constructors, no components register,
# and processImage() crashes with an NPE (SharedPrefManager is null).
-keep class * implements com.google.firebase.components.ComponentRegistrar { <init>(); }
