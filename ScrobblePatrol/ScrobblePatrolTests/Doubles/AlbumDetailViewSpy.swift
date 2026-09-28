@testable import ScrobblePatrol

@MainActor
final class AlbumDetailViewSpy: AlbumDetailViewProtocol {
    private(set) var loadingCallCount = 0
    private(set) var displayedAlbums: [Album] = []
    private(set) var displayedErrors: [(message: String, retryTitle: String)] = []

    func displayLoading() {
        loadingCallCount += 1
    }

    func displayAlbum(_ album: Album) {
        displayedAlbums.append(album)
    }

    func displayError(message: String, retryTitle: String) {
        displayedErrors.append((message, retryTitle))
    }
}
