using System;

using UIKit;

namespace HelpLightning.SDK.Sample.iOS
{
    public partial class SetupViewController : UIViewController
    {
        private static readonly string DefaultContactEmail = "small_u12@helplightning.com";

        public SetupViewController(IntPtr handle) : base(handle)
        {
        }

        public override void ViewDidLoad()
        {
            base.ViewDidLoad();
            // Perform any additional setup after loading the view, typically from a nib.
            AuthTokenTextField.Text = CallManager.Instance.AuthToken;
            ContactEmailTextField.Text = DefaultContactEmail;
        }

        public override void DidReceiveMemoryWarning()
        {
            base.DidReceiveMemoryWarning();
            // Release any cached data, images, etc that aren't in use.
        }

        partial void OnCreateCall(UIButton sender)
        {
            var email = ContactEmailTextField.Text.Trim();
            if (email.Length == 0)
            {
                Console.WriteLine("Empty Contact Email");
                return;
            }

            CallManager.Instance.ContactEmail = email;

            try
            {
                var json = HLServerClient.Instance.CreateCall(CallManager.Instance.AuthToken, email);

                CallManager.Instance.SessionID = json["session_id"][0].ToString();
                CallManager.Instance.SessionToken = json["session_token"].ToString();
                CallManager.Instance.UserToken = json["user_token"].ToString();
                CallManager.Instance.GssServerURL = json["url"].ToString();
                CallManager.Instance.SessionPIN = json["sid"].ToString();
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
            try
            {
                var json = HLServerClient.Instance.GetCall(pin, CallManager.Instance.AuthToken);
                CallManager.Instance.SessionID = json["session_id"][0].ToString();
                CallManager.Instance.SessionToken = json["session_token"].ToString();
                CallManager.Instance.UserToken = json["user_token"].ToString();
                CallManager.Instance.GssServerURL = json["url"].ToString();
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

