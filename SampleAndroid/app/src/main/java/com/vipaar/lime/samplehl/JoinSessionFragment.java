package com.vipaar.lime.samplehl;

import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ProgressBar;
import android.widget.Toast;

import com.vipaar.lime.hlsdk.HLTheme;
import com.vipaar.lime.hlsdk.client.HLCall;
import com.vipaar.lime.hlsdk.client.HLClient;
import com.vipaar.lime.hlsdk.core.android_util.miniview.OngoingCallInfo;
import com.vipaar.lime.hlsdk.misc.Environment;

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
import androidx.appcompat.widget.SwitchCompat;
import androidx.fragment.app.Fragment;
import androidx.lifecycle.Observer;
import timber.log.Timber;

public class JoinSessionFragment extends Fragment {

    // Views
    Button joinButton;
    Button leaveButton;
    SwitchCompat autoEnableCameraSwitch;
    SwitchCompat autoEnableMicSwitch;
    SwitchCompat enableMiniviewSwitch;
    EditText contactEditText;
    EditText pinEditText;
    ProgressBar progressBar;
    OngoingCallMiniView ongoingCallMiniView;

    HLCall sessionData;

    private static final String ARG_USER_TOKEN = "user_token";
    private static final String ARG_CALL_MODE = "mode";

    private String mUserToken;
    private String mMode;

    private final Environment.DataCenter DATA_CENTER = Environment.DEFAULT_DATACENTER;

