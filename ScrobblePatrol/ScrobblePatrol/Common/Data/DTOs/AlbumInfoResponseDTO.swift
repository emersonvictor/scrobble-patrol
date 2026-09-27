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

        private enum CodingKeys: String, CodingKey {
            case name
            case duration
        }

        init(from decoder: any Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            name = try container.decode(String.self, forKey: .name)

            if let stringDuration = try? container.decode(String.self, forKey: .duration) {
                duration = stringDuration
            } else if let integerDuration = try? container.decode(Int.self, forKey: .duration) {
                duration = String(integerDuration)
            } else {
                duration = nil
            }
        }
    }
}
