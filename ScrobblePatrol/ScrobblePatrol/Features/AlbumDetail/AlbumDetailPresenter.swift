import Foundation

@MainActor
protocol AlbumDetailPresenterProtocol: AnyObject {
    func attach(view: any AlbumDetailViewProtocol)
}

@MainActor
final class AlbumDetailPresenter: AlbumDetailPresenterProtocol {
    private weak var view: (any AlbumDetailViewProtocol)?

    func attach(view: any AlbumDetailViewProtocol) {
        self.view = view
    }
}
