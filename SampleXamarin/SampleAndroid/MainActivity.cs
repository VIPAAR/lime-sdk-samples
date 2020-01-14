using Android.App;
using Android.OS;
using Android.Widget;
using Android.Support.V7.App;
using Android.Content;
using System;
using Android;
using Android.Support.V4.App;
using Android.Support.V4.Content;
using Android.Content.PM;

namespace SampleAndroid
{
    [Activity(Label = "@string/app_name", Theme = "@style/AppTheme", MainLauncher = true)]
    public class MainActivity : AppCompatActivity
    {
        String[] mPerms = {
                Manifest.Permission.Internet,
                Manifest.Permission.WriteExternalStorage,
                Manifest.Permission.Camera,
                Manifest.Permission.RecordAudio,
                Manifest.Permission.Bluetooth
            };

        protected override void OnCreate(Bundle savedInstanceState)
        {
            base.OnCreate(savedInstanceState);
            //Xamarin.Essentials.Platform.Init(this, savedInstanceState);
            // Set our view from the "main" layout resource
            SetContentView(Resource.Layout.activity_main);

            RequestPermissions();

            HLServer.Instance.BaseUrl = Resources.GetString(Resource.String.host);
            string token = "";
            Button autheButton = FindViewById<Button>(Resource.Id.authButton);
            Button callContactButton = FindViewById<Button>(Resource.Id.callContactButton);
            Button callPinButton = FindViewById<Button>(Resource.Id.callPinButton);

            autheButton.Click += (sender, e) => {
                try
                {
                    token = HLServer.Instance.AuthUser(FindViewById<EditText>(Resource.Id.emailText).Text);
                    System.Console.WriteLine(token);

                    Toast.MakeText(this, "Authentication successed!", ToastLength.Short).Show();

                    callContactButton.Enabled = true;
                    callPinButton.Enabled = true;
                } catch(Exception ex)
                {
                    callContactButton.Enabled = false;
                    callPinButton.Enabled = false;
                    Toast.MakeText(this, "Authentication Failed!", ToastLength.Short).Show();
                }
             };

            callContactButton.Click += (sender, e) => {
                Intent join = new Intent(this, typeof(JoinSession));
                join.PutExtra("user_token", token);
                join.PutExtra("mode", "call_contact");
                this.StartActivity(join);
            };

            callPinButton.Click += (sender, e) => {
                Intent join = new Intent(this, typeof(JoinSession));
                join.PutExtra("user_token", token);
                join.PutExtra("mode", "call_pin_code");
                this.StartActivity(join);
            };
        }

        protected override void OnResume()
        {
            base.OnResume();
            RequestPermissions();
        }

        protected void RequestPermissions()
        {
            if (!PermissionGranted())
            {
                ActivityCompat.RequestPermissions(this, mPerms, 1);
            }
        }

        protected bool PermissionGranted()
        {
            bool bRet = true;
            for (int i = 0; i < mPerms.Length; i++)
            {
                if (ContextCompat.CheckSelfPermission(this, mPerms[i]) != Permission.Granted)
                {
                    bRet = false;
                    break;
                }
            }
            return bRet;
        }
    }
}
