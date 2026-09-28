@testable import ScrobblePatrol

@MainActor
final class AlbumDetailPresenterSpy: AlbumDetailPresenterProtocol {
    private(set) var loadingCallCount = 0
    private(set) var presentedAlbums: [Album] = []
    private(set) var presentedErrors: [LastFmError] = []

    func attach(view: any AlbumDetailViewProtocol) {}

    func presentLoading() {
        loadingCallCount += 1
    }

    func presentAlbum(_ album: Album) {
        presentedAlbums.append(album)
    }

    func presentError(_ error: LastFmError) {
        presentedErrors.append(error)
    }
}
