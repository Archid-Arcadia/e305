#Flutter Wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }
-keep class com.shatsy.admobflutter.** { *; }
-keep class com.dexterous.** { *; }
-keep class com.dexterous.flutterlocalnotifications.** { *; }
-keep class com.baseflow.permissionhandler.** { *; }
-keep class com.tekartik.sqflite.** { *; }
-keep class com.example.imagegallerysaver.** { *; }
-keep class com.google.firebase.** { *; }
-dontwarn io.flutter.embedding.**
-ignorewarnings

#import io.flutter.plugin.common.PluginRegistry;
#import com.shatsy.admobflutter.AdmobFlutterPlugin;
#import com.dexterous.flutterlocalnotifications.FlutterLocalNotificationsPlugin;
#import com.example.imagegallerysaver.ImageGallerySaverPlugin;
#import io.flutter.plugins.localauth.LocalAuthPlugin;
#import io.flutter.plugins.pathprovider.PathProviderPlugin;
#import com.baseflow.permissionhandler.PermissionHandlerPlugin;
#import flutter.plugins.screen.screen.ScreenPlugin;
#import io.flutter.plugins.sharedpreferences.SharedPreferencesPlugin;
#import com.tekartik.sqflite.SqflitePlugin;
#import io.flutter.plugins.urllauncher.UrlLauncherPlugin;
#import io.flutter.plugins.videoplayer.VideoPlayerPlugin;
#import io.flutter.plugins.webviewflutter.WebViewFlutterPlugin;