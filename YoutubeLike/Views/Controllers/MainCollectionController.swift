import UIKit

class MainCollectionController: UICollectionViewController, UICollectionViewDelegateFlowLayout {

    lazy var menuBar: MenuBar = {
        let bar = MenuBar()
        bar.delegate = self
        return bar
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Home"
        
        prepareNaivationBar()
        prepareNavigationItem()
        prepareMenuBar()
        prepareCollectionView()
    }
    
    private func prepareNaivationBar() {
        
        guard let navigationBar = navigationController?.navigationBar else {
            return
        
        }
        navigationBar.isTranslucent = false
        
        let titleLabel = UILabel(frame: navigationBar.bounds)
        titleLabel.text = self.title
        titleLabel.textColor = UIColor.white
        navigationItem.titleView = titleLabel
    }
    
    private func prepareNavigationItem() {
        let searchButtomItem = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(handleSearch))
        searchButtomItem.tintColor = UIColor.white
        let moreButtomItem = UIBarButtonItem(barButtonSystemItem: .bookmarks, target: self, action: #selector(handleMore))
        moreButtomItem.tintColor = UIColor.white
        navigationItem.rightBarButtonItems = [moreButtomItem, searchButtomItem]
    }
    
    private func prepareMenuBar() {
        
        navigationController?.hidesBarsOnSwipe = true
        
        let redView = UIView()
        redView.backgroundColor = UIColor.red
        view.addSubview(redView)
        view.addConstraints(withFormat: "H:|[v0]|", views: redView)
        view.addConstraints(withFormat: "V:[v0(50)]", views: redView)
        
        view.addSubview(menuBar)
        view.addConstraints(withFormat: "H:|[v0]|", views: menuBar)
        view.addConstraints(withFormat: "V:[v0(50)]", views: menuBar)
        
        menuBar.topAnchor.constraint(equalTo: topLayoutGuide.bottomAnchor).isActive = true
    }
    
    private func prepareCollectionView() {
        guard let collectionView = self.collectionView else {
            return
        }
        
        if let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.scrollDirection = .horizontal
        }
        collectionView.register(FeedCell.self, forCellWithReuseIdentifier: "cellId")
        collectionView.register(TrendingCell.self, forCellWithReuseIdentifier: "trendingId")
        collectionView.register(SubscriptionCell.self, forCellWithReuseIdentifier: "subscriptionId")

        collectionView.backgroundColor = UIColor.white
        collectionView.contentInset = UIEdgeInsets(top: 50, left: 0, bottom: 0, right: 0)
        collectionView.scrollIndicatorInsets = UIEdgeInsets(top: 50, left: 0, bottom: 0, right: 0)
        collectionView.isPagingEnabled = true
    }
    
    func handleSearch() {
        scrollToMenuIndex(menuIndex: 2)
    }
    
    func handleMore() {
        print("##### more")
    }
    
    func scrollToMenuIndex(menuIndex: Int) {
        let indexPath = IndexPath(row: menuIndex, section: 0)
        collectionView?.scrollToItem(at: indexPath, at: .left, animated: true)
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        menuBar.horizontalBarLeftAnchorConstraint?.constant = scrollView.contentOffset.x/4
    }
    
    override func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        
        let index = Int(targetContentOffset.pointee.x / view.frame.width)
        let indexPath = IndexPath(row: index, section: 0)
        menuBar.collectionView.selectItem(at: indexPath, animated: true, scrollPosition: .left)
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 4
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        var identifier: String = "cellId"
        if indexPath.row == 1 {
            identifier = "trendingId"
        } else if indexPath.row == 2 {
            identifier = "subscriptionId"
        }
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath) as! FeedCell
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: view.frame.height - 50)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}

extension MainCollectionController: MenuBarDelegate {
    func didSelectedMenuIndex(index: Int) {
        scrollToMenuIndex(menuIndex: index)
    }
}
