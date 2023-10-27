import Combine
import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    private var cancellables: [AnyCancellable] = []

    func scene(_ scene: UIScene, willConnectTo _: UISceneSession, options _: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = .init(windowScene: windowScene)
        window?.makeKeyAndVisible()

        window?.rootViewController = RootViewController()
    }

    func sceneDidDisconnect(_: UIScene) {}

    func sceneDidBecomeActive(_: UIScene) {
        AuthViewModel.shared.$isAuthenticated.sink { [weak self] authenticated in
            guard let self else { return }
            if !authenticated {
                let signInViewController = SignInViewController()
                signInViewController.modalPresentationStyle = .fullScreen
                window?.rootViewController?.present(signInViewController, animated: false, completion: nil)
            }
        }.store(in: &cancellables)
    }

    func sceneWillResignActive(_: UIScene) {}

    func sceneWillEnterForeground(_: UIScene) {}

    func sceneDidEnterBackground(_: UIScene) {}
}
