
import UIKit


private let ID = "PhotoBrowserCellID"

class XTPhotoBrowserViewController: UIViewController {
    
    var indexPath : IndexPath = IndexPath()
//    var cells:
    
    var collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: XTPhotoLayout())
    
    var shopsArray = [SSTApplyCodFile]()
    
    
    
    var codCells = [SSTCODCell]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.frame.size.width += 15
        
        view.backgroundColor = UIColor.blue
        setupUi()
        
        //滚动到正确的位置
        collectionView.scrollToItem(at: indexPath, at: .left, animated: false)
    }
    
}

// MARK:- 设置ui界面
extension XTPhotoBrowserViewController {
    func setupUi(){
        setupCollectionView()
        
        
        
    }
    
    fileprivate func setupCollectionView() {
        //创建collectionView
        collectionView.frame = view.bounds
        //注册cell
        collectionView.register(XTPhotoBrowserViewCell.classForCoder(), forCellWithReuseIdentifier: ID)
        
        collectionView.dataSource = self
        collectionView.delegate = self
        view.addSubview(collectionView)
        
    }
}

// MARK:- 监听按钮点击
extension XTPhotoBrowserViewController {
    @objc fileprivate func closeBtnClick(){
        dismiss(animated: true, completion: nil)
    }
    
    @objc fileprivate func saveBtnClick(){
    
        let cell = collectionView.visibleCells[0]  as! XTPhotoBrowserViewCell
        
        guard let image = cell.imageView.image else {
            return
        }
        
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
    }
    
}

// MARK:- 数据源方法
extension XTPhotoBrowserViewController : UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return shopsArray.count 
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ID, for: indexPath) as! XTPhotoBrowserViewCell
        
        let item = shopsArray[indexPath.item]
        
        cell.item = item
        cell.codCells = codCells
        
        return cell
    }
    
}

// MARK:- UICollectionView的代理方法
extension XTPhotoBrowserViewController : UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        closeBtnClick()
    }
}

extension XTPhotoBrowserViewController : AnimatorDismissedDelegate {
    
    func getCurrentIndexPath() -> IndexPath {
        
        // 1.获取在屏幕中显示的cell
        let cell = collectionView.visibleCells[0]
        
        // 2.获取cell对应的indexPath
        let indexPath = collectionView.indexPath(for: cell)!
        
        return indexPath
    }
    
    func getCurrentImageView() -> UIImageView {
        // 1.创建UIImageView
        let imageView = UIImageView()
        
        // 2.设置imageView属性
        let cell = collectionView.visibleCells[0] as! XTPhotoBrowserViewCell
        imageView.image = cell.imageView.image
        if let tmpImg = imageView.image {
            imageView.frame = calculateFrameWithImage(image: tmpImg)
        }
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        
        return imageView
    }
}
