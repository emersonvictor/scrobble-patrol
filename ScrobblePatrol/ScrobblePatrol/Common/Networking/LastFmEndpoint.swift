import Foundation

enum LastFmEndpoint {
    case recentTracks(username: String, page: Int)
    case albumInfo(artist: String, album: String)
    case topAlbums(username: String, period: TopAlbumsPeriod, page: Int, limit: Int)

    var queryItems: [URLQueryItem] {
        switch self {
        case let .recentTracks(username, page):
            return [
                URLQueryItem(name: "method", value: "user.getRecentTracks"),
                URLQueryItem(name: "user", value: username),
                URLQueryItem(name: "page", value: String(page)),
                URLQueryItem(name: "limit", value: "50")
            ]
        case let .albumInfo(artist, album):
            return [
                URLQueryItem(name: "method", value: "album.getInfo"),
                URLQueryItem(name: "artist", value: artist),
                URLQueryItem(name: "album", value: album),
                URLQueryItem(name: "autocorrect", value: "1")
            ]
        case let .topAlbums(username, period, page, limit):
            return [
                URLQueryItem(name: "method", value: "user.getTopAlbums"),
                URLQueryItem(name: "user", value: username),
                URLQueryItem(name: "period", value: period.rawValue),
                URLQueryItem(name: "page", value: String(page)),
                URLQueryItem(name: "limit", value: String(limit))
            ]
        }
    }
}
