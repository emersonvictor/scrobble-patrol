import Foundation
@testable import ScrobblePatrol

@MainActor
extension RecentScrobblesPage {
    static func fixture(
        scrobbles: [RecentScrobble],
        page: Int = 1,
        totalPages: Int = 1
    ) -> Self {
        let tracks = scrobbles.map { scrobble in
            RecentTrackDTO(
                name: scrobble.trackName,
                artist: .init(text: scrobble.artistName),
                album: scrobble.albumName.map { .init(text: $0) },
                image: scrobble.imageURL.map {
                    [.init(text: $0.absoluteString, size: "large")]
                },
                date: scrobble.playedAt.map {
                    .init(uts: String(Int($0.timeIntervalSince1970)))
                },
                attributes: scrobble.isNowPlaying ? .init(nowplaying: "true") : nil
            )
        }

        return Self(dto: RecentTracksDTO(
            track: tracks,
            attributes: .init(page: page, totalPages: totalPages)
        ))
    }
}
