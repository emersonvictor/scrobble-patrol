import Foundation

protocol LastFmClientProtocol {
    func request<Response: Decodable>(_ endpoint: LastFmEndpoint) async throws -> Response
}

struct LastFmClient: LastFmClientProtocol {
    private let session: URLSession
    private let baseComponents: URLComponents?

    init(apiKey: String, session: URLSession = .shared) throws {
        guard !apiKey.isEmpty else {
            throw LastFmError.missingAPIKey
        }

        self.session = session
        var components = URLComponents(string: "https://ws.audioscrobbler.com/2.0/")
        components?.queryItems = [
            URLQueryItem(name: "api_key", value: apiKey),
            URLQueryItem(name: "format", value: "json")
        ]
        self.baseComponents = components
    }

    func request<Response: Decodable>(_ endpoint: LastFmEndpoint) async throws -> Response {
        guard var components = baseComponents else {
            throw LastFmError.invalidURL
        }
        components.queryItems?.append(contentsOf: endpoint.queryItems)
        guard let url = components.url else { throw LastFmError.invalidURL }

        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await session.data(for: URLRequest(url: url))
        } catch is CancellationError {
            throw LastFmError.cancelled
        } catch let error as URLError {
            if error.code == .cancelled { throw LastFmError.cancelled }
            throw LastFmError.network(error)
        } catch {
            throw LastFmError.unexpected(error)
        }
        guard let response = response as? HTTPURLResponse else {
            throw LastFmError.invalidResponse
        }
        let decoder = JSONDecoder()
        if let error = try? decoder.decode(LastFmErrorDTO.self, from: data) {
            throw LastFmError.api(code: error.error, message: error.message)
        }
        guard (200..<300).contains(response.statusCode) else {
            throw LastFmError.httpStatus(response.statusCode)
        }
        do {
            return try decoder.decode(Response.self, from: data)
        } catch {
            throw LastFmError.decoding(error)
        }
    }
}
