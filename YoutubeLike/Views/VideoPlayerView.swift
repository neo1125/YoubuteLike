import UIKit
import AVFoundation

protocol VideoPalyerLayoutDelegate {
    func minimize()
    func maximize()
}

class VideoPlayerView: UIView {
    
    var player: AVPlayer?
    var playerLayer: AVPlayerLayer?
    var delegate: VideoPalyerLayoutDelegate? {
        didSet {
            controlContainerView.layoutDelegate = delegate
        }
    }
    lazy var controlContainerView: VideoControl = {
        let control = VideoControl(frame: self.bounds)
        control.backgroundColor = UIColor(white: 0, alpha: 0.5)
        return control
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    override func draw(_ rect: CGRect) {
        setupPlayerView()
        setupViews()
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "currentItem.loadedTimeRanges" {
            guard let duration = player?.currentItem?.duration, let seconds = CMTimeGetSeconds(duration) as? Double else {
                return
            }
            controlContainerView.isReady = true
            controlContainerView.totalDuration = seconds
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupViews() {
        controlContainerView.delegate = self
        addSubview(controlContainerView)
        backgroundColor = UIColor.black
        
        addConstraints(withFormat: "H:|[v0]|", views: controlContainerView)
        addConstraints(withFormat: "V:|[v0]|", views: controlContainerView)
    }
    
    private func setupPlayerView() {
        let urlString = "https://firebasestorage.googleapis.com/v0/b/gameofchats-762ca.appspot.com/o/message_movies%2F12323439-9729-4941-BA07-2BAE970967C7.mov?alt=media&token=3e37a093-3bc8-410f-84d3-38332af9c726"
        guard let url = URL(string: urlString) else {
            return
        }
        
        player = AVPlayer(url: url)
        playerLayer = AVPlayerLayer(player: player)
        if let pLayer = playerLayer {
            self.layer.addSublayer(pLayer)
            pLayer.frame = bounds
        }
        
        player!.addObserver(self, forKeyPath: "currentItem.loadedTimeRanges", options: .new, context: nil)
        let interval = CMTime(value: 1, timescale: 2)
        player!.addPeriodicTimeObserver(forInterval: interval, queue: DispatchQueue.main) { (progressTime) in
            self.controlContainerView.duration = CMTimeGetSeconds(progressTime)
        }
    }
    
//    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
//        if controlContainerView.isHidden {
//            controlContainerView.isHidden = false
//        }
//        
//        delegate?.maximize()
//    }
}

extension VideoPlayerView: VideoControlDelegate {
    func play() {
        player?.play()
    }
    
    func pause() {
        player?.pause()
    }
    
    func seek(point: Double) {
        guard let duration: CMTime = player?.currentItem?.duration, let totalSeconds: Double = CMTimeGetSeconds(duration) else {
            return
        }
        let value = point * totalSeconds
        let seekTime = CMTime(value: Int64(value), timescale: 1)
        player?.seek(to: seekTime)
    }
}
