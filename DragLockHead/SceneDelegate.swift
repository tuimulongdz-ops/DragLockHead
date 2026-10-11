import UIKit
import SwiftUI

class SceneDelegate:
    UIResponder,
    UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let ws = scene as? UIWindowScene
        else { return }

        let w = UIWindow(windowScene: ws)
        w.rootViewController = UIHostingController(
            rootView: MenuView()
        )
        w.backgroundColor = .black
        self.window = w
        w.makeKeyAndVisible()
    }
}
