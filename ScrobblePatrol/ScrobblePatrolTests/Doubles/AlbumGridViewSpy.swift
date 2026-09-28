@testable import ScrobblePatrol

@MainActor
final class AlbumGridViewSpy: AlbumGridViewProtocol {
    private(set) var displayedUsernames: [String?] = []
    private(set) var loadingCallCount = 0
    private(set) var displayedAlbums: [[TopAlbum]] = []
    private(set) var displayedErrors: [(message: String, retryTitle: String)] = []

    func displayUsername(_ username: String?) {
        displayedUsernames.append(username)
    }

    func displayLoading() {
        loadingCallCount += 1
    }

    func displayAlbums(_ albums: [TopAlbum]) {
        displayedAlbums.append(albums)
    }

    func displayError(message: String, retryTitle: String) {
        displayedErrors.append((message, retryTitle))
    }
}
