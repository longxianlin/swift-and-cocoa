

import UIKit

class CGContextViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let canvas = Canvas(frame: self.view.frame)
        canvas.backgroundColor = UIColor.white
        self.view.addSubview(canvas)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

private class Canvas: UIView {
    
    var startPoint: CGPoint = CGPoint.zero
    var endPoint: CGPoint = CGPoint.zero
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
        
        // Get current context
        if let context = UIGraphicsGetCurrentContext() {
            if self.endPoint != CGPoint.zero {
                //drawRectangle(context: context, startPoint: self.startPoint, endPoint: self.endPoint)
                //drawLine(context: context, startPoint: self.startPoint, endPoint: self.endPoint)
                //drawCircle(context: context, startPoint: self.startPoint, endPoint: self.endPoint)
                //drawArc(context: context, startPoint: self.startPoint, endPoint: self.endPoint)
                //drawPath(context: context, startPoint: self.startPoint, endPoint: self.endPoint)
                //drawGradient(context: context, startPoint: self.startPoint, endPoint: self.endPoint)
                addLines(context: context, startPoint: self.startPoint, endPoint: self.endPoint)
            }
        }
        
    }
    
    func drawRectangle(context: CGContext, startPoint: CGPoint, endPoint: CGPoint) {

        let width = endPoint.x - startPoint.x
        let height = endPoint.y - startPoint.y
        let rectangle = CGRect(x: startPoint.x, y: startPoint.y, width: width, height: height)
        
        context.setLineWidth(2.0)
        context.setStrokeColor(UIColor.blue.cgColor)
        context.addRect(rectangle)
        context.strokePath()
        context.setFillColor(UIColor.red.cgColor)
        context.fill(rectangle)
    }
    
    func drawLine(context: CGContext, startPoint: CGPoint, endPoint: CGPoint) {
        context.setLineWidth(2.0)
        context.setStrokeColor(UIColor.red.cgColor)
        context.move(to: startPoint)
        context.addLine(to: endPoint)
        context.strokePath()
    }
    
    func drawCircle(context: CGContext, startPoint: CGPoint, endPoint: CGPoint) {
        let width = endPoint.x - startPoint.x
        let height = endPoint.y - startPoint.y
        let rectangle = CGRect(x: startPoint.x, y: startPoint.y, width: width, height: height)
        context.setStrokeColor(UIColor.blue.cgColor)
        context.addEllipse(in: rectangle)
        context.strokePath()
    }
    
    func drawArc(context: CGContext, startPoint: CGPoint, endPoint: CGPoint) {
        context.setStrokeColor(UIColor.red.cgColor)
        //context.addArc(tangent1End: startPoint, tangent2End: endPoint, radius: 10)
        //context.addQuadCurve(to: endPoint, control: startPoint)
        context.addArc(center: CGPoint(x: 100, y: 300), radius: 50, startAngle: 3.14, endAngle: 0, clockwise: true)
        context.strokePath()
    }
    
    //To draw more complex shapes, you create a path and stroke it.
    func drawPath(context: CGContext, startPoint: CGPoint, endPoint: CGPoint) {
        context.setStrokeColor(UIColor.red.cgColor)
        context.move(to: CGPoint(x: 25, y: 250))
        context.addLine(to:  CGPoint(x: 175, y: 250))
        context.addLine(to:  CGPoint(x: 100, y: 150))
        context.addLine(to:  CGPoint(x: 25, y: 250))
        context.strokePath()
        
        context.setFillColor(UIColor.blue.cgColor)
        context.fillPath()
    }
    
    
    func drawGradient(context: CGContext, startPoint: CGPoint, endPoint: CGPoint) {
        let colorspace = CGColorSpaceCreateDeviceRGB()
        let colors = [UIColor.red.cgColor, UIColor.blue.cgColor]
        let locations: [CGFloat] = [0.0,1.0]
        let gradient = CGGradient(colorsSpace: colorspace, colors: colors as CFArray, locations: locations)
        context.drawLinearGradient(gradient!, start: startPoint, end: endPoint, options: CGGradientDrawingOptions.drawsAfterEndLocation)
    }
    
    func addLines(context: CGContext, startPoint: CGPoint, endPoint: CGPoint) {
        context.setStrokeColor(UIColor.red.cgColor)
        let lines = [CGPoint(x: 25, y: 150),CGPoint(x: 175, y: 150),CGPoint(x: 100, y: 50), CGPoint(x: 25, y: 150)]
        context.addLines(between: lines)
        context.strokePath()
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            self.startPoint = touch.location(in: touch.view)
            self.endPoint = CGPoint.zero
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let offset = touch.location(in: touch.view)
            self.endPoint = offset
            self.setNeedsDisplay()
        }
        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if self.endPoint != CGPoint.zero {
            // add object to canvas for display
            self.endPoint = CGPoint.zero
            // update display
            //self.setNeedsDisplay()
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        print(">>>touchesCancelled")
    }
    
    
    
}
