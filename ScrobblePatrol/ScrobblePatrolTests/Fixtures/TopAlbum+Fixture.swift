@testable import ScrobblePatrol

extension TopAlbum {
    static func fixture(
        name: String = "Titanic Rising",
        artistName: String = "Weyes Blood"
    ) -> TopAlbum {
        TopAlbum(dto: TopAlbumDTO(
            name: name,
            playcount: "100",
            url: "https://www.last.fm/music/Weyes+Blood/Titanic+Rising",
            artist: .init(name: artistName),
            image: nil
        ))
    }
}
