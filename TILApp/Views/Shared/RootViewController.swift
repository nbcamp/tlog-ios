import UIKit

final class RootViewController: UINavigationController {
    private struct Tab {
        let title: String
        let icon: String
        let controller: UIViewController
    }

    private(set) var _tabBarController: UITabBarController?

    override func viewDidLoad() {
        super.viewDidLoad()

        let tabs: [Tab] = [
            //            .init(title: "홈", icon: "house", controller: HomeViewController()),
            .init(title: "홈", icon: "house", controller: CalendarViewController()),
            .init(title: "커뮤니티", icon: "bubble.left", controller: CommunityViewController()),
            .init(title: "내 정보", icon: "person", controller: MyProfileViewController()),
        ]

        let tabBarController = UITabBarController().then {
            $0.setViewControllers(tabs.enumerated().map { index, tab in
                tab.controller.tabBarItem = .init(
                    title: tab.title,
                    image: .init(systemName: tab.icon),
                    tag: index
                ).then {
                    $0.imageInsets = .init(top: 5, left: 0, bottom: 5, right: 0)
                }
                return tab.controller
            }, animated: false)
        }

        setViewControllers([tabBarController], animated: true)
        _tabBarController = tabBarController
        RssViewModel.shared.prepare()
    }
}
