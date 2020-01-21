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
using Android.Views;
using System.Threading.Tasks;

namespace SampleAndroid
{
    public class Authentication : Android.Support.V4.App.Fragment
    {
        string token = "";
        View rootView;
        Button callContactButton;
        Button callPinButton;

        public override View OnCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState)
        {
            base.OnCreate(savedInstanceState);
            rootView = inflater.Inflate(Resource.Layout.fragment_authentication, container, false);

            HLServer.Instance.BaseUrl = Resources.GetString(Resource.String.host);
            
            Button autheButton = rootView.FindViewById<Button>(Resource.Id.authButton);
            callContactButton = rootView.FindViewById<Button>(Resource.Id.callContactButton);
            callPinButton = rootView.FindViewById<Button>(Resource.Id.callPinButton);

            autheButton.Click += async (sender, e) =>
            {
                try
                {
                    token = await HLServer.Instance.AuthUser(rootView.FindViewById<EditText>(Resource.Id.emailText).Text);
                    System.Console.WriteLine(token);

                    Toast.MakeText(rootView.Context, "Authentication succeed!", ToastLength.Short).Show();

                    callContactButton.Enabled = true;
                    callPinButton.Enabled = true;
                }
                catch (Exception ex)
                {
                    System.Console.WriteLine(ex.ToString());
                    callContactButton.Enabled = false;
                    callPinButton.Enabled = false;
                    Toast.MakeText(rootView.Context, "Authentication Failed!", ToastLength.Short).Show();
                }
            };

            callContactButton.Click += (sender, e) => {
                ((MainActivity)base.Activity).JoinSessionClicked("call_contact", token);
            };

            callPinButton.Click += (sender, e) => {
                ((MainActivity)base.Activity).JoinSessionClicked("call_pin_code", token);
            };

            return rootView;
        }
    }
}
