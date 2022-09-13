package com.vipaar.lime.samplehl;

import android.content.Intent;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Button;
import android.widget.EditText;
import android.widget.Switch;
import android.widget.Toast;

import com.vipaar.lime.hlsdk.HLTheme;
import com.vipaar.lime.hlsdk.client.HLCall;
import com.vipaar.lime.hlsdk.client.HLClient;
import com.vipaar.lime.hlsdk.misc.Environment;

import com.android.volley.AuthFailureError;
import com.android.volley.DefaultRetryPolicy;
import com.android.volley.Request;
import com.android.volley.RequestQueue;
import com.android.volley.toolbox.JsonObjectRequest;
import com.android.volley.toolbox.Volley;

import java.util.HashMap;
import java.util.Map;

import org.json.JSONException;
import org.json.JSONObject;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.fragment.app.Fragment;
import timber.log.Timber;

public class JoinSession extends Fragment implements View.OnClickListener {

    View rootView;
    EditText editText;
    Button joinAudioButton;
    Button joinVideoButton;
    String sessionId;
    HLCall sessionData;
    EditText pinEditText;
    EditText contactEditText;

    // TODO: Rename parameter arguments, choose names that match
    // the fragment initialization parameters, e.g. ARG_ITEM_NUMBER
    private static final String ARG_PARAM1 = "user_token";
    private static final String ARG_PARAM2 = "mode";

    // TODO: Rename and change types of parameters
    private String mUserToken;
    private String mMode;

    private final Environment.DataCenter dataCenter = Environment.DataCenter.US;

    public JoinSession() {
        // Required empty public constructor
    }

