package com.vipaar.lime.samplehl;

import android.content.Intent;
import android.graphics.Bitmap;

import com.vipaar.lime.hlsdk.client.HLCall;
import com.vipaar.lime.hlsdk.client.HLClient;
import com.vipaar.lime.hlsdk.services.InCallService;

import timber.log.Timber;

public class SampleInCallService extends InCallService {

    @Override
    public int onStartCommand(Intent intent, int flags, int startId) {
        HLClient.getInstance().setHLClientDelegate(this);
        return super.onStartCommand(intent, flags, startId);
    }

    public void onCallEnded(HLCall call, String reason) {
        Timber.d("Sample onCallEnded");
    }

    public void onScreenCaptured(HLCall call, Bitmap image) {
        Timber.d("Sample onScreenCaptured");
    }

    public void onInviteThirdParticipant() {
        Timber.d("Sample onInviteThirdParticipant");
    }
}
