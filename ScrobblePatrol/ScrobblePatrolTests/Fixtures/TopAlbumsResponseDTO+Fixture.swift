@testable import ScrobblePatrol

extension TopAlbumsResponseDTO {
    static func fixture() -> Self {
        Self(topalbums: TopAlbumsDTO(
            album: [
                TopAlbumDTO(
                    name: "Titanic Rising",
                    playcount: "100",
                    url: "https://www.last.fm/music/Weyes+Blood/Titanic+Rising",
                    artist: .init(name: "Weyes Blood"),
                    image: [
                        .init(text: "https://example.com/large.jpg", size: "large")
                    ]
                )
            ],
            attributes: .init(page: 2, totalPages: 4)
        ))
    }
}
