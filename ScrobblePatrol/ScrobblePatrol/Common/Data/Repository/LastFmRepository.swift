import Foundation

typealias RecentScrobblesCompletion = (Result<RecentScrobblesPage, LastFmError>) -> Void
typealias AlbumCompletion = (Result<Album, LastFmError>) -> Void
typealias TopAlbumsCompletion = (Result<TopAlbumsPage, LastFmError>) -> Void

@MainActor
protocol LastFmRepositoryProtocol {
    @discardableResult
    func getRecentTracks(
        username: String,
        page: Int,
        completion: @escaping RecentScrobblesCompletion
    ) -> Task<Void, Never>

    @discardableResult
    func getAlbumInfo(
        artist: String,
        album: String,
        completion: @escaping AlbumCompletion
    ) -> Task<Void, Never>

    @discardableResult
    func getTopAlbums(
        username: String,
        period: TopAlbumsPeriod,
        page: Int,
        limit: Int,
        completion: @escaping TopAlbumsCompletion
    ) -> Task<Void, Never>
}

@MainActor
struct LastFmRepository: LastFmRepositoryProtocol {
    private let apiClient: any LastFmAPIClientProtocol

    init(apiClient: any LastFmAPIClientProtocol) {
        self.apiClient = apiClient
    }

    @discardableResult
    func getRecentTracks(
        username: String,
        page: Int = 1,
        completion: @escaping RecentScrobblesCompletion
    ) -> Task<Void, Never> {
        execute(
            endpoint: .recentTracks(username: username, page: page),
            transform: { (response: RecentTracksResponseDTO) in
                RecentScrobblesPage(dto: response.recenttracks)
            },
            completion: completion
        )
    }

    @discardableResult
    func getAlbumInfo(
        artist: String,
        album: String,
        completion: @escaping AlbumCompletion
    ) -> Task<Void, Never> {
        execute(
            endpoint: .albumInfo(artist: artist, album: album),
            transform: { (response: AlbumInfoResponseDTO) in
                Album(dto: response.album)
            },
            completion: completion
        )
    }

    @discardableResult
    func getTopAlbums(
        username: String,
        period: TopAlbumsPeriod,
        page: Int = 1,
        limit: Int,
        completion: @escaping TopAlbumsCompletion
    ) -> Task<Void, Never> {
        execute(
            endpoint: .topAlbums(
                username: username,
                period: period,
                page: page,
                limit: limit
            ),
            transform: { (response: TopAlbumsResponseDTO) in
                TopAlbumsPage(dto: response.topalbums)
            },
            completion: completion
        )
    }

    private func execute<Response: Decodable, Model>(
        endpoint: LastFmEndpoint,
        transform: @escaping (Response) -> Model,
        completion: @escaping (Result<Model, LastFmError>) -> Void
    ) -> Task<Void, Never> {
        Task {
            do {
                let response: Response = try await apiClient.request(endpoint)
                try Task.checkCancellation()
                let result = transform(response)
                completion(.success(result))
            } catch is CancellationError {
                completion(.failure(.cancelled))
            } catch let error as LastFmError {
                completion(.failure(error))
            } catch {
                completion(.failure(.unexpected(error)))
            }
        }
    }
}
