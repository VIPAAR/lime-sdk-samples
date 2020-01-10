
using System;
using System.Collections;
using System.Collections.Generic;
using System.IO;
using System.Net;
using System.Threading.Tasks;
using Android;
using Android.App;
using Android.Content.PM;
using Android.OS;
using Android.Runtime;
using Android.Support.V4.App;
using Android.Support.V4.Content;
using Android.Support.V7.App;
using Android.Widget;
using HelpLightning.SDK;
using Newtonsoft.Json.Linq;

namespace SampleAndroid
{
    [Activity(Label = "@string/app_name", Theme = "@style/AppTheme", MainLauncher = true)]
    public class FakeSample : AppCompatActivity, ICallClientDelegate
    {
        String[] mPerms = {
                Manifest.Permission.Internet,
                Manifest.Permission.WriteExternalStorage,
                Manifest.Permission.Camera,
                Manifest.Permission.RecordAudio,
                Manifest.Permission.Bluetooth
            };

        string userToken = "";

        protected override void OnCreate(Bundle savedInstanceState)
        {
            base.OnCreate(savedInstanceState);
            SetContentView(Resource.Layout.activity_join_session);
            TextView pinCode = (TextView)FindViewById(Resource.Id.txt_pin_code_edit);
            TextView dialer = (TextView)FindViewById(Resource.Id.txt_pin_code_edit);
            TextView receiver = (TextView)FindViewById(Resource.Id.txt_receiver_email_edit);

            FindViewById(Resource.Id.btn_create_session).Click += (sender, e) => {
                string dialerEmail = dialer.Text;
                userToken = AuthUser(dialerEmail);
                string contactEmail = receiver.Text;
                pinCode.Text = CreateCall(userToken, contactEmail, dialerEmail);
            };
            CallClientFactory.Instance.CallClient.Delegate = this;
            
            IDictionary<string, object> images = new JavaDictionary<string, object>();
            images.Add("FACE_TO_FACE_ICON", Resource.Drawable.ic_f2f_on_test_48dp);

            IDictionary<string, IDictionary<string, object>> themes =
                new JavaDictionary<string, IDictionary<string, object>>();
            themes.Add("images", images);

            CallClientFactory.Instance.CallClient.Theme = themes;

            RequestPermissions();

            FindViewById(Resource.Id.btn_join_session).Click += (sender, e) =>
            {
                JoinCall(GetCall(pinCode.Text, ));
            };

            FindViewById(Resource.Id.btn_leave_session).Click += (sender, e) =>
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

        protected string AuthUser(string email)
        {
            JObject json = RequestJsonData("/auth?email=" + email, "GET");
            return json["token"].ToString();
        }

        protected String CreateCall(string userToken, string contactEmail, string userName = "user")
        {
            Dictionary<string, string> headers = new Dictionary<string, string>();
            headers.Add("Authorization", userToken);
            string args = String.Format(@"\{{'contact_email':'{0}'\}}", contactEmail);
            JObject json = RequestJsonData("/session", "POST", headers, args);
            return json["sid"].ToString();
        }

        protected Call GetCall(string pinCode, string userToken, string userName = "user")
        {
            Dictionary<string, string> headers = new Dictionary<string, string>();
            headers.Add("Authorization", userToken);
            JObject json = RequestJsonData("/session?sid=" + pinCode, "GET");
            return new Call
            (
                json["session_id"].ToString(),
                json["session_token"].ToString(),
                json["user_token"].ToString(),
                json["url"].ToString(),
                userName,
                "https://www.securenvoy.com/sites/default/files/legacy-uploads/2013/10/pizza_hut_logo.jpg"
            );
        }

        public JObject RequestJsonData(String path, String method, Dictionary<string, string> headers = null, string bodyArgs = "")
        {
            var httpWebRequest = (HttpWebRequest)WebRequest.Create(Resources.GetString(Resource.String.host) + path);
            httpWebRequest.ContentType = "application/json; charset=utf-8";
            httpWebRequest.Method = method;
            if(headers != null)
            {
                foreach (var item in headers)
                {
                    httpWebRequest.Headers.Add(item.Key, item.Value);
                }
            }
            using (var streamWriter = new StreamWriter(httpWebRequest.GetRequestStream()))
            {
                streamWriter.Write(bodyArgs);
            }
            var httpResponse = (HttpWebResponse)httpWebRequest.GetResponse();
            using (var streamReader = new StreamReader(httpResponse.GetResponseStream()))
            {
                var responseText = streamReader.ReadToEnd();
                return JObject.Parse(responseText);
            }
        }

        public void OnCallEnded(Call call, string reason)
        {
            Console.WriteLine("The call ended: " + reason);
        }
    }
}
