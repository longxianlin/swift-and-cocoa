

import UIKit

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    let titles = [
        "CGContext",
        "UIBezierPath",
        "UIBezierPath Pro",
        "UIBezierPath Pen Brush"
    ]
    
    var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Quartz 2D 绘图"
        // Do any additional setup after loading the view, typically from a nib.
        tableView = UITableView(frame: self.view.frame, style: .plain)
        tableView.dataSource = self
        tableView.delegate = self
        self.view.addSubview(self.tableView)

    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return titles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        let title = titles[indexPath.row]
        cell.textLabel?.text = title
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        switch indexPath.row {
        case 0:
            let vc = CGContextViewController()
            self.navigationController?.pushViewController(vc, animated: true)
        case 1:
            let vc = UIBezierPathViewController()
            self.navigationController?.pushViewController(vc, animated: true)
        case 2:
            let vc = UIBezierPathProViewController()
            self.navigationController?.pushViewController(vc, animated: true)
        case 3:
            let vc = UIBezierPathPenViewController()
            self.navigationController?.pushViewController(vc, animated: true)
        default: break
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

