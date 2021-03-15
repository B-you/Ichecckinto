//
//  FirstViewController.swift
//  CheckIn
//
//  Created by Bin on 2018/10/15.
//  Copyright © 2018 Bin. All rights reserved.
//

import UIKit

class FirstViewController: UIViewController {

    @IBOutlet weak var viewww: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()

       // self.viewww.setBottomCurve()
        //self.viewww.addTopRoundedCornerToView(targetView: self.viewww, desiredCurve:1.0)
        viewww.setCardView(view: viewww)
        // Do any additional setup after loading the view.
    }
    
    @IBAction func onclick_goHome(_ sender: Any) {
        self.performSegue(withIdentifier: "go_home", sender: nil)
    }
    
 

}
extension UIView {
    
    func addTopRoundedCornerToView(targetView:UIView?, desiredCurve:CGFloat?)
    {
        let offset:CGFloat =  targetView!.frame.width/desiredCurve!
        let bounds: CGRect = targetView!.bounds
        let rectBounds: CGRect = CGRect(x: bounds.origin.x,
                                        y: bounds.origin.y,
                                        width: bounds.size.width,
                                        height: bounds.size.height / 2)
        
        let rectPath: UIBezierPath = UIBezierPath(rect: rectBounds)
        let ovalBounds: CGRect = CGRect(x:bounds.origin.x - offset / 2,
                                        y: bounds.origin.y,
                                        width: bounds.size.width + offset,
                                        height: bounds.size.height)
        let ovalPath: UIBezierPath = UIBezierPath(ovalIn: ovalBounds)
        rectPath.append(ovalPath)
        
        // Create the shape layer and set its path
        let maskLayer: CAShapeLayer = CAShapeLayer()
        maskLayer.frame = bounds
        maskLayer.path = rectPath.cgPath
        
        // Set the newly created shape layer as the mask for the view's layer
        targetView!.layer.mask = maskLayer
    }
}

class CurvedView: UIView {
    
    override func draw(_ rect: CGRect) {
        let y:CGFloat = 20
        let curveTo:CGFloat = 0
        
        let myBezier = UIBezierPath()
        myBezier.move(to: CGPoint(x: 0, y: y))
        myBezier.addQuadCurve(to: CGPoint(x: rect.width, y: y), controlPoint: CGPoint(x: rect.width / 2, y: curveTo))
        myBezier.addLine(to: CGPoint(x: rect.width, y: rect.height))
        myBezier.addLine(to: CGPoint(x: 0, y: rect.height))
        myBezier.close()
        let context = UIGraphicsGetCurrentContext()
        context!.setLineWidth(4.0)
        UIColor.white.setFill()
        myBezier.fill()
    }
}
