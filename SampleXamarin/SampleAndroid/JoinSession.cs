
using System;
using System.Threading.Tasks;
using Android.OS;
using Android.Views;
using Android.Widget;
using Newtonsoft.Json.Linq;
using Fragment = Android.Support.V4.App.Fragment;

namespace HelpLightning.SDK.Sample.Android
{
    public class JoinSession : Fragment, ICallClientDelegate
    {
        private static String ARG_PARAM1 = "user_token";
        private static String ARG_PARAM2 = "mode";

        string userToken = "";
        string mode = "";
        string pin = "";
        Call currentCallData;
        View rootView;

        public override void OnCreate(Bundle savedInstanceState)
        {
            base.OnCreate(savedInstanceState);
            currentCallData = null;

            if (base.Arguments != null)
            {
                userToken = base.Arguments.GetString(ARG_PARAM1);
                mode = base.Arguments.GetString(ARG_PARAM2);
            }
            CallClientFactory.Instance.CallClient.Delegate = this;
        }

        public override View OnCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState)
        {
            rootView = inflater.Inflate(Resource.Layout.fragment_join_session, container, false);

            TextView pinCode = (TextView)rootView.FindViewById(Resource.Id.pin_code);
            TextView contact = (TextView)rootView.FindViewById(Resource.Id.contact_email);
            TextView pinCodeView = (TextView)rootView.FindViewById(Resource.Id.text_pin_code);

            if (mode.Equals("call_contact"))
            {
                rootView.FindViewById<View>(Resource.Id.pin_layout).Visibility = ViewStates.Gone;
                pinCode.Visibility = ViewStates.Invisible;
            }
            else if (mode.Equals("call_pin_code"))
            {
                rootView.FindViewById<View>(Resource.Id.contact_email_layout).Visibility = ViewStates.Gone;
                contact.Visibility = ViewStates.Invisible;
            }

            rootView.FindViewById(Resource.Id.btn_start_call).Click += async (sender, e) =>
            {
                try
                {
                    if(currentCallData == null)
                    {
                        JObject json = null;
                        if (mode.Equals("call_contact") && pin.Equals(""))
                        {
                            string dialerEmail = contact.Text;
                            json = await HLServerClient.Instance.CreateCall(userToken, contact.Text);
                            pinCodeView.Text = "You can share pin code with: " + json["sid"].ToString();
                        }
                        else if (mode.Equals("call_pin_code"))
                        {
                            pin = pinCode.Text;
                            json = await HLServerClient.Instance.GetCall(pin, userToken);
                        }

                        currentCallData = new Call
                            (
                                json["session_id"][0].ToString(),
                                json["session_token"].ToString(),
                                json["user_token"].ToString(),
                                json["url"].ToString(),
                                "darrel",
                                "https://www.securenvoy.com/sites/default/files/legacy-uploads/2013/10/pizza_hut_logo.jpg"
                            );
                    }
                   
                    JoinCall(currentCallData);
                }
                catch (Exception ex)
                {
                    System.Console.WriteLine(ex.ToString());

                    if (mode.Equals("call_contact"))
                    {                        
                        Toast.MakeText(rootView.Context, "Invalid email address.", ToastLength.Short).Show();
                    }
                    else if (mode.Equals("call_pin_code"))
                    {
                        Toast.MakeText(rootView.Context, "Invalid pin code.", ToastLength.Short).Show();
                    }
                }
            };

            rootView.FindViewById(Resource.Id.btn_stop_call).Click += (sender, e) =>
            {
                StopCall();
            };
            return rootView;
        }

        private void JoinCall(Call call)
        {
            rootView.FindViewById(Resource.Id.progressBar_cyclic).Visibility = ViewStates.Visible;
            Task<bool> task = CallClientFactory.Instance.CallClient.StartCall(call, rootView.Context);
            task.ContinueWith(t => {
                rootView.FindViewById(Resource.Id.progressBar_cyclic).Visibility = ViewStates.Invisible;
                if (t.IsCompleted)
                {
                    Console.WriteLine("The call has started: " + t.Result);
                }
                else
                {
                    Console.WriteLine("Cannot start the call: " + t.Exception);
                }
            });
        }

        private void StopCall()
        {
            rootView.FindViewById(Resource.Id.progressBar_cyclic).Visibility = ViewStates.Invisible;
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
