import XCTest
@testable import ScrobblePatrol

@MainActor
final class AlbumGridInteractorTests: XCTestCase {
    func testViewDidLoadPresentsSavedUsername() {
        let context = makeContext(username: "listener")

        context.sut.viewDidLoad()

        XCTAssertEqual(context.presenter.presentedUsernames, ["listener"])
        XCTAssertTrue(context.repository.topAlbumsRequests.isEmpty)
    }

    func testViewWillAppearWithSameUsernameDoesNothing() {
        let context = makeContext(username: "listener")
        context.sut.viewDidLoad()

        context.sut.viewWillAppear()

        XCTAssertEqual(context.presenter.presentedUsernames.count, 1)
        XCTAssertTrue(context.presenter.presentedAlbums.isEmpty)
    }

    func testViewWillAppearWithChangedUsernamePresentsUsernameAndClearsAlbums() {
        let context = makeContext(username: "old-user")
        context.sut.viewDidLoad()
        context.store.update("new-user")

        context.sut.viewWillAppear()

        XCTAssertEqual(context.presenter.presentedUsernames.last, "new-user")
        XCTAssertEqual(context.presenter.presentedAlbums.last, [])
    }

    func testUpdateUsernamePersistsPresentsAndClearsAlbums() {
        let context = makeContext(username: "old-user")

        context.sut.updateUser(username: "  new-user  ")

        XCTAssertEqual(context.store.username, "new-user")
        XCTAssertEqual(context.presenter.presentedUsernames.last, "new-user")
        XCTAssertEqual(context.presenter.presentedAlbums.last, [])
    }

    func testGenerateWithoutUsernameDoesNotRequestAlbums() {
        let context = makeContext()

        context.sut.generate(periodIndex: 0, gridSize: 3)

        XCTAssertTrue(context.repository.topAlbumsRequests.isEmpty)
        XCTAssertEqual(context.presenter.loadingCallCount, 0)
    }

    func testGenerateRequestsExpectedAlbums() {
        let context = makeContext(username: "listener")

        context.sut.viewDidLoad()
        context.sut.generate(periodIndex: 1, gridSize: 4)

        XCTAssertEqual(context.presenter.loadingCallCount, 1)
        XCTAssertEqual(context.repository.topAlbumsRequests.count, 1)
        let request = context.repository.topAlbumsRequests[0]
        XCTAssertEqual(request.username, "listener")
        XCTAssertEqual(request.period, .month)
        XCTAssertEqual(request.page, 1)
        XCTAssertEqual(request.limit, 16)
    }

    func testGenerateWithInvalidPeriodDoesNotRequestAlbums() {
        let context = makeContext(username: "listener")

        context.sut.generate(periodIndex: 10, gridSize: 3)

        XCTAssertTrue(context.repository.topAlbumsRequests.isEmpty)
    }

    func testGenerateWhileLoadingDoesNotStartConcurrentRequest() {
        let context = makeContext(username: "listener")
        context.sut.viewDidLoad()
        context.sut.generate(periodIndex: 0, gridSize: 3)

        context.sut.generate(periodIndex: 2, gridSize: 5)

        XCTAssertEqual(context.repository.topAlbumsRequests.count, 1)
    }

    func testSuccessfulRequestPresentsAlbums() {
        let context = makeContext(username: "listener")
        let albums = [TopAlbum.fixture()]
        context.sut.viewDidLoad()
        context.sut.generate(periodIndex: 0, gridSize: 3)

        context.repository.completeTopAlbums(with: .success(.fixture(albums: albums)))

        XCTAssertEqual(context.presenter.presentedAlbums.last, albums)
    }

    func testFailedRequestPresentsError() {
        let context = makeContext(username: "listener")
        context.sut.viewDidLoad()
        context.sut.generate(periodIndex: 0, gridSize: 3)

        context.repository.completeTopAlbums(with: .failure(.httpStatus(500)))

        XCTAssertEqual(context.presenter.presentedErrors.count, 1)
    }

    func testRetryRepeatsLastRequest() {
        let context = makeContext(username: "listener")
        context.sut.viewDidLoad()
        context.sut.generate(periodIndex: 2, gridSize: 5)
        context.repository.completeTopAlbums(with: .failure(.httpStatus(500)))

        context.sut.retry()

        XCTAssertEqual(context.repository.topAlbumsRequests.count, 2)
        XCTAssertEqual(context.repository.topAlbumsRequests[1].period, .year)
        XCTAssertEqual(context.repository.topAlbumsRequests[1].limit, 25)
    }

    func testChangingUsernameDuringRequestDiscardsOldResult() {
        let context = makeContext(username: "old-user")
        context.sut.viewDidLoad()
        context.sut.generate(periodIndex: 0, gridSize: 3)
        context.sut.updateUser(username: "new-user")

        context.repository.completeTopAlbums(
            with: .success(.fixture(albums: [.fixture(name: "Old Album")]))
        )

        XCTAssertEqual(context.presenter.presentedAlbums.last, [])
        XCTAssertFalse(
            context.presenter.presentedAlbums.contains { albums in
                albums.contains { $0.name == "Old Album" }
            }
        )
    }

    private func makeContext(username: String? = nil) -> Context {
        let presenter = AlbumGridPresenterSpy()
        let repository = LastFmRepositoryMock()
        let store = UsernameStoreMock(username: username)
        let sut = AlbumGridInteractor(
            presenter: presenter,
            repository: repository,
            usernameStore: store
        )
        return Context(
            sut: sut,
            presenter: presenter,
            repository: repository,
            store: store
        )
    }

    private struct Context {
        let sut: AlbumGridInteractor
        let presenter: AlbumGridPresenterSpy
        let repository: LastFmRepositoryMock
        let store: UsernameStoreMock
    }
}
