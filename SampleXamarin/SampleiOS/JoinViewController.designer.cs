// WARNING
//
// This file has been generated automatically by Visual Studio from the outlets and
// actions declared in your storyboard file.
// Manual changes to this file will not be maintained.
//
using Foundation;
using System;
using System.CodeDom.Compiler;
using UIKit;

namespace HelpLightning.SDK.Sample.iOS
{
    [Register ("JoinViewController")]
    partial class JoinViewController
    {
        [Outlet]
        [GeneratedCode ("iOS Designer", "1.0")]
        UIKit.UITextField GSSServerURLTextField { get; set; }

        [Outlet]
        [GeneratedCode ("iOS Designer", "1.0")]
        UIKit.UITextField SessionIDTextField { get; set; }

        [Outlet]
        [GeneratedCode ("iOS Designer", "1.0")]
        UIKit.UITextView SessionTokenTextView { get; set; }

        [Outlet]
        [GeneratedCode ("iOS Designer", "1.0")]
        UIKit.UITextField UserAvatarTextField { get; set; }

        [Outlet]
        [GeneratedCode ("iOS Designer", "1.0")]
        UIKit.UITextField UserNameTextField { get; set; }

        [Action ("OnJoinCall:")]
        [GeneratedCode ("iOS Designer", "1.0")]
        partial void OnJoinCall (UIKit.UIButton sender);

        void ReleaseDesignerOutlets ()
        {
            if (GSSServerURLTextField != null) {
                GSSServerURLTextField.Dispose ();
                GSSServerURLTextField = null;
            }

            if (SessionIDTextField != null) {
                SessionIDTextField.Dispose ();
                SessionIDTextField = null;
            }

            if (SessionTokenTextView != null) {
                SessionTokenTextView.Dispose ();
                SessionTokenTextView = null;
            }

            if (UserAvatarTextField != null) {
                UserAvatarTextField.Dispose ();
                UserAvatarTextField = null;
            }

            if (UserNameTextField != null) {
                UserNameTextField.Dispose ();
                UserNameTextField = null;
            }
        }
    }
}