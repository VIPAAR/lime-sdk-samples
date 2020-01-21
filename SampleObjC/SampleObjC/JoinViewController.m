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

@interface JoinViewController ()
@property (nonatomic, retain) IBOutlet UITextField *gssServerURLTextField;

@property (nonatomic, retain) IBOutlet UITextField *sessionIDTextField;

@property (nonatomic, retain) IBOutlet UITextField *sessionPINTextField;

@property (nonatomic, retain) IBOutlet UITextView *sessionTokenTextView;

@property (nonatomic, retain) IBOutlet UITextField *userAvatarTextField;

@property (nonatomic, retain) IBOutlet UITextField *userNameTextField;

@property (weak, nonatomic) IBOutlet UIButton *joinButton;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *indicator;

@property (weak, nonatomic) IBOutlet UISegmentedControl *themColorPicker;

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
    
    HLCall* call = [[HLCall alloc] initWithSessionId:CallManager.sharedInstance.sessionID
                                        sessionToken:CallManager.sharedInstance.sessionToken
                                           userToken:CallManager.sharedInstance.userToken
                                              gssUrl:CallManager.sharedInstance.gssServerURL
                                localUserDisplayName:CallManager.sharedInstance.userName
                                  localUserAvatarUrl:CallManager.sharedInstance.userAvatar];
    
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
            [theme setImage:kHLImageModeMenuFaceToFaceOn image:[UIImage imageNamed:@"Lightning"]];
            break;
        case 2:
            theme = [HLTheme new];
            [theme setColor:kHLMainColor color:UIColor.orangeColor];
            [theme setImage:kHLImageModeMenuFaceToFaceOn image:[UIImage imageNamed:@"03_contacts"]];
            break;
        case 3:
            theme = [HLTheme new];
            [theme setColor:kHLMainColor color:UIColor.purpleColor];
            [theme setImage:kHLImageModeMenuFaceToFaceOn image:[UIImage imageNamed:@"03_contacts_active"]];
            [theme setImage:kHLImageModeMenuFaceToFaceOff image:[UIImage imageNamed:@"Lightning"]];
            break;
        default:
            break;
    }
    [HLClient.sharedInstance setTheme:theme];
}

@end
