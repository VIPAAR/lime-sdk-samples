// WARNING
//
// This file has been generated automatically by Visual Studio from the outlets and
// actions declared in your storyboard file.
// Manual changes to this file will not be maintained.
//
using Foundation;
using System;
using System.CodeDom.Compiler;

namespace HelpLightning.SDK.Sample.iOS
{
    [Register ("AuthViewController")]
    partial class AuthViewController
    {
        [Outlet]
        [GeneratedCode ("iOS Designer", "1.0")]
        UIKit.UIButton authButton { get; set; }

        [Outlet]
        [GeneratedCode ("iOS Designer", "1.0")]
        UIKit.UIActivityIndicatorView indicator { get; set; }

        [Outlet]
        [GeneratedCode ("iOS Designer", "1.0")]
        UIKit.UITextField serverURLTextField { get; set; }

        [Outlet]
        [GeneratedCode ("iOS Designer", "1.0")]
        UIKit.UITextField userEmailTextField { get; set; }


        [Action ("OnAuthenticate:")]
        partial void OnAuthenticate (UIKit.UIButton sender);

        [Action ("OnCreateCall:")]
        [GeneratedCode ("iOS Designer", "1.0")]
        partial void OnCreateCall (UIKit.UIButton sender);

        void ReleaseDesignerOutlets ()
        {
            if (authButton != null) {
                authButton.Dispose ();
                authButton = null;
            }

            if (indicator != null) {
                indicator.Dispose ();
                indicator = null;
            }

            if (serverURLTextField != null) {
                serverURLTextField.Dispose ();
                serverURLTextField = null;
            }

            if (userEmailTextField != null) {
                userEmailTextField.Dispose ();
                userEmailTextField = null;
            }
        }
    }
}