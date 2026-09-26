import UIKit

final class MainTabBarController: UITabBarController {
    private let recentViewController: UIViewController
    private let albumGridViewController: UIViewController

    init(
        recentViewController: UIViewController,
        albumGridViewController: UIViewController
    ) {
        self.recentViewController = recentViewController
        self.albumGridViewController = albumGridViewController
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { nil }

    override func viewDidLoad() {
        super.viewDidLoad()

        let recentNavigation = UINavigationController(rootViewController: recentViewController)
        recentNavigation.tabBarItem = UITabBarItem(
            title: "Recentes", image: UIImage(systemName: "clock"), tag: 0
        )

        let albumGridNavigation = UINavigationController(rootViewController: albumGridViewController)
        albumGridNavigation.tabBarItem = UITabBarItem(
            title: "Semaninha", image: UIImage(systemName: "square.grid.3x3"), tag: 1
        )

        setViewControllers([recentNavigation, albumGridNavigation], animated: false)
    }
}
