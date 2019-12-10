
using System;
using System.IO;
using System.Net;
using System.Threading.Tasks;
using Android;
using Android.App;
using Android.Content.PM;
using Android.OS;
using Android.Runtime;
using Android.Widget;
using AndroidX.AppCompat.App;
using AndroidX.Core.App;
using AndroidX.Core.Content;
using HelpLightning.SDK;
using Newtonsoft.Json.Linq;

namespace SampleAndroid
{
    [Activity(Label = "@string/app_name", Theme = "@style/AppTheme", MainLauncher = true)]
    public class FakeSample : AppCompatActivity
    {
        private static String FAKE_CREATE_URL = "http://192.168.2.110:8777/session";
        private static String FAKE_JOIN_URL = "http://192.168.2.110:8777/session?sid={0}";
        private bool permissionGranted = false;
        
        protected override void OnCreate(Bundle savedInstanceState)
        {
            base.OnCreate(savedInstanceState);
            SetContentView(Resource.Layout.activity_join_session);
            TextView sessionIdTxt = (TextView)FindViewById(Resource.Id.session_id_edit_text);
            FindViewById(Resource.Id.create_session).Click += (sender, e) => {
                string s = GetSessionId();
                Toast.MakeText(this, s, 0);
                sessionIdTxt.Text = s;
            };
            FindViewById(Resource.Id.join_session).Click += (sender, e) => {
                if (permissionGranted)
                {
                    JoinCall(GetCallData(sessionIdTxt.Text));
                }
            };
        }

        public override void OnRequestPermissionsResult(int requestCode, string[] permissions, [GeneratedEnum] Permission[] grantResults)
        {
            //Xamarin.Essentials.Platform.OnRequestPermissionsResult(requestCode, permissions, grantResults);
            base.OnRequestPermissionsResult(requestCode, permissions, grantResults);

            foreach (Permission permission in grantResults)
            {
                permissionGranted = true;
                if (permission != Permission.Granted)
                {
                    permissionGranted = false;
                    break;
                }
            }
        }

        protected override void OnResume()
        {
            base.OnResume();
            RequestPermissions();
        }

        protected void RequestPermissions()
        {
            if(!permissionGranted)
            {
                ActivityCompat.RequestPermissions(this, new string[] { Manifest.Permission.Camera, Manifest.Permission.RecordAudio }, 1);
            }
        }

        private void JoinCall(Call call)
        {
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

        protected String GetSessionId()
        {
            JObject json = RequestJsonData(FAKE_CREATE_URL, "POST");
            return json["sid"].ToString();
        }

        protected Call GetCallData(string sessionId)
        {
            string url = string.Format(FAKE_JOIN_URL, sessionId);
            JObject json = RequestJsonData(url, "GET");
            return new Call(
                    json["sid"].ToString(),
                    json["session"].ToString(),
                    json["user"].ToString(),
                    json["gss_info"]["url"].ToString(),
                    "Jason",
                    "https://www.securenvoy.com/sites/default/files/legacy-uploads/2013/10/pizza_hut_logo.jpg");
        }

        public JObject RequestJsonData(String url, String method)
        {
            var httpWebRequest = (HttpWebRequest)WebRequest.Create(url);
            httpWebRequest.ContentType = "text/json";
            httpWebRequest.Method = method;
            var httpResponse = (HttpWebResponse)httpWebRequest.GetResponse();
            using (var streamReader = new StreamReader(httpResponse.GetResponseStream()))
            {
                var responseText = streamReader.ReadToEnd();
                return JObject.Parse(responseText);
            }
        }
    }
}
