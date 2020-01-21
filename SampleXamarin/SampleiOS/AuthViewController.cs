using System;
using Foundation;
using UIKit;
using CoreFoundation;

namespace HelpLightning.SDK.Sample.iOS
{

    public partial class AuthViewController : UIViewController
    {
        private static readonly string DefaultServerURL = "http://10.3.2.28:8777";
        private static readonly string DefaultUserEmail = "small_u13@helplightning.com";

        public AuthViewController(IntPtr handle) : base(handle)
        {
        }

        public override void ViewDidLoad()
        {
            base.ViewDidLoad();
            // Perform any additional setup after loading the view, typically from a nib.
            serverURLTextField.Text = DefaultServerURL;
            userEmailTextField.Text = DefaultUserEmail;
        }

        public override void DidReceiveMemoryWarning()
        {
            base.DidReceiveMemoryWarning();
            // Release any cached data, images, etc that aren't in use.
        }

        public override bool ShouldPerformSegue(string segueIdentifier, NSObject sender)
        {
            return CallManager.Instance.AuthToken != null;
        }

        partial void OnAuthenticate(UIButton sender)
        {
            string email = userEmailTextField.Text.Trim();
            if (email.Length == 0) {
                Console.WriteLine("Empty User Email");
                return;
            }

            authButton.Enabled = false;
            indicator.Hidden = false;
            HLServerClient.Instance.BaseUrl = serverURLTextField.Text;

            CallManager.Instance.UserEmail = email;
            CallManager.Instance.AuthToken = null;

            try {
                var task = HLServerClient.Instance.AuthUser(email);
                task.ContinueWith(t =>
                {
                    DispatchQueue.MainQueue.DispatchAsync(() =>
                    {
                        if (t.IsCompleted)
                        {
                            CallManager.Instance.AuthToken = task.Result;
                            PerformSegue("segueOpenSetupScreen", this);                       
                        }
                        else
                        {
                            Console.Error.WriteLine("Cannot Auth: " + t.Exception);
                        }
                        authButton.Enabled = true;
                        indicator.Hidden = true;
                    });
                });
            }
            catch (Exception e)
            {
                Console.Error.WriteLine(e);
            }
        }
    }
}

