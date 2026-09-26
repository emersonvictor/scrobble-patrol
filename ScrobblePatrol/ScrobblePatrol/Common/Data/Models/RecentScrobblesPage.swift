import Foundation

struct RecentScrobblesPage: Equatable {
    let scrobbles: [RecentScrobble]
    let page: Int
    let totalPages: Int

    init(dto: RecentTracksDTO) {
        self.scrobbles = dto.track.map { RecentScrobble(dto: $0) }
        self.page = dto.attributes.page
        self.totalPages = dto.attributes.totalPages
    }
}
