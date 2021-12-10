// WARNING
// This file has been generated automatically by Visual Studio to
// mirror C# types. Changes in this file made by drag-connecting
// from the UI designer will be synchronized back to C#, but
// more complex manual changes may not transfer correctly.


#import "AuthViewController.h"
#import "HLServerClient.h"
#import "CallManager.h"

//TODO
NSString* const kDefaultServerURL = @"[YOUR_SERVER_RUL]";
NSString* const kDefaultUserEmail = @"[YOUR_USER_NAME]";
@interface AuthViewController ()
@property (weak, nonatomic) IBOutlet UIButton *authButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *indicator;
@property (nonatomic, weak) IBOutlet UITextField *serverURLTextField;
@property (nonatomic, weak) IBOutlet UITextField *userEmailTextField;

@end

@implementation AuthViewController

- (void) viewDidLoad {
    [super viewDidLoad];
    self.serverURLTextField.text = kDefaultServerURL;
    self.userEmailTextField.text = kDefaultUserEmail;
}

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    return CallManager.sharedInstance.authToken != nil;
}

- (IBAction) OnAuthenticate:(UIButton *)sender {
    NSString* email = self.userEmailTextField.text;
    if (email.length == 0) {
        NSLog(@"No contact email");
        return;
    }
    self.authButton.enabled = NO;
    self.indicator.hidden = NO;
    HLServerClient.sharedInstance.serverURL = [NSURL URLWithString:self.serverURLTextField.text];

    CallManager.sharedInstance.userEmail = email;
    CallManager.sharedInstance.authToken = nil;
    [HLServerClient.sharedInstance authenticateWithEmail:email].then(^id(id result) {
        CallManager.sharedInstance.authToken = result;
        [self performSegueWithIdentifier:@"segueOpenSetupScreen" sender:self];
        return result;
    }).catch(^(NSError* error) {
        NSLog(@"%@", error);
    }).always(^() {
        self.authButton.enabled = YES;
        self.indicator.hidden = YES;
    });
}

@end
