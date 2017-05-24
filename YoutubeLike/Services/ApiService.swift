import UIKit

class ApiService: NSObject {
    
    static let shared = ApiService()
    let baseUrl = "https://s3-us-west-2.amazonaws.com/youtubeassets"
    
    func fetchVideos(completion: @escaping ([Video]) -> Void) {
        fetchFeedForUrlString(string: "/home.json", completion: completion)
    }
    
    func fetchTrendings(completion: @escaping ([Video]) -> Void) {
        fetchFeedForUrlString(string: "/trending.json", completion: completion)
    }
    
    func fetchSubscriptions(completion: @escaping ([Video]) -> Void) {
        fetchFeedForUrlString(string: "/subscriptions.json", completion: completion)
    }
    
    func fetchFeedForUrlString(string: String, completion: @escaping ([Video]) -> Void) {
        let url = URL(string: "\(baseUrl)\(string)")
        let urlRequest = URLRequest(url: url!)
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        let task = session.dataTask(with: urlRequest) { (data, response, error) in
            
            guard error == nil else {
                print("error : ", error?.localizedDescription)
                return
            }
            
            do {
                guard let unwrappedData = data, let jsonDictionaries = try JSONSerialization.jsonObject(with: unwrappedData, options: .mutableContainers) as? [[String: AnyObject]] else {
                    return
                }

                DispatchQueue.main.async {
                    completion(jsonDictionaries.map { return Video(dictionary: $0) })
                }
                
            } catch let jsonError {
                print(jsonError)
            }
        }
        task.resume()
    }
}
