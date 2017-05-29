import UIKit

open class RootController: UIViewController {

    fileprivate var rootViewController: UIViewController!
    let dimView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 0, alpha: 1)
        return view
    }()
    
    let launchView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.clear
        view.clipsToBounds = true
        return view
    }()
    
    lazy var videoPlayerView: VideoPlayerView = {
        let player = VideoPlayerView()
        player.delegate = self
        return player
    }()
    
    lazy var collectionView: UICollectionView = {
        let cv = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        cv.dataSource = self
        cv.delegate = self
        cv.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        cv.backgroundColor = UIColor.white
        return cv
    }()
    
    let playerAnimationDuration: Double = 0.3
    var palyerLayoutType: Int = 0
    var dragBeganPoint: CGPoint = .zero
    var videos: [Video] = []
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        prepare()
    }
    
    public init(rootViewController: UIViewController) {
        super.init(nibName: nil, bundle: nil)
        self.rootViewController = rootViewController
        prepare()
    }
    
    open func prepare() {
        view.clipsToBounds = true
        view.backgroundColor = .white
        view.contentScaleFactor = UIScreen.main.scale
        prepareRootViewController()
    }
}

extension RootController {
    internal func prepareRootViewController() {
        prepare(viewController: rootViewController, withContainer: view)
    }
    
    internal func prepare(viewController: UIViewController?, withContainer container: UIView) {
        guard let v = viewController else {
            return
        }
        
        addChildViewController(v)
        container.addSubview(v.view)
        
        v.didMove(toParentViewController: self)
        v.view.frame = container.bounds
        v.view.clipsToBounds = true
        v.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        v.view.contentScaleFactor = UIScreen.main.scale
        
        dimView.frame = view.frame
        dimView.isHidden = true
        view.addSubview(dimView)
    }
}

extension RootController {
    internal func showPlayerView() {
        setupPlayerView()
        showAnimation()
    }
    
    private func setupPlayerView() {
        
        dimView.isHidden = false
        
        launchView.frame = view.frame
        launchView.addSubview(videoPlayerView)
        launchView.addSubview(collectionView)

        let playerHeight = launchView.frame.width * 9 / 16
        videoPlayerView.frame = CGRect(x: 0, y: 0, width: launchView.frame.width, height: playerHeight)
        collectionView.frame = CGRect(x: 0, y: playerHeight, width: launchView.frame.width, height: launchView.frame.height - playerHeight)
        view.addSubview(launchView)
        
        let miniWidth: CGFloat = 200
        let miniHeight: CGFloat = miniWidth * 9 / 16
        launchView.frame = CGRect(x: view.frame.width - miniWidth, y: view.frame.height - (miniHeight + 44), width: miniWidth, height: miniHeight)
        
        
        let gesture = UIPanGestureRecognizer(target: self, action: #selector(handleSwipe(sender:)))
        launchView.addGestureRecognizer(gesture)
    }
    
    private func showAnimation() {
        UIView.animate(withDuration: playerAnimationDuration, delay: 0, options: .curveEaseInOut, animations: {
            self.launchView.frame = self.view.frame
            if let statusbar = UIApplication.shared.statusBarView {
                statusbar.alpha = 0
            }
        }) { ending in
            self.fetchVideos()
        }
    }
    
    private func fetchVideos() {
        ApiService.shared.fetchSubscriptions { videos in
            self.videos = videos
            self.collectionView.reloadData()
        }
    }
    
    func setMinimize() {
        UIView.animate(withDuration: playerAnimationDuration, delay: 0, options: .curveEaseInOut, animations: {
            
            let minimScale: CGFloat = 0.6
            self.dimView.alpha = 0
            self.collectionView.alpha = 0
            let scale = CGAffineTransform(scaleX: minimScale, y: minimScale)
            let tran = CGAffineTransform(translationX: 75, y: 357)
            self.launchView.transform = scale.concatenating(tran)
            
            if let statusbar = UIApplication.shared.statusBarView {
                statusbar.alpha = 1
            }
            
        }) { ending in
            self.dimView.isHidden = true
            self.palyerLayoutType = 1
        }
    }
    
    func setMaximize() {
        //if palyerLayoutType == 1 {
            print("##### full")
            self.dimView.isHidden = false
            UIView.animate(withDuration: playerAnimationDuration, delay: 0, options: .curveEaseInOut, animations: {
                self.dimView.alpha = 1
                self.collectionView.alpha = 1
                let scale = CGAffineTransform(scaleX: 1, y: 1)
                let translation = CGAffineTransform(translationX: 0, y: 0)
                self.launchView.transform = scale.concatenating(translation)
                
                if let statusbar = UIApplication.shared.statusBarView {
                    statusbar.alpha = 0
                }
            }) { ending in
                self.palyerLayoutType = 0
            }
        //}
    }
    
    func handleSwipe(sender: UIPanGestureRecognizer) {
     
        let point = sender.translation(in: nil)
        let velocity = sender.velocity(in: nil)
        
        if sender.state == .ended && (abs(velocity.x) < abs(velocity.y)) {
            let scale = UIScreen.main.bounds.height / point.y
            if abs(velocity.y) > 100 || scale < 6 {
                setMinimize()
            } else {
                setMaximize()
            }
        }
        
        if point.y >= 0 {
            let factor = (abs(sender.translation(in: nil).y) / UIScreen.main.bounds.height)
            var scaleFactor = 1 - factor
            if scaleFactor < 0.7 {
                scaleFactor = 0.7
            }
            let scale = CGAffineTransform(scaleX: scaleFactor, y: scaleFactor)
            
            var translationX = (launchView.bounds.width * factor)-1
            var translationY = (launchView.bounds.width * factor)-1
            if translationX > 30 {
                translationX = 30
            }
            
            if translationY / translationX > 1.6 {
                translationY = 50
            }
            
            
            let translation = CGAffineTransform(translationX: translationX, y: (launchView.bounds.height * factor)-1)
            let transform = scale.concatenating(translation)
            launchView.transform = transform
            dimView.alpha = 1 - (factor * 4)
            collectionView.alpha = 1 - (factor * 4)
            
            if let statusbar = UIApplication.shared.statusBarView {
                statusbar.alpha = (factor * 6) - 1
            }
        }
    }
}

extension RootController: UICollectionViewDataSource {
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return videos.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        cell.backgroundColor = UIColor.blue
        return cell
    }
}

extension RootController: UICollectionViewDelegateFlowLayout {
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.bounds.width, height: 200)
    }
}

extension RootController: VideoPalyerLayoutDelegate {
    func minimize() {
        setMinimize()
    }
    
    func maximize() {
        setMaximize()
    }
}
