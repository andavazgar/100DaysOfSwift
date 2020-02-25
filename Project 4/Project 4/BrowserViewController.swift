//
//  ViewController.swift
//  Project 4
//
//  Created by Andres Vazquez on 2019-12-11.
//  Copyright © 2019 Andavazgar. All rights reserved.
//

import UIKit
import WebKit

class BrowserViewController: UIViewController, WKNavigationDelegate {
    
    var webview: WKWebView!
    var progressView: UIProgressView!
    var websites = [String]()
    var chosenWebsite: String?
    
    override func loadView() {
        webview = WKWebView()
        webview.navigationDelegate = self
        view = webview
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupToolbarItems()
        loadWebsite()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Open", style: .plain, target: self, action: #selector(openTapped))
    }
    
    deinit {
        webview.removeObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress))
    }
    
    @objc private func openTapped() {
        let alertVC = UIAlertController(title: "Open...", message: nil, preferredStyle: .actionSheet)
        
        for website in websites {
            alertVC.addAction(UIAlertAction(title: website, style: .default, handler: openPage))
        }
        
        alertVC.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        alertVC.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
        
        present(alertVC, animated: true)
    }
    
    private func openPage(action: UIAlertAction) {
        guard let actionTitle = action.title, let url = URL(string: "https://" + actionTitle) else { return }
        webview.load(URLRequest(url: url))
    }
    
    private func setupToolbarItems() {
        progressView = UIProgressView(progressViewStyle: .default)
        progressView.sizeToFit()
        let progressBar = UIBarButtonItem(customView: progressView)
        
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let backBtn = UIBarButtonItem(barButtonSystemItem: .rewind, target: webview, action: #selector(webview.goBack))
        let forwardBtn = UIBarButtonItem(barButtonSystemItem: .fastForward, target: webview, action: #selector(webview.goForward))
        let refreshBtn = UIBarButtonItem(barButtonSystemItem: .refresh, target: webview, action: #selector(webview.reload))
        
        toolbarItems = [progressBar, flexibleSpace, backBtn, forwardBtn, flexibleSpace, refreshBtn]
        navigationController?.isToolbarHidden = false
        
        webview.addObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress), options: .new, context: nil)
    }
    
    private func loadWebsite() {
        if let chosenWebsite = chosenWebsite {
            let url = URL(string: "https://" + chosenWebsite)!
            webview.load(URLRequest(url: url))
            webview.allowsBackForwardNavigationGestures = true
        }
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "estimatedProgress" {
            progressView.progress = Float(webview.estimatedProgress)
        }
    }
}


// MARK: - WKNavigationDelegate methods

extension BrowserViewController {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        title = webview.title
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if let host = navigationAction.request.url?.host {
            for website in websites {
                if host.contains(website) {
                    decisionHandler(.allow)
                    return
                }
            }
        }
        
        let alertVC = UIAlertController(title: "Blocked Website", message: "The website you tried to reach is not in the list of allowed websites.", preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        present(alertVC, animated: true) {
            decisionHandler(.cancel)
        }
    }
}

