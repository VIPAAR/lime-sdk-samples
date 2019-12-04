//
//  ViewController.m
//  SampleObjC
//
//  Created by Hale Xie on 2019/11/14.
//  Copyright © 2019 Helplightning. All rights reserved.
//

#import "ViewController.h"
#import <HLSDK/HLSDK.h>
#import "FBLPromises.h"

#define HL_SESSION_ID       (@"c6d553ed-1feb-4e1c-b1a7-e85a5de04c31")
#define HL_SESSION_TOKEN    (@"eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJhdHRyaWJ1dGVzIjpbIm9yZ2FuaXplciJdLCJhdWQiOiJHaGF6YWwiLCJleHAiOjE2MDYxODY3NTgsImlhdCI6MTU3NDY1MDc1OCwiaXNzIjoiR2hhemFsIiwianRpIjoiYTYwMDlmODQtODg5NS00OWY2LWFlZjktNDJmNTRkNjMwZTVmIiwibWV0YSI6e30sIm5iZiI6MTU3NDY1MDc1Nywib3JpZ2luYXRvciI6MTYsInBlbSI6eyJzZXNzaW9uIjoyNTU5fSwicmVjb3JkaW5nX3BvbGljeSI6ImFsd2F5c19vbiIsInN1YiI6IlNlc3Npb246YzZkNTUzZWQtMWZlYi00ZTFjLWIxYTctZTg1YTVkZTA0YzMxIiwidHlwIjoiYWNjZXNzIiwidmVyIjoiMTAwIn0.u5ziXTqbTAMBCgx9MZ8JkMcgCvxhKDdN3wsSW4camPw")
#define HL_GSS_URL          (@"gss+ssl://containers-asia.helplightning.net:32773")

#define HL_USER1_TOKEN       (@"eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJhdWQiOiJHaGF6YWwiLCJleHAiOjE2MDYxODY2NDUsImlhdCI6MTU3NDY1MDY0NSwiaXNzIjoiR2hhemFsIiwianRpIjoiNDNhNzYzNTAtZjUxYi00ZDIwLTlmMDItMGQ1Yjc1OGIyMzNjIiwibWV0YSI6e30sIm5iZiI6MTU3NDY1MDY0NCwicGVtIjp7InVzZXIiOjEwOTg2NTI3MDA0ODU1OH0sInN1YiI6IlVzZXI6MTUiLCJ0eXAiOiJhY2Nlc3MiLCJ2ZXIiOiIxMDAifQ.PVskE0v8fYMYR62ixhJnkK93I5piP1WCtk2I3ZpkwQM")
#define HL_USER1_NAME       (@"Small User12")
#define HL_USER1_AVATAR     (@"")

#define HL_USER2_TOKEN       (@"eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJhdWQiOiJHaGF6YWwiLCJleHAiOjE2MDYxODY2NzcsImlhdCI6MTU3NDY1MDY3NywiaXNzIjoiR2hhemFsIiwianRpIjoiNmRmYWExYWYtMDk5Yy00YjYzLWJjMGEtOTkyOGM3NGFlMGQ2IiwibWV0YSI6e30sIm5iZiI6MTU3NDY1MDY3NiwicGVtIjp7InVzZXIiOjEwOTg2NTI3MDA0ODU1OH0sInN1YiI6IlVzZXI6MTYiLCJ0eXAiOiJhY2Nlc3MiLCJ2ZXIiOiIxMDAifQ.MA8ODeG-0UXKJ0XJW6lNnKhqlaSTPfuAt2ExASPhl9E")
#define HL_USER2_NAME       (@"Small User13")

#define HL_USER2_AVATAR     (@"")

@interface ViewController () <HLClientDelegate, UITabBarDelegate>
@property (weak, nonatomic) IBOutlet UITextView *sessionId;
@property (weak, nonatomic) IBOutlet UITextView *sessionToken;
@property (weak, nonatomic) IBOutlet UITextView *userToken;
@property (weak, nonatomic) IBOutlet UITextView *userName;
@property (weak, nonatomic) IBOutlet UITextView *userAvatar;
@property (weak, nonatomic) IBOutlet UITextView *gssURL;
@property (weak, nonatomic) IBOutlet UITabBar *userTab;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *joinIndicator;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.sessionId.text = HL_SESSION_ID;
    self.sessionToken.text = HL_SESSION_TOKEN;
    self.userToken.text = HL_USER1_TOKEN;
    self.userName.text = HL_USER1_NAME;
    self.userAvatar.text = HL_USER1_AVATAR;
    self.gssURL.text = HL_GSS_URL;
    [self.userTab setSelectedItem:self.userTab.items.firstObject];
    HLClient.sharedInstance.delegate = self;
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
}

- (IBAction)cancelCall:(id)sender {
    FBLPromise* promise = [HLClient.sharedInstance stopCurrentCall];
    [promise then:^id(id value) {
        NSLog(@"The call has stopped");
        return value;
    }];
    [promise catch:^(NSError* error) {
        NSLog(@"Cannot stop the call:%@", error);
    }];
}

- (IBAction)joinCall:(id)sender {
    HLCall* call = [[HLCall alloc] initWithSessionId:self.sessionId.text
                                        sessionToken:self.sessionToken.text
                                           userToken:self.userToken.text
                                              gssUrl:self.gssURL.text
                                localUserDisplayName:self.userName.text
                                  localUserAvatarUrl:self.userAvatar.text];
    
    [self.joinIndicator startAnimating];
    FBLPromise* promise = [HLClient.sharedInstance startCall:call withPresentingViewController:self];
    [promise then:^id(id value) {
        NSLog(@"The call has started");
        return value;
    }];
    [promise catch:^(NSError* error) {
        [self.joinIndicator stopAnimating];
        NSLog(@"Cannot start the call:%@", error);
    }];
}

- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item {
    NSUInteger index = [tabBar.items indexOfObject:item];
    if (index) {
        self.userToken.text = HL_USER2_TOKEN;
        self.userName.text = HL_USER2_NAME;
        self.userAvatar.text = HL_USER2_AVATAR;
    } else {
        self.userToken.text = HL_USER1_TOKEN;
        self.userName.text = HL_USER1_NAME;
        self.userAvatar.text = HL_USER1_AVATAR;
    }
}

#pragma mark - HLSDK Delegate

- (void) call:(HLCall*)call didEndWithReason:(NSString*)reason {
    [self.joinIndicator stopAnimating];
    NSLog(@"The call has ended: %@", call.sessionId);
}

@end
