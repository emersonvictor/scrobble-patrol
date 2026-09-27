struct TopAlbumsPage: Equatable {
    let albums: [TopAlbum]
    let page: Int
    let totalPages: Int

    init(dto: TopAlbumsDTO) {
        albums = dto.album.map { TopAlbum(dto: $0) }
        page = dto.attributes.page
        totalPages = dto.attributes.totalPages
    }
}
