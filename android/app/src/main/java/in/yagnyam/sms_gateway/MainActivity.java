package in.yagnyam.sms_gateway;

import android.os.Bundle;
import io.flutter.app.FlutterActivity;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugins.GeneratedPluginRegistrant;

public class MainActivity extends FlutterActivity {
  @Override
  protected void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    GeneratedPluginRegistrant.registerWith(this);
    registerPlugins();
  }

  private void registerPlugins() {
    new MethodChannel(getFlutterView(), SmsService.CHANNEL)
            .setMethodCallHandler(new SmsService());
  }
}
