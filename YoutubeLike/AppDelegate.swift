import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

        let layout = UICollectionViewFlowLayout()
        //let navigationController = UINavigationController(rootViewController: HomeCollectionController(collectionViewLayout: layout))
//        let navigationController = UINavigationController(rootViewController: HomeViewController(collectionViewLayout: layout))
        //let navigationController = UINavigationController(rootViewController: HomeViewController(collectionViewLayout: layout))
        let navigationController = UINavigationController(rootViewController: MainTabViewController())
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
        
        UINavigationBar.appearance().barTintColor = UIColor.red
        UINavigationBar.appearance().shadowImage = UIImage()
        UINavigationBar.appearance().setBackgroundImage(UIImage(), for: .default)
        
        UIApplication.shared.statusBarStyle = .lightContent
        //UIApplication.shared.statusBarView?.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.15)
        UIApplication.shared.statusBarView?.backgroundColor = UIColor.red
        
        return true
    }
}

