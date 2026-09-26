@testable import ScrobblePatrol

@MainActor
extension RecentTrackDTO {
    static func fixture(
        name: String = "Everything In Its Right Place",
        artist: String = "Radiohead",
        album: String? = "Kid A",
        images: [String: String]? = [
            "small": "https://example.com/small.jpg",
            "large": "https://example.com/large.jpg"
        ],
        timestamp: String? = "1700000000",
        nowPlaying: String? = nil
    ) -> Self {
        Self(
            name: name,
            artist: .init(text: artist),
            album: album.map { .init(text: $0) },
            image: images.map { values in
                values.map { .init(text: $0.value, size: $0.key) }
            },
            date: timestamp.map { .init(uts: $0) },
            attributes: nowPlaying.map { .init(nowplaying: $0) }
        )
    }
}
