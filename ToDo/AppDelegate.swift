import UIKit

@main

class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    var appCoordinator: AppCoordinatorProtocol?
   
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.backgroundColor = .white
        
        UIBarButtonItem.appearance().tintColor = .black

        let navigationContoller = UINavigationController.init()
        appCoordinator = AppCoordinator(navigationController: navigationContoller)
        appCoordinator?.start()
        
        window?.rootViewController = navigationContoller
        window?.makeKeyAndVisible()
        window?.overrideUserInterfaceStyle = .light
        
        return true
    }
}
