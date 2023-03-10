// WARNING
// This file has been generated automatically by Visual Studio to
// mirror C# types. Changes in this file made by drag-connecting
// from the UI designer will be synchronized back to C#, but
// more complex manual changes may not transfer correctly.


#import "JoinViewController.h"
#import "HLServerClient.h"
#import "CallManager.h"
#import <HLSDKCommon/HLSDKCommon.h>
#import <HLSDK/HLSDK.h>

//TODO
NSString* const kDefaultUserName = @"[YOUR_USER_NAME]";
NSString* const kHLApiKey = @"[YOUR_HL_API_KEY]";


@interface JoinViewController () <HLClientDelegate>
@property (nonatomic, retain) IBOutlet UITextField *gssServerURLTextField;

@property (nonatomic, retain) IBOutlet UITextField *sessionIDTextField;

@property (nonatomic, retain) IBOutlet UITextField *sessionPINTextField;

@property (nonatomic, retain) IBOutlet UITextView *sessionTokenTextView;

@property (nonatomic, retain) IBOutlet UITextField *userAvatarTextField;

@property (nonatomic, retain) IBOutlet UITextField *userNameTextField;

@property (weak, nonatomic) IBOutlet UIButton *joinButton;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *indicator;

@property (weak, nonatomic) IBOutlet UIImageView *imagePreview;

@property (weak, nonatomic) IBOutlet UISwitch *camOnSwitch;

@property (weak, nonatomic) IBOutlet UISwitch *micOnSwitch;

@end

@implementation JoinViewController

- (void) viewDidLoad {
    [super viewDidLoad];
    self.sessionPINTextField.text = CallManager.sharedInstance.sessionPIN;
    self.sessionIDTextField.text = CallManager.sharedInstance.sessionID;
    self.sessionTokenTextView.text = CallManager.sharedInstance.sessionToken;
    self.userNameTextField.text = CallManager.sharedInstance.userName;
    self.userAvatarTextField.text = CallManager.sharedInstance.userAvatar;
    self.gssServerURLTextField.text = CallManager.sharedInstance.gssServerURL;
    self.userNameTextField.text = kDefaultUserName;
    self.camOnSwitch.on = CallManager.sharedInstance.camOn;
    self.micOnSwitch.on = CallManager.sharedInstance.micOn;
    HLClient.sharedInstance.delegate = self;
}

