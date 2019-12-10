using System;
using Android.App;
using Android.OS;
using Android.Runtime;
using HelpLightning.SDK;
using System.Threading.Tasks;
using AndroidX.AppCompat.App;
using Android;
using AndroidX.Core.Content;
using AndroidX.Core.App;
using Android.Content.PM;
using Android.Widget;
using Android.Views;

namespace SampleAndroid
{
    [Activity(Label = "@string/app_name", Theme = "@style/AppTheme", MainLauncher = false)]
    public class MainActivity : AppCompatActivity
    {
        const string HL_SESSION_ID = ("c6d553ed-1feb-4e1c-b1a7-e85a5de04c31");
        const string HL_SESSION_TOKEN = ("eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJhdHRyaWJ1dGVzIjpbIm9yZ2FuaXplciJdLCJhdWQiOiJHaGF6YWwiLCJleHAiOjE2MDY4Nzc1MjUsImlhdCI6MTU3NTM0MTUyNSwiaXNzIjoiR2hhemFsIiwianRpIjoiNjhjOWMzN2UtNmNjNC00YTA5LTgyZjctOTQ1OTBhYWM4ZWQ4IiwibWV0YSI6e30sIm5iZiI6MTU3NTM0MTUyNCwib3JpZ2luYXRvciI6MTYsInBlbSI6eyJzZXNzaW9uIjoyNTU5fSwicmVjb3JkaW5nX3BvbGljeSI6ImFsd2F5c19vbiIsInN1YiI6IlNlc3Npb246YzZkNTUzZWQtMWZlYi00ZTFjLWIxYTctZTg1YTVkZTA0YzMxIiwidHlwIjoiYWNjZXNzIiwidmVyIjoiMTAwIn0.JOsIvRD0zHjChsikzQPbh52HDjXlnUq-BwVjl8nBjYA");
        const string HL_GSS_URL = ("gss+ssl://containers-asia.helplightning.net:32773");

        const string HL_USER1_TOKEN = ("eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJhdWQiOiJHaGF6YWwiLCJleHAiOjE2MDY4Nzc0NTIsImlhdCI6MTU3NTM0MTQ1MiwiaXNzIjoiR2hhemFsIiwianRpIjoiZmI2YTIzZWEtYjM0Yy00NjFiLWEyYmEtNmE0ZTE3OGMyZDgzIiwibWV0YSI6e30sIm5iZiI6MTU3NTM0MTQ1MSwicGVtIjp7InVzZXIiOjEyMzU3NjUxNzY4OTExODJ9LCJzdWIiOiJVc2VyOjE1IiwidHlwIjoiYWNjZXNzIiwidmVyIjoiMTAwIn0.74szAWHDyUc_JCsYeeyeDlwabG21rCDVDv5luSG1DFM");
        const string HL_USER1_NAME = ("Small User12");
        const string HL_USER1_AVATAR = ("");

        const string HL_USER2_TOKEN = ("eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJhdWQiOiJHaGF6YWwiLCJleHAiOjE2MDY4Nzc0NzgsImlhdCI6MTU3NTM0MTQ3OCwiaXNzIjoiR2hhemFsIiwianRpIjoiZmYwMjc3YTUtNTY5Zi00NDYxLTg5NzAtODZmODFiNjY2MTIyIiwibWV0YSI6e30sIm5iZiI6MTU3NTM0MTQ3NywicGVtIjp7InVzZXIiOjEyMzU3NjUxNzY4OTExODJ9LCJzdWIiOiJVc2VyOjE2IiwidHlwIjoiYWNjZXNzIiwidmVyIjoiMTAwIn0.NPgjGjUzi6Nit2vg5TY1llpTgu1WHtlfsjsTVmtw5rI");
        const string HL_USER2_NAME = ("Small User13");

        const string HL_USER2_AVATAR = ("");

        private EditText SessionId;
        private EditText SessionToken;
        private EditText GssUrl;
        private EditText UserToken;
        private EditText UserName;
        private EditText UserAvatar;
        private RadioGroup UserGroup;
        private Button JoinButton;
        private Button CancelButton;


