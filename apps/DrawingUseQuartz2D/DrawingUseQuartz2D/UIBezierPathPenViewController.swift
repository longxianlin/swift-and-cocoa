

//  https://code.tutsplus.com/tutorials/ios-sdk-advanced-freehand-drawing-techniques--mobile-15602

import UIKit

class UIBezierPathPenViewController: UIViewController, UIScrollViewDelegate {
    
    var scrollView: UIScrollView!
    fileprivate var canvasView: Canvas!
    
    var initialPosOfCanvasView = CGPoint.zero
    var dragPosOfCanvasView = CGPoint.zero
    var longPressGestureOfScrollView: UILongPressGestureRecognizer!
    var swipeGestureOfScrollView: UISwipeGestureRecognizer!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.lightGray
        
        // Do any additional setup after loading the view.
        scrollView = UIScrollView(frame: self.view.frame)
        scrollView.delegate = self
        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = 4.0
        scrollView.isScrollEnabled = false
        
        canvasView = Canvas(frame: self.view.frame)
        scrollView.addSubview(canvasView)
        scrollView.contentSize = scrollView.frame.size
        self.view.addSubview(scrollView)
        
        longPressGestureOfScrollView = UILongPressGestureRecognizer(target: self, action: #selector(self.gestureAction))
        longPressGestureOfScrollView.numberOfTouchesRequired = 2
        self.scrollView.addGestureRecognizer(longPressGestureOfScrollView)
        
        swipeGestureOfScrollView = UISwipeGestureRecognizer(target: self, action: #selector(self.gestureAction))
        swipeGestureOfScrollView.numberOfTouchesRequired = 2
        self.scrollView.addGestureRecognizer(swipeGestureOfScrollView)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return canvasView
    }
    
    
    func gestureAction(sender: UIGestureRecognizer) {
        if sender.state == .began {
            scrollView.isScrollEnabled = true
            initialPosOfCanvasView = sender.location(in: scrollView)
        }
        
        if sender.state == .changed {
            let loc = sender.location(in: scrollView)
            let newPos = CGPoint(x: initialPosOfCanvasView.x - loc.x + dragPosOfCanvasView.x, y: initialPosOfCanvasView.y - loc.y + dragPosOfCanvasView.y)
            dragPosOfCanvasView = newPos
            scrollView.contentOffset = newPos
        }
        
        if sender.state == .ended {
            
            var newOffset = scrollView.contentOffset
            var move = false
            if scrollView.contentOffset.x < 0 {
                newOffset.x = 0
                move = true
            }
            if scrollView.contentOffset.y < 0 {
                newOffset.y = 0
                move = true
            }
            if scrollView.contentOffset.x > canvasView.frame.size.width - scrollView.frame.size.width {
                newOffset.x = max(self.canvasView.frame.size.width - self.scrollView.frame.size.width, 0)
                move = true
            }
            if scrollView.contentOffset.y > canvasView.frame.size.height - scrollView.frame.size.height {
                newOffset.y = max(self.canvasView.frame.size.height - self.scrollView.frame.size.height, 0)
                move = true
            }
            if move {
                self.scrollView.contentOffset = newOffset
                self.scrollView.isScrollEnabled = false
            }
        }
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

fileprivate struct LineSegment {
    var firstPoint: CGPoint
    var secondPoint: CGPoint
}

let CAPACITY: Float = 100
let FF: Float = 0.2
let LOWER: Float = 0.01
let UPPER: Float = 1.0

fileprivate class Canvas: UIView {
    
    var incrementalImage: UIImage?
    
    var pts: [CGPoint] = Array.init(repeating: CGPoint.zero, count: 5)
    var ctr: Int = 0
    var pointsBuffer = Array.init(repeating: CGPoint.zero, count: 100)
    var bufIdx: Int = 0
    var drawingQueue: DispatchQueue?
    var isFirstTouchPoint = false
    var lastSegmentOfPrev: LineSegment?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.isMultipleTouchEnabled = false
        self.backgroundColor = UIColor.white
        self.drawingQueue = DispatchQueue(label: "drawingQueue")
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.eraseDrawing))
        tap.numberOfTapsRequired = 2
        self.addGestureRecognizer(tap)
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func eraseDrawing(sender: UITapGestureRecognizer) {
        incrementalImage = nil
        self.setNeedsDisplay()
    }
    
    override func draw(_ rect: CGRect) {
        autoreleasepool {
            incrementalImage?.draw(in: rect)
            //path.stroke()
        }
    }
    
    fileprivate override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        ctr = 0
        bufIdx = 0
        if let touch = touches.first {
            let point = touch.location(in: touch.view)
            pts[0] = point
            isFirstTouchPoint = true
        }
    }
    
