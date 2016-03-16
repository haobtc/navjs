//
//  NavJsViewController.swift
//  
//
//  Created by ZengKe on 16/3/15.
//
//

import UIKit

class NavJsViewController: UIViewController, UIWebViewDelegate {

    var url: NSURL?
    var contentWebView: UIWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.loadUrl()
    }
    deinit {
        if self.contentWebView != nil {
            self.contentWebView?.delegate = nil
            self.contentWebView = nil
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func loadView() {
        super.loadView()
        self.contentWebView = UIWebView()
        self.contentWebView.backgroundColor = UIColor.whiteColor()
        self.contentWebView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight, .FlexibleBottomMargin, .FlexibleRightMargin]
        self.contentWebView.delegate = self
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
            //print("url \(url)")
            if url.scheme == "navjs" {
                var query = Dictionary<String, [String]>()
                for pair in (url.query?.componentsSeparatedByString("&"))! {
                    let p = [String](pair.componentsSeparatedByString("="))
                    
                    let k = p[0]
                    url.pathComponents
                    let v = p[1].stringByRemovingPercentEncoding!
                    query[k]?.append(v)
                    if query[k] != nil {
                        query[k]!.append(v)
                    } else {
                        query[k] = [v]
                    }
                }
                let cmds = url.pathComponents!
                //print("request query \(query), commands \(cmds)");
                if cmds.count >= 2 {
                    if cmds[1] == "url" && cmds[2] == "open" {
                        let url = NSURL(string: query["u"]![0])
                        if let vc = self.nextNavJsViewController(url!) {
                            vc.url = url
                            self.navigationController?.pushViewController(vc, animated: true)
                        } else {
                            print("cannot detect next navjs controller")
                        }
                    } else if cmds[1] == "console" && cmds[2] == "log" {
                        print("navjs: \(query["msg"]![0])")
                    } else if cmds[1] == "event" {
                        self.onEvent(cmds[2], kwargs: query)
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
    func nextNavJsViewController(url: NSURL) -> NavJsViewController? {
        return NavJsViewController(nibName: "NavJsViewController", bundle: nil)
    }

    func onEvent(name: String, kwargs: [String: [String]]) {
        // do Nothing
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
