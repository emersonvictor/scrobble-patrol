import Foundation

struct AlbumTrack: Equatable {
    let name: String
    let duration: TimeInterval?

    var formattedDuration: String {
        guard let duration else { return "-" }
        let totalSeconds = Int(duration)
        return String(format: "%d:%02d", totalSeconds / 60, totalSeconds % 60)
    }

    init(dto: AlbumInfoDTO.TrackDTO) {
        name = dto.name
        duration = dto.duration.flatMap(TimeInterval.init)
    }
}
