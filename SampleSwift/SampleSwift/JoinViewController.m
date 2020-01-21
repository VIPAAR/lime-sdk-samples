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

#import "JoinViewController.h"
#import "HLServerClient.h"
#import "CallManager.h"
#import <HLSDK/HLSDK.h>

NSString* const kDefaultUserName = @"small_u13";

@interface JoinViewController1 ()
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

@implementation JoinViewController1

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
