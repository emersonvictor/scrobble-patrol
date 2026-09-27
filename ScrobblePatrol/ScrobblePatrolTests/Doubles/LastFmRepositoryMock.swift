@testable import ScrobblePatrol

@MainActor
final class LastFmRepositoryMock: LastFmRepositoryProtocol {
    struct RecentTracksRequest {
        let username: String
        let page: Int
        let completion: RecentScrobblesCompletion
    }

    private(set) var recentTracksRequests: [RecentTracksRequest] = []

    @discardableResult
    func getRecentTracks(
        username: String,
        page: Int,
        completion: @escaping RecentScrobblesCompletion
    ) -> Task<Void, Never> {
        recentTracksRequests.append(.init(
            username: username,
            page: page,
            completion: completion
        ))
        return Task {}
    }

    @discardableResult
    func getAlbumInfo(
        artist: String,
        album: String,
        completion: @escaping AlbumCompletion
    ) -> Task<Void, Never> {
        Task {}
    }

    @discardableResult
    func getTopAlbums(
        username: String,
        period: TopAlbumsPeriod,
        page: Int,
        limit: Int,
        completion: @escaping TopAlbumsCompletion
    ) -> Task<Void, Never> {
        Task {}
    }

    func completeRecentTracks(
        at index: Int = 0,
        with result: Result<RecentScrobblesPage, LastFmError>
    ) {
        recentTracksRequests[index].completion(result)
    }
}
