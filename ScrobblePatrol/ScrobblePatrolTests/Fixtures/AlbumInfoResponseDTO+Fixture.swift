import Foundation
@testable import ScrobblePatrol

extension AlbumInfoResponseDTO {
    static func fixture() throws -> Self {
        let data = Data(
            """
            {
              "album": {
                "name": "Titanic Rising",
                "artist": "Weyes Blood",
                "image": [
                  { "#text": "https://example.com/large.jpg", "size": "large" }
                ],
                "listeners": "1000",
                "playcount": "2000",
                "url": "https://www.last.fm/music/Weyes+Blood/Titanic+Rising",
                "tags": { "tag": [{ "name": "baroque pop" }] },
                "tracks": {
                  "track": [{ "name": "A Lot's Gonna Change", "duration": "262" }]
                }
              }
            }
            """.utf8
        )
        return try JSONDecoder().decode(Self.self, from: data)
    }
}
