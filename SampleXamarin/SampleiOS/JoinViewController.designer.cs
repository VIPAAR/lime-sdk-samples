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
        UIKit.UITextField gssServerURLTextField { get; set; }

        [Outlet]
        [GeneratedCode ("iOS Designer", "1.0")]
        UIKit.UIActivityIndicatorView indicator { get; set; }

        [Outlet]
        [GeneratedCode ("iOS Designer", "1.0")]
        UIKit.UIButton joinButton { get; set; }

        [Outlet]
        [GeneratedCode ("iOS Designer", "1.0")]
        UIKit.UITextField sessionIDTextField { get; set; }

        [Outlet]
        [GeneratedCode ("iOS Designer", "1.0")]
        UIKit.UITextField sessionPINTextField { get; set; }

        [Outlet]
        [GeneratedCode ("iOS Designer", "1.0")]
        UIKit.UITextView sessionTokenTextView { get; set; }

        [Outlet]
        [GeneratedCode ("iOS Designer", "1.0")]
        UIKit.UISegmentedControl themColorPicker { get; set; }

        [Outlet]
        [GeneratedCode ("iOS Designer", "1.0")]
        UIKit.UITextField userAvatarTextField { get; set; }

        [Outlet]
        [GeneratedCode ("iOS Designer", "1.0")]
        UIKit.UITextField userNameTextField { get; set; }

        [Action ("OnCancel:")]
        [GeneratedCode ("iOS Designer", "1.0")]
        partial void OnCancel (UIKit.UIBarButtonItem sender);

        [Action ("OnJoinCall:")]
        [GeneratedCode ("iOS Designer", "1.0")]
        partial void OnJoinCall (UIKit.UIButton sender);

        void ReleaseDesignerOutlets ()
        {
            if (gssServerURLTextField != null) {
                gssServerURLTextField.Dispose ();
                gssServerURLTextField = null;
            }

            if (indicator != null) {
                indicator.Dispose ();
                indicator = null;
            }

            if (joinButton != null) {
                joinButton.Dispose ();
                joinButton = null;
            }

            if (sessionIDTextField != null) {
                sessionIDTextField.Dispose ();
                sessionIDTextField = null;
            }

            if (sessionPINTextField != null) {
                sessionPINTextField.Dispose ();
                sessionPINTextField = null;
            }

            if (sessionTokenTextView != null) {
                sessionTokenTextView.Dispose ();
                sessionTokenTextView = null;
            }

            if (themColorPicker != null) {
                themColorPicker.Dispose ();
                themColorPicker = null;
            }

            if (userAvatarTextField != null) {
                userAvatarTextField.Dispose ();
                userAvatarTextField = null;
            }

            if (userNameTextField != null) {
                userNameTextField.Dispose ();
                userNameTextField = null;
            }
        }
    }
}