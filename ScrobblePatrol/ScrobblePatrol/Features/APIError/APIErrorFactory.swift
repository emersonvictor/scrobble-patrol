import UIKit

@MainActor
enum APIErrorFactory {
    static func make() -> UIViewController {
        APIErrorViewController(message: "Não foi possível configurar a API do Last.fm.")
    }
}
