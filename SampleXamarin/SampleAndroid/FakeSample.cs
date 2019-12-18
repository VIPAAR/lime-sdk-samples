
using System;
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
    [Activity(Label = "@string/app_name", Theme = "@style/AppTheme", MainLauncher = false)]
    public class FakeSample : AppCompatActivity, ICallClientDelegate
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
            SetContentView(Resource.Layout.activity_join_session);
            TextView sessionIdTxt = (TextView)FindViewById(Resource.Id.session_id_edit_text);
            FindViewById(Resource.Id.create_session).Click += (sender, e) => {
                sessionIdTxt.Text = GetSessionId();
            };
            CallClientFactory.Instance.CallClient.Delegate = this;

            RequestPermissions();

            FindViewById(Resource.Id.join_session).Click += (sender, e) =>
            {
                JoinCall(GetCallData(sessionIdTxt.Text));
            };

            FindViewById(Resource.Id.leave_session).Click += (sender, e) =>
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
            CallClientFactory.Instance.CallClient.Delegate = this;
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

        protected String GetSessionId()
        {
            JObject json = RequestJsonData(Resources.GetString(Resource.String.galdr_host) + "/session", "POST");
            return json["sid"].ToString();
        }

        protected Call GetCallData(string sessionId)
        {
            string url = string.Format(Resources.GetString(Resource.String.galdr_host) + "/session?sid={0}", sessionId);
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

        public void OnCallEnded(Call call, string reason)
        {
            Console.WriteLine("The call ended: " + reason);
        }
    }
}
