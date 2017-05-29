import UIKit

enum Direction {
    case up
    case down
    case left
    case right
    case none
}

open class RootController: UIViewController {

    fileprivate var rootViewController: UIViewController!
    fileprivate let playerAnimationDuration: Double = 0.3
    fileprivate var videos: [Video] = []
    fileprivate var direction = Direction.none
    
    fileprivate let dimView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 0, alpha: 1)
        return view
    }()
    
    fileprivate var launchView: UIView! = {
        let view = UIView()
        view.backgroundColor = UIColor.clear
        view.clipsToBounds = true
        return view
    }()
    
    fileprivate var videoPlayerView: VideoPlayerView?
    fileprivate var collectionView: UICollectionView?
    
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
        
        launchView = UIView(frame: view.frame)
        launchView.backgroundColor = UIColor.clear
        launchView.clipsToBounds = true
        launchView.frame = view.frame
        
        videoPlayerView = VideoPlayerView()
        videoPlayerView?.delegate = self
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        collectionView?.dataSource = self
        collectionView?.delegate = self
        collectionView?.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        collectionView?.backgroundColor = UIColor.white
        
        launchView.addSubview(videoPlayerView!)
        launchView.addSubview(collectionView!)

        let playerHeight = launchView.frame.width * 9 / 16
        videoPlayerView?.frame = CGRect(x: 0, y: 0, width: launchView.frame.width, height: playerHeight)
        collectionView?.frame = CGRect(x: 0, y: playerHeight, width: launchView.frame.width, height: launchView.frame.height - playerHeight)
        view.addSubview(launchView)
        
        let miniWidth: CGFloat = 200
        let miniHeight: CGFloat = miniWidth * 9 / 16
        launchView.frame = CGRect(x: view.frame.width - miniWidth, y: view.frame.height - (miniHeight + 44), width: miniWidth, height: miniHeight)
        
        
        let gesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(gesture:)))
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
            self.collectionView?.reloadData()
        }
    }
    
    func setMinimize() {
        UIView.animate(withDuration: playerAnimationDuration, delay: 0, options: .curveEaseInOut, animations: {
            self.dimView.alpha = 0
            self.collectionView?.alpha = 0
            self.videoPlayerView?.controlContainerView.isHidden = true
            self.launchView.transform.a = 0.6
            self.launchView.transform.d = 0.6
            self.launchView.transform.tx = 75
            self.launchView.transform.ty = 357
            
            if let statusbar = UIApplication.shared.statusBarView {
                statusbar.alpha = 1
            }
        }) { ending in
            self.dimView.isHidden = true
        }
    }
    
    func setMaximize() {
        self.dimView.isHidden = false
        
        UIView.animate(withDuration: playerAnimationDuration, delay: 0, options: .curveEaseInOut, animations: {
            self.dimView.alpha = 1
            self.collectionView?.alpha = 1
            self.videoPlayerView?.controlContainerView.isHidden = false
            self.launchView.transform.a = 1
            self.launchView.transform.d = 1
            self.launchView.transform.tx = 0
            self.launchView.transform.ty = 0
            if let statusbar = UIApplication.shared.statusBarView {
                statusbar.alpha = 0
            }
        })
    }
    
    func removeVideoPlayer() {
        dimView.alpha = 0
        launchView.removeFromSuperview()
        if let statusbar = UIApplication.shared.statusBarView {
            statusbar.alpha = 1
        }
    }
    
    func handlePanGesture(gesture: UIPanGestureRecognizer) {
     
        let point = gesture.translation(in: view)
        let velocity = gesture.velocity(in: view)
        
        if gesture.state == .began {
            if abs(velocity.x) < abs(velocity.y) {
                // up or down
                direction = velocity.y > 0 ? .down : .up
                if direction == .down && launchView.transform.a == 0.6 {
                    direction = .none
                }
            } else {
                // left or right
                direction = velocity.x > 0 ? .right : .left
                if direction == .left && launchView.transform.a == 1 {
                    direction = .none
                }
            }
        }
        
        if gesture.state == .ended {
            let scale = UIScreen.main.bounds.height / point.y
            guard direction != .none else {
                return
            }
            
            if direction == .down && (abs(velocity.y) > 100 || scale < 6) {
                self.setMinimize()
                return
            } else if direction == .up && (abs(velocity.y) > 100 || scale > 6) {
                self.setMaximize()
                return
            } else if direction == .left {
                self.removeVideoPlayer()
                return
            } else {
                if direction == .down {
                    self.setMaximize()
                } else if direction == .up {
                    self.setMinimize()
                }
                return
            }
        }
        
        if direction == .down && point.y >= 0 {
            let factor = (abs(point.y) / UIScreen.main.bounds.height)
            var scaleFactor = 1 - factor
            if scaleFactor < 0.6 {
                scaleFactor = 0.6
            }
            let scale = CGAffineTransform(scaleX: scaleFactor, y: scaleFactor)
            
            var translationX = launchView.bounds.width * factor
            var translationY = launchView.bounds.height * factor
            if translationX > 75 {
                translationX = 75
            }
            
            if translationY > 357 {
                translationY = 357
            }
            
            let translation = CGAffineTransform(translationX: translationX, y: (launchView.bounds.height * factor)-1)
            let transform = scale.concatenating(translation)
            launchView.transform = transform
            dimView.alpha = 1 - (factor * 4)
            collectionView?.alpha = 1 - (factor * 4)
            
            if let statusbar = UIApplication.shared.statusBarView {
                statusbar.alpha = (factor * 6) - 1
            }
        } else if direction == .up && abs(point.y) >= 0 {
            let factor = (abs(point.y) / UIScreen.main.bounds.height)
            var scaleFactor = factor + 0.6
            if scaleFactor >= 1 {
                scaleFactor = 1
            }
            
            let scale = CGAffineTransform(scaleX: scaleFactor, y: scaleFactor)
            var translationX = 75 - (launchView.bounds.width * factor)
            var translationY = 357 - (launchView.bounds.width * factor)
            if translationX <= 0 {
               translationX = 0
            }
            if translationY <= 0 {
                translationY = 0
            }
            
            let translation = CGAffineTransform(translationX: translationX, y: translationY)
            let transform = scale.concatenating(translation)
            launchView.transform = transform
            dimView.alpha = (factor * 4) - 1
            collectionView?.alpha = (factor * 4) - 1
            
            if let statusbar = UIApplication.shared.statusBarView {
                statusbar.alpha = 1 - (factor * 6)
            }
        } else if direction == .left && abs(point.x) >= 0 {
            let factor = (abs(point.x) / UIScreen.main.bounds.width)
            launchView.alpha = 1 - (factor * 10)
            launchView.transform.tx = launchView.transform.tx + (point.x / 10)
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
