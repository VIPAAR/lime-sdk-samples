#import "SceneDelegate.h"
#import "AuthViewController.h"
#import "DemoFlowController.h"

@implementation SceneDelegate

- (void)scene:(UIScene *)scene willConnectToSession:(UISceneSession *)session options:(UISceneConnectionOptions *)connectionOptions {
    if (![scene isKindOfClass:[UIWindowScene class]]) {
        return;
    }

    UIWindowScene *windowScene = (UIWindowScene *)scene;
    self.flowController = [[DemoFlowController alloc] init];
    AuthViewController *authViewController =
        [[AuthViewController alloc] initWithFlowController:self.flowController];
    UINavigationController *navigationController =
        [[UINavigationController alloc] initWithRootViewController:authViewController];
    self.flowController.navigationController = navigationController;

    UIWindow *window = [[UIWindow alloc] initWithWindowScene:windowScene];
    window.rootViewController = navigationController;
    [window makeKeyAndVisible];
    self.window = window;
}

@end
