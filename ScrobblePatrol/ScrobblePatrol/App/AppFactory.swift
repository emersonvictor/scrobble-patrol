import UIKit

@MainActor
enum AppFactory {
    static func makeRootViewController() -> UIViewController {
        guard
            let apiKey = Bundle.main.object(forInfoDictionaryKey: "LASTFM_API_KEY") as? String,
            !apiKey.isEmpty
        else {
            return APIErrorFactory.make()
        }

        let apiClient = LastFmAPIClient(apiKey: apiKey)
        let repository = LastFmRepository(apiClient: apiClient)

        let recent = RecentScrobblesFactory.make(repository: repository)
        let grid = AlbumGridFactory.make(repository: repository)

        return MainTabBarController(
            recentViewController: recent,
            albumGridViewController: grid
        )
    }
}
