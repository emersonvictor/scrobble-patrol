@testable import ScrobblePatrol

@MainActor
final class RecentScrobblesPresenterSpy: RecentScrobblesPresenterProtocol {
    private(set) var presentedUsernames: [String?] = []
    private(set) var usernameInputEnabledStates: [Bool] = []
    private(set) var loadingCallCount = 0
    private(set) var presentedErrors: [LastFmError] = []
    private(set) var presentedScrobbles: [[RecentScrobble]] = []
    private(set) var finishRefreshingCallCount = 0

    func attach(view: any RecentScrobblesViewProtocol) {}

    func presentUsername(_ username: String?) {
        presentedUsernames.append(username)
    }

    func presentUsernameInputEnabled(_ isEnabled: Bool) {
        usernameInputEnabledStates.append(isEnabled)
    }

    func presentLoading() {
        loadingCallCount += 1
    }

    func presentError(_ error: LastFmError) {
        presentedErrors.append(error)
    }

    func presentScrobbles(_ scrobbles: [RecentScrobble]) {
        presentedScrobbles.append(scrobbles)
    }

    func finishRefreshing() {
        finishRefreshingCallCount += 1
    }
}
