import UIKit

class SubscriptionCell: FeedCell {

    override func fetchVideos() {
        ApiService.shared.fetchSubscriptions { videos in
            self.videos = videos
            self.collectionView.reloadData()
        }
    }
}
