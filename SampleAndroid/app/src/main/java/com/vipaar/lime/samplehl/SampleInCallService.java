package com.vipaar.lime.samplehl;

import android.graphics.Bitmap;

import com.vipaar.lime.hlsdk.client.HLCall;
import com.vipaar.lime.hlsdk.services.InCallService;

import timber.log.Timber;

public class SampleInCallService extends InCallService {

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
