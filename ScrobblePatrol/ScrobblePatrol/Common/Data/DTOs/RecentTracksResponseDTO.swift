import Foundation

struct RecentTracksResponseDTO: Decodable {
    let recenttracks: RecentTracksDTO
}

struct RecentTracksDTO: Decodable {
    let track: [RecentTrackDTO]
    let attributes: PaginationDTO

    enum CodingKeys: String, CodingKey {
        case track
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

struct RecentTrackDTO: Decodable {
    let name: String
    let artist: TextDTO
    let album: TextDTO?
    let image: [ImageDTO]?
    let date: DateDTO?
    let attributes: AttributesDTO?

    enum CodingKeys: String, CodingKey {
        case name, artist, album, image, date
        case attributes = "@attr"
    }

    struct TextDTO: Decodable {
        let text: String
        enum CodingKeys: String, CodingKey { case text = "#text" }
    }

    struct ImageDTO: Decodable {
        let text: String
        let size: String
        enum CodingKeys: String, CodingKey {
            case text = "#text"
            case size
        }
    }

    struct DateDTO: Decodable { let uts: String }
    struct AttributesDTO: Decodable { let nowplaying: String? }
}

extension RecentTracksDTO.PaginationDTO {
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let pageValue = try container.decode(String.self, forKey: .page)
        let totalPagesValue = try container.decode(String.self, forKey: .totalPages)

        guard let page = Int(pageValue), page >= 1 else {
            throw DecodingError.dataCorruptedError(
                forKey: .page, in: container,
                debugDescription: "Expected a page number greater than zero"
            )
        }
        guard let totalPages = Int(totalPagesValue), totalPages >= 0 else {
            throw DecodingError.dataCorruptedError(
                forKey: .totalPages, in: container,
                debugDescription: "Expected a non-negative total page count"
            )
        }
        self.page = page
        self.totalPages = totalPages
    }
}
