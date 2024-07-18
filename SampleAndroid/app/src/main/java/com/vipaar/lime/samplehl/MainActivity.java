package com.vipaar.lime.samplehl;

import android.Manifest;
import android.content.Intent;
import android.net.Uri;
import android.os.Bundle;
import android.provider.Settings;

import androidx.annotation.NonNull;
import androidx.core.app.ActivityCompat;
import androidx.fragment.app.FragmentManager;
import androidx.fragment.app.FragmentTransaction;
import androidx.appcompat.app.AppCompatActivity;
import com.google.android.material.dialog.MaterialAlertDialogBuilder;

import android.widget.Toast;

import com.vipaar.lime.hlsdk.misc.PermissionsUtil;

public class MainActivity extends AppCompatActivity {

    private static final int REQUEST_APP_SETTINGS = 1;

    private static final int REQUEST_CODE_CAMERA_MICROPHONE = 1;
    private static final int REQUEST_CODE_CAMERA = 2;
    private static final int REQUEST_CODE_MICROPHONE = 3;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);
        if (savedInstanceState == null) {
            FragmentManager fm = getSupportFragmentManager();
            FragmentTransaction ft = fm.beginTransaction();
            MainFragment fragment = new MainFragment();
            ft.replace(R.id.fragment_container, fragment);
            ft.commit();
        }
    }

    @Override
    protected void onResume() {
        super.onResume();
        requestPermissions();
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        if (requestCode == REQUEST_APP_SETTINGS) {
            if (PermissionsUtil.checkCameraMicrophonePermissions(this)) {
                // permission granted
                Toast.makeText(this, R.string.toastPermsGranted, Toast.LENGTH_SHORT).show();
            } else {
                Toast.makeText(this, R.string.toastPermsNotGranted, Toast.LENGTH_SHORT).show();
            }
        }
        super.onActivityResult(requestCode, resultCode, data);
    }

    @Override
    public void onRequestPermissionsResult(int requestCode, @NonNull String[] permissions, @NonNull int[] grantResults) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults);
        switch (requestCode) {
        case REQUEST_CODE_CAMERA_MICROPHONE:
            if (!PermissionsUtil.verifyPermissions(grantResults)) {
                boolean showRationale =
                  ActivityCompat.shouldShowRequestPermissionRationale(this, Manifest.permission.CAMERA) ||
                    ActivityCompat
                      .shouldShowRequestPermissionRationale(this, Manifest.permission.RECORD_AUDIO);
                if (!showRationale) {
                    // User Denied permission with "Never show again" checkbox, so we need
                    // to send the user to the phone settings here.
                    Toast.makeText(this, R.string.toastPermsNotGranted, Toast.LENGTH_SHORT).show();

                    startSettingsActivity();

                } else {
                    showRationaleAlertDialog();
                }
            } else {
                Toast.makeText(this, R.string.toastThanks, Toast.LENGTH_SHORT).show();
            }
            break;
        case REQUEST_CODE_CAMERA:
            if (!PermissionsUtil.checkCameraPermission(this)) {
                boolean showRationale =
                  ActivityCompat.shouldShowRequestPermissionRationale(this, Manifest.permission.CAMERA);
                if (!showRationale) {
                    // User Denied permission with "Never show again" checkbox, so we need
                    // to send the user to the phone settings here.
                    Toast.makeText(this, R.string.toastPermsNotGranted, Toast.LENGTH_SHORT).show();

                    startSettingsActivity();

                } else {
                    showRationaleAlertDialog();
                }
            } else {
                Toast.makeText(this, R.string.toastThanks, Toast.LENGTH_SHORT).show();
            }
            break;
        case REQUEST_CODE_MICROPHONE:
            if (!PermissionsUtil.checkMicrophonePermission(this)) {
                boolean showRationale = ActivityCompat
                  .shouldShowRequestPermissionRationale(this, Manifest.permission.RECORD_AUDIO);
                if (!showRationale) {
                    // User Denied permission with "Never show again" checkbox, so we need
                    // to send the user to the phone settings here.
                    Toast.makeText(this, R.string.toastPermsNotGranted, Toast.LENGTH_SHORT).show();

                    startSettingsActivity();

                } else {
                    showRationaleAlertDialog();
                }
            } else {
                Toast.makeText(this, R.string.toastThanks, Toast.LENGTH_SHORT).show();
            }
            break;
        }
    }

    private void requestPermissions() {
        if (!PermissionsUtil.checkCameraPermission(this) &&
          !PermissionsUtil.checkMicrophonePermission(this)) {
            ActivityCompat.requestPermissions(
              this,
              new String[] {
                Manifest.permission.CAMERA,
                Manifest.permission.RECORD_AUDIO
              },
              REQUEST_CODE_CAMERA_MICROPHONE
            );
        } else if (!PermissionsUtil.checkCameraPermission(this) &&
          PermissionsUtil.checkMicrophonePermission(this)) {
            ActivityCompat.requestPermissions(
              this,
              new String[] {
                Manifest.permission.CAMERA
              },
              REQUEST_CODE_CAMERA
            );
        } else if (PermissionsUtil.checkCameraPermission(this) &&
          !PermissionsUtil.checkMicrophonePermission(this)) {
            ActivityCompat.requestPermissions(
              this,
              new String[] {
                Manifest.permission.RECORD_AUDIO
              },
              REQUEST_CODE_MICROPHONE
            );
        }
    }

    private void showRationaleAlertDialog() {
        MaterialAlertDialogBuilder builder = new MaterialAlertDialogBuilder(this);
        builder.setTitle(R.string.permsExplanationAlertTitle);
        builder.setCancelable(false);
        builder.setMessage(R.string.permsExplanationAlertMessage);
        builder.setPositiveButton(android.R.string.ok, (dialog, which) -> requestPermissions());
        builder.create().show();
    }

    private void startSettingsActivity() {
        Intent intent = new Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS);
        Uri uri = Uri.fromParts("package", getPackageName(), null);

        intent.setData(uri);
        startActivityForResult(intent, REQUEST_APP_SETTINGS);
    }

    public void joinCallClicked(String mode, String userToken) {
        FragmentManager fm = getSupportFragmentManager();
        FragmentTransaction ft = fm.beginTransaction();
        JoinSessionFragment fragment = JoinSessionFragment.newInstance(userToken, mode);
        ft.replace(R.id.fragment_container, fragment);
        ft.commit();
    }
}
