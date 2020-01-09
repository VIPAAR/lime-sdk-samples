using System;
using Android.App;
using Android.OS;
using Android.Runtime;
using HelpLightning.SDK;
using System.Threading.Tasks;
using Android;
using Android.Content.PM;
using Android.Widget;
using Android.Views;
using Android.Support.V7.App;
using Android.Support.V4.App;
using Android.Support.V4.Content;

namespace SampleAndroid
{
    [Activity(Label = "@string/app_name", Theme = "@style/AppTheme", MainLauncher = false)]
    public class MainActivity : AppCompatActivity, ICallClientDelegate
    {
        const string HL_SESSION_ID = ("c7baa9fc-3a68-415b-a287-1d37741441dd");
        const string HL_SESSION_TOKEN = ("eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJhdHRyaWJ1dGVzIjpbIm9yZ2FuaXplciJdLCJhdWQiOiJHaGF6YWwiLCJleHAiOjE2MDczMjExMzIsImlhdCI6MTU3NjU2MjczMiwiaXNzIjoiR2hhemFsIiwianRpIjoiNTkwM2U0OTUtNDBkMC00ZjMyLTg3YjUtMGUzMTU1MTM5YWJkIiwibWV0YSI6e30sIm5iZiI6MTU3NjU2MjczMSwib3JpZ2luYXRvciI6NCwicGVtIjp7InNlc3Npb24iOjI1NTl9LCJyZWNvcmRpbmdfcG9saWN5Ijoib3B0X2luIiwic3ViIjoiU2Vzc2lvbjpjN2JhYTlmYy0zYTY4LTQxNWItYTI4Ny0xZDM3NzQxNDQxZGQiLCJ0eXAiOiJhY2Nlc3MiLCJ2ZXIiOiIxMDAifQ.yDzlI0zpikZu4WpoJF8P57n9D0CSK1TfxlVShAydad8");
        const string HL_GSS_URL = ("gss+ssl://containers-asia.helplightning.net:32773");

        const string HL_USER1_TOKEN = ("eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJhdWQiOiJHaGF6YWwiLCJleHAiOjE2MDczMjcwNjUsImlhdCI6MTU3NjU2ODY2NSwiaXNzIjoiR2hhemFsIiwianRpIjoiYWQxOWFmMTUtMjgzZC00N2NlLThmYTEtMjVhNDM1NTEzOThlIiwibWV0YSI6e30sIm5iZiI6MTU3NjU2ODY2NCwicGVtIjp7InVzZXIiOjQ0NzI3OTYxMjg1NDA0NjJ9LCJzdWIiOiJVc2VyOjQiLCJ0eXAiOiJhY2Nlc3MiLCJ2ZXIiOiIxMDAifQ.eAS1IsnV1n-kj0VS-Dk1Ifjpp_580MibHZsf8sJQuBw");
        const string HL_USER1_NAME = ("Small User1");
        const string HL_USER1_AVATAR = ("");

        const string HL_USER2_TOKEN = ("eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJhdWQiOiJHaGF6YWwiLCJleHAiOjE2MDczOTg0NjYsImlhdCI6MTU3NjY0MDA2NiwiaXNzIjoiR2hhemFsIiwianRpIjoiMzkxNjUyMzUtMDc2MS00ZThiLWI2NzQtMmUwODA3MDY0ZjVhIiwibWV0YSI6e30sIm5iZiI6MTU3NjY0MDA2NSwicGVtIjp7InVzZXIiOjQ0NzI3OTYxMjg1NDA0NjJ9LCJzdWIiOiJVc2VyOjUiLCJ0eXAiOiJhY2Nlc3MiLCJ2ZXIiOiIxMDAifQ.wMJNnbK5vQGCZdS5KStzxThabyXtyuzeU5k-08ZaGwM");
        const string HL_USER2_NAME = ("Small User2");

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

            CallClientFactory.Instance.CallClient.Delegate = this;
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

        public void OnCallEnded(Call call, string reason)
        {
            Console.WriteLine("The call ended: " + reason);
        }
    }
}
