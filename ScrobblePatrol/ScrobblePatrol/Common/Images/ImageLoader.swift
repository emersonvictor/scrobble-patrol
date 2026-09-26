import UIKit

@MainActor
protocol ImageLoading {
    func load(_ url: URL) async throws -> UIImage
}

@MainActor
final class ImageLoader: ImageLoading {
    static let shared = ImageLoader()

    private let session: URLSession
    private let cache: NSCache<NSURL, UIImage>

    init(
        session: URLSession = .shared,
        cache: NSCache<NSURL, UIImage> = NSCache()
    ) {
        self.session = session
        self.cache = cache
        self.cache.countLimit = 100
    }

    func load(_ url: URL) async throws -> UIImage {
        if let cachedImage = cache.object(forKey: url as NSURL) {
            return cachedImage
        }

        let (data, response) = try await session.data(from: url)
        try Task.checkCancellation()

        guard
            let response = response as? HTTPURLResponse,
            (200..<300).contains(response.statusCode)
        else {
            throw ImageLoaderError.invalidResponse
        }
        guard let image = UIImage(data: data) else {
            throw ImageLoaderError.invalidData
        }

        cache.setObject(image, forKey: url as NSURL)
        return image
    }
}

private enum ImageLoaderError: Error {
    case invalidResponse
    case invalidData
}
