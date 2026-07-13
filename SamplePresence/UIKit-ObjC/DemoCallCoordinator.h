#import <Foundation/Foundation.h>
#import "DemoFlowController.h"

NS_ASSUME_NONNULL_BEGIN

@interface DemoCallCoordinator : NSObject
@property (nonatomic, copy, nullable) void (^onPhaseChanged)(DemoCallPhase phase, NSString *message);

- (void)joinCallWithSession:(DemoSession *)session
   presentingViewController:(UIViewController *)presentingViewController
                 completion:(void (^)(NSError * _Nullable error))completion;

- (void)stopCallWithCompletion:(void (^)(void))completion;
@end

NS_ASSUME_NONNULL_END
