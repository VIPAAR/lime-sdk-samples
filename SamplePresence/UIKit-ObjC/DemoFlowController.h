#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, DemoCallPhase) {
    DemoCallPhaseIdle,
    DemoCallPhaseStarting,
    DemoCallPhaseActive,
    DemoCallPhaseEnded
};

@interface DemoSession : NSObject
@property (nonatomic, copy) NSString *serverURL;
@property (nonatomic, copy) NSString *userEmail;
@property (nonatomic, copy) NSString *contactEmail;
@property (nonatomic, copy) NSString *apiKey;
@property (nonatomic, copy) NSString *authToken;
@property (nonatomic, copy) NSString *sessionID;
@property (nonatomic, copy) NSString *sessionToken;
@property (nonatomic, copy) NSString *userToken;
@property (nonatomic, copy) NSString *gssServerURL;
@property (nonatomic, copy) NSString *sessionPIN;
@property (nonatomic, copy) NSString *displayName;
@property (nonatomic, copy) NSString *avatarURL;
@property (nonatomic, assign) BOOL cameraEnabled;
@property (nonatomic, assign) BOOL microphoneEnabled;

- (void)applySessionDictionary:(NSDictionary *)dictionary;
- (void)applyDemoConfigurationDefaults;
- (void)clearSessionFields;
- (BOOL)canStartCall;
@end

@class DemoFlowController;
@class DemoCallCoordinator;
@class UINavigationController;
@class UIViewController;

@interface DemoFlowController : NSObject
@property (nonatomic, strong) DemoSession *session;
@property (nonatomic, strong, readonly) DemoCallCoordinator *callCoordinator;
@property (nonatomic, weak, nullable) UINavigationController *navigationController;
@property (nonatomic, assign, getter=isBusy) BOOL busy;
@property (nonatomic, copy, nullable) NSString *errorMessage;
@property (nonatomic, assign) DemoCallPhase callPhase;
@property (nonatomic, copy) NSString *callStatusMessage;

@property (nonatomic, copy, nullable) void (^onBusyChanged)(BOOL busy);
@property (nonatomic, copy, nullable) void (^onErrorChanged)(NSString * _Nullable errorMessage);
@property (nonatomic, copy, nullable) void (^onCallPhaseChanged)(DemoCallPhase phase);
@property (nonatomic, copy, nullable) void (^onCallStatusChanged)(NSString *message);

- (void)authenticate;
- (void)createSession;
- (void)retrieveSessionWithPIN:(NSString *)pin;
- (void)joinCallFromViewController:(UIViewController *)presentingViewController;
- (void)stopCall;
@end

NS_ASSUME_NONNULL_END
