import Foundation

struct Album: Equatable {
    let name: String
    let artistName: String
    let imageURL: URL?
    let tags: [String]
    let tracks: [AlbumTrack]
    let listeners: Int?
    let playcount: Int?
    let lastFMURL: URL?

    init(dto: AlbumInfoDTO) {
        name = dto.name
        artistName = dto.artist
        imageURL = Self.imageURL(from: dto.image ?? [])
        tags = dto.tags?.tag.map(\.name) ?? []
        tracks = dto.tracks?.track.map { AlbumTrack(dto: $0) } ?? []
        listeners = dto.listeners.flatMap(Int.init)
        playcount = dto.playcount.flatMap(Int.init)
        lastFMURL = dto.url.flatMap(URL.init(string:))
    }

    private static func imageURL(from images: [AlbumInfoDTO.ImageDTO]) -> URL? {
        let sizes = ["mega", "extralarge", "large", "medium", "small"]
        return sizes.lazy.compactMap { size in
            images.first(where: { $0.size == size }).flatMap {
                $0.text.isEmpty ? nil : URL(string: $0.text)
            }
        }.first
    }
}
