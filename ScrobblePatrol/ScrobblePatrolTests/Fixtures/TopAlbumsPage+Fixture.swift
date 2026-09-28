import Foundation
@testable import ScrobblePatrol

extension TopAlbumsPage {
    static func fixture(
        albums: [TopAlbum] = [.fixture()],
        page: Int = 1,
        totalPages: Int = 1
    ) -> TopAlbumsPage {
        let dto = TopAlbumsDTO(
            album: albums.map { album in
                TopAlbumDTO(
                    name: album.name,
                    playcount: album.playcount.map(String.init),
                    url: album.lastFMURL?.absoluteString,
                    artist: .init(name: album.artistName),
                    image: nil
                )
            },
            attributes: .init(page: page, totalPages: totalPages)
        )
        return TopAlbumsPage(dto: dto)
    }
}
