package com.eventevent2.android.eventevent;

import android.os.Bundle;
import io.flutter.app.FlutterActivity;
import io.flutter.plugins.GeneratedPluginRegistrant;
import com.anggach.flutterandroidlifecycle.FlutterAndroidLifecycleActivity;

public class MainActivity extends FlutterAndroidLifecycleActivity {
  @Override
  protected void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    GeneratedPluginRegistrant.registerWith(this);
  }
}
