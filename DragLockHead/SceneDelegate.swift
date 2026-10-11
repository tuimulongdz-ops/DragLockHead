// Quản lý cửa sổ chính
import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    func scene(_ scene: UIScene,
               willConnectTo session: UISceneSession,
               options connectionOptions: UIScene.ConnectionOptions) {
        guard let ws = (scene as? UIWindowScene) else { return }
        let w = UIWindow(windowScene: ws)
        w.rootViewController = ViewController()
        w.backgroundColor = .black
        self.window = w
        w.makeKeyAndVisible()
        if #available(iOS 15.0, *) {
            ws.preferredFrameRateRange =
                CAFrameRateRange(minimum: 60, maximum: 120, preferred: 120)
        }
    }
}
