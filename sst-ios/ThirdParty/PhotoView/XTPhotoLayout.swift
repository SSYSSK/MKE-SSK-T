
import UIKit

class XTPhotoLayout: UICollectionViewFlowLayout {
    
    override func prepare() {
        super.prepare()
        
//        let magin : CGFloat = 10
        minimumLineSpacing = 0
        minimumInteritemSpacing = 0
        
        scrollDirection = .horizontal
        
        if let tmpSize = collectionView?.bounds.size {
            itemSize = tmpSize
        }
        
        collectionView?.showsHorizontalScrollIndicator = false
        collectionView?.isPagingEnabled = true
        
    }
    
}
