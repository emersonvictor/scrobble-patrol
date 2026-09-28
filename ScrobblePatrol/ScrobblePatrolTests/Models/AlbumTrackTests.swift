import Foundation
import XCTest
@testable import ScrobblePatrol

@MainActor
final class AlbumTrackTests: XCTestCase {
    func testFormattedDurationUsesMinutesAndTwoDigitSeconds() throws {
        let track = AlbumTrack(dto: try decodeTrack(duration: "65"))

        XCTAssertEqual(track.formattedDuration, "1:05")
    }

    func testFormattedDurationSupportsZero() throws {
        let track = AlbumTrack(dto: try decodeTrack(duration: "0"))

        XCTAssertEqual(track.formattedDuration, "0:00")
    }

    func testFormattedDurationUsesPlaceholderWhenMissing() throws {
        let track = AlbumTrack(dto: try decodeTrack(duration: nil))

        XCTAssertEqual(track.formattedDuration, "-")
    }

    private func decodeTrack(duration: String?) throws -> AlbumInfoDTO.TrackDTO {
        let durationProperty = duration.map { #", "duration": "\#($0)""# } ?? ""
        let json = #"{"name":"Track"\#(durationProperty)}"#
        return try JSONDecoder().decode(
            AlbumInfoDTO.TrackDTO.self,
            from: Data(json.utf8)
        )
    }
}
