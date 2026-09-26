@testable import ScrobblePatrol

@MainActor
extension RecentTracksResponseDTO {
    static func fixture(
        tracks: [RecentTrackDTO]? = nil,
        page: Int = 2,
        totalPages: Int = 4
    ) -> Self {
        Self(recenttracks: RecentTracksDTO(
            track: tracks ?? [.fixture()],
            attributes: .init(page: page, totalPages: totalPages)
        ))
    }
}
