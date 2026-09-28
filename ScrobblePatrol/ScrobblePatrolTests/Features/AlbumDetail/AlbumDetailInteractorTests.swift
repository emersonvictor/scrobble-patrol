import XCTest
@testable import ScrobblePatrol

@MainActor
final class AlbumDetailInteractorTests: XCTestCase {
    func testViewDidLoadPresentsLoadingAndRequestsAlbum() {
        let context = makeContext()

        context.sut.viewDidLoad()

        XCTAssertEqual(context.presenter.loadingCallCount, 1)
        XCTAssertEqual(context.repository.albumInfoRequests.count, 1)
        XCTAssertEqual(context.repository.albumInfoRequests[0].artist, "Weyes Blood")
        XCTAssertEqual(context.repository.albumInfoRequests[0].album, "Titanic Rising")
    }

    func testSuccessfulRequestPresentsAlbum() {
        let context = makeContext()
        let album = Album.fixture()
        context.sut.viewDidLoad()

        context.repository.completeAlbumInfo(with: .success(album))

        XCTAssertEqual(context.presenter.presentedAlbums, [album])
    }

    func testFailedRequestPresentsError() {
        let context = makeContext()
        context.sut.viewDidLoad()

        context.repository.completeAlbumInfo(with: .failure(.httpStatus(500)))

        XCTAssertEqual(context.presenter.presentedErrors.count, 1)
    }

    func testRetryRequestsAlbumAgain() {
        let context = makeContext()
        context.sut.viewDidLoad()
        context.repository.completeAlbumInfo(with: .failure(.httpStatus(500)))

        context.sut.retry()

        XCTAssertEqual(context.presenter.loadingCallCount, 2)
        XCTAssertEqual(context.repository.albumInfoRequests.count, 2)
    }

    private func makeContext() -> Context {
        let presenter = AlbumDetailPresenterSpy()
        let repository = LastFmRepositoryMock()
        let sut = AlbumDetailInteractor(
            albumName: "Titanic Rising",
            artistName: "Weyes Blood",
            presenter: presenter,
            repository: repository
        )
        return Context(sut: sut, presenter: presenter, repository: repository)
    }

    private struct Context {
        let sut: AlbumDetailInteractor
        let presenter: AlbumDetailPresenterSpy
        let repository: LastFmRepositoryMock
    }
}
