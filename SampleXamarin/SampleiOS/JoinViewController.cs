using System;

using UIKit;
using System.Threading.Tasks;
using CoreFoundation;

namespace HelpLightning.SDK.Sample.iOS
{
    public partial class JoinViewController : UIViewController
    {
        private static readonly string DefaultUserName = "small_u13";

        public JoinViewController(IntPtr handle) : base(handle)
        {
        }

        public override void ViewDidLoad()
        {
            base.ViewDidLoad();
            sessionPINTextField.Text = CallManager.Instance.SessionPIN;
            sessionIDTextField.Text = CallManager.Instance.SessionID;
            sessionTokenTextView.Text = CallManager.Instance.SessionToken;
            userNameTextField.Text = CallManager.Instance.UserName;
            userAvatarTextField.Text = CallManager.Instance.UserAvatar;
            gssServerURLTextField.Text = CallManager.Instance.GssServerURL;
            userNameTextField.Text = DefaultUserName;
        }

        public override void DidReceiveMemoryWarning()
        {
            base.DidReceiveMemoryWarning();
            // Release any cached data, images, etc that aren't in use.
        }

        partial void OnJoinCall(UIButton sender)
        {
            SetupTheme();
            CallManager.Instance.SessionID = sessionIDTextField.Text.Trim();
            CallManager.Instance.SessionToken = sessionTokenTextView.Text.Trim();
            CallManager.Instance.UserName = userNameTextField.Text.Trim();
            CallManager.Instance.UserAvatar = userAvatarTextField.Text.Trim();
            CallManager.Instance.GssServerURL = gssServerURLTextField.Text.Trim();

            Call call = new Call(CallManager.Instance.SessionID,
                CallManager.Instance.SessionToken,
                CallManager.Instance.UserToken,
                CallManager.Instance.GssServerURL,
                CallManager.Instance.UserName, CallManager.Instance.UserAvatar);

            joinButton.Enabled = false;
            indicator.Hidden = false;

            Task<bool> task = CallClientFactory.Instance.CallClient.StartCall(call, this);
            task.ContinueWith(t =>
            {
                DispatchQueue.MainQueue.DispatchAsync(() =>
                {
                    if (t.IsCompleted)
                    {
                        Console.WriteLine("The call has started: " + t.Result);
                    }
                    else
                    {
                        Console.Error.WriteLine("Cannot start the call: " + t.Exception);
                    }

                    joinButton.Enabled = true;
                    indicator.Hidden = true;
                });
            });
        }

        partial void OnCancel(UIBarButtonItem sender)
        {
            this.PresentingViewController.DismissViewController(true, null);
        }

        private void SetupTheme()
        {
            var index = themColorPicker.SelectedSegment;
            Theme theme = null;
            switch (index)
            {
                case 1:
                    theme = new Theme();
                    theme.SetColor(Theme.ColorMain, UIColor.DarkGray);
                    theme.SetImage(Theme.ImageModeMenuFaceToFaceOn, UIImage.FromBundle("Lightning"));
                    break;

                case 2:
                    theme = new Theme();
                    theme.SetColor(Theme.ColorMain, UIColor.Orange);
                    theme.SetImage(Theme.ImageModeMenuFaceToFaceOn, UIImage.FromBundle("03_contacts"));
                    break;

                case 3:
                    theme = new Theme();
                    theme.SetColor(Theme.ColorMain, UIColor.Purple);
                    theme.SetImage(Theme.ImageModeMenuFaceToFaceOn, UIImage.FromBundle("03_contacts_active"));
                    theme.SetImage(Theme.ImageModeMenuFaceToFaceOff, UIImage.FromBundle("Lightning"));
                    break;
                default:
                    break;
            }
            CallClientFactory.Instance.CallClient.Theme = theme;
        }
    }
}

