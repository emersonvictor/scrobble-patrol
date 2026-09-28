@testable import ScrobblePatrol

@MainActor
final class AlbumGridPresenterSpy: AlbumGridPresenterProtocol {
    private(set) var presentedUsernames: [String?] = []
    private(set) var loadingCallCount = 0
    private(set) var presentedAlbums: [[TopAlbum]] = []
    private(set) var presentedErrors: [LastFmError] = []

    func attach(view: any AlbumGridViewProtocol) {}

    func presentUsername(_ username: String?) {
        presentedUsernames.append(username)
    }

    func presentLoading() {
        loadingCallCount += 1
    }

    func presentAlbums(_ albums: [TopAlbum]) {
        presentedAlbums.append(albums)
    }

    func presentError(_ error: LastFmError) {
        presentedErrors.append(error)
    }
}
