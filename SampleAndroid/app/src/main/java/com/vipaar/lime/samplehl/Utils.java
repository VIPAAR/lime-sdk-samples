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
          .setImage(HLTheme.IMAGE_CAMERA_DISABLED, R.drawable.image_test)
          .setImage(HLTheme.IMAGE_CAMERA_MENU_FREEZE_OFF, R.drawable.image_test)
          .setImage(HLTheme.IMAGE_CAMERA_MENU_FREEZE_ON, R.drawable.image_test)
          .setImage(HLTheme.IMAGE_CAMERA_MENU_FRONT_CAMERA_OFF, R.drawable.image_test)
          .setImage(HLTheme.IMAGE_CAMERA_MENU_FRONT_CAMERA_ON, R.drawable.image_test)
          .setImage(HLTheme.IMAGE_CAMERA_MENU_PHOTO_OFF, R.drawable.image_test)
          .setImage(HLTheme.IMAGE_CAMERA_MENU_PHOTO_ON, R.drawable.image_test)
          .setImage(HLTheme.IMAGE_CAMERA_MENU_SWITCH_CAMERA, R.drawable.image_test)
          .setImage(HLTheme.IMAGE_CAMERA_MENU_LIVE_VIDEO_OFF, R.drawable.image_test)
          .setImage(HLTheme.IMAGE_CAMERA_MENU_LIVE_VIDEO_ON, R.drawable.image_test3)
          .setImage(HLTheme.IMAGE_MAIN_MENU_DOCUMENT_OFF, R.drawable.image_test)
          .setImage(HLTheme.IMAGE_MAIN_MENU_DOCUMENT_ON, R.drawable.image_test)
          .setImage(HLTheme.IMAGE_MAIN_MENU_TORCH_OFF, R.drawable.image_test)
          .setImage(HLTheme.IMAGE_MAIN_MENU_TORCH_ON, R.drawable.image_test)
          .setImage(HLTheme.IMAGE_MAIN_MENU_INVITE, R.drawable.image_test)
          .setImage(HLTheme.IMAGE_MIC_OFF, R.drawable.image_test)
          .setImage(HLTheme.IMAGE_MIC_ON, R.drawable.image_test)
          .setImage(HLTheme.IMAGE_MODE_MENU_FACE_TO_FACE_OFF, R.drawable.image_test)
          .setImage(HLTheme.IMAGE_MODE_MENU_FACE_TO_FACE_ON, R.drawable.image_test)
          .setImage(HLTheme.IMAGE_MODE_MENU_GIVER_OFF, R.drawable.image_test)
          .setImage(HLTheme.IMAGE_MODE_MENU_GIVER_ON, R.drawable.image_test)
          .setImage(HLTheme.IMAGE_MODE_MENU_OBSERVER_OFF, R.drawable.image_test)
          .setImage(HLTheme.IMAGE_MODE_MENU_OBSERVER_ON, R.drawable.image_test)
          .setImage(HLTheme.IMAGE_MODE_MENU_RECEIVER_OFF, R.drawable.image_test)
          .setImage(HLTheme.IMAGE_MODE_MENU_RECEIVER_ON, R.drawable.image_test)
          .setImage(HLTheme.IMAGE_TELESTRATION_CLEAR_ALL, R.drawable.image_test)
          .setImage(HLTheme.IMAGE_TELESTRATION_MENU_ARROW_OFF, R.drawable.hltheme_ic_telestration_arrow_off)
          .setImage(HLTheme.IMAGE_TELESTRATION_MENU_ARROW_SOLID, R.drawable.hltheme_ic_telestration_arrow_on_solid)
          .setImage(HLTheme.IMAGE_TELESTRATION_MENU_ARROW_ON, R.drawable.hltheme_ic_telestration_arrow_blank)
          .setImage(HLTheme.IMAGE_TELESTRATION_MENU_COLOR_SELECTED, R.drawable.image_test)
          .setImage(HLTheme.IMAGE_TELESTRATION_MENU_COLOR_UNSELECTED, R.drawable.image_test)
          .setImage(HLTheme.IMAGE_TELESTRATION_MENU_PEN_OFF, R.drawable.image_test)
          .setImage(HLTheme.IMAGE_TELESTRATION_MENU_PEN_SOLID, R.drawable.image_test)
          .setImage(HLTheme.IMAGE_TELESTRATION_MENU_PEN_ON, R.drawable.ic_f2f_on)
          .setImage(HLTheme.IMAGE_TELESTRATION_UNDO, R.drawable.image_test)
          .setImage(HLTheme.IMAGE_END_CALL, R.drawable.image_test)
          .setImage(HLTheme.IMAGE_MAIN_MENU, R.drawable.image_test)
          .setImage(HLTheme.IMAGE_SCREEN_CAPTURE_UNPRESSED, R.drawable.image_test)
          .setImage(HLTheme.IMAGE_SCREEN_CAPTURE_TRANSITION, R.drawable.image_test)
          .setImage(HLTheme.IMAGE_SCREEN_CAPTURE_PRESSED, R.drawable.image_test3)
          .setImage(HLTheme.IMAGE_DEFAULT_PROFILE_ICON, R.drawable.image_test)
          .setImage(HLTheme.IMAGE_DEBUG_STATS_OFF, R.drawable.image_test)
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
          .setImage(HLTheme.IMAGE_CALL_QUALITY_AUDIO_PLUS, R.drawable.hltheme_ic_call_quality_audio_plus)
          .setImage(HLTheme.IMAGE_CAMERA_DISABLED, R.drawable.hltheme_ic_camera_disabled)
          .setImage(HLTheme.IMAGE_DEBUG_STATS_ON, R.drawable.image_test);

        return theme;
    }

}
