// Name:    Pavly Habashy
// Email:   phabashy@usc.edu
// Project: OneFeed

import UIKit
import TwitterKit

class ProfileViewController: UIViewController {
    
    // Outlets
    @IBOutlet weak var followingCount: UILabel!
    @IBOutlet weak var followerCount: UILabel!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var displayName: UILabel!
    @IBOutlet weak var username: UILabel!
    
    // Alert Controller
    let alertController = UIAlertController(title: "Would you like to sign out?", message: "", preferredStyle: .actionSheet)

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Destructive sign out action
        let signOutAction = UIAlertAction(title: "Sign Out", style: .destructive) { (action) in
            self.goToSignInPage()
        }
        
        // Cancel action
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        alertController.addAction(signOutAction)
     }
    
    override func viewWillAppear(_ animated: Bool) {
        getProfileInfo()
    }
    
    // Gear button tapped
    @IBAction func optionsButtonTapped(_ sender: Any) {
        // Brings up the action sheet
        self.present(alertController, animated: true, completion: nil)
    }
    
    // Goes back to the Login View Controller
    func goToSignInPage() {
        if self.presentingViewController != nil {
            self.dismiss(animated: false, completion: {
                self.navigationController!.popToRootViewController(animated: true)
            })
        }
        else {
            self.navigationController!.popToRootViewController(animated: true)
        }
    }
    
    // Makes a GET call to pull the user's information
    func getProfileInfo() {
        let client: TWTRAPIClient?
        let statusesShowEndpoint = "https://api.twitter.com/1.1/account/verify_credentials.json"
        var clientError : NSError?
        if let userID = TWTRTwitter.sharedInstance().sessionStore.session()?.userID {
            client = TWTRAPIClient(userID: userID)
            let params = ["id": userID]
            let request = client?.urlRequest(withMethod: "GET", urlString: statusesShowEndpoint, parameters: params, error: &clientError)
            
            client?.sendTwitterRequest(request!) { (response, data, connectionError) -> Void in
                if connectionError != nil {
                    print("Error: \(connectionError!)")
                }
                DispatchQueue.main.async {
                    do {
                        let json = try JSONSerialization.jsonObject(with: data!, options: []) as! [String: Any]
                        if let followers_count = json["followers_count"] as! Int? {
                            self.followerCount.text = String(followers_count)
                        }
                        if let friends_count = json["friends_count"]  as! Int? {
                            self.followingCount.text = String(friends_count)
                        }
                        if let name = json["name"] {
                            self.displayName.text = name as? String
                        }
                        if let screen_name = json["screen_name"] {
                            self.username.text = "@\(screen_name)"
                        }
                        if let profile_image = json["profile_image_url_https"] {
                            let profile_image = (profile_image as! String).replacingOccurrences(of: "normal", with: "200x200")
                            let data = try Data(contentsOf: URL.init(string: profile_image)!)
                            self.profileImage.image = UIImage.init(data: data)
                            self.profileImage.layer.masksToBounds = false
                            self.profileImage.layer.borderColor = UIColor.black.cgColor
                            self.profileImage.layer.borderWidth = 0.5
                            self.profileImage.layer.cornerRadius = self.profileImage.frame.height/2
                            self.profileImage.clipsToBounds = true
                        }
                        
                    } catch let jsonError as NSError {
                        print("json error: \(jsonError.localizedDescription)")
                    }
                }
            }
        }
    }
}
