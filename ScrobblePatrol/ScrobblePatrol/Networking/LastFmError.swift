import Foundation

enum LastFmError: Error {
    case cancelled
    case unexpected(Error)
    case missingAPIKey
    case invalidURL
    case invalidResponse
    case network(URLError)
    case httpStatus(Int)
    case decoding(Error)
    case api(code: Int, message: String)
}
