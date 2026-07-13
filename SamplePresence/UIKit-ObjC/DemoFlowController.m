#import "DemoFlowController.h"
#import "DemoCallCoordinator.h"
#import "SetupViewController.h"
#import "JoinViewController.h"
#import "SamplePresence_iOS_UIKit_ObjC-Swift.h"

@implementation DemoSession

- (instancetype)init {
    self = [super init];
    if (self) {
        _authToken = @"";
        _sessionID = @"";
        _sessionToken = @"";
        _userToken = @"";
        _gssServerURL = @"";
        _sessionPIN = @"";
        _cameraEnabled = YES;
        _microphoneEnabled = YES;
        [self applyDemoConfigurationDefaults];
    }
    return self;
}

- (void)applyDemoConfigurationDefaults {
    [DemoObjCSupport applyDemoConfigurationDefaultsToSession:self];
}

- (void)applySessionDictionary:(NSDictionary *)dictionary {
    self.sessionID = dictionary[@"sessionID"] ?: @"";
    self.sessionToken = dictionary[@"sessionToken"] ?: @"";
    self.userToken = dictionary[@"userToken"] ?: @"";
    self.gssServerURL = dictionary[@"gssURL"] ?: @"";
    if (dictionary[@"pin"]) {
        self.sessionPIN = dictionary[@"pin"];
    }
}

- (void)clearSessionFields {
    self.sessionID = @"";
    self.sessionToken = @"";
    self.userToken = @"";
    self.gssServerURL = @"";
    self.sessionPIN = @"";
}

- (BOOL)canStartCall {
    return self.sessionID.length > 0
        && self.sessionToken.length > 0
        && self.userToken.length > 0
        && self.gssServerURL.length > 0
        && self.apiKey.length > 0
        && ![self.apiKey containsString:@"[YOUR_"];
}

@end

@implementation DemoFlowController

- (instancetype)init {
    self = [super init];
    if (self) {
        _session = [[DemoSession alloc] init];
        _callCoordinator = [[DemoCallCoordinator alloc] init];
        _callPhase = DemoCallPhaseIdle;
        _callStatusMessage = @"";

        __weak typeof(self) weakSelf = self;
        _callCoordinator.onPhaseChanged = ^(DemoCallPhase phase, NSString *message) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (!strongSelf) { return; }
            strongSelf.callPhase = phase;
            strongSelf.callStatusMessage = message ?: @"";
            if (strongSelf.onCallPhaseChanged) {
                strongSelf.onCallPhaseChanged(phase);
            }
            if (strongSelf.onCallStatusChanged) {
                strongSelf.onCallStatusChanged(strongSelf.callStatusMessage);
            }
        };
    }
    return self;
}

- (void)setBusy:(BOOL)busy {
    if (_busy == busy) { return; }
    _busy = busy;
    if (self.onBusyChanged) {
        self.onBusyChanged(busy);
    }
}

- (void)setErrorMessage:(NSString *)errorMessage {
    _errorMessage = [errorMessage copy];
    if (self.onErrorChanged) {
        self.onErrorChanged(_errorMessage);
    }
}

- (void)setCallPhase:(DemoCallPhase)callPhase {
    _callPhase = callPhase;
    if (self.onCallPhaseChanged) {
        self.onCallPhaseChanged(callPhase);
    }
}

- (void)setCallStatusMessage:(NSString *)callStatusMessage {
    _callStatusMessage = [callStatusMessage copy];
    if (self.onCallStatusChanged) {
        self.onCallStatusChanged(_callStatusMessage);
    }
}

- (void)authenticate {
    self.busy = YES;
    self.errorMessage = nil;

    [[DemoServerBridge shared] authenticateWithServerURL:self.session.serverURL
                                                   email:self.session.userEmail
                                                  apiKey:self.session.apiKey
                                              completion:^(NSString *token, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.busy = NO;
            if (error) {
                self.errorMessage = error.localizedDescription;
                return;
            }
            self.session.authToken = token ?: @"";
            [self pushSetup];
        });
    }];
}

- (void)createSession {
    self.busy = YES;
    self.errorMessage = nil;
    [self.session clearSessionFields];

    [[DemoServerBridge shared] createSessionWithServerURL:self.session.serverURL
                                                authToken:self.session.authToken
                                             contactEmail:self.session.contactEmail
                                                   apiKey:self.session.apiKey
                                               completion:^(NSDictionary *response, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.busy = NO;
            if (error) {
                self.errorMessage = error.localizedDescription;
                return;
            }
            [self.session applySessionDictionary:response ?: @{}];
            [self pushJoin];
        });
    }];
}

- (void)retrieveSessionWithPIN:(NSString *)pin {
    self.busy = YES;
    self.errorMessage = nil;
    [self.session clearSessionFields];
    self.session.sessionPIN = pin;

    [[DemoServerBridge shared] retrieveSessionWithServerURL:self.session.serverURL
                                                  authToken:self.session.authToken
                                                        pin:pin
                                                     apiKey:self.session.apiKey
                                                 completion:^(NSDictionary *response, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.busy = NO;
            if (error) {
                self.errorMessage = error.localizedDescription;
                return;
            }
            [self.session applySessionDictionary:response ?: @{}];
            [self pushJoin];
        });
    }];
}

- (void)joinCallFromViewController:(UIViewController *)presentingViewController {
    self.busy = YES;
    self.errorMessage = nil;
    [self.callCoordinator joinCallWithSession:self.session
                     presentingViewController:presentingViewController
                                   completion:^(NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.busy = NO;
            if (error) {
                self.errorMessage = error.localizedDescription;
            }
        });
    }];
}

- (void)stopCall {
    self.busy = YES;
    [self.callCoordinator stopCallWithCompletion:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            self.busy = NO;
        });
    }];
}

- (void)pushSetup {
    if (!self.navigationController) { return; }
    SetupViewController *setup = [[SetupViewController alloc] initWithFlowController:self];
    [self.navigationController pushViewController:setup animated:YES];
}

- (void)pushJoin {
    if (!self.navigationController) { return; }
    JoinViewController *join = [[JoinViewController alloc] initWithFlowController:self];
    [self.navigationController pushViewController:join animated:YES];
}

@end
