
using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using Android;
using Android.App;
using Android.Content.PM;
using Android.OS;
using Android.Runtime;
using Android.Support.V4.App;
using Android.Support.V4.Content;
using Android.Support.V7.App;
using Android.Views;
using Android.Widget;
using HelpLightning.SDK;

namespace SampleAndroid
{
    [Activity(Label = "@string/app_name", Theme = "@style/AppTheme", MainLauncher = false)]
    public class JoinSession : AppCompatActivity, ICallClientDelegate
    {
        String[] mPerms = {
                Manifest.Permission.Internet,
                Manifest.Permission.WriteExternalStorage,
                Manifest.Permission.Camera,
                Manifest.Permission.RecordAudio,
                Manifest.Permission.Bluetooth
            };

        string userToken = "";
        string mode = "";
        protected override void OnCreate(Bundle savedInstanceState)
        {
            base.OnCreate(savedInstanceState);
            SetContentView(Resource.Layout.activity_join_session);

            RequestPermissions();
            CallClientFactory.Instance.CallClient.Delegate = this;

            userToken = Intent.GetStringExtra("user_token");
            mode = Intent.GetStringExtra("mode");
            TextView pinCode = (TextView)FindViewById(Resource.Id.pin_code);
            TextView contact = (TextView)FindViewById(Resource.Id.contact_email);
            TextView pinCodeView = (TextView)FindViewById(Resource.Id.text_pin_code);

            if (mode.Equals("call_contact"))
            {
                FindViewById<View>(Resource.Id.pin_layout).Visibility = ViewStates.Gone;
                pinCode.Visibility = Android.Views.ViewStates.Invisible;
            } else if (mode.Equals("call_pin_code"))
            {
                FindViewById<View>(Resource.Id.contact_email_layout).Visibility = ViewStates.Gone;
                contact.Visibility = Android.Views.ViewStates.Invisible;
            }                    
            
            FindViewById(Resource.Id.btn_start_call).Click += (sender, e) =>
            {
                try
                {
                    string pin = "";
                    if(mode.Equals("call_contact"))
                    {
                        string dialerEmail = contact.Text;
                        pin = HLServer.Instance.CreateCall(userToken, contact.Text);
                        pinCodeView.Text = "You can share pin code with: " + pin;
                    } else if(mode.Equals("call_pin_code"))
                    {
                        pin = pinCode.Text;
                    }
                
                    JoinCall(HLServer.Instance.GetCall(pin, userToken));
                } catch(Exception ex)
                {
                    if (mode.Equals("call_contact"))
                    {
                        Toast.MakeText(this, "Invalid email address.", ToastLength.Short).Show();
                    }
                    else if (mode.Equals("call_pin_code"))
                    {
                        Toast.MakeText(this, "Invalid pin code.", ToastLength.Short).Show();
                    }
                }
            };

            FindViewById(Resource.Id.btn_stop_call).Click += (sender, e) =>
            {
                StopCall();
            };
        }

        public override void OnRequestPermissionsResult(int requestCode, string[] permissions, [GeneratedEnum] Permission[] grantResults)
        {
            //Xamarin.Essentials.Platform.OnRequestPermissionsResult(requestCode, permissions, grantResults);
            base.OnRequestPermissionsResult(requestCode, permissions, grantResults);
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

        private void JoinCall(Call call)
        {
            FindViewById(Resource.Id.progressBar_cyclic).Visibility = Android.Views.ViewStates.Visible;
            Task<bool> task = CallClientFactory.Instance.CallClient.StartCall(call, this);
            task.ContinueWith(t => {
                FindViewById(Resource.Id.progressBar_cyclic).Visibility = Android.Views.ViewStates.Invisible;
                if (t.IsCompleted)
                {
                    Console.WriteLine("The call has started: " + t.Result);
                }
                else
                {
                    Console.Error.WriteLine("Cannot start the call: " + t.Exception);
                }
            });
        }

        private void StopCall()
        {
            FindViewById(Resource.Id.progressBar_cyclic).Visibility = Android.Views.ViewStates.Invisible;
            Task<bool> task = CallClientFactory.Instance.CallClient.StopCurrentCall();
            task.ContinueWith(t => {
                if (t.IsCompleted)
                {
                    Console.WriteLine("The call has stopped: " + t.Result);
                }
                else
                {
                    Console.Error.WriteLine("Cannot Stop the call: " + t.Exception);
                }
            });
        }

        public void OnCallEnded(Call call, string reason)
        {
            Console.WriteLine("The call ended: " + reason);
        }
    }
}