- (IBAction)OnCancel:(UIBarButtonItem *)sender {
    [HLClient.sharedInstance stopCurrentCall].always(^() {
        [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    });
}

- (IBAction)OnJoinCall:(UIButton *)sender {
    [self _setupTheme];
    
    CallManager.sharedInstance.sessionID = self.sessionIDTextField.text;
    CallManager.sharedInstance.sessionToken = self.sessionTokenTextView.text;
    CallManager.sharedInstance.userName = self.userNameTextField.text;
    CallManager.sharedInstance.userAvatar = self.userAvatarTextField.text;
    CallManager.sharedInstance.gssServerURL = self.gssServerURLTextField.text;
    CallManager.sharedInstance.camOn = self.camOnSwitch.on;
    CallManager.sharedInstance.micOn = self.micOnSwitch.on;
    
    HLCall* call = [[HLCall alloc] initWithSessionId:CallManager.sharedInstance.sessionID
                                        sessionToken:CallManager.sharedInstance.sessionToken
                                           userToken:CallManager.sharedInstance.userToken
                                              gssUrl:CallManager.sharedInstance.gssServerURL
                                 helplightningAPIKey:kHLApiKey
                                localUserDisplayName:CallManager.sharedInstance.userName
                                  localUserAvatarUrl:CallManager.sharedInstance.userAvatar
                                    autoEnableCamera:CallManager.sharedInstance.camOn
                                autoEnableMicrophone:CallManager.sharedInstance.micOn];
    
    self.joinButton.enabled = NO;
    self.indicator.hidden = NO;
    //TODO kHLDataCenterID_EU1 kHLDataCenterID_US1
    [HLClient.sharedInstance startCall:call withPresentingViewController:self dataCenter:kHLDataCenterID_US1].then(^id(id value) {
        NSLog(@"The call has started");
        return value;
    }).catch(^(NSError* error) {
        NSLog(@"Cannot start the call:%@", error);
    }).always(^() {
        self.indicator.hidden = TRUE;
        self.joinButton.enabled = TRUE;
    });
}

- (void) _setupTheme {
    HLTheme* theme = [HLTheme new];
    
    [theme setImage:kHLImageMainMenuTorchOff image:[UIImage imageNamed:@"Lightning"]];
    [theme setImage:kHLImageMainMenuTorchOn image:[UIImage imageNamed:@"Lightning"]];
    [theme setImage:kHLImageMainMenu image:[UIImage imageNamed:@"Lightning"]];
    [theme setImage:kHLImageMainMenuInvite image:[UIImage imageNamed:@"Lightning"]];
    
    [theme setImage:kHLImageCameraMenuPhotoOn image:[UIImage imageNamed:@"Lightning"]];
    [theme setImage:kHLImageCameraMenuFreezeOn image:[UIImage imageNamed:@"Lightning"]];
    [theme setImage:kHLImageCameraMenuFreezeOff image:[UIImage imageNamed:@"Lightning"]];
    [theme setImage:kHLImageCameraMenuSwitchCamera image:[UIImage imageNamed:@"Lightning"]];
    
    //mic
    [theme setImage:kHLImageMicOn image:[UIImage imageNamed:@"Lightning"]];
    [theme setImage:kHLImageMicOff image:[UIImage imageNamed:@"Lightning"]];
    
    [theme setImage:kHLImageTelestrationMenuArrowOn image:[UIImage imageNamed:@"Lightning"]];
    [theme setImage:kHLImageTelestrationMenuArrowOff image:[UIImage imageNamed:@"Lightning"]];
    [theme setImage:kHLImageTelestrationMenuPenOn image:[UIImage imageNamed:@"Lightning"]];
    [theme setImage:kHLImageTelestrationMenuPenOff image:[UIImage imageNamed:@"Lightning"]];
    
    [theme setImage:kHLImageTelestrationMenuPushPinOn image:[UIImage imageNamed:@"Lightning"]];
    [theme setImage:kHLImageTelestrationMenuPushPinOff image:[UIImage imageNamed:@"Lightning"]];
    [theme setImage:kHLImageTelestrationMenu3DArrowOff image:[UIImage imageNamed:@"Lightning"]];
    [theme setImage:kHLImageTelestrationMenu3DArrowOn image:[UIImage imageNamed:@"Lightning"]];
    [theme setImage:kHLImageTelestrationMenu3DPenOn image:[UIImage imageNamed:@"Lightning"]];
    [theme setImage:kHLImageTelestrationMenu3DPenOff image:[UIImage imageNamed:@"Lightning"]];
    [theme setImage:kHLImageTelestrationMenu3DPushPinOff image:[UIImage imageNamed:@"Lightning"]];
    [theme setImage:kHLImageTelestrationMenu3DPushPinOn image:[UIImage imageNamed:@"Lightning"]];
    [theme setImage:kHLImageTelestration3DIndicator image:[UIImage imageNamed:@"Lightning"]];
    [theme setImage:kHLImageTelestration3DIconBorder image:[UIImage imageNamed:@"Lightning"]];
    
    //clear
    [theme setImage:kHLImageTelestrationUndo image:[UIImage imageNamed:@"Lightning"]];
    [theme setImage:kHLImageTelestrationClearAll image:[UIImage imageNamed:@"Lightning"]];
    
    //end call
    [theme setImage:kHLImageEndCall image:[UIImage imageNamed:@"Lightning"]];
    
    //screen capture
    [theme setImage:kHLImageScreenCaptureUnpressed image:[UIImage imageNamed:@"Lightning"]];
    [theme setImage:kHLImageScreenCaptureTransition image:[UIImage imageNamed:@"Lightning"]];
    [theme setImage:kHLImageScreenCapturePressed image:[UIImage imageNamed:@"Lightning"]];
    
    //default profile icon
    [theme setImage:kHLImageDefaultProfileIcon image:[UIImage imageNamed:@"Lightning"]];
    
    //audio plus mode
    [theme setImage:kHLImageAudioPlusMode image:[UIImage imageNamed:@"Lightning"]];
    [theme setImage:kHLImageCallQualityAudio image:[UIImage imageNamed:@"Lightning"]];
    [theme setImage:kHLImageCallQualityHD image:[UIImage imageNamed:@"Lightning"]];
    [theme setImage:kHLImageCallQualitySD image:[UIImage imageNamed:@"Lightning"]];
    [theme setImage:kHLImageCameraDisabled image:[UIImage imageNamed:@"Lightning"]];
    
    //chat
    [theme setImage:kHLImageChatGroupAvatar image:[UIImage imageNamed:@"Lightning"]];
    [theme setImage:kHLImageChatMoreAction image:[UIImage imageNamed:@"Lightning"]];
    [theme setImage:kHLImageChatSend image:[UIImage imageNamed:@"Lightning"]];
    [theme setImage:kHLImageChatPlaceholder image:[UIImage imageNamed:@"Lightning"]];
    [theme setImage:kHLImageChatMenu image:[UIImage imageNamed:@"Lightning"]];
    [theme setImage:kHLImageChatAttachment image:[UIImage imageNamed:@"Lightning"]];
    [theme setImage:kHLImageChatCamera image:[UIImage imageNamed:@"Lightning"]];
    
    
    [theme setImage:kHLImageBannerRote image:[UIImage imageNamed:@"Lightning"]];
    [theme setImage:kHLImageActionBarMergeNormal image:[UIImage imageNamed:@"Lightning"]];
    [theme setImage:kHLImageActionBarMergeSelected image:[UIImage imageNamed:@"Lightning"]];
    [theme setImage:kHLImageActionBarShareNormal image:[UIImage imageNamed:@"Lightning"]];
    [theme setImage:kHLImageActionBarShareSelected image:[UIImage imageNamed:@"Lightning"]];
    [theme setImage:kHLIconAnnotation3DColorBorderRed image:[UIImage imageNamed:@"Lightning"]];
    [theme setImage:kHLIconAnnotation3DColorBorderYellow image:[UIImage imageNamed:@"Lightning"]];
    [theme setImage:kHLIconAnnotation3DColorBorderGreen image:[UIImage imageNamed:@"Lightning"]];
    [theme setImage:kHLIconAnnotation3DColorBorderBlue image:[UIImage imageNamed:@"Lightning"]];
    [theme setImage:kHLIconAnnotationColorBorderRed image:[UIImage imageNamed:@"Lightning"]];
    [theme setImage:kHLIconAnnotationColorBorderYellow image:[UIImage imageNamed:@"Lightning"]];
    [theme setImage:kHLIconAnnotationColorBorderGreen image:[UIImage imageNamed:@"Lightning"]];
    
    [theme setImage:kHLIconAnnotationColorBorderBlue image:[UIImage imageNamed:@"Lightning"]];
    [theme setImage:kHLIconAnnotationColorRed image:[UIImage imageNamed:@"Lightning"]];
    [theme setImage:kHLIconAnnotationColorYellow image:[UIImage imageNamed:@"Lightning"]];
    [theme setImage:kHLIconAnnotationColorGreen image:[UIImage imageNamed:@"Lightning"]];
    [theme setImage:kHLIconAnnotationColorBlue image:[UIImage imageNamed:@"Lightning"]];
    [theme setImage:kHLImageScreenCapture image:[UIImage imageNamed:@"Lightning"]];
    [theme setImage:kHLImageEndCap image:[UIImage imageNamed:@"Lightning"]];
    [theme setImage:kHLImageTick image:[UIImage imageNamed:@"Lightning"]];
    [theme setImage:kHLImageCameraMenuCameraOn image:[UIImage imageNamed:@"Lightning"]];
    [theme setImage:kHLImageCameraMenuCameraOff image:[UIImage imageNamed:@"Lightning"]];
    [theme setImage:kHLImageShareMenuFile image:[UIImage imageNamed:@"Lightning"]];
    [theme setImage:kHLImageShareMenuFileSelected image:[UIImage imageNamed:@"Lightning"]];
    [theme setImage:kHLImageShareMenuGallery image:[UIImage imageNamed:@"Lightning"]];
    [theme setImage:kHLImageShareMenuGallerySelected image:[UIImage imageNamed:@"Lightning"]];
    [theme setImage:kHLImageShareMyCamera image:[UIImage imageNamed:@"Lightning"]];
    [theme setImage:kHLImageShareMenuTakePhoto image:[UIImage imageNamed:@"Lightning"]];
    [theme setImage:kHLImageShareMenuTakePhotoSelected image:[UIImage imageNamed:@"Lightning"]];
    [theme setImage:kHLImageShareMenuVideo image:[UIImage imageNamed:@"Lightning"]];
    [theme setImage:kHLImageShareMenuWhiteBoard image:[UIImage imageNamed:@"Lightning"]];
    [theme setImage:kHLImageShareMenuWhiteBoardSelected image:[UIImage imageNamed:@"Lightning"]];
    [theme setImage:kHLImageChevron image:[UIImage imageNamed:@"Lightning"]];
    [HLClient.sharedInstance setTheme:theme];
}

#pragma mark - HLClientDelegate
- (void) call:(HLCall*)call didCaptureScreen:(UIImage *)image {
    NSLog(@"Image Captured: %@", image);
    self.imagePreview.image = image;
}

- (void) call:(HLCall*)call didEndWithReason:(NSString *)reason {
    NSLog(@"Call Ended: %@", call.sessionId);
}

@end
