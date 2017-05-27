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
        view.backgroundColor = UIColor.white
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
        cv.backgroundColor = UIColor.clear
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
    
//    open override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        guard let touch = touches.first else {
//            return
//        }
//        
//        dragBeganPoint = touch.location(in: self.view)
//    }
//    
//    open override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
//        guard let touch = touches.first else {
//            return
//        }
//        
//        let frame = launchView.frame
//        let movePoint = touch.location(in: self.view)
//        let factor = dragBeganPoint.y / movePoint.y
//        
//        print("### factor : ", factor)
//        
//        let width = frame.width * factor
//        let height = width * CGFloat(9 / 16)
//        
//        
//        self.launchView.frame = CGRect(x: 30, y: 30, width: 30, height: 30)
//        
////        dimView.alpha = 1 - factor
////        collectionView.alpha = 1 - factor
////        let scale = CGAffineTransform.init(scaleX: (1 - 0.5 * factor), y: (1 - 0.5 * factor))
////        let trasform = scale.concatenating(CGAffineTransform.init(translationX: (frame.width / 4 * factor), y: (frame.height / 4 * factor)))
////        launchView.transform = trasform
//    }
//    
//    open override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
//        //print("######## touchesEnded : ", event)
//    }
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
        print("#########")
        UIView.animate(withDuration: playerAnimationDuration, delay: 0, options: .curveEaseInOut, animations: {
            let miniWidth: CGFloat = 200
            let miniHeight: CGFloat = miniWidth * 9 / 16
            self.dimView.alpha = 0
            self.collectionView.alpha = 0
            self.launchView.frame = CGRect(x: self.view.frame.width - miniWidth, y: self.view.frame.height - (miniHeight + 44), width: miniWidth, height: miniHeight)
            
            if let statusbar = UIApplication.shared.statusBarView {
                statusbar.alpha = 1
            }
            
        }) { ending in
            self.dimView.isHidden = true
            self.palyerLayoutType = 1
            print("self.launchView.frame : ", self.launchView.frame)
        }
    }
    
    func maximize() {
        if palyerLayoutType == 1 {
            self.dimView.isHidden = false
            UIView.animate(withDuration: playerAnimationDuration, delay: 0, options: .curveEaseInOut, animations: {
                self.dimView.alpha = 1
                self.collectionView.alpha = 1
                self.launchView.frame = self.view.frame
                
                if let statusbar = UIApplication.shared.statusBarView {
                    statusbar.alpha = 0
                }
            }) { ending in
                self.palyerLayoutType = 0
            }
        }
    }
}
