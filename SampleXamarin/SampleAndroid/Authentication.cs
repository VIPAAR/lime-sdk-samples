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

namespace SampleAndroid
{
    public class Authentication : Android.Support.V4.App.Fragment
    {
        public override View OnCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState)
        {
            base.OnCreate(savedInstanceState);
            View rootView = inflater.Inflate(Resource.Layout.fragment_authentication, container, false);

            HLServer.Instance.BaseUrl = Resources.GetString(Resource.String.host);
            string token = "";
            Button autheButton = rootView.FindViewById<Button>(Resource.Id.authButton);
            Button callContactButton = rootView.FindViewById<Button>(Resource.Id.callContactButton);
            Button callPinButton = rootView.FindViewById<Button>(Resource.Id.callPinButton);

            autheButton.Click += (sender, e) => {
                try
                {
                    token = HLServer.Instance.AuthUser(rootView.FindViewById<EditText>(Resource.Id.emailText).Text);
                    System.Console.WriteLine(token);

                    Toast.MakeText(rootView.Context, "Authentication successed!", ToastLength.Short).Show();

                    callContactButton.Enabled = true;
                    callPinButton.Enabled = true;
                } catch(Exception ex)
                {
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
