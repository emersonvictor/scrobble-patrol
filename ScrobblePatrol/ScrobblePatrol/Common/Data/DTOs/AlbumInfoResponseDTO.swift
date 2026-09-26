import Foundation

struct AlbumInfoResponseDTO: Decodable {
    let album: AlbumInfoDTO
}

struct AlbumInfoDTO: Decodable {
    let name: String
    let artist: String
    let image: [ImageDTO]?
    let listeners: String?
    let playcount: String?
    let url: String?
    let tags: TagsDTO?
    let tracks: TracksDTO?

    struct ImageDTO: Decodable {
        let text: String
        let size: String

        enum CodingKeys: String, CodingKey {
            case text = "#text"
            case size
        }
    }

    struct TagsDTO: Decodable {
        let tag: [TagDTO]
    }

    struct TagDTO: Decodable {
        let name: String
    }

    struct TracksDTO: Decodable {
        let track: [TrackDTO]
    }

    struct TrackDTO: Decodable {
        let name: String
        let duration: String?
    }
}
