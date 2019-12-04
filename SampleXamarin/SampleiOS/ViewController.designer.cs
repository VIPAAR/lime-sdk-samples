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
    [Register ("ViewController")]
    partial class ViewController
    {
        [Outlet]
        UIKit.UITextView gssURL { get; set; }


        [Outlet]
        UIKit.UIActivityIndicatorView joinIndicator { get; set; }


        [Outlet]
        UIKit.UITextView sessionId { get; set; }


        [Outlet]
        UIKit.UITextView sessionToken { get; set; }


        [Outlet]
        UIKit.UITextView userAvatar { get; set; }


        [Outlet]
        UIKit.UITextView userName { get; set; }


        [Outlet]
        UIKit.UITabBar userTab { get; set; }


        [Outlet]
        UIKit.UITextView userToken { get; set; }

        [Action ("OnCancelCall:")]
        [GeneratedCode ("iOS Designer", "1.0")]
        partial void OnCancelCall (UIKit.UIButton sender);

        [Action ("OnJoinCall:")]
        [GeneratedCode ("iOS Designer", "1.0")]
        partial void OnJoinCall (UIKit.UIButton sender);

        void ReleaseDesignerOutlets ()
        {
        }
    }
}