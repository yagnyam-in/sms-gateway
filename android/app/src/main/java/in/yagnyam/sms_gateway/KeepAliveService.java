package in.yagnyam.sms_gateway;

import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.app.PendingIntent;
import android.app.Service;
import android.content.Context;
import android.content.Intent;
import android.os.Build;
import android.os.IBinder;
import androidx.core.app.NotificationCompat;

public class KeepAliveService extends Service {

    private static final int NOTIF_ID = 1;
    private static final String NOTIF_CHANNEL_ID = "KeepAlive";
    private static final String NOTIF_CHANNEL_NAME = "KeepAlive";

    @Override
    public IBinder onBind(Intent intent) {
        return null;
    }

    @Override
    public int onStartCommand(Intent intent, int flags, int startId) {
        initChannels(getApplicationContext());
        startForeground();
        return super.onStartCommand(intent, flags, startId);
    }

    private void initChannels(Context context) {
        if (Build.VERSION.SDK_INT < 26) {
            return;
        }
        NotificationManager notificationManager =
                (NotificationManager) context.getSystemService(Context.NOTIFICATION_SERVICE);
        NotificationChannel channel = new NotificationChannel(NOTIF_CHANNEL_ID, NOTIF_CHANNEL_NAME,
                NotificationManager.IMPORTANCE_DEFAULT);
        channel.setDescription("Channel to keep App running always");
        if (notificationManager != null) {
            notificationManager.createNotificationChannel(channel);
        }
    }


    private void startForeground() {
        Intent notificationIntent = new Intent(this, MainActivity.class);
        PendingIntent pendingIntent = PendingIntent.getActivity(this, 0, notificationIntent, 0);
        startForeground(NOTIF_ID, new NotificationCompat.Builder(this, NOTIF_CHANNEL_ID)
                .setOngoing(true)
                .setSmallIcon(R.mipmap.ic_launcher)
                .setContentTitle("SMS Gateway")
                .setContentText("Service is running background")
                .setContentIntent(pendingIntent)
                .build());
    }
}
