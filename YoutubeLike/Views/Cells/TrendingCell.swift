import UIKit

class TrendingCell: FeedCell {
    
    override func fetchVideos() {
        ApiService.shared.fetchTrendings { videos in
            self.videos = videos
            self.collectionView.reloadData()
        }
    }
}
