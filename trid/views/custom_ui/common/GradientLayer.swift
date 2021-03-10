//
//  GradientLayer.swift
//  trid
//
//  Created by Black on 9/26/16.
//  Copyright © 2016 Black. All rights reserved.
//

import UIKit
import PureLayout

class GradientLayer: UIView {
    
    var gradient : MyGradient!
    
    override init(frame: CGRect){
        super.init(frame: frame)
        createUI()
    }
    
    required init?(coder aDecoder: NSCoder){
        super.init(coder: aDecoder)
        createUI()
    }
    
    func createUI() {
        self.backgroundColor = UIColor.clear
        let colorTop = UIColor.clear.cgColor
        let colorBottom = UIColor(white: 0.0, alpha: 0.3).cgColor
        gradient = MyGradient(forAutoLayout: ())
        gradient.gradientLayer?.colors = [colorTop, colorBottom]
        gradient.gradientLayer?.locations = [0.0, 1.0]
        self.insertSubview(gradient, at: 0)
        gradient.autoPinEdgesToSuperviewEdges()
    }
    
}

public final class MyGradient : UIView {
    public override class var layerClass: AnyClass {
        return CAGradientLayer.self
    }
    
    public var gradientLayer: CAGradientLayer? {
        return self.layer as? CAGradientLayer
    }
    
    @IBInspectable
    public var startPoint: CGPoint {
        get {
            return self.gradientLayer?.startPoint ?? .zero
        }
        set {
            self.gradientLayer?.startPoint = newValue
        }
    }
    
    @IBInspectable
    public var endPoint: CGPoint {
        get {
            return self.gradientLayer?.endPoint ?? .zero
        }
        set {
            self.gradientLayer?.endPoint = newValue
        }
    }
    
    @IBInspectable public var startColor: UIColor?
    @IBInspectable public var endColor: UIColor?
    
    public override func awakeFromNib() {
        super.awakeFromNib()
        self.setGradient([(self.startColor, 0.0), (self.endColor, 1.0)])
    }
    
    public override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        self.setGradient([(self.startColor, 0.0), (self.endColor, 1.0)])
    }
    
    public func setGradient(_ points: [(color: UIColor?, location: Float)]) {
        self.backgroundColor = .clear
        
        self.gradientLayer?.colors = points.map { point in
            point.color?.cgColor ?? UIColor.clear.cgColor
        }
        
        self.gradientLayer?.locations = points.map { point in
            NSNumber(value: point.location)
        }
    }
}
