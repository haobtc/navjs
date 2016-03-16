//
//  ViewController.swift
//  NavJsSwiftDemo
//
//  Created by ZengKe on 16/3/15.
//  Copyright © 2016年 Haobtc. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var button: UIButton!
    @IBAction func buttonTapped(_: AnyObject) {
        print("button tapped")
        let c = DemoNavJsViewController(nibName: "DemoNavJsViewController", bundle: nil)
        let path = NSBundle.mainBundle().pathForResource("index", ofType: "html")
        print("path is \(path)")
        c.url = NSURL(string: path!)
        self.navigationController?.pushViewController(c, animated: true)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

