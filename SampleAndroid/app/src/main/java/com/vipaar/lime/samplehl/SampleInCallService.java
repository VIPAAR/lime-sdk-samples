package com.vipaar.lime.samplehl;

import android.content.Intent;
import android.graphics.Bitmap;
import android.net.Uri;

import com.vipaar.lime.hlsdk.client.HLCall;
import com.vipaar.lime.hlsdk.client.HLClient;
import com.vipaar.lime.hlsdk.client.HLClientBase;
import com.vipaar.lime.hlsdk.client.HLClientDelegate;
import com.vipaar.lime.hlsdk.services.InCallService;

import timber.log.Timber;

public class SampleInCallService extends InCallService {

    @Override
    public int onStartCommand(Intent intent, int flags, int startId) {
        HLClient.getInstance().setHLClientDelegate(this);
        return super.onStartCommand(intent, flags, startId);
    }

    /**
     * Called when a call has ended.
     *
     * @param call   The call that ended.
     * @param reason The reason the call ended.
     */
    @Override
    public void onCallEnded(HLCall call, String reason) {
        Timber.d("Sample onCallEnded");
    }

    /**
     * Triggered when user taps the screen capture button.
     *
     * @param call  The ongoing call.
     * @param image The captured screen as a Bitmap.
     */
    @Override
    public void onScreenCaptured(HLCall call, Bitmap image) {
        Timber.d("Sample onScreenCaptured");
    }

    /**
     * Called to invite a third participant into an existing call.
     */
    @Override
    public void onInviteThirdParticipant() {
        Timber.d("Sample onInviteThirdParticipant");
    }

    /**
     * Checks if the "Share Knowledge" feature is enabled.
     *
     * @return true if enabled, false otherwise.
     */
    @Override
    public boolean isShareKnowledgeEnabled() {
        return true;
    }

    /**
     * Called when user taps "knowledge" in the share menu.
     * <p>
     * Share Knowledge is a way for users to share internal content
     * that might be stored in your app or in a cloud storage
     * that the user has access to through your app. If this does
     * not exist, you can reroute the user to the OS image picker
     * or just return false in {@link HLClientDelegate#isShareKnowledgeEnabled()} to hide this
     * feature.
     */
    @Override
    public void onShareKnowledge() {
        Intent intent = new Intent(this, ImageSelectActivity.class);
        intent.putExtra("mode", ImageSelectActivity.MODE_QUICK_KNOWLEDGE);
        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
        startActivity(intent);
    }

    /**
     * Checks if the "Share Quick Knowledge" feature is enabled.
     *
     * @return true if enabled, false otherwise.
     */
    @Override
    public boolean isShareQuickKnowledgeEnabled() {
        return true;
    }

    /**
     * Called to select a quick overlay for sharing knowledge.
     * <p>
     * Similar to sharing knowledge, sharing quick knowledge for overlay
     * is a way for users to share internal content
     * that might be stored in your app or in a cloud storage
     * that the user has access to through your app. If this does
     * not exist, you can reroute the user to the OS image picker
     * or just return false in {@link HLClientDelegate#isShareQuickKnowledgeEnabled()} to hide this
     * feature.
     * <p>
     * An overlay is put on top of the other shared content in your call,
     * so you can view a live video source with a separate floating
     * image on top of that video.
     * <p>
     * Expects {@link HLClientBase#onQuickKnowledgeOverlaySelected(Uri)}
     * to be called to deliver the image to the call.
     */
    @Override
    public void onSelectKnowledgeQuickOverlay() {
        Intent intent = new Intent(this, ImageSelectActivity.class);
        intent.putExtra("mode", ImageSelectActivity.MODE_QUICK_KNOWLEDGE_OVERLAY);
        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
        startActivity(intent);
    }
}
