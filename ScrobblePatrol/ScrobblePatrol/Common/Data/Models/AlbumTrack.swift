import Foundation

struct AlbumTrack: Equatable {
    let name: String
    let duration: TimeInterval?

    init(dto: AlbumInfoDTO.TrackDTO) {
        name = dto.name
        duration = dto.duration.flatMap(TimeInterval.init)
    }
}
