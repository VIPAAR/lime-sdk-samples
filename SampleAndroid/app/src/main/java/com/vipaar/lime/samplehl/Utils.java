package com.vipaar.lime.samplehl;

import com.vipaar.lime.hlsdk.HLTheme;
import com.vipaar.lime.hlsdk.client.HLCall;

import org.json.JSONException;
import org.json.JSONObject;

public class Utils {

    public static HLCall getSessionData(JSONObject json, boolean autoEnableCamera, boolean autoEnableMic, boolean startInMiniview)
      throws JSONException {
        HLCall.Builder builder = new HLCall.Builder()
                .sessionId(json.getString("session_id"))
                .sessionToken(json.getString("session_token"))
                .userToken(json.getString("user_token"))
                .gssUrl(json.getString("url"))
                .helplightningAPIKey(BuildConfig.GALDR_API_KEY)
                .localUserDisplayName("Jason")
                .localUserAvatarUrl("https://www.gravatar.com/avatar/?d=identicon")
                .autoEnableCamera(autoEnableCamera)
                .autoEnableMicrophone(autoEnableMic)
                .startInMiniView(startInMiniview);
        return builder.build();
    }

    public static HLCall renewSessionData(HLCall call, boolean autoEnableCamera, boolean autoEnableMic, boolean startInMiniview) {
        HLCall.Builder builder = new HLCall.Builder()
                .sessionId(call.getSessionId())
                .sessionToken(call.getSessionToken())
                .userToken(call.getUserToken())
                .gssUrl(call.getGssUrl())
                .helplightningAPIKey(BuildConfig.GALDR_API_KEY)
                .localUserDisplayName("Jason")
                .localUserAvatarUrl("https://www.gravatar.com/avatar/?d=identicon")
                .autoEnableCamera(autoEnableCamera)
                .autoEnableMicrophone(autoEnableMic)
                .autoEnableAudioPlusMode(false)
                .startInMiniView(startInMiniview);
        return builder.build();
    }

    public static HLTheme createTheme() {
        HLTheme theme = new HLTheme()
          .setImage(HLTheme.IMAGE_CAMERA_MENU_BACK_CAMERA_OFF, R.drawable.image_test)
          .setImage(HLTheme.IMAGE_CAMERA_MENU_BACK_CAMERA_ON, R.drawable.image_test)
          .setImage(HLTheme.IMAGE_CAMERA_MENU_FREEZE_OFF, R.drawable.image_test)
          .setImage(HLTheme.IMAGE_CAMERA_MENU_FRONT_CAMERA_OFF, R.drawable.image_test)
          .setImage(HLTheme.IMAGE_CAMERA_MENU_FRONT_CAMERA_ON, R.drawable.image_test)
          .setImage(HLTheme.IMAGE_CAMERA_MENU_SWITCH_CAMERA, R.drawable.image_test)
          .setImage(HLTheme.IMAGE_MIC_OFF, R.drawable.image_test)
          .setImage(HLTheme.IMAGE_MIC_ON, R.drawable.image_test)
          .setImage(HLTheme.IMAGE_TELESTRATION_CLEAR_ALL, R.drawable.image_test)
          .setImage(HLTheme.IMAGE_TELESTRATION_MENU_ARROW_ON, R.drawable.hltheme_ic_telestration_arrow_blank)
          .setImage(HLTheme.IMAGE_TELESTRATION_MENU_PEN_ON, R.drawable.ic_f2f_on)
          .setImage(HLTheme.IMAGE_TELESTRATION_UNDO, R.drawable.image_test)
          .setImage(HLTheme.IMAGE_END_CALL, R.drawable.image_test)
          .setImage(HLTheme.IMAGE_MAIN_MENU, R.drawable.image_test)
          .setImage(HLTheme.IMAGE_SCREEN_CAPTURE_UNPRESSED, R.drawable.image_test)
          .setImage(HLTheme.IMAGE_SCREEN_CAPTURE_TRANSITION, R.drawable.image_test)
          .setImage(HLTheme.IMAGE_SCREEN_CAPTURE_PRESSED, R.drawable.image_test3)
          .setImage(HLTheme.IMAGE_DEFAULT_PROFILE_ICON, R.drawable.image_test)
          .setImage(HLTheme.IMAGE_MESSAGE_CHAT, R.drawable.hltheme_ic_chat)
          .setImage(HLTheme.IMAGE_MESSAGE_SEND_BUTTON, R.drawable.hltheme_ic_chat_send)
          .setImage(HLTheme.IMAGE_MESSAGE_PAPERCLIP, R.drawable.hltheme_ic_chat_attachment)
          .setImage(HLTheme.IMAGE_MESSAGE_PHOTO_FILM, R.drawable.hltheme_ic_add_photo)
          .setImage(HLTheme.IMAGE_MESSAGE_FOLDER_OPEN, R.drawable.hltheme_ic_add_document)
          .setImage(HLTheme.IMAGE_MESSAGE_CAMERA, R.drawable.hltheme_ic_take_picture)
          .setImage(HLTheme.IMAGE_MESSAGE_GROUP, R.drawable.hltheme_ic_icon_group)
          .setImage(HLTheme.IMAGE_MESSAGE_XMARK, R.drawable.hltheme_ic_x_mark)
          .setImage(HLTheme.IMAGE_MESSAGE_FILE, R.drawable.hltheme_ic_file_solid)
          .setImage(HLTheme.IMAGE_MESSAGE_VIDEO, R.drawable.hltheme_ic_videocam)
          .setImage(HLTheme.IMAGE_MESSAGE_PDF, R.drawable.hltheme_ic_file_pdf_solid)
          .setImage(HLTheme.IMAGE_CALL_QUALITY_HD, R.drawable.hltheme_ic_call_quality_hd)
          .setImage(HLTheme.IMAGE_CALL_QUALITY_SD, R.drawable.hltheme_ic_call_quality_sd)
          .setImage(HLTheme.IMAGE_CALL_QUALITY_AUDIO_PLUS, R.drawable.hltheme_ic_call_quality_audio_plus);

        return theme;
    }

}
