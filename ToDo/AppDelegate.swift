import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
       var appCoordinator : AppCoordinator?
       
       func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

           window = UIWindow(frame: UIScreen.main.bounds)
           window?.backgroundColor = .white

           let navigationContoller = UINavigationController.init()
           appCoordinator = AppCoordinator(navigationController: navigationContoller)
           appCoordinator!.start()

           window?.rootViewController = navigationContoller
           window?.makeKeyAndVisible()
           window?.overrideUserInterfaceStyle = .light

           return true
       }
   }
