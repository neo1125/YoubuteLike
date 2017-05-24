import UIKit
import AVFoundation

class VideoPlayerView: UIView {
    
    let controlContainerView: VideoControl = {
        let view = VideoControl()
        view.backgroundColor = UIColor(white: 0, alpha: 0.5)
        return view
    }()
    
    var player: AVPlayer?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupPlayerView()
        setupViews()
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "currentItem.loadedTimeRanges" {
//            activityIndicatorView.stopAnimating()
//            controlContainerView.backgroundColor = UIColor.clear
//            pausePlayButton.isHidden = false
//            isPlaying = true
            
            guard let duration = player?.currentItem?.duration as? CMTime, let seconds = CMTimeGetSeconds(duration) as? Double else {
                return
            }
            let minutesText = String(format: "%02d", Int(seconds) / 60)
            let secondsText = Int(seconds) % 60
//            videoLengthLabel.text = "\(minutesText):\(secondsText)"
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupViews() {
        
        controlContainerView.frame = frame
        addSubview(controlContainerView)
        
        backgroundColor = UIColor.black
    }
    
//    func handlePausePlay() {
//        if isPlaying {
//            player?.pause()
//            pausePlayButton.setImage(UIImage(named: "play"), for: .normal)
//        } else {
//            player?.play()
//            pausePlayButton.setImage(UIImage(named: "pause"), for: .normal)
//        }
//        
//        isPlaying = !isPlaying
//    }
//    
//    func handleExpand() {
//        
//    }
    
//    func handleSliderChange() {
//        guard let duration: CMTime = player?.currentItem?.duration, let totalSeconds: Double = CMTimeGetSeconds(duration) else {
//            return
//        }
//        let value = Double(videoSlider.value) * totalSeconds
//        let seekTime = CMTime(value: Int64(value), timescale: 1)
//        player?.seek(to: seekTime, completionHandler: { (completed) in
//            
//        })
//    }
    
    private func setupPlayerView() {
//        let urlString = "https://firebasestorage.googleapis.com/v0/b/gameofchats-762ca.appspot.com/o/message_movies%2F12323439-9729-4941-BA07-2BAE970967C7.mov?alt=media&token=3e37a093-3bc8-410f-84d3-38332af9c726"
//        guard let url = URL(string: urlString) else {
//            return
//        }
//        
//        player = AVPlayer(url: url)
//        let playerLayer = AVPlayerLayer(player: player)
//        self.layer.addSublayer(playerLayer)
//        playerLayer.frame = frame
//        
//        player!.play()
//        player!.addObserver(self, forKeyPath: "currentItem.loadedTimeRanges", options: .new, context: nil)
//        let interval = CMTime(value: 1, timescale: 2)
//        player!.addPeriodicTimeObserver(forInterval: interval, queue: DispatchQueue.main) { (progressTime) in
//            
//            let seconds = CMTimeGetSeconds(progressTime)
//            let secondsText = String(format: "%02d", Int(seconds) % 60)
//            let minutesText = String(format: "%02d", Int(seconds) / 60)
//            self.currentTimeLabel.text = "\(minutesText):\(secondsText)"
//
//            if let duration: CMTime = self.player?.currentItem?.duration, let totalSeconds: Double = CMTimeGetSeconds(duration) {
//                self.videoSlider.value = Float(seconds / totalSeconds)
//            }
//        }
    }
}

class VideoLauncher: NSObject {
    
    func showVideoPlayer() {
        
        guard let keyWindow = UIApplication.shared.keyWindow else {
            return
        }
        
        let view = UIView(frame: keyWindow.frame)
        view.backgroundColor = UIColor.white
        
        view.frame = CGRect(x: keyWindow.frame.width - 20, y: keyWindow.frame.height - 20, width: 20, height: 20)
        
        let height = keyWindow.frame.width * 9 / 16
        let videoPlayerFrame = CGRect(x: 0, y: 0, width: keyWindow.frame.width, height: height)
        let videoPlayerView = VideoPlayerView(frame: videoPlayerFrame)
        view.addSubview(videoPlayerView)
        
        keyWindow.addSubview(view)
        
        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseOut, animations: { 
            view.frame = keyWindow.frame
        }) { (completed) in
            UIApplication.shared.isStatusBarHidden = true
        }
    }
}
