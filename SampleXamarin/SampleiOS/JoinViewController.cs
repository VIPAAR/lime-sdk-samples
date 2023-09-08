using System;

using UIKit;
using System.Threading.Tasks;
using CoreFoundation;
using System.Collections.Generic;
using Foundation;
using UniformTypeIdentifiers;

namespace HelpLightning.SDK.Sample.iOS
{
    public partial class JoinViewController : UIViewController, ICallClientDelegate
    {
        private static readonly string DefaultUserName = "your-user-name";
        private static readonly string HLApiKey = "[INSERT API KEY]";

        public JoinViewController(IntPtr handle) : base(handle)
        {
            CallClientFactory.Instance.CallClient.Delegate = this;
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

            camOnSwitch.On = CallManager.Instance.AutoEnableCamera;
            micOnSwitch.On = CallManager.Instance.AutoEnableMicrophone;
        }

        public override void DidReceiveMemoryWarning()
        {
            base.DidReceiveMemoryWarning();
            // Release any cached data, images, etc that aren't in use.
        }

        partial void OnJoinCall(UIButton sender)
        {
            //SetupTheme();
            CallManager.Instance.SessionID = sessionIDTextField.Text.Trim();
            CallManager.Instance.SessionToken = sessionTokenTextView.Text.Trim();
            CallManager.Instance.UserName = userNameTextField.Text.Trim();
            CallManager.Instance.UserAvatar = userAvatarTextField.Text.Trim();
            CallManager.Instance.GssServerURL = gssServerURLTextField.Text.Trim();
            CallManager.Instance.AutoEnableCamera = camOnSwitch.On;
            CallManager.Instance.AutoEnableMicrophone = micOnSwitch.On;
            Call call = new Call(CallManager.Instance.SessionID,
                CallManager.Instance.SessionToken,
                CallManager.Instance.UserToken,
                CallManager.Instance.GssServerURL,
                HLApiKey,
                CallManager.Instance.UserName,
                CallManager.Instance.UserAvatar,
                CallManager.Instance.AutoEnableCamera,
                CallManager.Instance.AutoEnableMicrophone
                );

            joinButton.Enabled = false;
            indicator.Hidden = false;

            Task<IDictionary<string, object>> task = CallClientFactory.Instance.CallClient.StartCall(call, this, DataCenter.US1);
            task.ContinueWith(t =>
            {
                DispatchQueue.MainQueue.DispatchAsync(() =>
                {
                    if (!t.IsFaulted)
                    {
                        Console.WriteLine("The call has started: " + t.Result[Call.HLCallInfoCallIDKey]);
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
            var theme = new Theme();
            theme.SetImage(Theme.ImageMainMenuTorchOff, UIImage.FromBundle("TestIcon"));
            theme.SetImage(Theme.ImageMainMenuTorchOn, UIImage.FromBundle("TestIcon"));
            theme.SetImage(Theme.ImageMainMenu, UIImage.FromBundle("TestIcon"));
            theme.SetImage(Theme.ImageMainMenuInvite, UIImage.FromBundle("TestIcon"));

            theme.SetImage(Theme.ImageCameraMenuPhotoOn, UIImage.FromBundle("TestIcon"));
            theme.SetImage(Theme.ImageCameraMenuFreezeOn, UIImage.FromBundle("TestIcon"));
            theme.SetImage(Theme.ImageCameraMenuFreezeOff, UIImage.FromBundle("TestIcon"));
            theme.SetImage(Theme.ImageCameraMenuSwitchCamera, UIImage.FromBundle("TestIcon"));

            //mic
            theme.SetImage(Theme.ImageMicOn, UIImage.FromBundle("TestIcon"));
            theme.SetImage(Theme.ImageMicOff, UIImage.FromBundle("TestIcon"));

            theme.SetImage(Theme.ImageTelestrationMenuArrowOn, UIImage.FromBundle("TestIcon"));
            theme.SetImage(Theme.ImageTelestrationMenuArrowOff, UIImage.FromBundle("TestIcon"));
            theme.SetImage(Theme.ImageTelestrationMenuPenOn, UIImage.FromBundle("TestIcon"));
            theme.SetImage(Theme.ImageTelestrationMenuPenOff, UIImage.FromBundle("TestIcon"));

            theme.SetImage(Theme.ImageTelestrationMenu2DPushPinOn, UIImage.FromBundle("TestIcon"));
            theme.SetImage(Theme.ImageTelestrationMenu2DPushPinOff, UIImage.FromBundle("TestIcon"));
            theme.SetImage(Theme.ImageTelestrationMenu3DArrowOff, UIImage.FromBundle("TestIcon"));
            theme.SetImage(Theme.ImageTelestrationMenu3DArrowOn, UIImage.FromBundle("TestIcon"));
            theme.SetImage(Theme.ImageTelestrationMenu3DPenOn, UIImage.FromBundle("TestIcon"));
            theme.SetImage(Theme.ImageTelestrationMenu3DPenOff, UIImage.FromBundle("TestIcon"));
            theme.SetImage(Theme.ImageTelestrationMenu3DPushPinOff, UIImage.FromBundle("TestIcon"));
            theme.SetImage(Theme.ImageTelestrationMenu3DPushPinOn, UIImage.FromBundle("TestIcon"));
            theme.SetImage(Theme.ImageTelestration3DIndicator, UIImage.FromBundle("TestIcon"));
            theme.SetImage(Theme.ImageTelestration3DIconBorderIOS, UIImage.FromBundle("TestIcon"));

            //clear
            theme.SetImage(Theme.ImageTelestrationUndo, UIImage.FromBundle("TestIcon"));
            theme.SetImage(Theme.ImageTelestrationClearAll, UIImage.FromBundle("TestIcon"));

            //end call
            theme.SetImage(Theme.ImageEndCall, UIImage.FromBundle("TestIcon"));

            //screen capture
            theme.SetImage(Theme.ImageScreenCaptureUnpressed, UIImage.FromBundle("TestIcon"));
            theme.SetImage(Theme.ImageScreenCaptureTransition, UIImage.FromBundle("TestIcon"));
            theme.SetImage(Theme.ImageScreenCapturePressed, UIImage.FromBundle("TestIcon"));

            //default profile icon
            theme.SetImage(Theme.ImageDefaultProfileIcon, UIImage.FromBundle("TestIcon"));

            //audio plus mode
            theme.SetImage(Theme.ImageAudioPlusModeIOS, UIImage.FromBundle("TestIcon"));
            theme.SetImage(Theme.ImageCallQualityAudioPlusIOS, UIImage.FromBundle("TestIcon"));
            theme.SetImage(Theme.ImageCallQualityHDIOS, UIImage.FromBundle("TestIcon"));
            theme.SetImage(Theme.ImageCallQualitySDIOS, UIImage.FromBundle("TestIcon"));
            theme.SetImage(Theme.ImageCameraDisabledIOS, UIImage.FromBundle("TestIcon"));

            //chat
            theme.SetImage(Theme.ImageChatGroupAvatarIOS, UIImage.FromBundle("TestIcon"));
            theme.SetImage(Theme.ImageChatMoreActionIOS, UIImage.FromBundle("TestIcon"));
            theme.SetImage(Theme.ImageChatSendIOS, UIImage.FromBundle("TestIcon"));
            theme.SetImage(Theme.ImageChatPlaceholderIOS, UIImage.FromBundle("TestIcon"));
            theme.SetImage(Theme.ImageChatMenuIOS, UIImage.FromBundle("TestIcon"));
            theme.SetImage(Theme.ImageChatAttachmentIOS, UIImage.FromBundle("TestIcon"));
            theme.SetImage(Theme.ImageChatCameraIOS, UIImage.FromBundle("TestIcon"));


            theme.SetImage(Theme.ImageBannerRote, UIImage.FromBundle("TestIcon"));
            theme.SetImage(Theme.ImageActionBarMergeNormal, UIImage.FromBundle("TestIcon"));
            theme.SetImage(Theme.ImageActionBarMergeSelected, UIImage.FromBundle("TestIcon"));
            theme.SetImage(Theme.ImageActionBarShareNormal, UIImage.FromBundle("TestIcon"));
            theme.SetImage(Theme.ImageActionBarShareSelected, UIImage.FromBundle("TestIcon"));
            theme.SetImage(Theme.IconAnnotation3DColorBorderRed, UIImage.FromBundle("TestIcon"));
            theme.SetImage(Theme.IconAnnotation3DColorBorderYellow, UIImage.FromBundle("TestIcon"));
            theme.SetImage(Theme.IconAnnotation3DColorBorderGreen, UIImage.FromBundle("TestIcon"));
            theme.SetImage(Theme.IconAnnotation3DColorBorderBlue, UIImage.FromBundle("TestIcon"));
            theme.SetImage(Theme.IconAnnotationColorBorderRed, UIImage.FromBundle("TestIcon"));
            theme.SetImage(Theme.IconAnnotationColorBorderYellow, UIImage.FromBundle("TestIcon"));
            theme.SetImage(Theme.IconAnnotationColorBorderGreen, UIImage.FromBundle("TestIcon"));

            theme.SetImage(Theme.IconAnnotationColorBorderBlue, UIImage.FromBundle("TestIcon"));
            theme.SetImage(Theme.IconAnnotationColorRed, UIImage.FromBundle("TestIcon"));
            theme.SetImage(Theme.IconAnnotationColorYellow, UIImage.FromBundle("TestIcon"));
            theme.SetImage(Theme.IconAnnotationColorGreen, UIImage.FromBundle("TestIcon"));
            theme.SetImage(Theme.IconAnnotationColorBlue, UIImage.FromBundle("TestIcon"));
            theme.SetImage(Theme.ImageScreenCapture, UIImage.FromBundle("TestIcon"));
            theme.SetImage(Theme.ImageEndCap, UIImage.FromBundle("TestIcon"));
            theme.SetImage(Theme.ImageTick, UIImage.FromBundle("TestIcon"));
            theme.SetImage(Theme.ImageCameraMenuCameraOn, UIImage.FromBundle("TestIcon"));
            theme.SetImage(Theme.ImageCameraMenuCameraOff, UIImage.FromBundle("TestIcon"));
            theme.SetImage(Theme.ImageShareMenuFile, UIImage.FromBundle("TestIcon"));
            theme.SetImage(Theme.ImageShareMenuGallery, UIImage.FromBundle("TestIcon"));
            theme.SetImage(Theme.ImageShareMyCamera, UIImage.FromBundle("TestIcon"));
            theme.SetImage(Theme.ImageShareMenuTakePhoto, UIImage.FromBundle("TestIcon"));
            theme.SetImage(Theme.ImageShareMenuVideo, UIImage.FromBundle("TestIcon"));
            theme.SetImage(Theme.ImageShareMenuWhiteBoard, UIImage.FromBundle("TestIcon"));
            theme.SetImage(Theme.ImageChevron, UIImage.FromBundle("TestIcon"));

            theme.SetImage(Theme.ImageShareMenuFileSelected, UIImage.FromBundle("TestIcon"));
            theme.SetImage(Theme.ImageShareMenuGallerySelected, UIImage.FromBundle("TestIcon"));
            theme.SetImage(Theme.ImageShareMenuTakePhotoSelected, UIImage.FromBundle("TestIcon"));
            theme.SetImage(Theme.ImageShareMenuWhiteBoardSelected, UIImage.FromBundle("TestIcon"));

            theme.SetImage(Theme.ImageShareMenuKnowledgeIOS, UIImage.FromBundle("TestIcon"));
            theme.SetImage(Theme.ImageShareMenuKnowledgeSelectedIOS, UIImage.FromBundle("TestIcon"));
            theme.SetImage(Theme.ImageQuickKnowledgeIOS, UIImage.FromBundle("TestIcon"));
            theme.SetImage(Theme.ImageQuickKnowledgeHighlightIOS, UIImage.FromBundle("TestIcon"));
            theme.SetImage(Theme.ImageQuickKnowledgeDeleteIOS, UIImage.FromBundle("TestIcon"));
            theme.SetImage(Theme.ImageQuickKnowledgeResizeIOS, UIImage.FromBundle("TestIcon"));
            theme.SetImage(Theme.ImageQuickKnowledgeSelectionIOS, UIImage.FromBundle("TestIcon"));
            theme.SetImage(Theme.ImageQuickKnowledgeSelectionHighlightIOS, UIImage.FromBundle("TestIcon"));
            theme.SetImage(Theme.ImageTelestrationMenuPushPinNormalIOS, UIImage.FromBundle("TestIcon"));
            theme.SetImage(Theme.ImageTelestrationMenuCurveNormalIOS, UIImage.FromBundle("TestIcon"));
            theme.SetImage(Theme.ImageTelestrationMenuArrowNormalIOS, UIImage.FromBundle("TestIcon"));
            theme.SetImage(Theme.IconAnnotationColorRedSelectedIOS, UIImage.FromBundle("TestIcon"));
            theme.SetImage(Theme.IconAnnotationColorYellowSelectedIOS, UIImage.FromBundle("TestIcon"));
            theme.SetImage(Theme.IconAnnotationColorGreenSelectedIOS, UIImage.FromBundle("TestIcon"));
            theme.SetImage(Theme.IconAnnotationColorBlueSelectedIOS, UIImage.FromBundle("TestIcon"));

            CallClientFactory.Instance.CallClient.Theme = theme;
        }

        public void OnCallEnded(Call call, string reason)
        {
            Console.WriteLine("Call Ended");
        }

        public void OnScreenCaptureCreated(Call call, object image)
        {
            Console.WriteLine("Screen Captured");
            imagePreview.Image = (UIImage)image;
        }

        private TaskCompletionSource<IDictionary<string, object>> SharingKnowledgePickingTaskCompletionSource;

        public object IsSharingKnowledgeSupported(Call call)
        {
            return true;
        }

        public Task<IDictionary<string, object>> SelectSharedKnowledge(Call call, IDictionary<string, object> userInfo)
        {
            var contentTypes = new UTType[] {
                UTTypes.Image,
                UTTypes.Pdf
            };
            UIDocumentPickerViewController docPicker = new UIDocumentPickerViewController(contentTypes, true);
            docPicker.ModalPresentationStyle = UIModalPresentationStyle.FullScreen;
            docPicker.OverrideUserInterfaceStyle = UIUserInterfaceStyle.Dark;
            docPicker.WasCancelled += DocPicker_WasCancelled;
            docPicker.DidPickDocument += DocPicker_DidPickDocument;
            docPicker.DidPickDocumentAtUrls += DocPicker_DidPickDocumentAtUrls;

            var target = userInfo[CallClientDelegateConstants.TargetPresentViewControllerIOS];
            UIViewController presenter;
            if (target is UIViewController c)
            {
                presenter = c;
            }
            else
            {
                presenter = this.PresentedViewController;
            }

            presenter.PresentViewController(docPicker, true, null);

            if (SharingKnowledgePickingTaskCompletionSource != null)
            {
                SharingKnowledgePickingTaskCompletionSource.TrySetCanceled();
                SharingKnowledgePickingTaskCompletionSource = null;
            }

            SharingKnowledgePickingTaskCompletionSource = new TaskCompletionSource<IDictionary<string, object>>();
            return SharingKnowledgePickingTaskCompletionSource.Task;
        }

        private void DocPicker_DidPickDocumentAtUrls(object sender, UIDocumentPickedAtUrlsEventArgs e)
        {
            if (e.Urls.Length == 0)
            {
                return;
            }
            var docUrl = e.Urls[0];
            HandlePickedSharingKnowledge(sender, docUrl);
        }

        private void DocPicker_DidPickDocument(object sender, UIDocumentPickedEventArgs e)
        {
            HandlePickedSharingKnowledge(sender, e.Url);
        }

        private void HandlePickedSharingKnowledge(object sender, NSUrl docUrl)
        {
            var output = new Dictionary<string, object>();
            if (docUrl != null)
            {
                var directory = NSFileManager.TemporaryDirectory;
                string filePath = directory + "/" + docUrl.LastPathComponent;
                var targetUrl = new NSUrl(filePath, false);
                NSError error;
                NSFileManager.DefaultManager.Remove(targetUrl, out _);
                if (NSFileManager.DefaultManager.Copy(docUrl, targetUrl, out error))
                {
                    output[CallClientDelegateConstants.SharedURL] = targetUrl;
                }
                else
                {
                    Console.Error.WriteLine("Cannot copy the document: ${0}, ${1}", docUrl, error);
                }
            }
            SharingKnowledgePickingTaskCompletionSource.TrySetResult(output);
            if (sender is UIImagePickerController picker)
            {
                picker.DismissViewController(true, null);
            }
        }

        private void DocPicker_WasCancelled(object sender, EventArgs e)
        {
            if (SharingKnowledgePickingTaskCompletionSource != null)
            {
                SharingKnowledgePickingTaskCompletionSource.TrySetResult(new Dictionary<string, object>());
                SharingKnowledgePickingTaskCompletionSource = null;
            }
            if (sender is UIDocumentPickerViewController picker)
            {
                picker.DismissViewController(true, null);
            }
        }

        public object IsQuickKnowledgeOverlaySupported(Call call)
        {
            return true;
        }


        //private KnowledgeOverlayPickerDelegateImpl KnowledgeOverlayPickerDelegate;
        private TaskCompletionSource<IDictionary<string, object>> KnowledgeOverlayPickingTaskCompletionSource;

        private void ImagePicker_Canceled(object sender, EventArgs e)
        {
            if (KnowledgeOverlayPickingTaskCompletionSource != null)
            {
                KnowledgeOverlayPickingTaskCompletionSource.TrySetResult(new Dictionary<string, object>());
                KnowledgeOverlayPickingTaskCompletionSource = null;
            }
            if (sender is UIImagePickerController picker)
            {
                picker.DismissViewController(true, null);
            }
        }


        private void ImagePicker_FinishedPickingImage(object sender, UIImagePickerImagePickedEventArgs e)
        {
            var userInfo = e.EditingInfo;
            var imageUrl = userInfo[UIImagePickerController.ImageUrl] as NSUrl;
            HandlePickedKnowledgeOverlay(sender, imageUrl);
        }

        private void ImagePicker_FinishedPickingMedia(object sender, UIImagePickerMediaPickedEventArgs e)
        {
            HandlePickedKnowledgeOverlay(sender, e.ImageUrl);
        }

        private void HandlePickedKnowledgeOverlay(object sender, NSUrl imageUrl)
        {
            var output = new Dictionary<string, object>();
            if (imageUrl != null)
            {
                output[CallClientDelegateConstants.SharedURL] = imageUrl;
            }
            KnowledgeOverlayPickingTaskCompletionSource.TrySetResult(output);
            if (sender is UIImagePickerController picker)
            {
                picker.DismissViewController(true, null);
            }
        }

        public Task<IDictionary<string, object>> SelectQuickKnowledgeOverlay(Call call, IDictionary<string, object> userInfo)
        {
            var imagePicker = new UIImagePickerController();
            imagePicker.SourceType = UIImagePickerControllerSourceType.PhotoLibrary;
            imagePicker.AllowsEditing = false;
            imagePicker.ModalPresentationStyle = UIModalPresentationStyle.FullScreen;
            imagePicker.OverrideUserInterfaceStyle = UIUserInterfaceStyle.Dark;
            imagePicker.Canceled += ImagePicker_Canceled;
            imagePicker.FinishedPickingImage += ImagePicker_FinishedPickingImage;
            imagePicker.FinishedPickingMedia += ImagePicker_FinishedPickingMedia;

            var target = userInfo[CallClientDelegateConstants.TargetPresentViewControllerIOS];
            UIViewController presenter = null;
            if (target != null && target is UIViewController c) {
                presenter = c;
            }
            else
            {
                presenter = this.PresentedViewController;
            }

            presenter.PresentViewController(imagePicker, true, null);

            if (KnowledgeOverlayPickingTaskCompletionSource != null)
            {
                KnowledgeOverlayPickingTaskCompletionSource.TrySetCanceled();
                KnowledgeOverlayPickingTaskCompletionSource = null;
            }

            KnowledgeOverlayPickingTaskCompletionSource = new TaskCompletionSource<IDictionary<string, object>>();
            return KnowledgeOverlayPickingTaskCompletionSource.Task;
        }
    }
}

