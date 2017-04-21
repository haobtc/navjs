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
    
    func add(_ key: String, value: String) {
        if self.dict[key] != nil {
            self.dict[key]!.append(value)
        } else {
            self.dict[key] = [value]
        }
    }
    
    func get(_ key: String) -> String? {
        if self.dict[key] != nil {
            return self.dict[key]![0]
        } else {
            return nil
        }
    }
    
    func getList(_ key: String) -> [String]? {
        return self.dict[key]
    }
}

class NavJsViewController: UIViewController, UIWebViewDelegate {

    var url: URL?
    var isPresent: Bool = false
    var contentWebView: UIWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if self.isPresent {
            let dismissButton = UIBarButtonItem(title: "Dismiss", style: .plain, target: self, action: #selector(NavJsViewController.dismiss as (NavJsViewController) -> () -> ()))
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
        self.dismiss(animated: true, completion: nil)
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
        self.contentWebView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.contentWebView.delegate = self
        //self.contentWebView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(self.contentWebView)
    }
    
    func setURL(_ asset: String, ofType: String) {
        let path = Bundle.main.path(forResource: asset, ofType: ofType)
        self.url = URL(string: path!)
    }
    
    func loadUrl() {
        if self.url != nil {
            let req = URLRequest(url:self.url!)
            self.contentWebView.loadRequest(req)
        }
    }
    
    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        //if navigationType == .LinkClicked {
        if true {
            let url = request.url!
            print("url \(url)")
            if url.scheme == "navjs" {
                //var query = Dictionary<String, [String]>()
                let params = BridgeParams()
                
                for pair in (url.query?.components(separatedBy: "&"))! {
                    let p = [String](pair.components(separatedBy: "="))
                    
                    let k = p[0]
                    //let v = p[1].stringByRemovingPercentEncoding!
                    //let v = p[1].stringByRemovingPercentEncoding()
                    let v = p[1].removingPercentEncoding
                    params.add(k, value: v!)
                }
                //let cmds = url.pathComponents!
                let cmds = url.pathComponents
                //print("request query \(params), commands \(cmds)");
                if cmds.count >= 2 {
                    if cmds[1] == "url" && cmds[2] == "open" {

                        if let u = params.get("href") {
                            let url = URL(string: u)
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
                                    self.navigationController?.present(nav, animated: true, completion: nil)
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
                    } else if cmds[1] == "call" {
                        self.onCall(cmds[2], callId: cmds[3], params: params)
                    }
                }
                return false
            }
        }
        return true
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        let theTitle = webView.stringByEvaluatingJavaScript(from: "document.title")
        if theTitle != nil && theTitle != "" {
            self.title = theTitle
        }
        
        let path = Bundle.main.path(forResource: "navjs_bootstrap", ofType: "js")
        do {
            let data = try String(contentsOfFile: path!, encoding: String.Encoding.utf8)
            if data != "" {
                webView.stringByEvaluatingJavaScript(from: data)
            }
        } catch {
            print(error)
        }
    }
    
    func sendEvent(_ name: String, kwargs: [String: [String]]) {
        do {
            var ds = "navjs.dispatch('" + name + "', "
            let data = try JSONSerialization.data(withJSONObject: kwargs, options: .prettyPrinted)
            ds += String(data: data, encoding:String.Encoding.utf8) ?? "{}"
            ds += ")"
            //print("ds is \(ds)")
            self.contentWebView.stringByEvaluatingJavaScript(from: ds)
            //print("return \(r)")
        } catch {
            print(error)
        }
    }
    
    func callReturn(_ callId: String, result: [String: [String]]) {
        do {
            var ds = "navjs.callReturn('" + callId + "', "
            let data = try JSONSerialization.data(withJSONObject: result, options: .prettyPrinted)
            ds += String(data: data, encoding:String.Encoding.utf8) ?? "{}"
            ds += ")"
            //print("ds is \(ds)")
            self.contentWebView.stringByEvaluatingJavaScript(from: ds)
        } catch {
            print(error)
        }
    }
    
    // Overridable methods
    func nextViewController(_ url: URL, params:BridgeParams) -> UIViewController? {
        return NavJsViewController(nibName: "NavJsViewController", bundle: nil)
    }

    func onEvent(_ name: String, params: BridgeParams) {
        if name == "menu.open" {
            self.showActionSheet(params.get("title"),
                                 message: params.get("message"),
                                 cancel: params.get("cancel"),
                                 seq: params.get("sequence"),
                                 actions: (params.getList("actions") ?? []),
                                 callId: nil)
        }
    }
    
    func onCall(_ name: String, callId: String, params: BridgeParams) {
        if name == "menu.open" {
            self.showActionSheet(params.get("title"),
                message: params.get("message"),
                cancel: params.get("cancel"),
                seq: params.get("sequence"),
                actions: (params.getList("actions") ?? []),
                callId: callId
            )
        }
    }
    
    // Event Handlers
    
    // Show action sheet according to event
    func showActionSheet(_ title:String?, message:String?, cancel: String?, seq: String?, actions:[String], callId:String?) {
        let actionSheet = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
        actionSheet.modalPresentationStyle = .popover
        
        if cancel != nil {
            let act = UIAlertAction(title:cancel, style: .cancel) { action -> Void in
                print("actionsheet cancelled", callId)
                if callId == nil {
                    self.sendEvent("menu.clicked", kwargs: ["cancel": [cancel!], "sequence": [seq ?? ""]])
                } else {
                    self.callReturn(callId!, result: ["cancel": ["true"], "sequence": [seq ?? ""]])
                }
            }
            actionSheet.addAction(act)
        }
        
        for (index, actionText) in actions.enumerated() {
            let act = UIAlertAction(title:actionText, style: .default) { action -> Void in
                let t = action.title!
                if callId == nil {
                    self.sendEvent("menu.clicked", kwargs: ["title": [t], "index": [String(index)], "sequence": [seq ?? ""]])
                } else {
                    self.callReturn(callId!, result: ["title": [t], "index": [String(index)], "sequence": [seq ?? ""]])
                }
            }
            actionSheet.addAction(act)
        }
        if let popoverController = actionSheet.popoverPresentationController {
            popoverController.sourceView = self.view;
            popoverController.sourceRect = CGRect(x: 20, y: 20, width: self.view.bounds.width - 40, height: self.view.bounds.height-40) //self.view.bounds;
            //popoverController.sourceRect = self.contentWebView.bounds;
        }
        self.present(actionSheet, animated: true, completion: nil)
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
