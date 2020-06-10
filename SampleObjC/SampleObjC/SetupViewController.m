// WARNING
// This file has been generated automatically by Visual Studio to
// mirror C# types. Changes in this file made by drag-connecting
// from the UI designer will be synchronized back to C#, but
// more complex manual changes may not transfer correctly.


#import "SetupViewController.h"
#import "HLServerClient.h"
#import "CallManager.h"

NSString* const kDefaultContactEmail = @"small_u13@helplightning.com";

@interface SetupViewController ()
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *indicator;
@property (weak, nonatomic) IBOutlet UIButton *createCallButton;
@property (weak, nonatomic) IBOutlet UIButton *getCallButton;
@property (nonatomic, weak) IBOutlet UITextField *authTokenTextField;
@property (nonatomic, weak) IBOutlet UITextField *contactEmailTextField;
@property (nonatomic, weak) IBOutlet UITextField *PINTextField;

@end

@implementation SetupViewController

- (void) viewDidLoad {
    [super viewDidLoad];
    self.contactEmailTextField.text = kDefaultContactEmail;
    self.authTokenTextField.text = CallManager.sharedInstance.authToken;
}

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    return CallManager.sharedInstance.sessionID != nil
    && CallManager.sharedInstance.sessionToken != nil
    && CallManager.sharedInstance.userToken != nil;
}

- (IBAction)OnCancel:(UIBarButtonItem *)sender {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)OnCreateCall:(UIButton *)sender {
    NSString* contactEmail = self.contactEmailTextField.text;
    if (contactEmail.length == 0) {
        NSLog(@"No contact email");
        return;
    }
    self.indicator.hidden = NO;
    self.createCallButton.enabled = NO;
    self.getCallButton.enabled = NO;
    
    CallManager.sharedInstance.contactEmail = contactEmail;
    
    CallManager.sharedInstance.sessionID = nil;
    CallManager.sharedInstance.sessionToken = nil;
    CallManager.sharedInstance.userToken = nil;
    
    [HLServerClient.sharedInstance createCallWithAuthToken:CallManager.sharedInstance.authToken contactEmail:contactEmail].then(^id(id result) {
        NSDictionary* json = (NSDictionary*)result;
        CallManager.sharedInstance.sessionID = json[@"session_id"][0];
        CallManager.sharedInstance.sessionToken = json[@"session_token"];
        CallManager.sharedInstance.userToken = json[@"user_token"];
        CallManager.sharedInstance.gssServerURL = json[@"url"][0];
        CallManager.sharedInstance.sessionPIN = json[@"sid"];
        
        [self performSegueWithIdentifier:@"segueOpenJoinScreen1" sender:self];
        return result;
    }).catch(^(NSError* error) {
        NSLog(@"%@", error);
    }).always(^() {
        self.indicator.hidden = YES;
        self.createCallButton.enabled = YES;
        self.getCallButton.enabled = YES;
    });
    
}

- (IBAction) OnGetCall:(UIButton *)sender {
    NSString* pin = self.PINTextField.text;
    if (pin.length == 0) {
        NSLog(@"No PIN");
        return;
    }
    self.indicator.hidden = NO;
    self.createCallButton.enabled = NO;
    self.getCallButton.enabled = NO;
    
    CallManager.sharedInstance.sessionPIN = pin;
    
    CallManager.sharedInstance.sessionID = nil;
    CallManager.sharedInstance.sessionToken = nil;
    CallManager.sharedInstance.userToken = nil;
    
    [HLServerClient.sharedInstance retreiveCallWithAuthToken:CallManager.sharedInstance.authToken
                                                         pin:pin]
    .then(^id(id result) {
        NSDictionary* json = (NSDictionary*)result;
        CallManager.sharedInstance.sessionID = json[@"session_id"][0];
        CallManager.sharedInstance.sessionToken = json[@"session_token"];
        CallManager.sharedInstance.userToken = json[@"user_token"];
        CallManager.sharedInstance.gssServerURL = json[@"url"][0];
        [self performSegueWithIdentifier:@"segueOpenJoinScreen2" sender:self];
        return result;
    }).catch(^(NSError* error) {
        NSLog(@"%@", error);
    }).always(^() {
        self.indicator.hidden = YES;
        self.createCallButton.enabled = YES;
        self.getCallButton.enabled = YES;
    });
}

@end
