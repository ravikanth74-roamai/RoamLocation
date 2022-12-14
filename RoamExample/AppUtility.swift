//
//  AppUtility.swift
//  RoamExample
//
//  Created by GeoSpark on 05/08/22.
//

import Foundation
import UIKit

class Alert: NSObject {
    
    static func alertController(title: String?,message:String?, viewController:UIViewController) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            let firstAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
            alert.addAction(firstAction)
            viewController.present(alert, animated: true, completion: nil)
        }
    }
    
}


private var hudViewAssociatedKey: UInt8 = 0

public extension UIViewController {
    
    var hudView: HudView? {
        get {
            return objc_getAssociatedObject(self, &hudViewAssociatedKey) as? HudView
        }
        set {
            objc_setAssociatedObject(self, &hudViewAssociatedKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
        }
    }
    
    
    func showHud() {
        DispatchQueue.main.async {
            self.showHud(withBackground: .white)
        }
    }
    
    func showHud(withBackground backgroundColor: UIColor? = .white) {
        
        removeHudIfPresent()
        
        hudView = HudView(frame: CGRect(origin: .zero, size: CGSize(width: 100, height: 100)))
        hudView?.backgroundColor = backgroundColor
        hudView!.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(hudView!)
        hudView!.cr_fillContainerWithInsets(.zero)
        hudView!.startProgress()
    }
    
    func dismissHud(withCompletion completionBlock: (() -> Void)? = nil) {
        DispatchQueue.main.async {
            if let hudView = self.hudView {
                UIView.animate(withDuration: 0.25, animations: {
                    hudView.alpha = 0
                }, completion: { (isValue) in
                    self.removeHudIfPresent()
                })
            }
        }
    }
    
    private func removeHudIfPresent() {
        if let hudView = hudView {
            hudView.removeFromSuperview()
            self.hudView = nil
        }
    }
    
}


public class HudView: UIView {
    
    public var spinningView: UIView!

    private var spinningCircleSize: CGSize!
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        
        autoresizingMask = [.flexibleWidth, .flexibleHeight]
        alpha = 0
        backgroundColor = .white
        
        spinningCircleSize = CGSize(width: frame.width / 2, height: frame.height / 2)
        
        createSubviews()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        alpha = 0
        backgroundColor = .white
        
        spinningCircleSize = CGSize(width: 30, height: 30)
        
        createSubviews()
    }

    public func startProgress() {
        spinningView.startRotation(duration: 1.3)
    }
    
    public func stopProgress() {
        spinningView.stopRotation()
    }
    
    private func createSubviews() {
        
        self.spinningView = UIView()
        spinningView.translatesAutoresizingMaskIntoConstraints = false
        spinningView.backgroundColor = .clear

        let hudCircleView = HudCircleView(frame: CGRect(origin: .zero, size: spinningCircleSize))
        hudCircleView.radius = spinningCircleSize.width / 2
        hudCircleView.translatesAutoresizingMaskIntoConstraints = false
        hudCircleView.backgroundColor = .clear
        spinningView.addSubview(hudCircleView)
        hudCircleView.cr_fillContainerWithInsets(.zero)

        addSubview(spinningView)
        spinningView.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        spinningView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        spinningView.widthAnchor.constraint(equalToConstant: 100.0).isActive = true
        spinningView.heightAnchor.constraint(equalToConstant: 100.0).isActive = true

        UIView.animate(withDuration: 0.25) {
            self.alpha = 0.9
        }
    }
    
}

fileprivate class HudCircleView: UIView {

    fileprivate var radius: CGFloat!
    
    override public func draw(_ rect: CGRect) {
        
        // TODO: all colors should be taken from the styles not created directly
        
        let backgroundBezierPath = UIBezierPath(arcCenter: CGPoint(x: rect.size.width / 2, y: rect.size.height / 2),
                                                radius: radius, startAngle: 0,
                                                endAngle: .pi * 2, clockwise: true)
        backgroundBezierPath.lineWidth = 2
        
        // background color
        UIColor(red: 49.0/255.0, green: 227.0/255.0, blue: 194.0/255.0, alpha: 1.0).setStroke()
        backgroundBezierPath.stroke()
        
        
        // progress arc
        let progressArcPath = UIBezierPath(arcCenter: CGPoint(x: rect.size.width / 2, y: rect.size.height / 2),
                                           radius: radius, startAngle: -.pi / 2,
                                           endAngle: -.pi / 4, clockwise: true)
        UIColor(red: 40.0/255.0, green: 42.0/255.0, blue: 47.0/255.0, alpha: 1.0).setStroke()
        progressArcPath.lineWidth = 2
        progressArcPath.lineCapStyle = .round
        progressArcPath.stroke()
    }

}

public extension UIView {
    
     func startRotation(duration: CFTimeInterval = 2, repeatCount: Float = Float.infinity, clockwise: Bool = true) {
        if self.layer.animation(forKey: "transform.rotation.z") != nil {
            return
        }
        let animation = CABasicAnimation(keyPath: "transform.rotation.z")
        let direction = clockwise ? 1.0 : -1.0
        animation.toValue = NSNumber(value: .pi * 2 * direction)
        animation.duration = duration
        animation.isCumulative = true
        animation.repeatCount = repeatCount
        self.layer.add(animation, forKey: "transform.rotation.z")
    }
    
    
    func stopRotation() {
        self.layer.removeAnimation(forKey: "transform.rotation.z")
    }
    
    func cr_fillContainerWithInsets(_ insets: UIEdgeInsets) {
        assert(superview != nil, "Must have superview!")
        
        let h = NSLayoutConstraint.constraints(withVisualFormat: "|-left-[self]-right-|",
                                               options: .alignAllLeft, metrics: ["left": insets.left, "right": insets.right], views: ["self": self])
        let v = NSLayoutConstraint.constraints(withVisualFormat: "V:|-top-[self]-bottom-|",
                                               options: .alignAllLeft, metrics: ["top": insets.top, "bottom": insets.bottom], views: ["self": self])
        
        superview?.addConstraints(h + v)
    }
    
    
}

extension UIApplication {
    class func topViewController(base: UIViewController? = UIApplication.shared.windows.first?.rootViewController) -> UIViewController? {
        if let nav = base as? UINavigationController {
            return topViewController(base: nav.visibleViewController)
        }
        if let tab = base as? UITabBarController {
            if let selected = tab.selectedViewController {
                return topViewController(base: selected)
            }
        }
        if let presented = base?.presentedViewController {
            return topViewController(base: presented)
        }
        return base
    }
}

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
extension String {
     func random() -> String {
        let base = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        var randomString: String = ""

        for _ in 0..<5 {
            let randomValue = arc4random_uniform(UInt32(base.count))
            randomString += "\(base[base.index(base.startIndex, offsetBy: Int(randomValue))])"
        }
        return randomString
    }
}
