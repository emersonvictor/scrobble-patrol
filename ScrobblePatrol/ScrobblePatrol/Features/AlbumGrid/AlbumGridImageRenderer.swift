import UIKit

@MainActor
protocol AlbumGridImageRendering {
    func render(collectionView: UICollectionView, gridSize: Int) -> UIImage?
}

@MainActor
final class AlbumGridImageRenderer: AlbumGridImageRendering {
    func render(collectionView: UICollectionView, gridSize: Int) -> UIImage? {
        collectionView.layoutIfNeeded()

        guard let firstItem = collectionView.layoutAttributesForItem(
            at: IndexPath(item: 0, section: 0)
        ) else {
            return nil
        }

        let gridSide = firstItem.size.width * CGFloat(gridSize)
        let gridFrame = CGRect(
            origin: firstItem.frame.origin,
            size: CGSize(width: gridSide, height: gridSide)
        )

        let format = UIGraphicsImageRendererFormat()
        format.scale = collectionView.traitCollection.displayScale
        format.opaque = true

        let renderer = UIGraphicsImageRenderer(
            size: gridFrame.size,
            format: format
        )

        return renderer.image { context in
            context.cgContext.translateBy(
                x: -gridFrame.minX,
                y: -gridFrame.minY
            )
            collectionView.layer.render(in: context.cgContext)
        }
    }
}
