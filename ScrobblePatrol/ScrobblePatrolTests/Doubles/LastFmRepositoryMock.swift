@testable import ScrobblePatrol

@MainActor
final class LastFmRepositoryMock: LastFmRepositoryProtocol {
    struct RecentTracksRequest {
        let username: String
        let page: Int
        let completion: RecentScrobblesCompletion
    }

    struct AlbumInfoRequest {
        let artist: String
        let album: String
        let completion: AlbumCompletion
    }

    struct TopAlbumsRequest {
        let username: String
        let period: TopAlbumsPeriod
        let page: Int
        let limit: Int
        let completion: TopAlbumsCompletion
    }

    private(set) var recentTracksRequests: [RecentTracksRequest] = []
    private(set) var albumInfoRequests: [AlbumInfoRequest] = []
    private(set) var topAlbumsRequests: [TopAlbumsRequest] = []

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
        albumInfoRequests.append(.init(
            artist: artist,
            album: album,
            completion: completion
        ))
        return Task {}
    }

    @discardableResult
    func getTopAlbums(
        username: String,
        period: TopAlbumsPeriod,
        page: Int,
        limit: Int,
        completion: @escaping TopAlbumsCompletion
    ) -> Task<Void, Never> {
        topAlbumsRequests.append(.init(
            username: username,
            period: period,
            page: page,
            limit: limit,
            completion: completion
        ))
        return Task {}
    }

    func completeRecentTracks(
        at index: Int = 0,
        with result: Result<RecentScrobblesPage, LastFmError>
    ) {
        recentTracksRequests[index].completion(result)
    }

    func completeAlbumInfo(
        at index: Int = 0,
        with result: Result<Album, LastFmError>
    ) {
        albumInfoRequests[index].completion(result)
    }

    func completeTopAlbums(
        at index: Int = 0,
        with result: Result<TopAlbumsPage, LastFmError>
    ) {
        topAlbumsRequests[index].completion(result)
    }
}
