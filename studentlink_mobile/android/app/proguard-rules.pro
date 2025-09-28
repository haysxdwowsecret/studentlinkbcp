# 🚀 SIZE OPTIMIZATION: ProGuard rules for maximum app size reduction

# Keep Flutter framework
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# Keep Firebase
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }

# Aggressive optimization
-optimizations !code/simplification/arithmetic,!code/simplification/cast,!field/*,!class/merging/*
-optimizationpasses 5
-allowaccessmodification
-dontpreverify

# Remove logging in release builds
-assumenosideeffects class android.util.Log {
    public static boolean isLoggable(java.lang.String, int);
    public static int v(...);
    public static int i(...);
    public static int w(...);
    public static int d(...);
    public static int e(...);
}

# Remove debug prints
-assumenosideeffects class kotlin.io.ConsoleKt {
    public static void print(java.lang.Object);
    public static void print(java.lang.String);
}

# Remove System.out.println
-assumenosideeffects class java.io.PrintStream {
    public void println(%);
    public void println(**);
}

# 🚀 SIZE OPTIMIZATION: Remove unused resources and classes
-dontwarn **
-ignorewarnings

# Keep native methods
-keepclasseswithmembernames class * {
    native <methods>;
}

# Keep enums
-keepclassmembers enum * {
    public static **[] values();
    public static ** valueOf(java.lang.String);
}

# Keep Parcelable
-keep class * implements android.os.Parcelable {
    public static final android.os.Parcelable$Creator *;
}

# Keep Serializable
-keepclassmembers class * implements java.io.Serializable {
    static final long serialVersionUID;
    private static final java.io.ObjectStreamField[] serialPersistentFields;
    private void writeObject(java.io.ObjectOutputStream);
    private void readObject(java.io.ObjectInputStream);
    java.lang.Object writeReplace();
    java.lang.Object readResolve();
}

# 🚀 SIZE OPTIMIZATION: Aggressive class removal
-keep,allowshrinking,allowoptimization class * {
    @com.google.gson.annotations.SerializedName <fields>;
}

# Remove unused classes from ML Kit (if not using accessibility features)
-dontwarn com.google.mlkit.**
-keep class com.google.mlkit.** { *; }

# 🚀 SIZE OPTIMIZATION: Remove unused Firebase features
-dontwarn com.google.firebase.storage.**
-dontwarn com.google.firebase.database.**

# Keep only essential Firebase features
-keep class com.google.firebase.messaging.** { *; }
-keep class com.google.firebase.analytics.** { *; }
-keep class com.google.firebase.core.** { *; }