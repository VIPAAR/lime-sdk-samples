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
    [Register ("AuthViewController")]
    partial class AuthViewController
    {
        [Outlet]
        [GeneratedCode ("iOS Designer", "1.0")]
        UIKit.UIButton AuthButton { get; set; }

        [Outlet]
        [GeneratedCode ("iOS Designer", "1.0")]
        UIKit.UITextField ServerURLTextField { get; set; }

        [Outlet]
        [GeneratedCode ("iOS Designer", "1.0")]
        UIKit.UITextField UserEmailTextField { get; set; }

        [Action ("OnAuthenticate:")]
        [GeneratedCode ("iOS Designer", "1.0")]
        partial void OnAuthenticate (UIKit.UIButton sender);

        [Action ("OnCreateCall:")]
        [GeneratedCode ("iOS Designer", "1.0")]
        partial void OnCreateCall (UIKit.UIButton sender);

        void ReleaseDesignerOutlets ()
        {
            if (AuthButton != null) {
                AuthButton.Dispose ();
                AuthButton = null;
            }

            if (ServerURLTextField != null) {
                ServerURLTextField.Dispose ();
                ServerURLTextField = null;
            }

            if (UserEmailTextField != null) {
                UserEmailTextField.Dispose ();
                UserEmailTextField = null;
            }
        }
    }
}