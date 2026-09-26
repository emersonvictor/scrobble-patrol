import Foundation

@MainActor
protocol AlbumGridPresenterProtocol: AnyObject {
    func attach(view: any AlbumGridViewProtocol)
}

@MainActor
final class AlbumGridPresenter: AlbumGridPresenterProtocol {
    private weak var view: (any AlbumGridViewProtocol)?

    func attach(view: any AlbumGridViewProtocol) {
        self.view = view
    }
}
