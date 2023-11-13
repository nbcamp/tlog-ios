import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    private var cancellables: Set<AnyCancellable> = []
    private var initialized = false

    func scene(_ scene: UIScene, willConnectTo _: UISceneSession, options _: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        let window = UIWindow(windowScene: windowScene)
        window.overrideUserInterfaceStyle = .light
        window.makeKeyAndVisible()

        window.rootViewController = LoadingViewController()
        AuthViewModel.shared.$isAuthenticated.dropFirst().sink { isAuthenticated in
            if isAuthenticated, window.rootViewController is SignInViewController {
                window.rootViewController = RootViewController()
            } else if !isAuthenticated {
                window.rootViewController = SignInViewController()
            }
        }.store(in: &cancellables)

        AuthViewModel.shared.checkAuthorization { [unowned self] result in
            switch result {
            case .success: window.rootViewController = RootViewController()
            case .failure: window.rootViewController = SignInViewController()
            }
            initialized = true
        }

        self.window = window
    }

    func sceneDidDisconnect(_: UIScene) {}

    func sceneDidBecomeActive(_: UIScene) {
        if initialized {
            AuthViewModel.shared.checkAuthorization()
        }
    }

    func sceneWillResignActive(_: UIScene) {}

    func sceneWillEnterForeground(_: UIScene) {}

    func sceneDidEnterBackground(_: UIScene) {}
}
