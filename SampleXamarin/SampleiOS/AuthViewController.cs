using System;

using UIKit;

namespace HelpLightning.SDK.Sample.iOS
{

    public partial class AuthViewController : UIViewController
    {
        private static readonly string DefaultServerURL = "http://localhost:8777";

        public AuthViewController() : base("AuthViewController", null)
        {
        }

        public override void ViewDidLoad()
        {
            base.ViewDidLoad();
            // Perform any additional setup after loading the view, typically from a nib.
            ServerURLTextField.Text = DefaultServerURL;
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

        //partial void OnCreateCall(UIButton sender)
        //{
        //    string email = ContactEmailTextField.Text.Trim();
        //    if (email.Length == 0)
        //    {
        //        Console.WriteLine("Empty Contact Email");
        //        return;
        //    }

        //    var json = HLServerClient.Instance.CreateCall(authToken, email);
        //    var call = new Call(json["session_id"][0].ToString(),
        //                        json["session_token"].ToString(),
        //                        json["user_token"].ToString(),
        //                        json["url"].ToString(),
        //                        email,
        //                        "");
        //}
    }
}

