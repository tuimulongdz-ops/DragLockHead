import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(_ scene: UIScene,
               willConnectTo session: UISceneSession,
               options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        let w = UIWindow(windowScene: windowScene)
        w.rootViewController = ViewController()
        w.backgroundColor = .black
        self.window = w
        w.makeKeyAndVisible()

        if #available(iOS 15.0, *) {
            windowScene.preferredFrameRateRange =
                CAFrameRateRange(minimum: 60, maximum: 120, preferred: 120)
        }
    }
}
