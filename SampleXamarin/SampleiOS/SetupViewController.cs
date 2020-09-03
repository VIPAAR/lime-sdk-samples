using System;
using Foundation;
using UIKit;
using CoreFoundation;

namespace HelpLightning.SDK.Sample.iOS
{
    public partial class SetupViewController : UIViewController
    {
        private static readonly string DefaultContactEmail = "small_u11@helplightning.com";

        public SetupViewController(IntPtr handle) : base(handle)
        {
        }

        public override void ViewDidLoad()
        {
            base.ViewDidLoad();
            // Perform any additional setup after loading the view, typically from a nib.
            authTokenTextField.Text = CallManager.Instance.AuthToken;
            contactEmailTextField.Text = DefaultContactEmail;
        }

        public override void DidReceiveMemoryWarning()
        {
            base.DidReceiveMemoryWarning();
            // Release any cached data, images, etc that aren't in use.
        }

        public override bool ShouldPerformSegue(string segueIdentifier, NSObject sender)
        {
            return CallManager.Instance.SessionID != null && CallManager.Instance.SessionToken != null && CallManager.Instance.UserToken != null; ;
        }

        partial void OnCreateCall(UIButton sender)
        {
            var email = contactEmailTextField.Text.Trim();
            if (email.Length == 0)
            {
                Console.WriteLine("Empty Contact Email");
                return;
            }

            indicator.Hidden = false;
            createCallButton.Enabled = false;
            getCallButton.Enabled = false;

            CallManager.Instance.ContactEmail = email;
            CallManager.Instance.SessionID = null;
            CallManager.Instance.SessionToken = null;
            CallManager.Instance.UserToken = null;

            try
            {
                var task = HLServerClient.Instance.CreateCall(CallManager.Instance.AuthToken, email);
                task.ContinueWith(t => {
                    DispatchQueue.MainQueue.DispatchAsync(() =>
                    {
                        if (t.IsCompletedSuccessfully)
                        {
                            var json = task.Result;
                            CallManager.Instance.SessionID = json["session_id"].ToString();
                            CallManager.Instance.SessionToken = json["session_token"].ToString();
                            CallManager.Instance.UserToken = json["user_token"].ToString();
                            CallManager.Instance.GssServerURL = json["url"].ToString();
                            CallManager.Instance.SessionPIN = json["sid"].ToString();

                            PerformSegue("segueOpenJoinScreen1", this);
                        }
                        else
                        {
                            Console.Error.WriteLine("Cannot Create a Call: " + t.Exception);
                        }
                        createCallButton.Enabled = true;
                        getCallButton.Enabled = true;
                        indicator.Hidden = true;
                    });
                });
            }
            catch (Exception e)
            {
                Console.Error.WriteLine(e);
            }
        }

        partial void OnGetCall(UIButton sender)
        {
            var pin = PINTextField.Text.Trim();
            if (pin.Length == 0)
            {
                Console.WriteLine("Empty PIN");
                return;
            }
            CallManager.Instance.SessionPIN = pin;
            CallManager.Instance.SessionID = null;
            CallManager.Instance.SessionToken = null;
            CallManager.Instance.UserToken = null;
            try
            {
                var task = HLServerClient.Instance.GetCall(pin, CallManager.Instance.AuthToken);
                task.ContinueWith(t =>
                {
                    DispatchQueue.MainQueue.DispatchAsync(() =>
                    {
                        if (t.IsCompletedSuccessfully)
                        {
                            var json = task.Result;
                            CallManager.Instance.SessionID = json["session_id"][0].ToString();
                            CallManager.Instance.SessionToken = json["session_token"].ToString();
                            CallManager.Instance.UserToken = json["user_token"].ToString();
                            CallManager.Instance.GssServerURL = json["url"][0].ToString();

                            PerformSegue("segueOpenJoinScreen2", this);
                        }
                        else
                        {
                            Console.Error.WriteLine("Cannot Create a Call: " + t.Exception);
                        }
                        createCallButton.Enabled = true;
                        getCallButton.Enabled = true;
                        indicator.Hidden = true;
                    });
                });
            }
            catch (Exception e)
            {
                Console.Error.WriteLine(e);
            }
        }

        partial void OnCancel(UIBarButtonItem sender)
        {
            this.PresentingViewController.DismissViewController(true, null);
        }
    }

}

