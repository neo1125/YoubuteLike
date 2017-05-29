import UIKit
import AVFoundation

protocol VideoControlDelegate {
    func play()
    func pause()
    func seek(point: Double)
}

class VideoControl: UIView {
    
    var isAutoPlay = false
    var isPlaying = false
    var delegate: VideoControlDelegate?
    var layoutDelegate: VideoPalyerLayoutDelegate?
    
    override var isHidden: Bool {
        didSet {
            self.pausePlayButton.isEnabled = !isHidden
        }
    }
    
    var duration: Double = 0 {
        didSet {
            let secondsText = String(format: "%02d", Int(duration) % 60)
            let minutesText = String(format: "%02d", Int(duration) / 60)
            currentTimeLabel.text = "\(minutesText):\(secondsText)"
            videoSlider.value = Float(duration / totalDuration)
        }
    }
    
    var totalDuration: Double = 0 {
        didSet {
            let minutesText = String(format: "%02d", Int(totalDuration) / 60)
            let secondsText = Int(totalDuration) % 60
            videoLengthLabel.text = "\(minutesText):\(secondsText)"
        }
    }
    
    var isReady = false {
        didSet {
            if isReady {
                activityIndicatorView.stopAnimating()
                pausePlayButton.isHidden = false
                if isAutoPlay {
                    handlePausePlay()
                }
            }
        }
    }
    
    let activityIndicatorView: UIActivityIndicatorView = {
        let aiv = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.whiteLarge)
        aiv.translatesAutoresizingMaskIntoConstraints = false
        aiv.startAnimating()
        return aiv
    }()
    
    let pausePlayButton: UIButton = {
        let button = UIButton(type: UIButtonType.system)
        let image = UIImage(named: "play")
        button.setImage(image, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.tintColor = UIColor.white
        button.isHidden = true
        button.addTarget(self, action: #selector(handlePausePlay), for: .touchUpInside)
        return button
    }()
    
    let videoLengthLabel: UILabel = {
        let label = UILabel()
        label.text = "00:00"
        label.textColor = UIColor.white
        label.font = UIFont.boldSystemFont(ofSize: 13)
        label.textAlignment = .right
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let currentTimeLabel: UILabel = {
        let label = UILabel()
        label.text = "00:00"
        label.textColor = UIColor.white
        label.font = UIFont.boldSystemFont(ofSize: 13)
        label.textAlignment = .right
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let videoSlider: UISlider = {
        let slider = UISlider()
        slider.translatesAutoresizingMaskIntoConstraints = false
        slider.minimumTrackTintColor = UIColor.red
        slider.maximumTrackTintColor = UIColor.white
        slider.setThumbImage(UIImage(named: "thumb"), for: .normal)
        slider.addTarget(self, action: #selector(handleSliderChange), for: .valueChanged)
        return slider
    }()
    
    let expandButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "expand"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupGradientLayer()
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if isReady {
            UIView.animate(withDuration: 0.35) {
                self.alpha = (self.alpha <= 0) ? 1 : 0
            }
        }
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if self.point(inside: point, with: event) {
            for subview in self.subviews.enumerated().reversed() {
                let convertPoint = subview.element.convert(point, from: self)
                if let hitTestView = subview.element.hitTest(convertPoint, with: event) {
                    return hitTestView
                }
            }
        }
        return self
    }
    
    private func setupGradientLayer() {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = bounds
        gradientLayer.colors = [UIColor.clear.cgColor, UIColor.black.cgColor]
        gradientLayer.locations = [0.7, 1.2]
        
        layer.addSublayer(gradientLayer)
    }
    
    private func setupViews() {
        
        addSubview(activityIndicatorView)
        activityIndicatorView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        activityIndicatorView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        
        addSubview(pausePlayButton)
        pausePlayButton.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        pausePlayButton.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        pausePlayButton.widthAnchor.constraint(equalToConstant: 50).isActive = true
        pausePlayButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        addSubview(videoLengthLabel)
        videoLengthLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: -8).isActive = true
        videoLengthLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -2 ).isActive = true
        videoLengthLabel.widthAnchor.constraint(equalToConstant: 60).isActive = true
        videoLengthLabel.heightAnchor.constraint(equalToConstant: 24).isActive = true
        
        addSubview(currentTimeLabel)
        currentTimeLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: -8).isActive = true
        currentTimeLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -2).isActive = true
        currentTimeLabel.widthAnchor.constraint(equalToConstant: 60).isActive = true
        currentTimeLabel.heightAnchor.constraint(equalToConstant: 24).isActive = true
        
        addSubview(videoSlider)
        videoSlider.rightAnchor.constraint(equalTo: videoLengthLabel.leftAnchor).isActive = true
        videoSlider.leftAnchor.constraint(equalTo: currentTimeLabel.rightAnchor, constant: 8).isActive = true
        videoSlider.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        videoSlider.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        addSubview(expandButton)
        expandButton.leftAnchor.constraint(equalTo: leftAnchor, constant: 0).isActive = true
        expandButton.topAnchor.constraint(equalTo: topAnchor, constant: 8).isActive = true
        expandButton.widthAnchor.constraint(equalToConstant: 44).isActive = true
        expandButton.heightAnchor.constraint(equalToConstant: 44).isActive = true
        expandButton.addTarget(self, action: #selector(handleExpand), for: .touchUpInside)
    }
    
    func handlePausePlay() {
        if isPlaying {
            delegate?.pause()
            UIView.animate(withDuration: 0.2, animations: { 
                self.pausePlayButton.setImage(UIImage(named: "play"), for: .normal)
            })
            
        } else {
            delegate?.play()
            UIView.animate(withDuration: 0.2, animations: {
                self.pausePlayButton.setImage(UIImage(named: "pause"), for: .normal)
            })
        }
        isPlaying = !isPlaying
    }
    
    func handleSliderChange() {
        delegate?.seek(point: Double(videoSlider.value))
    }
    
    func handleExpand() {
        isHidden = true
        layoutDelegate?.minimize()
    }
}
