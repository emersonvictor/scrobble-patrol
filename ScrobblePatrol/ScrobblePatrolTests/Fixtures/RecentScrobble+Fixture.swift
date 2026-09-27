@testable import ScrobblePatrol

@MainActor
extension RecentScrobble {
    static func fixture(
        trackName: String = "Everything In Its Right Place",
        artistName: String = "Radiohead",
        albumName: String? = "Kid A"
    ) -> Self {
        Self(dto: .fixture(
            name: trackName,
            artist: artistName,
            album: albumName
        ))
    }
}
