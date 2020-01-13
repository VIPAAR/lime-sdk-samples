using Android.App;
using Android.OS;
using Android.Widget;
using Android.Support.V7.App;
using Android.Content;
using System;

namespace SampleAndroid
{
    [Activity(Label = "@string/app_name", Theme = "@style/AppTheme", MainLauncher = true)]
    public class MainActivity : AppCompatActivity
    {     
        protected override void OnCreate(Bundle savedInstanceState)
        {
            base.OnCreate(savedInstanceState);
            //Xamarin.Essentials.Platform.Init(this, savedInstanceState);
            // Set our view from the "main" layout resource
            SetContentView(Resource.Layout.activity_main);
            HLServer.Instance.BaseUrl = Resources.GetString(Resource.String.host);
            string token = "";
            Button autheButton = FindViewById<Button>(Resource.Id.authButton);
            Button callContactButton = FindViewById<Button>(Resource.Id.callContactButton);
            Button callPinButton = FindViewById<Button>(Resource.Id.callPinButton);

            autheButton.Click += (sender, e) => {
                try
                {
                    token = HLServer.Instance.AuthUser(FindViewById<EditText>(Resource.Id.emailText).Text);
                    System.Console.WriteLine(token);

                    Toast.MakeText(this, "Authentication successed!", ToastLength.Short).Show();

                    callContactButton.Enabled = true;
                    callPinButton.Enabled = true;
                } catch(Exception ex)
                {
                    callContactButton.Enabled = false;
                    callPinButton.Enabled = false;
                    Toast.MakeText(this, "Authentication Failed!", ToastLength.Short).Show();
                }
             };

            callContactButton.Click += (sender, e) => {
                Intent join = new Intent(this, typeof(JoinSession));
                join.PutExtra("user_token", token);
                join.PutExtra("mode", "call_contact");
                this.StartActivity(join);
            };

            callPinButton.Click += (sender, e) => {
                Intent join = new Intent(this, typeof(JoinSession));
                join.PutExtra("user_token", token);
                join.PutExtra("mode", "call_pin_code");
                this.StartActivity(join);
            };
        }
    }
}
