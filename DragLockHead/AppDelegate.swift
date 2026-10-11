import UIKit
import SwiftUI

@main
class AppDelegate:
    UIResponder,
    UIApplicationDelegate {

    var window: UIWindow?

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions:
            [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {

        UIApplication.shared.isIdleTimerDisabled = true

        let w = UIWindow(
            frame: UIScreen.main.bounds
        )
        w.rootViewController = UIHostingController(
            rootView: MenuView()
        )
        w.backgroundColor = .black
        self.window = w
        w.makeKeyAndVisible()

        return true
    }
}
