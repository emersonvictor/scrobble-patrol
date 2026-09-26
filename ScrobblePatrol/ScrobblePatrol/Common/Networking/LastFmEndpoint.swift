import Foundation

enum LastFmEndpoint {
    case recentTracks(username: String, page: Int, limit: Int)

    var queryItems: [URLQueryItem] {
        switch self {
        case let .recentTracks(username, page, limit):
            return [
                URLQueryItem(name: "method", value: "user.getRecentTracks"),
                URLQueryItem(name: "user", value: username),
                URLQueryItem(name: "page", value: String(page)),
                URLQueryItem(name: "limit", value: String(limit))
            ]
        }
    }
}
