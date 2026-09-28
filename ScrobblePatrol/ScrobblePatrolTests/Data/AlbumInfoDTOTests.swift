import Foundation
import XCTest
@testable import ScrobblePatrol

@MainActor
final class AlbumInfoDTOTests: XCTestCase {
    func testTrackDurationDecodesString() throws {
        let track = try decodeTrack(from: #"{"name":"Track","duration":"245"}"#)

        XCTAssertEqual(track.duration, "245")
    }

    func testTrackDurationDecodesNumberAsString() throws {
        let track = try decodeTrack(from: #"{"name":"Track","duration":245}"#)

        XCTAssertEqual(track.duration, "245")
    }

    func testTrackDurationDecodesMissingValueAsNil() throws {
        let track = try decodeTrack(from: #"{"name":"Track"}"#)

        XCTAssertNil(track.duration)
    }

    func testTrackDurationDecodesNullAsNil() throws {
        let track = try decodeTrack(from: #"{"name":"Track","duration":null}"#)

        XCTAssertNil(track.duration)
    }

    private func decodeTrack(from json: String) throws -> AlbumInfoDTO.TrackDTO {
        try JSONDecoder().decode(AlbumInfoDTO.TrackDTO.self, from: Data(json.utf8))
    }
}
