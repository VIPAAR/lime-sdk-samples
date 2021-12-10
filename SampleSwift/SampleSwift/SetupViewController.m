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


#import "SetupViewController.h"
#import "HLServerClient.h"
#import "CallManager.h"

NSString* const kDefaultContactEmail = @"[YOUR_USER_NAME]";

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
        CallManager.sharedInstance.sessionID = json[@"session_id"];
        CallManager.sharedInstance.sessionToken = json[@"session_token"];
        CallManager.sharedInstance.userToken = json[@"user_token"];
        CallManager.sharedInstance.gssServerURL = json[@"url"];
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
        CallManager.sharedInstance.sessionID = json[@"session_id"];
        CallManager.sharedInstance.sessionToken = json[@"session_token"];
        CallManager.sharedInstance.userToken = json[@"user_token"];
        CallManager.sharedInstance.gssServerURL = json[@"url"];
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
