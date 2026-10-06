# Ignore missing ML Kit text recognition language classes
-dontwarn com.google.mlkit.vision.text.chinese.**
-dontwarn com.google.mlkit.vision.text.devanagari.**
-dontwarn com.google.mlkit.vision.text.japanese.**
-dontwarn com.google.mlkit.vision.text.korean.**

# Optionally keep the core plugin classes from being stripped
-keep class com.google_mlkit_text_recognition.** { *; }
