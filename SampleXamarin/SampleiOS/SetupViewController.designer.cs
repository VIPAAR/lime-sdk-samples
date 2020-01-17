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
        UIKit.UITextField AuthTokenTextField { get; set; }

        [Outlet]
        [GeneratedCode ("iOS Designer", "1.0")]
        UIKit.UITextField ContactEmailTextField { get; set; }

        [Outlet]
        [GeneratedCode ("iOS Designer", "1.0")]
        UIKit.UITextField PINTextField { get; set; }

        [Action ("OnCreateCall:")]
        [GeneratedCode ("iOS Designer", "1.0")]
        partial void OnCreateCall (UIKit.UIButton sender);

        [Action ("OnGetCall:")]
        [GeneratedCode ("iOS Designer", "1.0")]
        partial void OnGetCall (UIKit.UIButton sender);

        void ReleaseDesignerOutlets ()
        {
            if (AuthTokenTextField != null) {
                AuthTokenTextField.Dispose ();
                AuthTokenTextField = null;
            }

            if (ContactEmailTextField != null) {
                ContactEmailTextField.Dispose ();
                ContactEmailTextField = null;
            }

            if (PINTextField != null) {
                PINTextField.Dispose ();
                PINTextField = null;
            }
        }
    }
}