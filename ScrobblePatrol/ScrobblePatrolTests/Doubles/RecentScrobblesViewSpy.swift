@testable import ScrobblePatrol

@MainActor
final class RecentScrobblesViewSpy: RecentScrobblesViewProtocol {
    private(set) var displayedUsernames: [String?] = []
    private(set) var loadingCallCount = 0
    private(set) var displayedErrors: [(message: String, retryTitle: String)] = []
    private(set) var displayedScrobbles: [[RecentScrobble]] = []
    private(set) var finishRefreshingCallCount = 0

    func displayUsername(_ username: String?) {
        displayedUsernames.append(username)
    }

    func displayLoading() {
        loadingCallCount += 1
    }

    func displayError(message: String, retryTitle: String) {
        displayedErrors.append((message, retryTitle))
    }

    func displayScrobbles(_ scrobbles: [RecentScrobble]) {
        displayedScrobbles.append(scrobbles)
    }

    func finishRefreshing() {
        finishRefreshingCallCount += 1
    }
}
