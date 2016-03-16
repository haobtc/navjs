//
//  DemoNavJsViewController.swift
//  NavJsSwiftDemo
//
//  Created by ZengKe on 16/3/16.
//  Copyright © 2016年 Haobtc. All rights reserved.
//

import UIKit

class DemoNavJsViewController: NavJsViewController {

    override func viewDidLoad() {
        if self.url == nil {
            self.setURL("index", ofType: "html")
        }
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func nextNavJsViewController(url: NSURL) -> NavJsViewController? {
        return DemoNavJsViewController(nibName: "DemoNavJsViewController", bundle: nil)
    }

    override func onEvent(name: String, kwargs: [String: [String]]) {
        super.onEvent(name, kwargs: kwargs)
        if name == "hello" {
            self.sendEvent("hello", kwargs: ["text": ["waka"], "mike": ["niike"]])
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
