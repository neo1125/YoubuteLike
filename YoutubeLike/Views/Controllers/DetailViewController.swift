import UIKit

class DetailViewController: UICollectionViewController {
    
    var videos: [Video]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("####### DetailViewController viewDidLoad ###")
        view.clipsToBounds = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        print("####### DetailViewController viewWillAppear ###")
        
        prepareCollectionView()
        fetchVideos()
    }
    
    private func prepareCollectionView() {
        guard let collectionView = self.collectionView else {
            return
        }
        
        if let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.scrollDirection = .vertical
        }
        collectionView.register(VideoCell.self, forCellWithReuseIdentifier: "cellId")
        
        collectionView.backgroundColor = UIColor.white
    }
    
    private func fetchVideos() {
        ApiService.shared.fetchTrendings { videos in
            print("### fetchTrendings : ", videos)
            self.videos = videos
            
            print("### collectionView : ", self.collectionView)
            self.collectionView?.reloadData()
        }
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print("### numberOfItemsInSection")
        return videos?.count ?? 0
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        print("### cellForItemAt")
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cellId", for: indexPath) as! VideoCell
        cell.video = videos?[indexPath.row]
        return cell
    }
}

extension DetailViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let height = (view.frame.width - (16*2)) * (9/16)
        return CGSize(width: view.bounds.width, height: height + 16 + 68)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
}