    public static JoinSessionFragment newInstance(String param1, String param2) {
        JoinSessionFragment fragment = new JoinSessionFragment();
        Bundle args = new Bundle();
        args.putString(ARG_USER_TOKEN, param1);
        args.putString(ARG_CALL_MODE, param2);
        fragment.setArguments(args);
        return fragment;
    }

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        sessionData = null;
        if (getArguments() != null) {
            mUserToken = getArguments().getString(ARG_USER_TOKEN);
            mMode = getArguments().getString(ARG_CALL_MODE);
        }
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
      Bundle savedInstanceState) {
        // Inflate the layout for this fragment
        return inflater.inflate(R.layout.fragment_join_session, container, false);
    }

    public void onViewCreated(@NonNull View view, @Nullable Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);

        initUI(view);

        if (mMode.equals("contact")) {
            pinEditText.setEnabled(false);
        } else {
            contactEditText.setEnabled(false);
        }

        HLTheme theme = Utils.createTheme();
        HLClient.INSTANCE.setTheme(theme);

        joinButton.setOnClickListener(v -> {
            joinSession();
        });

        leaveButton.setOnClickListener(v -> {
            leaveSession();
        });

        ongoingCallMiniView.setOngoingCallListener(new OngoingCallListener() {
            public void onMaximizeCall() {
                HLClient.INSTANCE.returnToActiveCall();
            }

            public void onEndCall() {
                HLClient.INSTANCE.endActiveCall(getActivity());
            }
        });

        // Observer miniview data
        HLClient.INSTANCE.getMinimizedCall().observe(getViewLifecycleOwner(), new Observer<OngoingCallInfo>() {
            public void onChanged(OngoingCallInfo ongoingCallInfo) {
                if (ongoingCallInfo != null) {
                    ongoingCallMiniView.setCallInfo(ongoingCallInfo.getMiniView(), ongoingCallInfo.getCallTitle());
                } else {
                    ongoingCallMiniView.setCallInfo(null, null);
                }
            }
        });
    }

    private void joinSession() {
        try {
            if (sessionData == null) {
                createSessionAndStartCall();
            } else {
                renewSessionAndStartCall();
            }
        } catch (JSONException e) {
            Timber.e(e);
        }
    }

    private void renewSessionAndStartCall() {
        sessionData = renewSessionData(sessionData);
        HLClient.INSTANCE.startCall(sessionData, getContext(), SampleInCallService.class, DATA_CENTER)
          .then(result -> {
              progressBar.setVisibility(View.INVISIBLE);
          }, err -> {
              Toast.makeText(getContext(), ((Exception)err).getMessage(), Toast.LENGTH_SHORT).show();
          });
    }

    private void createSessionAndStartCall() throws JSONException {
        RequestQueue queue = Volley.newRequestQueue(requireContext());
        if (mMode.equals("contact") && pinEditText.getText().toString().isEmpty()) {
            String url = BuildConfig.GALDR_HOST + "/session";
            JSONObject obj = new JSONObject();
            obj.put("contact_email", contactEditText.getText());
            final JsonObjectRequest jsonObjectRequest = createContactRequest(url, obj);
            queue.add(jsonObjectRequest);
        } else {
            String url = BuildConfig.GALDR_HOST + "/session?sid=" + pinEditText.getText();
            final JsonObjectRequest jsonObjectRequest = createPinRequest(url);
            queue.add(jsonObjectRequest);
        }
    }

    @NonNull
    private JsonObjectRequest createPinRequest(String url) {
        return new JsonObjectRequest(Request.Method.GET, url, null,
          response -> {
              try {
                  sessionData = getSessionData(response);
                  progressBar.setVisibility(View.VISIBLE);
                  startCall();
              } catch (JSONException e) {
                  Timber.e(e);
              }
          }, Timber::e) {
            @Override
            public Map<String, String> getHeaders() {
                Map<String, String> headers = new HashMap<>();
                headers.put("Authorization", mUserToken);
                headers.put("ContentType", "application/json; charset=utf-8");
                return headers;
            }
        };
    }

    @NonNull
    private JsonObjectRequest createContactRequest(String url, JSONObject obj) {
        final JsonObjectRequest jsonObjectRequest = new JsonObjectRequest(Request.Method.POST, url, obj,
          response -> {
              try {
                  sessionData = getSessionData(response);
                  pinEditText.setText(response.getString("sid"));
                  startCall();
              } catch (JSONException e) {
                  Timber.e(e);
              }
          }, Timber::e) {
            @Override
            public Map<String, String> getHeaders() {
                Map<String, String> headers = new HashMap<>();
                headers.put("Authorization", mUserToken);
                headers.put("ContentType", "application/json; charset=utf-8");
                return headers;
            }
        };
        jsonObjectRequest.setRetryPolicy(new DefaultRetryPolicy(50000, 5, DefaultRetryPolicy.DEFAULT_BACKOFF_MULT));
        return jsonObjectRequest;
    }

    private void startCall() {
        HLClient.INSTANCE
          .startCall(sessionData, getContext(), SampleInCallService.class, DATA_CENTER)
          .then(result -> {
              progressBar.setVisibility(View.INVISIBLE);
          }, err -> {
              Toast.makeText(getContext(), ((Exception)err).getMessage(), Toast.LENGTH_SHORT).show();
          });
    }

    private void leaveSession() {
        try {
            progressBar.setVisibility(View.INVISIBLE);
            HLClient.INSTANCE.stopCurrentCall();
        } catch (Exception e) {
            Timber.e(e);
            Toast.makeText(getContext(), "Error", Toast.LENGTH_SHORT).show();
        }
    }

    private void initUI(@NonNull View view) {
        autoEnableCameraSwitch = view.findViewById(R.id.cameraSwitch);
        autoEnableMicSwitch = view.findViewById(R.id.audioSwitch);
        enableMiniviewSwitch = view.findViewById(R.id.miniviewSwitch);
        contactEditText = view.findViewById(R.id.contact_edit_text);
        pinEditText = view.findViewById(R.id.pin_edit_text);
        joinButton = view.findViewById(R.id.join_session);
        leaveButton = view.findViewById(R.id.leave_session);
        progressBar = view.findViewById(R.id.progressBar_cyclic);
        ongoingCallMiniView = view.findViewById(R.id.minimized_call_view);
    }

    private HLCall getSessionData(JSONObject json) throws JSONException {
        return Utils.getSessionData(json, autoEnableCameraSwitch.isChecked(), autoEnableMicSwitch.isChecked(),
          enableMiniviewSwitch.isChecked());
    }

    private HLCall renewSessionData(HLCall call) {
        return Utils.renewSessionData(call, autoEnableCameraSwitch.isChecked(), autoEnableMicSwitch.isChecked(),
          enableMiniviewSwitch.isChecked());
    }
}
