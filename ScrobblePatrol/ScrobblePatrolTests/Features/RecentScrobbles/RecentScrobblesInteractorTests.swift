import XCTest
@testable import ScrobblePatrol

@MainActor
final class RecentScrobblesInteractorTests: XCTestCase {
    func testViewDidLoadWithoutSavedUsernameDoesNotRequestScrobbles() {
        let context = makeContext()

        context.sut.viewDidLoad()

        XCTAssertEqual(context.presenter.presentedUsernames.count, 1)
        XCTAssertNil(context.presenter.presentedUsernames[0])
        XCTAssertTrue(context.repository.recentTracksRequests.isEmpty)
    }

    func testViewDidLoadWithSavedUsernameLoadsFirstPage() {
        let context = makeContext(username: "listener")

        context.sut.viewDidLoad()

        XCTAssertEqual(context.presenter.presentedUsernames, ["listener"])
        XCTAssertEqual(context.presenter.loadingCallCount, 1)
        XCTAssertEqual(context.repository.recentTracksRequests.count, 1)
        XCTAssertEqual(context.repository.recentTracksRequests[0].username, "listener")
        XCTAssertEqual(context.repository.recentTracksRequests[0].page, 1)
    }

    func testSuccessfulFirstPagePresentsScrobbles() {
        let context = makeContext(username: "listener")
        let scrobble = RecentScrobble.fixture()
        context.sut.viewDidLoad()

        context.repository.completeRecentTracks(
            with: .success(.fixture(scrobbles: [scrobble]))
        )

        XCTAssertEqual(context.presenter.presentedScrobbles.last, [scrobble])
    }

    func testUpdateUsernamePersistsResetsAndLoadsFirstPage() {
        let context = makeContext(username: "old-user")

        context.sut.updateUsername("  new-user  ")

        XCTAssertEqual(context.store.username, "new-user")
        XCTAssertEqual(context.presenter.presentedUsernames.last, "new-user")
        XCTAssertEqual(context.presenter.presentedScrobbles.last, [])
        XCTAssertEqual(context.repository.recentTracksRequests.last?.username, "new-user")
        XCTAssertEqual(context.repository.recentTracksRequests.last?.page, 1)
    }

    func testLoadNextPageAppendsResults() {
        let context = makeContext(username: "listener")
        let first = RecentScrobble.fixture(trackName: "First")
        let second = RecentScrobble.fixture(trackName: "Second")
        context.sut.viewDidLoad()
        context.repository.completeRecentTracks(
            with: .success(.fixture(scrobbles: [first], page: 1, totalPages: 2))
        )

        context.sut.loadNextPage()

        XCTAssertEqual(context.repository.recentTracksRequests.last?.page, 2)
        context.repository.completeRecentTracks(
            at: 1,
            with: .success(.fixture(scrobbles: [second], page: 2, totalPages: 2))
        )
        XCTAssertEqual(context.presenter.presentedScrobbles.last, [first, second])
    }

    func testPaginationFailureRetriesSamePage() {
        let context = makeContext(username: "listener")
        context.sut.viewDidLoad()
        context.repository.completeRecentTracks(
            with: .success(.fixture(
                scrobbles: [.fixture()],
                page: 1,
                totalPages: 2
            ))
        )
        context.sut.loadNextPage()
        context.repository.completeRecentTracks(
            at: 1,
            with: .failure(.httpStatus(500))
        )

        context.sut.retry()

        XCTAssertEqual(context.repository.recentTracksRequests.last?.page, 2)
        XCTAssertEqual(context.presenter.presentedErrors.count, 1)
    }

