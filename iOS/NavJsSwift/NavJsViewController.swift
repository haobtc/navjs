//
//  NavJsViewController.swift
//  
//
//  Created by ZengKe on 16/3/15.
//
//

import UIKit

class BridgeParams {
    var dict = [String: [String]]()
    
    func add(key: String, value: String) {
        if self.dict[key] != nil {
            self.dict[key]!.append(value)
        } else {
            self.dict[key] = [value]
        }
    }
    
    func get(key: String) -> String? {
        if self.dict[key] != nil {
            return self.dict[key]![0]
        } else {
            return nil
        }
    }
    
    func getList(key: String) -> [String]? {
        return self.dict[key]
    }
}

class NavJsViewController: UIViewController, UIWebViewDelegate {

    var url: NSURL?
    var isPresent: Bool = false
    var contentWebView: UIWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if self.isPresent {
            let dismissButton = UIBarButtonItem(title: "Dismiss", style: .Plain, target: self, action: "dismiss")
            self.navigationItem.rightBarButtonItem = dismissButton
        }
        
        // Do any additional setup after loading the view.
        self.loadUrl()
    }
    
    deinit {
        if self.contentWebView != nil {
            self.contentWebView?.delegate = nil
            self.contentWebView = nil
        }
    }
    
    func dismiss() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func loadView() {
        super.loadView()
        self.view.autoresizesSubviews = true
        
        //self.contentWebView = UIWebView(frame: CGRectMake(20, 20, self.view.frame.width-40, self.view.frame.height-200))
        self.contentWebView = UIWebView(frame: self.view.bounds)
        //iew = UIWebView(frame: CGRectMake(20, 20, self.view.frame.width-40, self.view.frame.height-200))
        //self.contentWebView.layer.borderColor = UIColor.redColor().CGColor
        self.contentWebView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        self.contentWebView.delegate = self
        //self.contentWebView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(self.contentWebView)
    }
    
    func setURL(asset: String, ofType: String) {
        let path = NSBundle.mainBundle().pathForResource(asset, ofType: ofType)
        self.url = NSURL(string: path!)
    }
    
    func loadUrl() {
        if self.url != nil {
            let req = NSURLRequest(URL:self.url!)
            self.contentWebView.loadRequest(req)
        }
    }
    
    func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        //if navigationType == .LinkClicked {
        if true {
            let url = request.URL!
            print("url \(url)")
            if url.scheme == "navjs" {
                //var query = Dictionary<String, [String]>()
                let params = BridgeParams()
                
                for pair in (url.query?.componentsSeparatedByString("&"))! {
                    let p = [String](pair.componentsSeparatedByString("="))
                    
                    let k = p[0]
                    let v = p[1].stringByRemovingPercentEncoding!
                    params.add(k, value: v)
                }
                let cmds = url.pathComponents!
                //print("request query \(params), commands \(cmds)");
                if cmds.count >= 2 {
                    if cmds[1] == "url" && cmds[2] == "open" {

                        if let u = params.get("href") {
                            let url = NSURL(string: u)
                            if let vc = self.nextViewController(url!, params: params) {
                                if let navjsVc = vc as? NavJsViewController {
                                    navjsVc.url = url!
                                    if params.get("trans") == "present" {
                                        navjsVc.isPresent = true
                                    }
                                }
                                switch (params.get("trans") ?? "push") {
                                case "present":
                                    let nav = UINavigationController()
                                    nav.pushViewController(vc, animated: true)
                                    self.navigationController?.presentViewController(nav, animated: true, completion: nil)
                                default:
                                    self.navigationController?.pushViewController(vc, animated: true)
                                }
                            } else {
                                print("cannot detect next navjs controller")
                            }
                        }
                    } else if cmds[1] == "console" && cmds[2] == "log" {
                        print("navjs: \(params.get("msg"))")
                    } else if cmds[1] == "event" {
                        self.onEvent(cmds[2], params: params)
                    }
                }
                return false
            }
        }
        return true
    }
    
    func webViewDidFinishLoad(webView: UIWebView) {
        let theTitle = webView.stringByEvaluatingJavaScriptFromString("document.title")
        if theTitle != nil && theTitle != "" {
            self.title = theTitle
        }
        
        let path = NSBundle.mainBundle().pathForResource("navjs_bootstrap", ofType: "js")
        do {
            let data = try String(contentsOfFile: path!, encoding: NSUTF8StringEncoding)
            if data != "" {
                webView.stringByEvaluatingJavaScriptFromString(data)
            }
        } catch {
            print(error)
        }
    }
    
    func sendEvent(name: String, kwargs: [String: [String]]) {
        do {
            var ds = "navjs.dispatch('" + name + "', "
            let data = try NSJSONSerialization.dataWithJSONObject(kwargs, options: .PrettyPrinted)
            ds += String(data: data, encoding:NSUTF8StringEncoding) ?? "{}"
            ds += ")"
            //print("ds is \(ds)")
            self.contentWebView.stringByEvaluatingJavaScriptFromString(ds)
            //print("return \(r)")
        } catch {
            print(error)
        }
    }
    
    // Overridable methods
    func nextViewController(url: NSURL, params:BridgeParams) -> UIViewController? {
        return NavJsViewController(nibName: "NavJsViewController", bundle: nil)
    }

    func onEvent(name: String, params: BridgeParams) {
        if name == "menu.open" {
            self.showActionSheet(params.get("title"),
                                 message: params.get("message"),
                                 cancel: params.get("cancel"),
                                 seq: params.get("sequence"),
                                 actions: (params.getList("actions") ?? []))
        }
    }
    
    // Event Handlers
    
    // Show action sheet according to event
    func showActionSheet(title:String?, message:String?, cancel: String?, seq: String?, actions:[String]) {
        let actionSheet = UIAlertController(title: title, message: message, preferredStyle: .ActionSheet)
        actionSheet.modalPresentationStyle = .Popover
        
        if cancel != nil {
            let act = UIAlertAction(title:cancel, style: .Cancel) { action -> Void in
                self.sendEvent("menu.clicked", kwargs: ["cancel": [cancel!], "sequence": [seq ?? ""]])
            }
            actionSheet.addAction(act)
        }
        
        
        for (index, actionText) in actions.enumerate() {
            let act = UIAlertAction(title:actionText, style: .Default) { action -> Void in
                let t = action.title!
                self.sendEvent("menu.clicked", kwargs: ["title": [t], "index": [String(index)], "sequence": [seq ?? ""]])
            }
            actionSheet.addAction(act)
        }
        if let popoverController = actionSheet.popoverPresentationController {
            popoverController.sourceView = self.view;
            popoverController.sourceRect = CGRectMake(20, 20, self.view.bounds.width - 40, self.view.bounds.height-40) //self.view.bounds;
            //popoverController.sourceRect = self.contentWebView.bounds;
        }
        self.presentViewController(actionSheet, animated: true, completion: nil)
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
