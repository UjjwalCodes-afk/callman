# ================================================
# FLUTTER SPECIFIC RULES
# ================================================
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# ================================================
# APPLICATION SPECIFIC CLASSES
# ================================================
-keep class com.example.callman.** { *; }
-keep class com.yourapp.** { *; }

# ================================================
# PLUGIN-SPECIFIC RULES
# ================================================
# For flutter_callkit_incoming
-keep class com.hiennv.flutter_callkit_incoming.** { *; }
-keep class io.wazo.callkit.** { *; }

# For flutter_contacts
-keep class co.quis.flutter_contacts.** { *; }

# For flutter_phone_direct_caller
-keep class com.yanisalfian.flutterphonedirectcaller.** { *; }

# For overlay plugins
-keep class dev.xslayer.overlay.** { *; }
-keep class flutter.overlay.window.** { *; }

# ================================================
# ANDROID SYSTEM CLASSES
# ================================================
# Telephony/Phone related
-keep class android.telephony.** { *; }
-keep class android.telecom.** { *; }
-dontwarn com.android.internal.telephony.**

# Contacts/Content Providers
-keep class android.provider.ContactsContract.** { *; }
-keep class android.content.ContentResolver.** { *; }

# Shared Preferences
-keep class android.app.SharedPreferencesImpl.** { *; }
-keep class android.content.SharedPreferences.** { *; }

# ================================================
# SERIALIZATION/PARCELABLE
# ================================================
# Parcelable
-keepclassmembers class * implements android.os.Parcelable {
    public static final ** CREATOR;
}

# Serializable
-keepclassmembers class * implements java.io.Serializable {
    static final long serialVersionUID;
    private static final java.io.ObjectStreamField[] serialPersistentFields;
    private void writeObject(java.io.ObjectOutputStream);
    private void readObject(java.io.ObjectInputStream);
    java.lang.Object writeReplace();
    java.lang.Object readResolve();
}

# ================================================
# ANNOTATIONS AND REFLECTION
# ================================================
-keepattributes *Annotation*, Signature, InnerClasses
-keepnames class * { @androidx.annotation.* *; }

# ================================================
# NATIVE METHODS
# ================================================
-keepclasseswithmembernames class * {
    native <methods>;
}

# ================================================
# ENUM CLASSES
# ================================================
-keepclassmembers enum * {
    public static **[] values();
    public static ** valueOf(java.lang.String);
}

# ================================================
# NETWORKING LIBRARIES
# ================================================
# Retrofit
-keep class retrofit2.** { *; }
-keepclasseswithmembers class * {
    @retrofit2.http.* <methods>;
}

# OkHttp
-keep class okhttp3.** { *; }
-keep interface okhttp3.** { *; }
-dontwarn okhttp3.**

# ================================================
# GENERAL CONFIGURATION
# ================================================
-dontwarn android.arch.**
-dontwarn androidx.**
-dontwarn dev.fluttercommunity.plus.androidintent.**
-dontwarn org.jetbrains.annotations.**
-ignorewarnings