import Foundation

struct TopAlbum: Equatable {
    let name: String
    let artistName: String
    let imageURL: URL?
    let playcount: Int?
    let lastFMURL: URL?

    init(dto: TopAlbumDTO) {
        let sizes = ["mega", "extralarge", "large", "medium", "small"]
        let images = dto.image ?? []

        name = dto.name
        artistName = dto.artist.name
        imageURL = sizes.lazy.compactMap { size in
            images.first(where: { $0.size == size }).flatMap {
                $0.text.isEmpty ? nil : URL(string: $0.text)
            }
        }.first
        playcount = dto.playcount.flatMap(Int.init)
        lastFMURL = dto.url.flatMap(URL.init(string:))
    }
}
