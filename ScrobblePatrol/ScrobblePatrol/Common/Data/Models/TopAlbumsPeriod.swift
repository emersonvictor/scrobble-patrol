enum TopAlbumsPeriod: String, CaseIterable {
    case week = "7day"
    case month = "1month"
    case year = "12month"

    init?(selectedIndex: Int) {
        switch selectedIndex {
        case 0:
            self = .week
        case 1:
            self = .month
        case 2:
            self = .year
        default:
            return nil
        }
    }
}
