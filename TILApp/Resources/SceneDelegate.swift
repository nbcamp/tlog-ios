import Combine
import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    private var cancellables: [AnyCancellable] = []

    func scene(_ scene: UIScene, willConnectTo _: UISceneSession, options _: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = .init(windowScene: windowScene)
        window?.makeKeyAndVisible()

        let viewController = UIViewController()
        viewController.view.backgroundColor = .systemBackground
        window?.rootViewController = viewController

        AuthViewModel.shared.withUser { [unowned self] _ in
            self.window?.rootViewController = RootViewController()
        } onError: { [unowned self] _ in
            self.window?.rootViewController = SignInViewController()
        }
    }

    func sceneDidDisconnect(_: UIScene) {}

    func sceneDidBecomeActive(_: UIScene) {
        AuthViewModel.shared.$isAuthenticated.sink { [unowned self] authenticated in
            self.window?.rootViewController = authenticated ? RootViewController() : SignInViewController()
        }.store(in: &cancellables)
    }

    func sceneWillResignActive(_: UIScene) {}

    func sceneWillEnterForeground(_: UIScene) {}

    func sceneDidEnterBackground(_: UIScene) {}
}
