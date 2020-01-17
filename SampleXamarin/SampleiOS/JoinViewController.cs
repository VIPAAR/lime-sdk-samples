using System;

using UIKit;
using System.Threading.Tasks;

namespace HelpLightning.SDK.Sample.iOS
{
    public partial class JoinViewController : UIViewController
    {
        public JoinViewController() : base("JoinViewController", null)
        {
        }

        public override void ViewDidLoad()
        {
            base.ViewDidLoad();
            // Perform any additional setup after loading the view, typically from a nib.
            SessionIDTextField.Text = CallManager.Instance.SessionID;
            SessionTokenTextView.Text = CallManager.Instance.SessionToken;
            UserNameTextField.Text = CallManager.Instance.UserName;
            UserAvatarTextField.Text = CallManager.Instance.UserAvatar;
            GSSServerURLTextField.Text = CallManager.Instance.GssServerURL;

        }

        public override void DidReceiveMemoryWarning()
        {
            base.DidReceiveMemoryWarning();
            // Release any cached data, images, etc that aren't in use.
        }

        partial void OnJoinCall(UIButton sender)
        {
            CallManager.Instance.SessionID = SessionIDTextField.Text.Trim();
            CallManager.Instance.SessionToken = SessionTokenTextView.Text.Trim();
            CallManager.Instance.UserName = UserNameTextField.Text.Trim();
            CallManager.Instance.UserAvatar = UserAvatarTextField.Text.Trim();
            CallManager.Instance.GssServerURL = GSSServerURLTextField.Text.Trim();

            Call call = new Call(CallManager.Instance.SessionID,
                CallManager.Instance.SessionToken,
                CallManager.Instance.UserToken,
                CallManager.Instance.GssServerURL,
                CallManager.Instance.UserName, CallManager.Instance.UserAvatar);
            Task<bool> task = CallClientFactory.Instance.CallClient.StartCall(call, this);
            task.ContinueWith(t => {
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
    }
}

