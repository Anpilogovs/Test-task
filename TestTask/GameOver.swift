//
//  GameOver.swift
//  TestTask
//
//  Created by Serhii Anp on 25.08.2024.
//

import Foundation
import UIKit
import WebKit


class GameOver: UIViewController, WKNavigationDelegate {
    
    private let webView: WKWebView = {
        let webView = WKWebView()
        webView.translatesAutoresizingMaskIntoConstraints = false
        return webView
    }()
    
    private let toolbar: UIToolbar = {
        let toolbar = UIToolbar()
        toolbar.translatesAutoresizingMaskIntoConstraints = false
        return toolbar
    }()
    
    private let backButton: UIBarButtonItem = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(systemName: "arrowshape.turn.up.left"), for: .normal)
        button.imageView?.contentMode = .scaleAspectFit
        button.frame.size = CGSize(width: 20, height: 20)
        return UIBarButtonItem(customView: button)
    }()
    
    private let forwardButton: UIBarButtonItem = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(systemName: "arrowshape.turn.up.right"), for: .normal)
        button.imageView?.contentMode = .scaleAspectFit
        button.frame.size = CGSize(width: 20, height: 20)
        return UIBarButtonItem(customView: button)
    }()
    
    private let refreshButton: UIBarButtonItem = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(systemName: "arrow.clockwise"), for: .normal)
        button.imageView?.contentMode = .scaleAspectFit
        button.frame.size = CGSize(width: 20, height: 20)
        button.addTarget(self, action: #selector(refreshWebView), for: .touchUpInside)
        return UIBarButtonItem(customView: button)
    }()
    
    private let exitButton: UIBarButtonItem = {
        let button = UIBarButtonItem(image: UIImage(systemName: "xmark"), style: .plain, target: self, action: #selector(exitGame))
        return button
    }()
    
    var isWinner: Bool = false
    var gameScene: GameScene?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        loadContent()
        setupSubviews()
        setupConstraints()
    }
    
    // MARK: - Configuration Methods
    private func configureView() {
        view.backgroundColor = .white
        webView.navigationDelegate = self
    }
    
    private func setupSubviews() {
        view.addSubview(webView)
        view.addSubview(toolbar)
        
        if let backButtonView = backButton.customView as? UIButton {
            backButtonView.addTarget(self, action: #selector(navigateBack), for: .touchUpInside)
        }
        if let forwardButtonView = forwardButton.customView as? UIButton {
            forwardButtonView.addTarget(self, action: #selector(navigateForward), for: .touchUpInside)
        }
        
        let fixedSpace = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        
        toolbar.items = [backButton, fixedSpace, forwardButton, flexibleSpace, refreshButton, exitButton]
    }
    
    // MARK: - Layout Constraints
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            webView.bottomAnchor.constraint(equalTo: toolbar.topAnchor),
            
            toolbar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            toolbar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            toolbar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    // MARK: - Content Loading
    private func loadContent() {
        DispatchQueue.main.async {
            let urlString = self.isWinner ? GameURLManager.shared.winnerURL : GameURLManager.shared.loserURL
            print("URL to load: \(urlString ?? "None")")
            guard let urlString = urlString, let url = URL(string: urlString) else {
                self.showError()
                return
            }
            self.webView.load(URLRequest(url: url))
        }
    }
    
    @objc private func navigateBack() {
        webView.goBack()
    }
    
    @objc private func navigateForward() {
        webView.goForward()
    }
    
    @objc private func refreshWebView() {
        webView.reload()
    }
    
    @objc private func exitGame() {
        navigationController?.popViewController(animated: true)
        gameScene?.restartGame()
    }
    
    // MARK: - WKNavigationDelegate Methods
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        backButton.isEnabled = webView.canGoBack
        forwardButton.isEnabled = webView.canGoForward
    }

    private func showError() {
        let alert = UIAlertController(title: "Error", message: "Failed to load content.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
