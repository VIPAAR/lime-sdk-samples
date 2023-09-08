using Foundation;
using System;
using System.Threading.Tasks;
using System.Collections.Generic;
using UIKit;
using HelpLightning.SDK;

namespace HelpLightning.SDK.Sample.iOS
{
    class TabBarDelegateImipl : UITabBarDelegate
    {
        SessionViewController viewController;
        public TabBarDelegateImipl(SessionViewController viewController)
        {
            this.viewController = viewController;
        }
        public override void ItemSelected(UITabBar tabbar, UITabBarItem item)
        {
            int index = System.Array.IndexOf(tabbar.Items, item);
            if (index == 0)
            {
                this.viewController.SwitchToUser1();
            }
            else
            {
                this.viewController.SwitchToUser2();
            }
        }
     
    }

    public partial class SessionViewController : UIViewController, ICallClientDelegate
    {
        const string HL_SESSION_ID = ("c7baa9fc-3a68-415b-a287-1d37741441dd");
        const string HL_SESSION_TOKEN = ("eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJhdHRyaWJ1dGVzIjpbIm9yZ2FuaXplciJdLCJhdWQiOiJHaGF6YWwiLCJleHAiOjE2MDczMjExMzIsImlhdCI6MTU3NjU2MjczMiwiaXNzIjoiR2hhemFsIiwianRpIjoiNTkwM2U0OTUtNDBkMC00ZjMyLTg3YjUtMGUzMTU1MTM5YWJkIiwibWV0YSI6e30sIm5iZiI6MTU3NjU2MjczMSwib3JpZ2luYXRvciI6NCwicGVtIjp7InNlc3Npb24iOjI1NTl9LCJyZWNvcmRpbmdfcG9saWN5Ijoib3B0X2luIiwic3ViIjoiU2Vzc2lvbjpjN2JhYTlmYy0zYTY4LTQxNWItYTI4Ny0xZDM3NzQxNDQxZGQiLCJ0eXAiOiJhY2Nlc3MiLCJ2ZXIiOiIxMDAifQ.yDzlI0zpikZu4WpoJF8P57n9D0CSK1TfxlVShAydad8");
        const string HL_GSS_URL = ("gss+ssl://containers-asia.helplightning.net:32773");

        const string HL_USER1_TOKEN = ("eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJhdWQiOiJHaGF6YWwiLCJleHAiOjE2MDczMjcwNjUsImlhdCI6MTU3NjU2ODY2NSwiaXNzIjoiR2hhemFsIiwianRpIjoiYWQxOWFmMTUtMjgzZC00N2NlLThmYTEtMjVhNDM1NTEzOThlIiwibWV0YSI6e30sIm5iZiI6MTU3NjU2ODY2NCwicGVtIjp7InVzZXIiOjQ0NzI3OTYxMjg1NDA0NjJ9LCJzdWIiOiJVc2VyOjQiLCJ0eXAiOiJhY2Nlc3MiLCJ2ZXIiOiIxMDAifQ.eAS1IsnV1n-kj0VS-Dk1Ifjpp_580MibHZsf8sJQuBw");
        const string HL_USER1_NAME = ("Small User1");
        const string HL_USER1_AVATAR = ("");

        const string HL_USER2_TOKEN = ("eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJhdWQiOiJHaGF6YWwiLCJleHAiOjE2MDczOTg0NjYsImlhdCI6MTU3NjY0MDA2NiwiaXNzIjoiR2hhemFsIiwianRpIjoiMzkxNjUyMzUtMDc2MS00ZThiLWI2NzQtMmUwODA3MDY0ZjVhIiwibWV0YSI6e30sIm5iZiI6MTU3NjY0MDA2NSwicGVtIjp7InVzZXIiOjQ0NzI3OTYxMjg1NDA0NjJ9LCJzdWIiOiJVc2VyOjUiLCJ0eXAiOiJhY2Nlc3MiLCJ2ZXIiOiIxMDAifQ.wMJNnbK5vQGCZdS5KStzxThabyXtyuzeU5k-08ZaGwM");
        const string HL_USER2_NAME = ("Small User2");

        const string HL_USER2_AVATAR = ("");

        public SessionViewController(IntPtr handle) : base(handle)
        {
        }

        public override void ViewDidLoad()
        {
            base.ViewDidLoad();

            this.sessionId.Text = HL_SESSION_ID;
            this.sessionToken.Text = HL_SESSION_TOKEN;
            this.userToken.Text = HL_USER1_TOKEN;
            this.userName.Text = HL_USER1_NAME;
            this.userAvatar.Text = HL_USER1_AVATAR;
            this.gssURL.Text = HL_GSS_URL;

            this.userTab.SelectedItem = this.userTab.Items[0];
            this.userTab.Delegate = new TabBarDelegateImipl(this);

            CallClientFactory.Instance.CallClient.Delegate = this;
        }

        public void SwitchToUser1()
        {
            userToken.Text = HL_USER1_TOKEN;
            userName.Text = HL_USER1_NAME;
            userAvatar.Text = HL_USER1_AVATAR;
        }

        public void SwitchToUser2()
        {
            userToken.Text = HL_USER2_TOKEN;
            userName.Text = HL_USER2_NAME;
            userAvatar.Text = HL_USER2_AVATAR;
        }

        public override void DidReceiveMemoryWarning()
        {
            base.DidReceiveMemoryWarning();
            // Release any cached data, images, etc that aren't in use.
        }

        partial void OnCancelCall(UIButton sender)
        {
            Task<bool> task = CallClientFactory.Instance.CallClient.StopCurrentCall();
            task.ContinueWith(t => {
                if (t.IsCompletedSuccessfully)
                {
                    Console.WriteLine("The call has stopped: " + t.Result);
                }
                else
                {
                    Console.Error.WriteLine("Cannot stop the call: " + t.Exception);
                }
            });
        }

        partial void OnJoinCall(UIButton sender)
        {
            joinIndicator.StartAnimating();

            Call call = new Call(this.sessionId.Text, this.sessionToken.Text, this.userToken.Text, this.gssURL.Text, "", this.userName.Text, this.userAvatar.Text);
            Task<IDictionary<string, object>> task = CallClientFactory.Instance.CallClient.StartCall(call, this);
            task.ContinueWith( t => {
                if (t.IsCompletedSuccessfully)
                {
                    Console.WriteLine("The call has started: " + t.Result[Call.HLCallInfoCallIDKey]);
                }
                else
                {
                    Console.Error.WriteLine("Cannot start the call: " + t.Exception);
                }
            });
        }

        public void OnCallEnded(Call call, string reason)
        {
            joinIndicator.StopAnimating();
            Console.WriteLine("The call has ended: {0}", reason);
        }

        public void OnScreenCaptureCreated(Call call, object image)
        {
            throw new NotImplementedException();
        }

        public object IsSharingKnowledgeSupported(Call call)
        {
            throw new NotImplementedException();
        }

        public Task<IDictionary<string, object>> SelectSharedKnowledge(Call call, IDictionary<string, object> userInfo)
        {
            throw new NotImplementedException();
        }

        public object IsQuickKnowledgeOverlaySupported(Call call)
        {
            throw new NotImplementedException();
        }

        public Task<IDictionary<string, object>> SelectQuickKnowledgeOverlay(Call call, IDictionary<string, object> userInfo)
        {
            throw new NotImplementedException();
        }
    }
}