        protected override void OnCreate(Bundle savedInstanceState)
        {
            base.OnCreate(savedInstanceState);
            //Xamarin.Essentials.Platform.Init(this, savedInstanceState);
            // Set our view from the "main" layout resource
            SetContentView(Resource.Layout.activity_main);
            SessionId = FindViewById<EditText>(Resource.Id.etSessionId);
            SessionToken = FindViewById<EditText>(Resource.Id.etSessionToken);
            GssUrl = FindViewById<EditText>(Resource.Id.etGssUrl);
            UserToken = FindViewById<EditText>(Resource.Id.etUserToken);
            UserName = FindViewById<EditText>(Resource.Id.etUserName);
            UserAvatar = FindViewById<EditText>(Resource.Id.etUserAvatar);
            UserGroup = FindViewById<RadioGroup>(Resource.Id.rgUsers);
            JoinButton = FindViewById<Button>(Resource.Id.btnJoin);
            CancelButton = FindViewById<Button>(Resource.Id.btnCancel);

            SessionId.Text = HL_SESSION_ID;
            SessionToken.Text = HL_SESSION_TOKEN;
            GssUrl.Text = HL_GSS_URL;
            SetUserInfo(0);

        }

        public override void OnRequestPermissionsResult(int requestCode, string[] permissions, [GeneratedEnum] Permission[] grantResults)
        {
            //Xamarin.Essentials.Platform.OnRequestPermissionsResult(requestCode, permissions, grantResults);
            base.OnRequestPermissionsResult(requestCode, permissions, grantResults);

            bool readyForCall = true;
            foreach (Permission permission in grantResults)
            {
                if (permission != Permission.Granted)
                {
                    readyForCall = false;
                    break;
                } 
            }
            if (readyForCall)
            {
                MakeCall();
            }

        }

        private void MakeCall()
        {
            Call call = new Call(SessionId.Text, SessionToken.Text, UserToken.Text, GssUrl.Text, UserName.Text, UserAvatar.Text);
            Task<bool> task = CallClientFactory.Instance.CallClient.StartCall(call, this);
            task.ContinueWith(t => {
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

        private void SetUserInfo(int userIndex)
        {
            if (userIndex == 0)
            {
                UserToken.Text = HL_USER1_TOKEN;
                UserName.Text = HL_USER1_NAME;
                UserAvatar.Text = HL_USER1_AVATAR;
            }
            else
            {
                UserToken.Text = HL_USER2_TOKEN;
                UserName.Text = HL_USER2_NAME;
                UserAvatar.Text = HL_USER2_AVATAR;
            }
        }

        [Java.Interop.Export("JoinCall")]
        public void JoinCall(View view)
        {
            if (ContextCompat.CheckSelfPermission(this, Manifest.Permission.Camera) == Permission.Granted
                && ContextCompat.CheckSelfPermission(this, Manifest.Permission.RecordAudio) == Permission.Granted)
            {
                MakeCall();
            }
            else
            {
                ActivityCompat.RequestPermissions(this, new string[] { Manifest.Permission.Camera, Manifest.Permission.RecordAudio }, 1);
            }
        }

        [Java.Interop.Export("CancelCall")]
        public void CancelCall(View view)
        {
            Task<bool> task = CallClientFactory.Instance.CallClient.StopCurrentCall();
            task.ContinueWith(t => {
                if (t.IsCompleted)
                {
                    Console.WriteLine("The call has stopped: " + t.Result);
                }
                else
                {
                    Console.Error.WriteLine("Cannot stop the call: " + t.Exception);
                }
            });
        }

        [Java.Interop.Export("SelectUser1")]
        public void SelectUser1(View view)
        {
            SetUserInfo(0);
        }

        [Java.Interop.Export("SelectUser2")]
        public void SelectUser2(View view)
        {
            SetUserInfo(1);
        }
    }
}
