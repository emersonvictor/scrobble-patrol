@testable import ScrobblePatrol

extension Album {
    static func fixture(
        name: String = "Titanic Rising",
        artistName: String = "Weyes Blood"
    ) -> Album {
        Album(dto: AlbumInfoDTO(
            name: name,
            artist: artistName,
            image: nil,
            listeners: "1000",
            playcount: "2000",
            url: "https://www.last.fm/music/Weyes+Blood/Titanic+Rising",
            tags: nil,
            tracks: nil
        ))
    }
}
