import UIKit

final class RootViewController: UITabBarController {
    struct Tab {
        let title: String
        let icon: String
        let controller: UIViewController
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let tabs: [Tab] = [
            .init(title: "홈", icon: "house", controller: HomeViewController()),
            .init(title: "캘린더", icon: "calendar", controller: CalendarViewController()),
            .init(title: "커뮤니티", icon: "bubble", controller: CommunityViewController()),
            .init(title: "내 정보", icon: "person", controller: MyProfileViewController()),
        ]

        setViewControllers(tabs.enumerated().map { index, tab in
            let navigationController = UINavigationController(rootViewController: tab.controller)
            let tabBarItem = UITabBarItem(
                title: tab.title,
                image: .init(systemName: tab.icon),
                tag: index
            )
            navigationController.tabBarItem = tabBarItem
            return navigationController
        }, animated: false)

        RssViewModel.shared.prepare()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        let paddingTop: CGFloat = 10.0
        tabBar.frame = .init(
            x: tabBar.frame.origin.x,
            y: tabBar.frame.origin.y - paddingTop,
            width: tabBar.frame.width,
            height: tabBar.frame.height + paddingTop
        )
    }
}
