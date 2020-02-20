/* -*- Mode:objc; c-basic-offset: 4; indent-tabs-mode: nil; -*- */
/*
 **
 ** Copyright (c) 2020 VIPAAR, LLC all rights reserved.
 **
 ** Any commercial use of this software is subject to license
 ** agreement. Disclosure of the information contained herein to any
 ** third parties is prohibited without prior written consent. This
 ** software is subject to US export control regulations.
 **
 ** THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 ** ``AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 ** LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
 ** FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
 ** AUTHORS OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
 ** INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 ** (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 ** SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 ** INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
 ** WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
 ** NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
 ** THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 **
 */


#import "AuthViewController.h"
#import "HLServerClient.h"
#import "CallManager.h"

NSString* const kDefaultServerURL = @"http://192.168.0.31:8777";
NSString* const kDefaultUserEmail = @"small_u13@helplightning.com";
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
