import Foundation
@testable import ScrobblePatrol

@MainActor
final class LastFmAPIClientMock: LastFmAPIClientProtocol {
    private let result: Result<Any, Error>
    private(set) var requestedEndpoints: [LastFmEndpoint] = []

    init(result: Result<Any, Error>) {
        self.result = result
    }

    func request<Response: Decodable>(_ endpoint: LastFmEndpoint) async throws -> Response {
        requestedEndpoints.append(endpoint)
        let value = try result.get()
        guard let response = value as? Response else {
            throw MockError.unexpectedResponseType
        }
        return response
    }

    enum MockError: Error {
        case unexpectedResponseType
    }
}
