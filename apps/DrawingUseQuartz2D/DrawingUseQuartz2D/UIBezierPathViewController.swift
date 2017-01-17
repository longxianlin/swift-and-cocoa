

import UIKit

class UIBezierPathViewController: UIViewController, UIScrollViewDelegate {
    
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

fileprivate class Canvas: UIView {
    
    var path: UIBezierPath = {
        let path = UIBezierPath()
        path.lineWidth = 2.0
        path.lineCapStyle = .round
        return path
    }()
    var incrementalImage: UIImage?
    // to keep track of the four points of our Bezier segment
    var pts: [CGPoint] = Array.init(repeating: CGPoint.zero, count: 5)
    var ctr: Int = 0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.isMultipleTouchEnabled = false
        self.backgroundColor = UIColor.white
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        autoreleasepool {
            incrementalImage?.draw(in: rect)
            path.stroke()
        }
    }
    
    fileprivate override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        ctr = 0
        if let touch = touches.first {
            let point = touch.location(in: touch.view)
            pts[0] = point
        }
    }
    
    fileprivate override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        ctr += 1
        if let touch = touches.first {
            let point = touch.location(in: touch.view)
            pts[ctr] = point
            if (ctr == 4) // 5th point
            {
                pts[3] = CGPoint(x: (pts[2].x + pts[4].x)/2.0, y: (pts[2].y + pts[4].y)/2.0)
                    
                // move the endpoint to the middle of the line joining the second control point of the first Bezier segment and the first control point of the second Bezier segment
                path.move(to: pts[0])
                path.addCurve(to: pts[3], controlPoint1: pts[1], controlPoint2: pts[2])

                // add a cubic Bezier from pt[0] to pt[3], with control points pt[1] and pt[2]
                
                self.setNeedsDisplay()
                // replace points and get ready to handle the next segment
                pts[0] = pts[3]
                pts[1] = pts[4]
                ctr = 1
            }
        }

    }
    
    fileprivate override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.drawBitmap()
        self.setNeedsDisplay()
        path.removeAllPoints()
        ctr = 0
    }
    
    fileprivate override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.touchesEnded(touches, with: event)
    }
    
    func drawBitmap() {
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, true, 0.0)
        UIColor.black.setStroke()
        if incrementalImage == nil {
            let rectpath = UIBezierPath(rect: self.bounds)
            UIColor.white.setFill()
            rectpath.fill()
        }
        incrementalImage?.draw(at: CGPoint.zero)
        path.stroke()
        incrementalImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
    }
}
