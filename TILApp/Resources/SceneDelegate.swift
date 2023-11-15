import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    private var cancellables: Set<AnyCancellable> = []
    private var initialized = false
    private var needToReset = false

    func scene(_ scene: UIScene, willConnectTo _: UISceneSession, options _: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        let window = UIWindow(windowScene: windowScene)
        window.overrideUserInterfaceStyle = .light
        window.makeKeyAndVisible()

        window.rootViewController = LoadingViewController()

        AuthViewModel.shared.checkAuthorization { [unowned self] result in
            switch result {
            case .success:
                window.rootViewController = RootViewController()
                if !AuthViewModel.shared.isAgreed {
                    presentAgreeTermsViewController()
                }
            case .failure:
                let signInVC = SignInViewController()
                signInVC.modalPresentationStyle = .fullScreen
                window.rootViewController?.present(signInVC, animated: false)
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [unowned self] in
                initialized = true
            }
        }

        AuthViewModel.shared.$isAuthenticated.dropFirst().sink { [unowned self] isAuthenticated in
            guard initialized else { return }
            if window.rootViewController is LoadingViewController {
                window.rootViewController = RootViewController()
            }

            if isAuthenticated, let rootVC = window.rootViewController as? RootViewController {
                if needToReset {
                    needToReset = false
                    rootVC._tabBarController?.selectedIndex = 0
                }
                if !AuthViewModel.shared.isAgreed {
                    presentAgreeTermsViewController()
                } else {
                    rootVC.dismiss(animated: true)
                }
            } else if !isAuthenticated {
                UserViewModel.reset()
                BlogViewModel.reset()
                PostViewModel.reset()
                CommunityViewModel.reset()
                RssViewModel.reset()
                needToReset = true
                let signInVC = SignInViewController()
                signInVC.modalPresentationStyle = .fullScreen
                window.rootViewController?.present(signInVC, animated: true)
            }
        }.store(in: &cancellables)

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

    func presentAgreeTermsViewController() {
        let currentViewController = window?.rootViewController
        if !(currentViewController is AgreeTermsViewController) {
            let agreeTermsVC = AgreeTermsViewController()
            agreeTermsVC.modalPresentationStyle = .fullScreen
            currentViewController?.present(agreeTermsVC, animated: false)
        }
    }
}
