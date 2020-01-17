using System;

using UIKit;

namespace HelpLightning.SDK.Sample.iOS
{

    public partial class AuthViewController : UIViewController
    {
        private static readonly string DefaultServerURL = "http://192.168.0.30:8777";
        private static readonly string DefaultUserEmail = "small_u13@helplightning.com";

        public AuthViewController(IntPtr handle) : base(handle)
        {
        }

        public override void ViewDidLoad()
        {
            base.ViewDidLoad();
            // Perform any additional setup after loading the view, typically from a nib.
            ServerURLTextField.Text = DefaultServerURL;
            UserEmailTextField.Text = DefaultUserEmail;
        }

        public override void DidReceiveMemoryWarning()
        {
            base.DidReceiveMemoryWarning();
            // Release any cached data, images, etc that aren't in use.
        }

        partial void OnAuthenticate(UIButton sender)
        {
            HLServerClient.Instance.ServerURL = ServerURLTextField.Text;
            string email = UserEmailTextField.Text.Trim();
            if (email.Length == 0) {
                Console.WriteLine("Empty User Email");
                return;
            }
            CallManager.Instance.UserEmail = email;
            try { 
                CallManager.Instance.AuthToken = HLServerClient.Instance.AuthUser(email);
            }
            catch (Exception e)
            {
                Console.Error.WriteLine(e);
            }
        }
    }
}

