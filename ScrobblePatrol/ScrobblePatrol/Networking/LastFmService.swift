import Foundation

typealias RecentScrobblesCompletion = (Result<RecentScrobblesPage, LastFmError>) -> Void

@MainActor
protocol LastFmServiceProtocol {
    @discardableResult
    func getRecentTracks(
        username: String,
        page: Int,
        limit: Int,
        completion: @escaping RecentScrobblesCompletion
    ) -> Task<Void, Never>
}

@MainActor
struct LastFmService: LastFmServiceProtocol {
    private let client: any LastFmClientProtocol

    init(client: any LastFmClientProtocol) {
        self.client = client
    }

    @discardableResult
    func getRecentTracks(
        username: String,
        page: Int = 1,
        limit: Int = 50,
        completion: @escaping RecentScrobblesCompletion
    ) -> Task<Void, Never> {
        execute(
            endpoint: .recentTracks(username: username, page: page, limit: limit),
            transform: { (response: RecentTracksResponseDTO) in
                RecentScrobblesPage(dto: response.recenttracks)
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
                let response: Response = try await client.request(endpoint)
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
