import UIKit

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    private let flowController = DemoFlowController()

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = scene as? UIWindowScene else { return }

        let navigationController = UINavigationController(
            rootViewController: AuthViewController(flowController: flowController)
        )
        flowController.navigationController = navigationController

        let window = UIWindow(windowScene: windowScene)
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
        self.window = window
    }
}
