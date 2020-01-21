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
    [Register ("SetupViewController")]
    partial class SetupViewController
    {
        [Outlet]
        [GeneratedCode ("iOS Designer", "1.0")]
        UIKit.UITextField authTokenTextField { get; set; }

        [Outlet]
        [GeneratedCode ("iOS Designer", "1.0")]
        UIKit.UITextField contactEmailTextField { get; set; }

        [Outlet]
        [GeneratedCode ("iOS Designer", "1.0")]
        UIKit.UIButton createCallButton { get; set; }

        [Outlet]
        [GeneratedCode ("iOS Designer", "1.0")]
        UIKit.UIButton getCallButton { get; set; }

        [Outlet]
        [GeneratedCode ("iOS Designer", "1.0")]
        UIKit.UIActivityIndicatorView indicator { get; set; }

        [Outlet]
        [GeneratedCode ("iOS Designer", "1.0")]
        UIKit.UITextField PINTextField { get; set; }

        [Action ("OnCancel:")]
        [GeneratedCode ("iOS Designer", "1.0")]
        partial void OnCancel (UIKit.UIBarButtonItem sender);

        [Action ("OnCreateCall:")]
        [GeneratedCode ("iOS Designer", "1.0")]
        partial void OnCreateCall (UIKit.UIButton sender);

        [Action ("OnGetCall:")]
        [GeneratedCode ("iOS Designer", "1.0")]
        partial void OnGetCall (UIKit.UIButton sender);

        void ReleaseDesignerOutlets ()
        {
            if (authTokenTextField != null) {
                authTokenTextField.Dispose ();
                authTokenTextField = null;
            }

            if (contactEmailTextField != null) {
                contactEmailTextField.Dispose ();
                contactEmailTextField = null;
            }

            if (createCallButton != null) {
                createCallButton.Dispose ();
                createCallButton = null;
            }

            if (getCallButton != null) {
                getCallButton.Dispose ();
                getCallButton = null;
            }

            if (indicator != null) {
                indicator.Dispose ();
                indicator = null;
            }

            if (PINTextField != null) {
                PINTextField.Dispose ();
                PINTextField = null;
            }
        }
    }
}