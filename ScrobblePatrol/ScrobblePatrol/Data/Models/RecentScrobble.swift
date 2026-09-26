import Foundation

struct RecentScrobble: Equatable {
    let trackName: String
    let artistName: String
    let albumName: String?
    let imageURL: URL?
    let playedAt: Date?
    let isNowPlaying: Bool

    init(dto: RecentTrackDTO) {
        let sizes = ["mega", "extralarge", "large", "medium", "small"]
        let images = dto.image ?? []
        let album = dto.album?.text.trimmingCharacters(in: .whitespacesAndNewlines)

        trackName = dto.name
        artistName = dto.artist.text
        albumName = album.flatMap { $0.isEmpty ? nil : $0 }
        imageURL = sizes.lazy.compactMap { size in
            images.first(where: { $0.size == size }).flatMap {
                $0.text.isEmpty ? nil : URL(string: $0.text)
            }
        }.first
        playedAt = dto.date.flatMap { TimeInterval($0.uts) }.map(Date.init(timeIntervalSince1970:))
        isNowPlaying = dto.attributes?.nowplaying == "true"
    }
}
