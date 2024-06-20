package com.vipaar.lime.samplehl;

import android.os.Bundle;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.fragment.app.Fragment;
import timber.log.Timber;

import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Button;
import android.widget.TextView;
import android.widget.Toast;

import com.android.volley.Request;
import com.android.volley.RequestQueue;
import com.android.volley.toolbox.JsonObjectRequest;
import com.android.volley.toolbox.Volley;

import java.io.UnsupportedEncodingException;
import java.net.URLEncoder;

import org.json.JSONException;

public class MainFragment extends Fragment {

    private String mUserToken;

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        // Inflate the layout for this fragment
        return inflater.inflate(R.layout.fragment_main, container, false);
    }

    public void onViewCreated(@NonNull View view, @Nullable Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);
        Button authButton = view.findViewById(R.id.button);
        Button callContactButton = view.findViewById(R.id.button2);
        Button callPinButton = view.findViewById(R.id.button3);
        TextView email = view.findViewById(R.id.email_edit_text);
        RequestQueue queue = Volley.newRequestQueue(requireContext());

        authButton.setOnClickListener(v -> {
            JsonObjectRequest jsonObjectRequest = null;
            try {
                jsonObjectRequest = new JsonObjectRequest(
                  Request.Method.GET,
                  BuildConfig.GALDR_HOST + "/auth?email=" + URLEncoder.encode(email.getText().toString(), "UTF-8"),
                  null,
                  response -> {
                      try {
                          mUserToken = response.getString("token");
                          callContactButton.setEnabled(true);
                          callPinButton.setEnabled(true);
                          Toast.makeText(view.getContext(), "Authentication succeed!", Toast.LENGTH_SHORT).show();
                      } catch (JSONException e) {
                          callContactButton.setEnabled(false);
                          callPinButton.setEnabled(false);
                          Toast.makeText(view.getContext(), "Authentication Failed!", Toast.LENGTH_SHORT).show();
                      }
                  }, error -> {
                    callContactButton.setEnabled(false);
                    callPinButton.setEnabled(false);
                    Toast.makeText(view.getContext(), "Authentication Failed!", Toast.LENGTH_SHORT).show();
                });
            } catch (UnsupportedEncodingException e) {
                e.printStackTrace();
            }
            queue.add(jsonObjectRequest);
        });

        callContactButton.setOnClickListener(v -> ((MainActivity)getActivity()).joinCallClicked("contact", mUserToken));
        callPinButton.setOnClickListener(v -> ((MainActivity)getActivity()).joinCallClicked("pin", mUserToken));

    }
}
