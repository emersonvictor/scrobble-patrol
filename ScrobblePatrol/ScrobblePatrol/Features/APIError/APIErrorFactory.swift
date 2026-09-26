import UIKit

@MainActor
enum APIErrorFactory {
    static func make() -> UIViewController {
        APIErrorViewController()
    }
}
