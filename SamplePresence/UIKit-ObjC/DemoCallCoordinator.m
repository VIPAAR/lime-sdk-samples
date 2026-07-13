#import "DemoCallCoordinator.h"
#import "DemoCallOptions.h"
#import <HLSDK/HLSDK.h>
#import "SamplePresence_iOS_UIKit_ObjC-Swift.h"

@interface DemoCallCoordinator () <HLClientDelegate>
@end

@implementation DemoCallCoordinator

- (instancetype)init {
    self = [super init];
    if (self) {
        [HLClient sharedInstance].delegate = self;
        [DemoObjCSupport tidyLoggingAfterSDKInit];
    }
    return self;
}

- (void)joinCallWithSession:(DemoSession *)session
   presentingViewController:(UIViewController *)presentingViewController
                 completion:(void (^)(NSError * _Nullable))completion {
    if (![session canStartCall]) {
        [self notifyPhase:DemoCallPhaseEnded
                  message:@"Replace placeholder session values and API key before joining a call."];
        if (completion) {
            completion([NSError errorWithDomain:@"SamplePresence"
                                           code:1
                                       userInfo:@{NSLocalizedDescriptionKey: @"Invalid session fields."}]);
        }
        return;
    }

    [self notifyPhase:DemoCallPhaseStarting message:@"Starting call…"];

    HLCall *call = [[HLCall alloc] initWithSessionId:session.sessionID
                                        sessionToken:session.sessionToken
                                           userToken:session.userToken
                                              gssUrl:session.gssServerURL
                                 helplightningAPIKey:session.apiKey
                                localUserDisplayName:session.displayName
                                localUserAvatarUrl:session.avatarURL
                                      autoEnableCamera:session.cameraEnabled
                                   autoEnableMicrophone:session.microphoneEnabled];
    if (!call) {
        NSString *message = @"Could not create an SDK call object from the current session fields.";
        [self notifyPhase:DemoCallPhaseEnded message:message];
        if (completion) {
            completion([NSError errorWithDomain:@"SamplePresence"
                                           code:2
                                       userInfo:@{NSLocalizedDescriptionKey: message}]);
        }
        return;
    }

    call.dataCenterID = kHLDataCenterID_US1;

#if SAMPLE_PRESENCE_USE_LEGACY_UIKIT_START_CALL
    FBLPromise *startPromise =
        [[HLClient sharedInstance] startCall:call
                withPresentingViewController:presentingViewController];
#else
    HLCallConfiguration *configuration =
        [HLCallConfiguration uikitConfigurationWithCall:call
                             presentingViewController:presentingViewController];
    if (!configuration) {
        NSString *message = @"Could not create a UIKit call configuration.";
        [self notifyPhase:DemoCallPhaseEnded message:message];
        if (completion) {
            completion([NSError errorWithDomain:@"SamplePresence"
                                           code:3
                                       userInfo:@{NSLocalizedDescriptionKey: message}]);
        }
        return;
    }

    FBLPromise *startPromise =
        [[HLClient sharedInstance] startCallWithConfiguration:configuration];
#endif

    [startPromise then:^id _Nullable(id  _Nullable value) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self notifyPhase:DemoCallPhaseActive message:@"Call active"];
            if (completion) {
                completion(nil);
            }
        });
        return value;
    }].catch(^(NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self notifyPhase:DemoCallPhaseEnded message:error.localizedDescription];
            if (completion) {
                completion(error);
            }
        });
    });
}

- (void)stopCallWithCompletion:(void (^)(void))completion {
    [[[HLClient sharedInstance] stopCurrentCall] then:^id _Nullable(id  _Nullable value) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self notifyPhase:DemoCallPhaseIdle message:@"Call ended"];
            if (completion) {
                completion();
            }
        });
        return value;
    }].catch(^(NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self notifyPhase:DemoCallPhaseEnded message:error.localizedDescription];
            if (completion) {
                completion();
            }
        });
    });
}

- (NSDictionary *)hlCallNeedScreenSharingInfo:(id<HLGenericCall>)call {
    return @{
        kHLCallPluginScreenSharingAppGroupName: DemoObjCSupport.screenSharingAppGroup,
        kHLCallPluginScreenSharingBroadcastExtensionBundleId: DemoObjCSupport.screenSharingExtensionBundleIdentifier
    };
}

- (void)hlCall:(HLCall *)call didEndWithReason:(NSString *)reason {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self notifyPhase:DemoCallPhaseEnded message:reason ?: @""];
    });
}

- (void)notifyPhase:(DemoCallPhase)phase message:(NSString *)message {
    if (self.onPhaseChanged) {
        self.onPhaseChanged(phase, message ?: @"");
    }
}

@end
