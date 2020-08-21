// WARNING
// This file has been generated automatically by Visual Studio to
// mirror C# types. Changes in this file made by drag-connecting
// from the UI designer will be synchronized back to C#, but
// more complex manual changes may not transfer correctly.


#import "JoinViewController.h"
#import "HLServerClient.h"
#import "CallManager.h"
#import <HLSDK/HLSDK.h>

NSString* const kDefaultUserName = @"small_u13";
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

@property (weak, nonatomic) IBOutlet UISegmentedControl *themColorPicker;

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
    [HLClient.sharedInstance startCall:call withPresentingViewController:self].then(^id(id value) {
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
    NSInteger index = self.themColorPicker.selectedSegmentIndex;
    HLTheme* theme = nil;
    switch (index) {
        case 1:
            theme = [HLTheme new];
            [theme setColor:kHLMainColor color:UIColor.darkGrayColor];
            break;
        case 2:
            theme = [HLTheme new];
            [theme setColor:kHLMainColor color:UIColor.orangeColor];
            break;
        case 3:
            theme = [HLTheme new];
            [theme setColor:kHLMainColor color:UIColor.purpleColor];
            
            //main menu
            [theme setImage:kHLImageMainMenuDocumentOff image:[UIImage imageNamed:@"Lightning"]];
            [theme setImage:kHLImageMainMenuDocumentOn image:[UIImage imageNamed:@"Lightning"]];
            [theme setImage:kHLImageMainMenuTorchOff image:[UIImage imageNamed:@"Lightning"]];
            [theme setImage:kHLImageMainMenuTorchOn image:[UIImage imageNamed:@"Lightning"]];
            [theme setImage:kHLImageMainMenu image:[UIImage imageNamed:@"Lightning"]];

            //mode
            [theme setImage:kHLImageModeMenuFaceToFaceOn image:[UIImage imageNamed:@"Lightning"]];
            [theme setImage:kHLImageModeMenuFaceToFaceOff image:[UIImage imageNamed:@"Lightning"]];
            [theme setImage:kHLImageModeMenuReceiverOn image:[UIImage imageNamed:@"Lightning"]];
            [theme setImage:kHLImageModeMenuReceiverOff image:[UIImage imageNamed:@"Lightning"]];
            [theme setImage:kHLImageModeMenuGiverOn image:[UIImage imageNamed:@"Lightning"]];
            [theme setImage:kHLImageModeMenuGiverOff image:[UIImage imageNamed:@"Lightning"]];
            [theme setImage:kHLImageCameraMenuPhotoOn image:[UIImage imageNamed:@"Lightning"]];
            [theme setImage:kHLImageCameraMenuPhotoOff image:[UIImage imageNamed:@"Lightning"]];
            [theme setImage:kHLImageCameraMenuFreezeOn image:[UIImage imageNamed:@"Lightning"]];
            [theme setImage:kHLImageCameraMenuFreezeOff image:[UIImage imageNamed:@"Lightning"]];
            [theme setImage:kHLImageCameraMenuSwitchCamera image:[UIImage imageNamed:@"Lightning"]];
            [theme setImage:kHLImageCameraMenuFrontCameraOn image:[UIImage imageNamed:@"Lightning"]];
            [theme setImage:kHLImageCameraMenuFrontCameraOff image:[UIImage imageNamed:@"Lightning"]];

            //mic
            [theme setImage:kHLImageMicOn image:[UIImage imageNamed:@"Lightning"]];
            [theme setImage:kHLImageMicOff image:[UIImage imageNamed:@"Lightning"]];

            //telestration
            [theme setImage:kHLImageTelestrationMenuColorUnselected image:[UIImage imageNamed:@"Lightning"]];
            [theme setImage:kHLImageTelestrationMenuColorSelected image:[UIImage imageNamed:@"Lightning"]];
            [theme setImage:kHLImageTelestrationMenuArrowOn image:[UIImage imageNamed:@"Lightning"]];
            [theme setImage:kHLImageTelestrationMenuArrowOff image:[UIImage imageNamed:@"Lightning"]];
            [theme setImage:kHLImageTelestrationMenuPenOn image:[UIImage imageNamed:@"Lightning"]];
            [theme setImage:kHLImageTelestrationMenuPenOff image:[UIImage imageNamed:@"Lightning"]];

            //clear
            [theme setImage:kHLImageTelestrationUndo image:[UIImage imageNamed:@"Lightning"]];
            [theme setImage:kHLImageTelestrationClearAll image:[UIImage imageNamed:@"Lightning"]];

            //end call
            [theme setImage:kHLImageEndCall image:[UIImage imageNamed:@"Lightning"]];

            [theme setImage:kHLImageScreenCaptureUnpressed image:[UIImage imageNamed:@"Lightning"]];
            [theme setImage:kHLImageScreenCaptureTransition image:[UIImage imageNamed:@"Lightning"]];
            [theme setImage:kHLImageScreenCapturePressed image:[UIImage imageNamed:@"Lightning"]];
            break;
        default:
            break;
    }
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
