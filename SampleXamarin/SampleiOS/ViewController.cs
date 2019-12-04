using Foundation;
using System;
using System.Threading.Tasks;
using UIKit;
using HelpLightning.SDK;

namespace HelpLightning.SDK.Sample.iOS
{
    class TabBarDelegateImipl : UITabBarDelegate
    {
        ViewController viewController;
        public TabBarDelegateImipl(ViewController viewController)
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

    public partial class ViewController : UIViewController, ICallClientDelegate
    {
        const string HL_SESSION_ID = ("c6d553ed-1feb-4e1c-b1a7-e85a5de04c31");
        const string HL_SESSION_TOKEN = ("eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJhdHRyaWJ1dGVzIjpbIm9yZ2FuaXplciJdLCJhdWQiOiJHaGF6YWwiLCJleHAiOjE2MDY4Nzc1MjUsImlhdCI6MTU3NTM0MTUyNSwiaXNzIjoiR2hhemFsIiwianRpIjoiNjhjOWMzN2UtNmNjNC00YTA5LTgyZjctOTQ1OTBhYWM4ZWQ4IiwibWV0YSI6e30sIm5iZiI6MTU3NTM0MTUyNCwib3JpZ2luYXRvciI6MTYsInBlbSI6eyJzZXNzaW9uIjoyNTU5fSwicmVjb3JkaW5nX3BvbGljeSI6ImFsd2F5c19vbiIsInN1YiI6IlNlc3Npb246YzZkNTUzZWQtMWZlYi00ZTFjLWIxYTctZTg1YTVkZTA0YzMxIiwidHlwIjoiYWNjZXNzIiwidmVyIjoiMTAwIn0.JOsIvRD0zHjChsikzQPbh52HDjXlnUq-BwVjl8nBjYA");
        const string HL_GSS_URL = ("gss+ssl://containers-asia.helplightning.net:32773");

        const string HL_USER1_TOKEN = ("eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJhdWQiOiJHaGF6YWwiLCJleHAiOjE2MDY4Nzc0NTIsImlhdCI6MTU3NTM0MTQ1MiwiaXNzIjoiR2hhemFsIiwianRpIjoiZmI2YTIzZWEtYjM0Yy00NjFiLWEyYmEtNmE0ZTE3OGMyZDgzIiwibWV0YSI6e30sIm5iZiI6MTU3NTM0MTQ1MSwicGVtIjp7InVzZXIiOjEyMzU3NjUxNzY4OTExODJ9LCJzdWIiOiJVc2VyOjE1IiwidHlwIjoiYWNjZXNzIiwidmVyIjoiMTAwIn0.74szAWHDyUc_JCsYeeyeDlwabG21rCDVDv5luSG1DFM");
        const string HL_USER1_NAME = ("Small User12");
        const string HL_USER1_AVATAR = ("");

        const string HL_USER2_TOKEN = ("eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJhdWQiOiJHaGF6YWwiLCJleHAiOjE2MDY4Nzc0NzgsImlhdCI6MTU3NTM0MTQ3OCwiaXNzIjoiR2hhemFsIiwianRpIjoiZmYwMjc3YTUtNTY5Zi00NDYxLTg5NzAtODZmODFiNjY2MTIyIiwibWV0YSI6e30sIm5iZiI6MTU3NTM0MTQ3NywicGVtIjp7InVzZXIiOjEyMzU3NjUxNzY4OTExODJ9LCJzdWIiOiJVc2VyOjE2IiwidHlwIjoiYWNjZXNzIiwidmVyIjoiMTAwIn0.NPgjGjUzi6Nit2vg5TY1llpTgu1WHtlfsjsTVmtw5rI");
        const string HL_USER2_NAME = ("Small User13");

        const string HL_USER2_AVATAR = ("");

        public ViewController(IntPtr handle) : base(handle)
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
                if (t.IsCompleted)
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

            Call call = new Call(this.sessionId.Text, this.sessionToken.Text, this.userToken.Text, this.gssURL.Text, this.userName.Text, this.userAvatar.Text);
            Task<bool> task = CallClientFactory.Instance.CallClient.StartCall(call, this);
            task.ContinueWith( t => {
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

        public void OnCallEnded(Call call, string reason)
        {
            joinIndicator.StopAnimating();
            Console.WriteLine("The call has ended: {0}", call.SessionId);
        }

    }
}
