import Foundation

struct TopAlbumsResponseDTO: Decodable {
    let topalbums: TopAlbumsDTO
}

struct TopAlbumsDTO: Decodable {
    let album: [TopAlbumDTO]
    let attributes: PaginationDTO

    enum CodingKeys: String, CodingKey {
        case album
        case attributes = "@attr"
    }

    struct PaginationDTO: Decodable {
        let page: Int
        let totalPages: Int

        enum CodingKeys: String, CodingKey {
            case page, totalPages
        }
    }
}

extension TopAlbumsDTO.PaginationDTO {
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let pageValue = try container.decode(String.self, forKey: .page)
        let totalPagesValue = try container.decode(String.self, forKey: .totalPages)

        guard let page = Int(pageValue), page >= 1 else {
            throw DecodingError.dataCorruptedError(
                forKey: .page,
                in: container,
                debugDescription: "Expected a page number greater than zero"
            )
        }
        guard let totalPages = Int(totalPagesValue), totalPages >= 0 else {
            throw DecodingError.dataCorruptedError(
                forKey: .totalPages,
                in: container,
                debugDescription: "Expected a non-negative total page count"
            )
        }
        self.page = page
        self.totalPages = totalPages
    }
}

struct TopAlbumDTO: Decodable {
    let name: String
    let playcount: String?
    let url: String?
    let artist: ArtistDTO
    let image: [ImageDTO]?

    struct ArtistDTO: Decodable {
        let name: String
    }

    struct ImageDTO: Decodable {
        let text: String
        let size: String

        enum CodingKeys: String, CodingKey {
            case text = "#text"
            case size
        }
    }
}