    fileprivate override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let point = touch.location(in: touch.view)
            ctr += 1
            pts[ctr] = point
            if (ctr == 4)
            {
                pts[3] = CGPoint(x: (pts[2].x + pts[4].x)/2.0, y: (pts[2].y + pts[4].y)/2.0)
                
                for i in 0..<4 {
                    pointsBuffer[bufIdx + i] = pts[i]
                }
                
                bufIdx += 4
                
                drawingQueue?.async {
                    let offsetPath = UIBezierPath()

                    if self.bufIdx == 0 { return }
                    
                    var ls = Array.init(repeating: LineSegment.init(firstPoint: CGPoint.zero, secondPoint: CGPoint.zero), count: 4)
                    
                    for i in stride(from: 0, to: self.bufIdx, by: 4) {
                        
                        if self.isFirstTouchPoint {
                            ls[0] = LineSegment.init(firstPoint: self.pointsBuffer[0], secondPoint: self.pointsBuffer[0])
                            offsetPath.move(to: ls[0].firstPoint)
                            self.isFirstTouchPoint = false
                        } else {
                            ls[0] = self.lastSegmentOfPrev!
                        }
                        
                        //算法
                        let value1 = self.len_sq(p1: self.pointsBuffer[i], p2: self.pointsBuffer[i+1])
                        let frac1: Float = FF/self.clamp(value: value1, lower: Float(LOWER), higher: Float(UPPER))
                        let value2 = self.len_sq(p1: self.pointsBuffer[i+1], p2: self.pointsBuffer[i+2])
                        let frac2: Float = FF/self.clamp(value: value2, lower: Float(LOWER), higher: Float(UPPER))
                        let value3 = self.len_sq(p1: self.pointsBuffer[i+2], p2: self.pointsBuffer[i+3])
                        let frac3: Float = FF/self.clamp(value: value3, lower: Float(LOWER), higher: Float(UPPER))
                        ls[1] = self.lineSegmentPerpendicularTo(pp: LineSegment.init(firstPoint: self.pointsBuffer[i], secondPoint: self.pointsBuffer[i+1]), ofRelativeLength: frac1)
                            
                        ls[2] = self.lineSegmentPerpendicularTo(pp: LineSegment.init(firstPoint: self.pointsBuffer[i+1], secondPoint: self.pointsBuffer[i+2]), ofRelativeLength: frac2)
                        
                        ls[3] = self.lineSegmentPerpendicularTo(pp: LineSegment.init(firstPoint: self.pointsBuffer[i+2], secondPoint: self.pointsBuffer[i+3]), ofRelativeLength: frac3)
                        
                        offsetPath.move(to: ls[0].firstPoint)
                        offsetPath.addCurve(to: ls[3].firstPoint, controlPoint1: ls[1].firstPoint, controlPoint2: ls[2].firstPoint)
                        offsetPath.addLine(to: ls[3].secondPoint)
                        offsetPath.addCurve(to: ls[0].secondPoint, controlPoint1: ls[2].secondPoint, controlPoint2: ls[1].secondPoint)
                        offsetPath.close()
                        
                        self.lastSegmentOfPrev = ls[3]

                    }
                    
                    UIGraphicsBeginImageContextWithOptions(self.bounds.size, true, 0.0)
                    if self.incrementalImage == nil {
                        let rectpath = UIBezierPath(rect: self.bounds)
                        UIColor.white.setFill()
                        rectpath.fill()
                    }
                    self.incrementalImage?.draw(at: CGPoint.zero)
                    UIColor.black.setStroke()
                    UIColor.black.setFill()
                    offsetPath.stroke()
                    offsetPath.fill()
                    
                    self.incrementalImage = UIGraphicsGetImageFromCurrentImageContext()
                    UIGraphicsEndImageContext()
                    offsetPath.removeAllPoints()
                    
                    DispatchQueue.main.async {
                        self.bufIdx = 0
                        self.setNeedsDisplay()
                    }
                }
                pts[0] = pts[3]
                pts[1] = pts[4]
                ctr = 1
            }
        }
        
    }
    
    fileprivate override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.setNeedsDisplay()
    }
    
    fileprivate override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.touchesEnded(touches, with: event)
    }
    
    func lineSegmentPerpendicularTo(pp: LineSegment, ofRelativeLength fraction: Float) -> LineSegment {
        let x0: CGFloat = pp.firstPoint.x, y0 = pp.firstPoint.y, x1 = pp.secondPoint.x, y1 = pp.secondPoint.y
        
        var dx:CGFloat, dy:CGFloat
        
        dx = x1 - x0;
        dy = y1 - y0;
        
        var xa:CGFloat, ya:CGFloat, xb:CGFloat, yb:CGFloat;
        xa = x1 + CGFloat(fraction)/2 * dy;
        ya = y1 - CGFloat(fraction)/2 * dx;
        xb = x1 - CGFloat(fraction)/2 * dy;
        yb = y1 + CGFloat(fraction)/2 * dx;
        
        return LineSegment.init(firstPoint: CGPoint.init(x: xa, y: ya), secondPoint: CGPoint.init(x: xb, y: yb))
    }
    
    func len_sq(p1: CGPoint, p2: CGPoint) -> Float {
        let dx: Float = Float(p2.x) - Float(p1.x)
        let dy: Float = Float(p2.y) - Float(p1.y)
        return dx * dx + dy * dy
    }
    
    func clamp(value: Float, lower: Float, higher: Float) -> Float {
        if value < lower { return lower }
        if value > higher { return higher }
        return value
    }
}
