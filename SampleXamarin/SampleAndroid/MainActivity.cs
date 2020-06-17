using Android.App;
using Android.OS;
using System;
using Android;
using Android.Content.PM;
using AndroidX.AppCompat.App;
using AndroidX.Core.Content;
using AndroidX.Core.App;

namespace HelpLightning.SDK.Sample.Android
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

            CallClientFactory.Instance.CallClient.Theme = new Theme()
                    //.SetImage(HelpLightning.SDK.Theme.ImageCameraMenuBackCameraOff, Resource.Drawable.image_test)
                    //.SetImage(HelpLightning.SDK.Theme.ImageCameraMenuBackCameraOn, Resource.Drawable.image_test)
                    // .SetImage(HelpLightning.SDK.Theme.ImageCameraMenuCameraOff, Resource.Drawable.image_test)
                    // .SetImage(HelpLightning.SDK.Theme.ImageCameraMenuFreezeOff, Resource.Drawable.image_test)
                    //.SetImage(HelpLightning.SDK.Theme.ImageCameraMenuFreezeOn, Resource.Drawable.image_test)
                    // .SetImage(HelpLightning.SDK.Theme.ImageCameraMenuFrontCameraOff, Resource.Drawable.image_test)
                    // .SetImage(HelpLightning.SDK.Theme.ImageCameraMenuFrontCameraOn, Resource.Drawable.image_test)
                    // .SetImage(HelpLightning.SDK.Theme.ImageCameraMenuPhotoOff, Resource.Drawable.image_test)
                    //  .SetImage(HelpLightning.SDK.Theme.ImageCameraMenuPhotoOn, Resource.Drawable.image_test)
                    //  .SetImage(HelpLightning.SDK.Theme.ImageCameraMenuSwitchCamera, Resource.Drawable.image_test)
                    //  .SetImage(HelpLightning.SDK.Theme.ImageMainMenuDocumentOff, Resource.Drawable.image_test)
                    //  .SetImage(HelpLightning.SDK.Theme.ImageMainMenuDocumentOn, Resource.Drawable.image_test)
                    //  .SetImage(HelpLightning.SDK.Theme.ImageMainMenuTorchOff, Resource.Drawable.image_test)
                    //  .SetImage(HelpLightning.SDK.Theme.ImageMainMenuTorchOn, Resource.Drawable.image_test)
                    //  .SetImage(HelpLightning.SDK.Theme.ImageMicOff, Resource.Drawable.image_test)
                    //  .SetImage(HelpLightning.SDK.Theme.ImageMicOn, Resource.Drawable.image_test)
                    // .SetImage(HelpLightning.SDK.Theme.ImageModeMenuFaceToFaceOff, Resource.Drawable.image_test)
                    //  .SetImage(HelpLightning.SDK.Theme.ImageModeMenuFaceToFaceOn, Resource.Drawable.image_test)
                    //  .SetImage(HelpLightning.SDK.Theme.ImageModeMenuGiverOff, Resource.Drawable.image_test)
                    //  .SetImage(HelpLightning.SDK.Theme.ImageModeMenuGiverOn, Resource.Drawable.image_test)
                    //  .SetImage(HelpLightning.SDK.Theme.ImageModeMenuReceiverOff, Resource.Drawable.image_test)
                    //  .SetImage(HelpLightning.SDK.Theme.ImageModeMenuReceiverOn, Resource.Drawable.image_test)
                    //  .SetImage(HelpLightning.SDK.Theme.ImageTelestrationClearAll, Resource.Drawable.image_test)
                    //  .SetImage(HelpLightning.SDK.Theme.ImageTelestrationMenuArrowOff, Resource.Drawable.image_test)
                    //  .SetImage(HelpLightning.SDK.Theme.ImageTelestrationMenuArrowOn, Resource.Drawable.image_test)
                    //  .SetImage(HelpLightning.SDK.Theme.ImageTelestrationMenuColorSelected, Resource.Drawable.image_test)
                    //  .SetImage(HelpLightning.SDK.Theme.ImageTelestrationMenuColorUnselected, Resource.Drawable.image_test)
                    //  .SetImage(HelpLightning.SDK.Theme.ImageTelestrationMenuPenOff, Resource.Drawable.image_test)
                    //  .SetImage(HelpLightning.SDK.Theme.ImageTelestrationMenuPenOn, Resource.Drawable.image_test)
                    //   .SetImage(HelpLightning.SDK.Theme.ImageTelestrationUndo, Resource.Drawable.image_test)
                    .SetImage(HelpLightning.SDK.Theme.ImageEndCall, ContextCompat.GetDrawable(this.BaseContext, Resource.Drawable.image_test))
                    .SetImage(HelpLightning.SDK.Theme.ImageMainMenu, Resource.Drawable.image_test)
                    .SetImage(HelpLightning.SDK.Theme.imageScreenCaptureButton1, Resource.Drawable.image_test)
                    .SetImage(HelpLightning.SDK.Theme.imageScreenCaptureButton2, Resource.Drawable.image_test2)
                    .SetImage(HelpLightning.SDK.Theme.imageScreenCaptureButton3, Resource.Drawable.image_test3);

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
            var ft = base.SupportFragmentManager.BeginTransaction();
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
