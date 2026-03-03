# Fix SLF4J issue from Pusher
-keep class org.slf4j.** { *; }
-dontwarn org.slf4j.**

# Google Sign-In
-keep class com.google.android.gms.** { *; }
-keep class com.google.firebase.** { *; }
-dontwarn com.google.android.gms.**

# Keep Google Sign-In classes
-keepattributes Signature
-keepattributes *Annotation*
-keep class com.google.android.gms.auth.** { *; }
-keep class com.google.android.gms.common.** { *; }

# AndroidX and Edge-to-Edge support
-keep class androidx.activity.** { *; }
-keep class androidx.core.** { *; }
-dontwarn androidx.**
