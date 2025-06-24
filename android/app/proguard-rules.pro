# Add these at the top of your existing proguard-rules.pro
-keep class com.github.tamir7.contacts.** { *; }
-keep class com.github.tamir7.phonestate.** { *; }
-keep class com.github.tamir7.calllog.** { *; }
-keepattributes *Annotation*, Signature, InnerClasses
-keepnames class * { @javax.annotation.* <methods>; }
-keepnames class * { @javax.annotation.* <fields>; }

# Flutter Quill lifecycle fix
-keep class androidx.lifecycle.** { *; }
-keep class * extends androidx.lifecycle.LifecycleObserver { *; }

# Jackson specific rules
-keep class com.fasterxml.jackson.** { *; }
-keep class org.codehaus.** { *; }
-dontwarn com.fasterxml.jackson.databind.**
-dontwarn org.codehaus.**

# OkHttp/Conscrypt rules
-keep class okhttp3.** { *; }
-keep interface okhttp3.** { *; }
-keep class org.conscrypt.** { *; }
-dontwarn okhttp3.**
-dontwarn org.conscrypt.**

# Java beans
-keep class java.beans.** { *; }
-keepclassmembers class * {
    @java.beans.ConstructorProperties <init>(...);
}

# DOM/XML processing
-keep class org.w3c.dom.** { *; }
-keep class javax.xml.** { *; }

# Flutter/AndroidX
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class androidx.** { *; }
-keep class com.google.android.material.** { *; }

# Add these to handle the specific missing classes
-keep class javax.annotation.** { *; }
-dontwarn javax.annotation.**
-keep class org.conscrypt.** { *; }
-dontwarn org.conscrypt.**
-keep class org.w3c.dom.bootstrap.** { *; }

# Custom rules for your app (specific to InteractionScreen)
-keep class com.yourpackage.InteractionScreen { *; }

# Keep Flutter dependencies
-keep class io.flutter.** { *; }

# Keep all Parcelable implementations
-keepclassmembers class * implements android.os.Parcelable {
    static ** CREATOR;
}

# Keep JSON parsing classes
-keepclassmembers class * {
    @com.google.gson.annotations.SerializedName <fields>;
}

# Retrofit and network rules
-keep class retrofit2.** { *; }
-keep class okhttp3.** { *; }
-dontwarn retrofit2.**
-dontwarn okhttp3.**

# General configuration for avoiding minification issues
-dontwarn android.arch.**
-dontwarn androidx.lifecycle.**

# Ensure all R8 optimizations are properly handled
-ignorewarnings
-keepattributes *Annotation*
