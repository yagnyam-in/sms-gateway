package in.yagnyam.sms_gateway;

import android.telephony.SmsManager;
import android.util.Log;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

public class SmsService implements MethodChannel.MethodCallHandler {

    private static final String TAG = "SmsService";
    public static final String CHANNEL = "sms_gateway.yagnyam.in/SmsService";

    private String stringArgument(MethodCall methodCall, String argumentName) {
        String value = methodCall.argument(argumentName);
        if (value == null) {
            throw new IllegalArgumentException("Missing " + argumentName);
        }
        return value;
    }

    @Override
    public void onMethodCall(MethodCall methodCall, MethodChannel.Result result) {
        Log.d(TAG, "onMethodCall(" + methodCall + ")");
        try {
            if ("sendSMS".equals(methodCall.method)) {
                result.success(sendSMS(methodCall));
            } else {
                result.notImplemented();
            }
        } catch (IllegalArgumentException e) {
            Log.e(TAG, "Missing Arguments", e);
            result.error("MISSING_ARGUMENTS", e.getMessage(), null);
        } catch (Exception e) {
            Log.e(TAG, "Unknown Error", e);
            result.error("UNKNOWN_ERROR", e.getMessage(), null);
        }
    }

    private String sendSMS(MethodCall methodCall) {
        String phone = stringArgument(methodCall, "phone");
        String message = stringArgument(methodCall, "message");
        SmsManager smsManager = SmsManager.getDefault();
        smsManager.sendTextMessage(phone, null, message, null, null);
        return "SUCCESS";
    }

}
