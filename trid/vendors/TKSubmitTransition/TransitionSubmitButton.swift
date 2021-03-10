import Foundation
import UIKit

@IBDesignable
open class TKTransitionSubmitButton : UIButton, UIViewControllerTransitioningDelegate, CAAnimationDelegate {
    
    lazy var spiner: SpinerLayer! = {
        let s = SpinerLayer(frame: self.frame)
        self.layer.addSublayer(s)
        return s
    }()
    
    @IBInspectable open var spinnerColor: UIColor = UIColor.white {
        didSet {
            spiner.spinnerColor = spinnerColor
        }
    }
    
    open var didEndFinishAnimation : (()->())? = nil
    
    let springGoEase = CAMediaTimingFunction(controlPoints: 0.45, -0.36, 0.44, 0.92)
    let shrinkCurve = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
    let expandCurve = CAMediaTimingFunction(controlPoints: 0.95, 0.02, 1, 0.05)
    let shrinkDuration: CFTimeInterval  = 0.1
    @IBInspectable open var normalCornerRadius: CGFloat = 0.0{
        didSet {
            self.layer.cornerRadius = normalCornerRadius
        }
    }
    
    var size : CGSize!
    var cachedTitle: String?
    var isAnimating = false
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
    }
    
    public required init!(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        self.setup()
    }
    
    func setup() {
        self.clipsToBounds = true
        spiner.spinnerColor = spinnerColor
        size = self.frame.size
    }
    
    open func startLoadingAnimation() {
        if isAnimating {
            return
        }
        self.isEnabled = false
        isAnimating = true
        self.cachedTitle = self.title(for: UIControl.State())
        self.setTitle("", for: UIControl.State())
        UIView.animate(withDuration: 0.1, animations: { () -> Void in
            self.layer.cornerRadius = self.frame.height / 2
        }, completion: { (done) -> Void in
            self.shrink()
            Timer.schedule(delay: self.shrinkDuration - 0.25) { timer in
                self.spiner.animation()
            }
        })
        
    }
    
    open func stopAnimation(_ delay: TimeInterval = 0, completion:(()->())? = nil) {
        if !isAnimating {
            if completion != nil {
                completion!()
            }
            return
        }
        Timer.schedule(delay: delay) { timer in
            if completion != nil {
                completion!()
            }
            self.returnToOriginalState()
        }
    }
    
    open func returnToOriginalState() {
        self.isEnabled = true
        isAnimating = false
        self.layer.removeAllAnimations()
        if self.cachedTitle != nil {
            self.setTitle(self.cachedTitle, for: UIControl.State())
        }
        self.spiner.stopAnimation()
        self.shrinkOut()
        Timer.schedule(delay: self.shrinkDuration - 0.25) { timer in
            UIView.animate(withDuration: 0.1, animations: {
                self.layer.cornerRadius = self.normalCornerRadius
            })
        }
    }
    
    func shrink() {
        let shrinkAnim = CABasicAnimation(keyPath: "bounds.size.width")
        shrinkAnim.fromValue = frame.width
        shrinkAnim.toValue = frame.height
        shrinkAnim.duration = shrinkDuration
        shrinkAnim.timingFunction = shrinkCurve
        shrinkAnim.fillMode = CAMediaTimingFillMode.forwards
        shrinkAnim.isRemovedOnCompletion = false
        layer.add(shrinkAnim, forKey: shrinkAnim.keyPath)
    }
    
    func shrinkOut() {
        let shrinkAnim = CABasicAnimation(keyPath: "bounds.size.width")
        shrinkAnim.fromValue = size.height
        shrinkAnim.toValue = size.width
        shrinkAnim.duration = shrinkDuration
        shrinkAnim.timingFunction = shrinkCurve
        shrinkAnim.fillMode = CAMediaTimingFillMode.forwards
        shrinkAnim.isRemovedOnCompletion = false
        layer.add(shrinkAnim, forKey: shrinkAnim.keyPath)
    }
    
}