    /**
     * Use this factory method to create a new instance of this fragment using the provided parameters.
     *
     * @param param1 Parameter 1.
     * @param param2 Parameter 2.
     * @return A new instance of fragment JoinSession.
     */
    // TODO: Rename and change types and number of parameters
    public static JoinSession newInstance(String param1, String param2) {
        JoinSession fragment = new JoinSession();
        Bundle args = new Bundle();
        args.putString(ARG_PARAM1, param1);
        args.putString(ARG_PARAM2, param2);
        fragment.setArguments(args);
        return fragment;
    }

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        sessionData = null;
        if (getArguments() != null) {
            mUserToken = getArguments().getString(ARG_PARAM1);
            mMode = getArguments().getString(ARG_PARAM2);
        }
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
      Bundle savedInstanceState) {
        // Inflate the layout for this fragment
        rootView = inflater.inflate(R.layout.fragment_join_session, container, false);
        contactEditText = rootView.findViewById(R.id.contact_edit_text);
        pinEditText = rootView.findViewById(R.id.pin_edit_text);

        if (mMode.equals("contact")) {
            pinEditText.setEnabled(false);
        } else {
            contactEditText.setEnabled(false);
        }
        setTheme();

        joinVideoButton = rootView.findViewById(R.id.join_video_session);
        joinAudioButton = rootView.findViewById(R.id.join_audio_session);
        joinVideoButton.setOnClickListener(this);
        joinAudioButton.setOnClickListener(this);

        rootView.findViewById(R.id.leave_session).setOnClickListener(v -> {
            try {
                rootView.findViewById(R.id.progressBar_cyclic).setVisibility(View.INVISIBLE);
                HLClient.getInstance().stopCurrentCall();
            } catch (Exception e) {
                Toast.makeText(getContext(), "Error", Toast.LENGTH_SHORT).show();
            }
        });
        return rootView;
    }

    @Override
    public void onViewCreated(@NonNull View view, @Nullable Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);
    }

    @Override
    public void onDetach() {
        super.onDetach();
    }

    @Override
    public void onActivityResult(int requestCode, int resultCode, @Nullable Intent data) {
        super.onActivityResult(requestCode, resultCode, data);
    }

    private HLCall getSessionData(JSONObject json, boolean audioPlusModeEnabled) throws JSONException {
        Switch simpleSwitch = rootView.findViewById(R.id.cameraSwitch);
        Switch audioSwitch = rootView.findViewById(R.id.audioSwitch);

// check current state of a Switch (true or false).
        Boolean switchState = simpleSwitch.isChecked();
        return new HLCall(
          json.getString("session_id"),
          json.getString("session_token"),
          json.getString("user_token"),
          json.getString("url"),
          BuildConfig.GALDR_API_KEY,
          "Jason",
          "https://www.securenvoy.com/sites/default/files/legacy-uploads/2013/10/pizza_hut_logo.jpg",
          simpleSwitch.isChecked(),
          audioSwitch.isChecked(),
          audioPlusModeEnabled);

    }

    private HLCall renewSessionData(HLCall call) {
        Switch simpleSwitch = rootView.findViewById(R.id.cameraSwitch);
        Switch audioSwitch = rootView.findViewById(R.id.audioSwitch);

        return new HLCall(
          call.getSessionId(),
          call.getSessionToken(),
          call.getUserToken(),
          call.getGssUrl(),
          BuildConfig.GALDR_API_KEY,
          "Jason",
          "https://www.securenvoy.com/sites/default/files/legacy-uploads/2013/10/pizza_hut_logo.jpg",
          simpleSwitch.isChecked(),
          audioSwitch.isChecked());
    }

    private void setTheme() {
        HLTheme theme = new HLTheme()
          .setImage(HLTheme.IMAGE_CAMERA_MENU_BACK_CAMERA_OFF, R.drawable.ic_camera_back_off)
          .setImage(HLTheme.IMAGE_CAMERA_MENU_BACK_CAMERA_ON, R.drawable.ic_camera_back_on)
          .setImage(HLTheme.IMAGE_CAMERA_MENU_FREEZE_OFF, R.drawable.ic_freeze_off)
          .setImage(HLTheme.IMAGE_CAMERA_MENU_FREEZE_ON, R.drawable.ic_freeze_on)
          .setImage(HLTheme.IMAGE_CAMERA_MENU_FRONT_CAMERA_OFF, R.drawable.ic_camera_front_off)
          .setImage(HLTheme.IMAGE_CAMERA_MENU_FRONT_CAMERA_ON, R.drawable.ic_camera_front_on)
          .setImage(HLTheme.IMAGE_CAMERA_MENU_PHOTO_OFF, R.drawable.ic_ghop_off)
          .setImage(HLTheme.IMAGE_CAMERA_MENU_PHOTO_ON, R.drawable.ic_ghop_on)
          .setImage(HLTheme.IMAGE_CAMERA_MENU_SWITCH_CAMERA, R.drawable.ic_camera_frontback_toggle)
          .setImage(HLTheme.IMAGE_CAMERA_MENU_LIVE_VIDEO_OFF, R.drawable.ic_live_video_off)
          .setImage(HLTheme.IMAGE_CAMERA_MENU_LIVE_VIDEO_ON, R.drawable.ic_live_video_on)
          .setImage(HLTheme.IMAGE_MAIN_MENU_DOCUMENT_OFF, R.drawable.ic_doc_share_off)
          .setImage(HLTheme.IMAGE_MAIN_MENU_DOCUMENT_ON, R.drawable.ic_doc_share_on)
          .setImage(HLTheme.IMAGE_MAIN_MENU_TORCH_OFF, R.drawable.ic_torch_off)
          .setImage(HLTheme.IMAGE_MAIN_MENU_TORCH_ON, R.drawable.ic_torch_on)
          .setImage(HLTheme.IMAGE_MAIN_MENU_INVITE, R.drawable.ic_invite)
          .setImage(HLTheme.IMAGE_MIC_OFF, R.drawable.ic_mic_off)
          .setImage(HLTheme.IMAGE_MIC_ON, R.drawable.ic_mic_on)
          .setImage(HLTheme.IMAGE_MODE_MENU_FACE_TO_FACE_OFF, R.drawable.ic_f2f_off)
          .setImage(HLTheme.IMAGE_MODE_MENU_FACE_TO_FACE_ON, R.drawable.ic_f2f_on)
          .setImage(HLTheme.IMAGE_MODE_MENU_GIVER_OFF, R.drawable.ic_give_help_off)
          .setImage(HLTheme.IMAGE_MODE_MENU_GIVER_ON, R.drawable.ic_give_help_on)
          .setImage(HLTheme.IMAGE_MODE_MENU_OBSERVER_OFF, R.drawable.ic_observer_off)
          .setImage(HLTheme.IMAGE_MODE_MENU_OBSERVER_ON, R.drawable.ic_observer_on)
          .setImage(HLTheme.IMAGE_MODE_MENU_RECEIVER_OFF, R.drawable.ic_receive_help_off)
          .setImage(HLTheme.IMAGE_MODE_MENU_RECEIVER_ON, R.drawable.ic_receive_help_on)
          .setImage(HLTheme.IMAGE_TELESTRATION_CLEAR_ALL, R.drawable.ic_telestration_erase)
          .setImage(HLTheme.IMAGE_TELESTRATION_MENU_ARROW_OFF, R.drawable.ic_telestration_arrow_off)
          .setImage(HLTheme.IMAGE_TELESTRATION_MENU_ARROW_ON, R.drawable.ic_telestration_arrow_blank)
          .setImage(HLTheme.IMAGE_TELESTRATION_MENU_ARROW_SOLID, R.drawable.ic_telestration_arrow_on_solid)
          .setImage(HLTheme.IMAGE_TELESTRATION_MENU_ARROW_BORDER, R.drawable.ic_telestration_arrow_on_border)
          .setImage(HLTheme.IMAGE_TELESTRATION_MENU_COLOR_SELECTED, R.drawable.ic_color_donut_filled)
          .setImage(HLTheme.IMAGE_TELESTRATION_MENU_COLOR_UNSELECTED, R.drawable.ic_color_donut)
          .setImage(HLTheme.IMAGE_TELESTRATION_MENU_PEN_OFF, R.drawable.ic_telestration_pen_off)
          .setImage(HLTheme.IMAGE_TELESTRATION_MENU_PEN_ON, R.drawable.ic_telestration_pen_blank)
          .setImage(HLTheme.IMAGE_TELESTRATION_MENU_PEN_SOLID, R.drawable.ic_telestration_pen_on_solid)
          .setImage(HLTheme.IMAGE_TELESTRATION_MENU_PEN_BORDER, R.drawable.ic_telestration_pen_on_border)
          .setImage(HLTheme.IMAGE_TELESTRATION_UNDO, R.drawable.ic_telestration_undo)
          .setImage(HLTheme.IMAGE_END_CALL, R.drawable.ic_phone_end)
          .setImage(HLTheme.IMAGE_MAIN_MENU, R.drawable.ic_menu_white_48dp)
          .setImage(HLTheme.IMAGE_SCREEN_CAPTURE_UNPRESSED, R.drawable.ic_capture_unpressed)
          .setImage(HLTheme.IMAGE_SCREEN_CAPTURE_TRANSITION, R.drawable.ic_capture_transition)
          .setImage(HLTheme.IMAGE_SCREEN_CAPTURE_PRESSED, R.drawable.ic_capture_pressed)
          .setImage(HLTheme.IMAGE_DEFAULT_PROFILE_ICON, R.drawable.ic_user_avatar)
          .setImage(HLTheme.IMAGE_DEBUG_STATS_OFF, R.drawable.ic_debug_stats_off)
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
          .setImage(HLTheme.IMAGE_CAMERA_DISABLED , R.drawable.hltheme_ic_camera_disabled)
          .setImage(HLTheme.IMAGE_DEBUG_STATS_ON, R.drawable.ic_debug_stats_on);

        HLClient.getInstance().setTheme(theme);
    }

    public void onClick(View v) {
        try {
            RequestQueue queue = Volley.newRequestQueue(requireContext());
            if (sessionData == null) {
                if (mMode.equals("contact") && pinEditText.getText().toString().equals("")) {
                    String url = BuildConfig.GALDR_HOST + "/session";
                    JSONObject obj = new JSONObject();
                    obj.put("contact_email", contactEditText.getText());
                    final JsonObjectRequest jsonObjectRequest = new JsonObjectRequest(Request.Method.POST, url, obj,
                      response -> {
                          try {
                              sessionData = getSessionData(response, v.getId() == R.id.join_audio_session);
                              pinEditText.setText(response.getString("sid"));

                              HLClient.getInstance()
                                .startCall(sessionData, rootView.getContext(), SampleInCallService.class, dataCenter)
                                .then(result -> {
                                    rootView.findViewById(R.id.progressBar_cyclic).setVisibility(View.INVISIBLE);
                                }, err -> {
                                    Toast.makeText(rootView.getContext(), ((Exception)err).getMessage(), Toast.LENGTH_SHORT)
                                      .show();
                                });
                          } catch (JSONException e) {
                              e.printStackTrace();
                          }
                      }, error -> Timber.e(error, "volley error")) {
                        @Override
                        public Map<String, String> getHeaders() throws AuthFailureError {
                            Map<String, String> headers = new HashMap<>();
                            headers.put("Authorization", mUserToken);
                            headers.put("ContentType", "application/json; charset=utf-8");
                            return headers;
                        }
                    };
                    jsonObjectRequest.setRetryPolicy(new DefaultRetryPolicy(50000, 5, DefaultRetryPolicy.DEFAULT_BACKOFF_MULT));
                    queue.add(jsonObjectRequest);
                } else {
                    String url = BuildConfig.GALDR_HOST  + "/session?sid=" + pinEditText.getText();
                    final JsonObjectRequest jsonObjectRequest = new JsonObjectRequest(Request.Method.GET, url, null,
                      response -> {
                          try {
                              sessionData = getSessionData(response, v.getId() == R.id.join_audio_session);
                              rootView.findViewById(R.id.progressBar_cyclic).setVisibility(View.VISIBLE);

                              HLClient.getInstance()
                                .startCall(sessionData, rootView.getContext(), SampleInCallService.class, dataCenter)
                                .then(result -> {
                                    rootView.findViewById(R.id.progressBar_cyclic).setVisibility(View.INVISIBLE);
                                }, err -> {
                                    Toast.makeText(rootView.getContext(), ((Exception)err).getMessage(), Toast.LENGTH_SHORT)
                                      .show();
                                });
                          } catch (JSONException e) {
                              e.printStackTrace();
                          }
                      }, error -> Timber.e(error, "volley error")) {
                        @Override
                        public Map<String, String> getHeaders() throws AuthFailureError {
                            Map<String, String> headers = new HashMap<>();
                            headers.put("Authorization", mUserToken);
                            headers.put("ContentType", "application/json; charset=utf-8");
                            return headers;
                        }
                    };
                    queue.add(jsonObjectRequest);
                }
            } else {
                sessionData = renewSessionData(sessionData);
                HLClient.getInstance().startCall(sessionData, rootView.getContext(), SampleInCallService.class, dataCenter)
                  .then(result -> {
                      rootView.findViewById(R.id.progressBar_cyclic).setVisibility(View.INVISIBLE);
                  }, err -> {
                      Toast.makeText(rootView.getContext(), ((Exception)err).getMessage(), Toast.LENGTH_SHORT).show();
                  });
            }
        } catch (JSONException e) {
            e.printStackTrace();
        }
    }
}
