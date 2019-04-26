

import UIKit
var imageFrame = CGRect()

public protocol AnimatorPresentedDelegate : class {
    func startRect(_ indexPath : IndexPath)->CGRect
    func endRect(_ indexPath : IndexPath)->CGRect
    func imageView (_ indexPath : IndexPath)->UIImageView
}

public protocol AnimatorDismissedDelegate : class {
    func getCurrentIndexPath() -> IndexPath
    func getCurrentImageView() -> UIImageView
}

open class XTPhotoBrowserAnimator : NSObject {
    
    var indexPath : IndexPath?
    
    var applyCodFiles = [SSTApplyCodFile]()
    
    var isPresent : Bool = true
    //代理属性
    weak var presentedDelegate : AnimatorPresentedDelegate?
    weak var dismissedDelegate : AnimatorDismissedDelegate?
}

extension XTPhotoBrowserAnimator :  UIViewControllerTransitioningDelegate{
    public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning?{
        isPresent = true
        return self
    }
    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning?{
        isPresent = false
        return self
    }
}

extension XTPhotoBrowserAnimator : UIViewControllerAnimatedTransitioning {
    public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.3
    }

    public func animateTransition(using transitionContext: UIViewControllerContextTransitioning){
        
        if isPresent {
            
            //判断代理是否有值
            guard let presentedDelegate = presentedDelegate else {
                return
            }
            
            guard let indexPath = indexPath else {
                return
            }
            
            //获取弹出的view
            let presentView = transitionContext.view(forKey: UITransitionContextViewKey.to)
            if let tmpV = presentView {
                transitionContext.containerView.addSubview(tmpV)
            }
            presentView?.alpha = 0
            transitionContext.containerView.backgroundColor = UIColor.black
            
            //获取动画需要的元素
            let ImageView = presentedDelegate.imageView(indexPath)
            let startRect = presentedDelegate.startRect(indexPath)
            ImageView.frame = startRect
            transitionContext.containerView.addSubview(ImageView)
            
            UIView.animate(withDuration: transitionDuration(using: transitionContext), animations: {
            
                let endRect = presentedDelegate.endRect(indexPath)
                
                ImageView.frame = endRect
                imageFrame = endRect
                
                               
            }, completion: { (isFinished:Bool) in
                ImageView.removeFromSuperview()
                presentView?.alpha = 1
                transitionContext.containerView.backgroundColor = UIColor.clear
                transitionContext.completeTransition(isFinished)
            }) 
        }else{
            
            // 0.对可选类型进行校验
            guard let dismissedDelegate = dismissedDelegate else {
                return
            }
            
            guard let presentedDelegate = presentedDelegate else {
                return
            }
            
            let dismissView = transitionContext.view(forKey: UITransitionContextViewKey.from)
            dismissView?.removeFromSuperview()
            
            let indexPath = dismissedDelegate.getCurrentIndexPath()
            
            
            // 获取UIImageView对象
            let imageView = dismissedDelegate.getCurrentImageView()
            transitionContext.containerView.addSubview(imageView)
            
//            // 获取起始位置
            let startRect = presentedDelegate.endRect(indexPath)
            imageView.frame = startRect


            UIView.animate(withDuration: transitionDuration(using: transitionContext), animations: {

                imageView.alpha = 0.0
                imageView.frame = CGRect(x: kScreenWidth/2, y: kScreenHeight/2, width: 0, height: 0)

                }, completion: { (isFinished : Bool) in
                    transitionContext.completeTransition(isFinished)
            })
        }
    
    }
  
}