    func testRefreshResetsToFirstPageAndFinishesRefreshing() {
        let context = makeContext(username: "listener")
        context.sut.viewDidLoad()
        context.repository.completeRecentTracks(
            with: .success(.fixture(
                scrobbles: [.fixture()],
                page: 1,
                totalPages: 2
            ))
        )
        context.sut.loadNextPage()
        context.repository.completeRecentTracks(
            at: 1,
            with: .success(.fixture(
                scrobbles: [.fixture(trackName: "Second")],
                page: 2,
                totalPages: 2
            ))
        )

        context.sut.refresh()

        XCTAssertEqual(context.repository.recentTracksRequests.last?.page, 1)
        context.repository.completeRecentTracks(
            at: 2,
            with: .success(.fixture(scrobbles: [.fixture(trackName: "Refreshed")]))
        )
        XCTAssertEqual(context.presenter.finishRefreshingCallCount, 1)
        XCTAssertEqual(
            context.presenter.presentedScrobbles.last?.map(\.trackName),
            ["Refreshed"]
        )
    }

    func testUsernameConfirmationWhileLoadingIsIgnored() {
        let context = makeContext(username: "old-user")
        context.sut.viewDidLoad()

        context.sut.updateUsername("new-user")

        XCTAssertEqual(context.store.username, "old-user")
        XCTAssertEqual(context.repository.recentTracksRequests.count, 1)
        context.repository.completeRecentTracks(
            with: .success(.fixture(scrobbles: [.fixture(trackName: "Old")]))
        )

        XCTAssertEqual(context.repository.recentTracksRequests.count, 1)
        XCTAssertEqual(context.presenter.usernameInputEnabledStates, [false, true])
    }

    func testConfirmingSameUsernameKeepsResultsAndPagination() {
        let context = makeContext(username: "listener")
        let first = RecentScrobble.fixture(trackName: "First")
        context.sut.viewDidLoad()
        context.repository.completeRecentTracks(
            with: .success(.fixture(scrobbles: [first], page: 1, totalPages: 2))
        )

        context.sut.updateUsername("  listener  ")

        XCTAssertEqual(context.repository.recentTracksRequests.count, 1)
        XCTAssertEqual(context.presenter.presentedScrobbles.last, [first])
        context.sut.loadNextPage()
        XCTAssertEqual(context.repository.recentTracksRequests.last?.page, 2)
    }

    func testUsernameInputIsReenabledAfterPaginationErrorAndRefresh() {
        let context = makeContext(username: "listener")
        context.sut.viewDidLoad()
        context.repository.completeRecentTracks(
            with: .success(.fixture(scrobbles: [.fixture()], page: 1, totalPages: 2))
        )
        context.sut.loadNextPage()
        context.repository.completeRecentTracks(at: 1, with: .failure(.httpStatus(500)))
        context.sut.refresh()

        XCTAssertEqual(
            context.presenter.usernameInputEnabledStates,
            [false, true, false, true, false]
        )
        context.repository.completeRecentTracks(at: 2, with: .success(.fixture()))
        XCTAssertEqual(context.presenter.usernameInputEnabledStates.last, true)
    }

    func testChangingUsernameInOtherTabDuringRequestDiscardsOldResult() {
        let context = makeContext(username: "old-user")
        context.sut.viewDidLoad()
        context.store.update("new-user")
        context.sut.viewWillAppear()

        context.repository.completeRecentTracks(
            with: .success(.fixture(scrobbles: [.fixture(trackName: "Old")]))
        )

        XCTAssertEqual(context.repository.recentTracksRequests.last?.username, "new-user")
        XCTAssertFalse(context.presenter.presentedScrobbles.contains { $0.contains { $0.trackName == "Old" } })
    }

    private func makeContext(username: String? = nil) -> Context {
        let presenter = RecentScrobblesPresenterSpy()
        let repository = LastFmRepositoryMock()
        let store = UsernameStoreMock(username: username)
        let sut = RecentScrobblesInteractor(
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
        let sut: RecentScrobblesInteractor
        let presenter: RecentScrobblesPresenterSpy
        let repository: LastFmRepositoryMock
        let store: UsernameStoreMock
    }
}
