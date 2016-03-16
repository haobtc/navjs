//
//  NavJsContainerViewController.swift
//  
//
//  Created by ZengKe on 16/3/15.
//
//

import UIKit

class NavJsContainerViewController: UIViewController, UIWebViewDelegate {

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
                var query = Dictionary<String, String>()
                for pair in (url.query?.componentsSeparatedByString("&"))! {
                    let p = [String](pair.componentsSeparatedByString("="))
                    
                    let k = p[0]
                    url.pathComponents
                    let v = p[1].stringByRemovingPercentEncoding!
                    query[k] = v
                }
                let cmds = url.pathComponents!
                print("request query \(query), commands \(cmds)");
                if cmds.count >= 2 {
                    if cmds[1] == "url" && cmds[2] == "open" {
                    // open url in navigator
                        let vc = NavJsContainerViewController(nibName: "NavJsContainerViewController", bundle: nil)
                        vc.url = NSURL(string: query["u"]!)
                        self.navigationController?.pushViewController(vc, animated: true)
                    } else if cmds[1] == "console" && cmds[2] == "log" {
                        print("navjs: \(query["msg"]!)");
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
        
        let path = NSBundle.mainBundle().pathForResource("start", ofType: "js")
        do {
            let data = try String(contentsOfFile: path!, encoding: NSUTF8StringEncoding)
            //print("start.js data \(data)")
            if data != "" {
                webView.stringByEvaluatingJavaScriptFromString(data)
            }
        } catch {
            print(error)
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
