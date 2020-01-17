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

            SupportFragmentManager
                .BeginTransaction()
                .Replace(Resource.Id.fragment_container, new Authentication())
                .Commit();

            RequestPermissions();
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

        public void JoinSessionClicked(string mode, string userToken)
        {
            Android.Support.V4.App.FragmentManager fm = base.SupportFragmentManager;
            Android.Support.V4.App.FragmentTransaction ft = fm.BeginTransaction();
            JoinSession fragment = new JoinSession();
            Bundle args = new Bundle();
            args.PutString("user_token", userToken);
            args.PutString("mode", mode);
            fragment.Arguments = args;
            ft.Replace(Resource.Id.fragment_container, fragment);
            ft.AddToBackStack(null);
            ft.Commit();
        }
    }
}
