import UIKit

class MainTabViewController: UITabBarController {

    let homeController: HomeViewController = {
        let layout = UICollectionViewFlowLayout()
        let vc = HomeViewController(collectionViewLayout: layout)
        vc.tabBarItem = UITabBarItem(title: "홈", image: UIImage(named: "home"), tag: 1)
        return vc
    }()
    
    let trendingController: UIViewController = {
        let vc = UIViewController()
        vc.tabBarItem = UITabBarItem(title: "인기", image: UIImage(named: "trending"), tag: 2)
        vc.view.backgroundColor = UIColor.blue
        return vc
    }()
    
    let subscriptionController: UIViewController = {
        let vc = UIViewController()
        vc.tabBarItem = UITabBarItem(title: "구독", image: UIImage(named: "subscriptions"), tag: 3)
        vc.view.backgroundColor = UIColor.brown
        return vc
    }()
    
    let libraryController: UIViewController = {
        let vc = UIViewController()
        vc.tabBarItem = UITabBarItem(title: "라이브러리", image: UIImage(named: "account"), tag: 4)
        vc.view.backgroundColor = UIColor.purple
        return vc
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tabBar.tintColor = UIColor.red
        tabBar.barStyle = .default
        tabBar.isTranslucent = false
        tabBar.barTintColor = UIColor.white
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        prepareNaivationBar()
        prepareNavigationItem()
        viewControllers = [homeController, trendingController, subscriptionController, libraryController]
    }
    
    func handleSearch() {
        
    }
    
    func handleCamera() {
        
    }
    
    func handleProfile() {
        
    }
    
    private func prepareNaivationBar() {
        
        guard let navigationBar = navigationController?.navigationBar else {
            return
            
        }
        navigationBar.isTranslucent = false
        let titleLabel = UILabel(frame: navigationBar.bounds)
        titleLabel.text = "  \(title ?? "Youbute")"
        titleLabel.textColor = UIColor.white
        titleLabel.font = UIFont.systemFont(ofSize: 18)
        navigationItem.titleView = titleLabel
    }
    
    private func prepareNavigationItem() {
        let searchButtonItem = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(handleSearch))
        searchButtonItem.tintColor = UIColor.white
        let cameraButtonItem = UIBarButtonItem(barButtonSystemItem: .camera, target: self, action: #selector(handleCamera))
        cameraButtonItem.tintColor = UIColor.white
        
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 25, height: 25))
        label.text = "훈희"
        label.textColor = UIColor.white
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 10)
        label.backgroundColor = UIColor(red: 1.0, green: 0.44, blue: 0.597, alpha: 1.0)
        label.layer.cornerRadius = 25/2
        label.layer.masksToBounds = true
        
        let profileButtonItem = UIBarButtonItem(customView: label)
        navigationItem.rightBarButtonItems = [profileButtonItem, searchButtonItem, cameraButtonItem]
    }
    
    
}
