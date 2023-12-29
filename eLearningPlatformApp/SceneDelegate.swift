import UIKit
import Turbo
import WebKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    
    private let navigationController = UINavigationController()
    private lazy var session: Session = {
        let configuration = WKWebViewConfiguration()
        configuration.applicationNameForUserAgent = "Turbo Native iOS"
        
        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.uiDelegate = self
        
        let session = Session(webView: webView)
        session.delegate = self
        return session
    }()

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        self.window = UIWindow(windowScene: windowScene)
        self.window?.rootViewController = navigationController
        self.window?.makeKeyAndVisible()
        
        visit()
    }
    
    private func visit() {
        let url = URL(string: "http://127.0.0.1:3000")!
        let controller = VisitableViewController(url: url)
        session.visit(controller, action: .advance)
        navigationController.pushViewController(controller, animated: true)
    }
}


extension SceneDelegate: SessionDelegate {
    func session(_ session: Turbo.Session, didProposeVisit proposal: Turbo.VisitProposal) {
        let controller = VisitableViewController(url: proposal.url)
        session.visit(controller, options: proposal.options)
        navigationController.pushViewController(controller, animated: true)
    }
    
    func session(_ session: Turbo.Session, didFailRequestForVisitable visitable: Turbo.Visitable, error: Error) {
        print("Failed to load visitable: \(error.localizedDescription)")
    }
    
    func sessionWebViewProcessDidTerminate(_ session: Turbo.Session) {
        //
    }
}

extension SceneDelegate: WKUIDelegate {
    func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (Bool) -> Void) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Confirm", style: .destructive) { _ in
            completionHandler(true)
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { _ in
            completionHandler(false)
        })
        navigationController.present(alert, animated: true)
    }
}
