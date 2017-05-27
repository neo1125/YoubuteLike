import UIKit

extension UIApplication {
    var statusBarView: UIView? {
        return value(forKey: "statusBar") as? UIView
    }
}

extension UIViewController {
    var rootController: RootController?  {
        var parentResponder: UIResponder? = self
        while parentResponder != nil {
            parentResponder = parentResponder!.next
            if let result = parentResponder as? RootController {
                return result
            }
        }
        return nil
    }
}

extension UIView {
    func addConstraints(withFormat: String, views: UIView...) {
        
        var viewsDictionary = [String: UIView]()
        for (index, view) in views.enumerated() {
            viewsDictionary["v\(index)"] = view
            view.translatesAutoresizingMaskIntoConstraints = false
        }
        
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: withFormat, options: NSLayoutFormatOptions(), metrics: nil, views: viewsDictionary))
    }
    
    var viewController: UIViewController? {
        var parentResponder: UIResponder? = self
        while parentResponder != nil {
            parentResponder = parentResponder!.next
            if let result = parentResponder as? UIViewController {
                return result
            }
        }
        return nil
    }
    
    var currentFirstResponder: UIResponder? {
        if self.isFirstResponder {
            return self
        }
        
        for view in self.subviews {
            if let responder = view.currentFirstResponder {
                return responder
            }
        }
        
        return nil
    }
}

let imageCache = NSCache<AnyObject, AnyObject>()

extension UIImageView {
    
    func loadImageUsingUrl(string: String) {
        
        image = nil
        
        if let imageFormCache = imageCache.object(forKey: string as AnyObject) as? UIImage {
            self.image = imageFormCache
            return
        }
        
        guard let url = URL(string: string) else {
            return
        }
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            
            guard error == nil else {
                print("error : ", error)
                return
            }
            
            DispatchQueue.main.async {
                let imageToCache = UIImage(data: data!)
                imageCache.setObject(imageToCache!, forKey: string as AnyObject)
                self.image = imageToCache
            }
            
        }.resume()
    }
}
