import UIKit

final class MainTabBarController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()

        let recentNavigation = UINavigationController(rootViewController: RecentScrobblesViewController())
        recentNavigation.tabBarItem = UITabBarItem(
            title: "Recentes", image: UIImage(systemName: "clock"), tag: 0
        )

        let albumGridNavigation = UINavigationController(rootViewController: AlbumGridViewController())
        albumGridNavigation.tabBarItem = UITabBarItem(
            title: "Semaninha", image: UIImage(systemName: "square.grid.3x3"), tag: 1
        )

        setViewControllers([recentNavigation, albumGridNavigation], animated: false)
    }
}
