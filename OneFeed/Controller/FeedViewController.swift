// Name:    Pavly Habashy
// Email:   phabashy@usc.edu
// Project: OneFeed

import UIKit
import TwitterKit
import SafariServices
import MessageUI

class FeedViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextViewDelegate, MFMessageComposeViewControllerDelegate {
    
    // Variables
    var feed: [Post] = []
    var count = 30
    private let refreshControl = UIRefreshControl()
    var firstRun = true
    var maxId = 0
    let overlayTransitioningDelegate = OverlayTransitioningDelegate()
    
    // Outlets
    @IBOutlet var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.makeCorner(withRadius: 10.0)
        setupTable()
    }
    
    // Sets up the table view
    func setupTable() {
        tableView.allowsSelection = false
        tableView.rowHeight = UITableView.automaticDimension
        
        if #available(iOS 10.0, *) {
            tableView.refreshControl = refreshControl
        } else {
            tableView.addSubview(refreshControl)
        }
        
        refreshControl.addTarget(self, action: #selector(refreshFeed), for: .valueChanged)
        tableView.addSubview(refreshControl)
        
        self.loadMoreData()
    }
    
    // Used to refresh the feed when you drag down
    @objc func refreshFeed() {
        firstRun = true
        count = 30
        self.feed.removeAll()
        loadMoreData()
    }
    
    // Makes a POST call to Twitter to either like or unlike a post based on the passed in parameter 'action'
    func likeTweet(action: String, id: Int) {
        let client: TWTRAPIClient?
        var statusesShowEndpoint = ""
        statusesShowEndpoint = "https://api.twitter.com/1.1/favorites/\(action).json?id=\(id)"
        
        var clientError : NSError?
        if let userID = TWTRTwitter.sharedInstance().sessionStore.session()?.userID {
            client = TWTRAPIClient(userID: userID)
            let params = ["id": userID]
            let request = client?.urlRequest(withMethod: "POST", urlString: statusesShowEndpoint, parameters: params, error: &clientError)
            
            client?.sendTwitterRequest(request!) { (response, data, connectionError) -> Void in
                if connectionError != nil {
                    print("Error: \(connectionError!)")
                }
            }
        }
    }
    
    // Is used to pull the user's feed
    @objc func loadMoreData() {
        let client: TWTRAPIClient?
        var statusesShowEndpoint = ""
        
        if firstRun == true {
            statusesShowEndpoint = "https://api.twitter.com/1.1/statuses/home_timeline.json?count=\(count)&include_rts=false"
            firstRun = false
        } else {
            statusesShowEndpoint = "https://api.twitter.com/1.1/statuses/home_timeline.json?count=\(count)&include_rts=false&max_id=\(maxId - 1)"
        }
        
        var clientError : NSError?
        if let userID = TWTRTwitter.sharedInstance().sessionStore.session()?.userID {
            client = TWTRAPIClient(userID: userID)
            let params = ["id": userID]
            let request = client?.urlRequest(withMethod: "GET", urlString: statusesShowEndpoint, parameters: params, error: &clientError)
            
            // Sends GET request
            client?.sendTwitterRequest(request!) { (response, data, connectionError) -> Void in
                if connectionError != nil {
                    print("Error: \(connectionError!)")
                }
                DispatchQueue.main.async {
                    do {
                        let json = try JSONSerialization.jsonObject(with: data!, options: []) as! [[String: Any]]
                        
                        // Parses each tweet
                        for tweet in json {
                            
                            // New tweet
                            let post = Post()
                            
                            // Timestamp
                            if let timestamp = tweet["created_at"] as! String? {
                                post.date = self.parseTimeDate(timestamp: timestamp)
                            }
                            
                            // Text
                            if let text = tweet["text"] as! String? {
                                post.statusText = text
                            }
                            
                            // User info
                            if let user = tweet["user"]  as? NSDictionary {
                                let profileImage = user["profile_image_url_https"] as! String
                                post.profilePicture = profileImage
                                post.profilePicture = post.profilePicture?.replacingOccurrences(of: "normal", with: "200x200")
                                let screenname = user["screen_name"] as! String
                                post.username = screenname
                                let name = user["name"] as! String
                                post.displayName = name
                                
                            }
                            
                            // Tweet ID
                            if let id = tweet["id"] as! Int? {
                                post.id = id
                            }
                            
                            // Like status
                            if let favorited = tweet["favorited"] as! Int? {
                                if favorited == 0 {
                                    post.favorited = false
                                } else {
                                    post.favorited = true
                                }
                            }
                            
                            // Add tweet to the 'feed' array to be used as the data source of the table
                            self.feed.append(post)
                        }
                        
                        // Get the last id so that it pulls tweets after it
                        self.maxId = self.feed[self.feed.count - 1].id!
                        
                        // Reloads the table
                        self.tableView.reloadData()
                        
                        // Stops refreshing
                        self.refreshControl.endRefreshing()
                        
                    } catch let jsonError as NSError {
                        print("json error: \(jsonError.localizedDescription)")
                    }
                }
            }
        }
    }
    
    // Parses the timestamp string
    func parseTimeDate(timestamp: String) -> Date {
        let dateFormatterGet = DateFormatter()
        dateFormatterGet.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateFormatterGet.timeZone = NSTimeZone(name: "UTC") as TimeZone?
        
        var timestampArray = timestamp.split(separator: " ") as Array
        var date = timestampArray[1]
        switch date {
        case "Jan":
            date = "01"
            break
        case "Feb":
            date = "02"
            break
        case "Mar":
            date = "03"
            break
        case "Apr":
            date = "04"
            break
        case "May":
            date = "05"
            break
        case "Jun":
            date = "06"
            break
        case "July":
            date = "07"
            break
        case "Aug":
            date = "08"
            break
        case "Sep":
            date = "09"
            break
        case "Oct":
            date = "10"
            break
        case "Nov":
            date = "11"
            break
        case "Dec":
            date = "12"
            break
        default:
            print("Something went wrong")
            break
        }

        let date1 = String("\(timestampArray[5])-\(date)-\(timestampArray[2]) \(timestampArray[3])")
        
        if let formattedDate = dateFormatterGet.date(from: date1) {
            return formattedDate
        } else {
            print("There was an error decoding the string")
        }
        let nilDate: Date = Date()
        return nilDate
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return feed.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "TwitterCell", for: indexPath) as! TwitterViewCell
        
        cell.displayName.text = feed[indexPath.row].displayName
        cell.username.text = "@\((feed[indexPath.row].username)!)"
        cell.statusText.text = feed[indexPath.row].statusText
        cell.statusText.delegate = self
        cell.statusText.dataDetectorTypes = .link;
        cell.statusText.isEditable = false
        
        if feed[indexPath.row].favorited == true {
            cell.indicator.backgroundColor = #colorLiteral(red: 0.869217813, green: 0.1482557356, blue: 0.3706927896, alpha: 1)
        } else {
            cell.indicator.backgroundColor = .white
        }
        
        cell.timestamp.text = timeAgoSinceDate(feed[indexPath.row].date!)
        
        do {
            let data = try Data(contentsOf: URL.init(string: feed[indexPath.row].profilePicture!)!)
            cell.profilePicture
                .image = UIImage.init(data: data)
            cell.profilePicture.layer.masksToBounds = false
            cell.profilePicture.layer.borderColor = UIColor.black.cgColor
            cell.profilePicture.layer.borderWidth = 0.5
            cell.profilePicture.layer.cornerRadius = cell.profilePicture.frame.height/2
            cell.profilePicture.clipsToBounds = true
        } catch {
            print(error.localizedDescription)
        }
        
        if indexPath.row == self.feed.count - 3 {
            count = count + 10
            self.loadMoreData()
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        var title = ""
        var action: UIContextualAction?
        title = NSLocalizedString("Share", comment: "Share")
        action = UIContextualAction(style: .normal, title: title, handler: { (action, view, completionHandler) in
            if (MFMessageComposeViewController.canSendText()) {
                let controller = MFMessageComposeViewController()
                controller.body = "https://twitter.com/\((self.feed[indexPath.row].username)!)/status/\((self.feed[indexPath.row].id)!)?s=12"
                controller.recipients = []
                controller.messageComposeDelegate = self
                self.present(controller, animated: true, completion: nil)
            }
        })
        
        let configuration = UISwipeActionsConfiguration(actions: [action!])
        return configuration
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        guard let favorite = feed[indexPath.row].favorited else {
            return nil
        }
        var title = ""
        var action: UIContextualAction?
        
        // Swipe action to favorite a tweet
        if favorite == false {
            title = NSLocalizedString("Favorite", comment: "Favorite")
            action?.backgroundColor = #colorLiteral(red: 0.8680773377, green: 0.1495420039, blue: 0.3696835041, alpha: 1)
            action = UIContextualAction(style: .normal, title: title) { (action, view, completionHandler) in
                self.feed[indexPath.row].favorited = true
                completionHandler(true)
                self.likeTweet(action: "create", id: self.feed[indexPath.row].id!)
                
                let indexPath = IndexPath(row: indexPath.row, section: 0)
                let cell = tableView.cellForRow(at: indexPath) as! TwitterViewCell
                UIView.animate(withDuration: 1, animations: { () -> Void in
                    cell.indicator.backgroundColor = #colorLiteral(red: 0.869217813, green: 0.1482557356, blue: 0.3706927896, alpha: 1)
                })
                
            }
        // Swipe action to unfavorite a tweet
        } else {
            title = NSLocalizedString("Unfavorite", comment: "Unfavorite")
            action?.backgroundColor = #colorLiteral(red: 0.6666666865, green: 0.6666666865, blue: 0.6666666865, alpha: 1)
            action = UIContextualAction(style: .normal, title: title) { (action, view, completionHandler) in
                self.feed[indexPath.row].favorited = false
                completionHandler(true)
                self.likeTweet(action: "destroy", id: self.feed[indexPath.row].id!)
                
                let indexPath = IndexPath(row: indexPath.row, section: 0)
                let cell = tableView.cellForRow(at: indexPath) as! TwitterViewCell
                UIView.animate(withDuration: 1, animations: { () -> Void in
                    cell.indicator.backgroundColor = .white
                })
            }
        }
        
        let configuration = UISwipeActionsConfiguration(actions: [action!])
        return configuration
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any!) {
        if segue.identifier == "compose" {
            prepareOverlay(viewController: segue.destination)
        }
    }
    
    // Handles the animation when pressing the compose button
    @IBAction func handleBouncyPresentPressed(sender: AnyObject) {
        let overlayViewController = storyboard?.instantiateViewController(withIdentifier: "ComposeViewController")
        prepareOverlay(viewController: overlayViewController!)
        present(overlayViewController!, animated: true)
        setNeedsStatusBarAppearanceUpdate()
    }
    
    // Handles the animation when pressing the compose button
    private func prepareOverlay(viewController: UIViewController) {
        viewController.transitioningDelegate = overlayTransitioningDelegate
        viewController.modalPresentationStyle = .custom
        setNeedsStatusBarAppearanceUpdate()
    }

    // Opens links in in-app Safari View Controller
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange) -> Bool {
        let safariVC = SFSafariViewController(url: URL)
        present(safariVC, animated: true, completion: nil)
        return false
    }
    
    // Adopted from https://gist.github.com/minorbug/468790060810e0d29545#file-timeago-swift
    // Converts the timestamp to a relative timestamp (relative to the current date)
    func timeAgoSinceDate(_ date:Date, numericDates:Bool = false) -> String {
        let calendar = NSCalendar.current
        let unitFlags: Set<Calendar.Component> = [.minute, .hour, .day, .month, .year, .second]
        let now = Date()
        let earliest = now < date ? now : date
        let latest = (earliest == now) ? date : now
        let components = calendar.dateComponents(unitFlags, from: earliest,  to: latest)
        
        if (components.year! >= 2) {
            return "\(components.year!) y"
        } else if (components.year! >= 1){
            if (numericDates){
                return "1 y"
            } else {
                return "1 y"
            }
        } else if (components.month! >= 2) {
            return "\(components.month!) m"
        } else if (components.month! >= 1){
            if (numericDates){
                return "1 m"
            } else {
                return "1 m"
            }
        } else if (components.day! >= 2) {
            return "\(components.day!) d"
        } else if (components.day! >= 1){
            if (numericDates){
                return "1 d"
            } else {
                return "1 d"
            }
        } else if (components.hour! >= 2) {
            return "\(components.hour!) h"
        } else if (components.hour! >= 1){
            if (numericDates){
                return "1 h"
            } else {
                return "1 h"
            }
        } else if (components.minute! >= 2) {
            return "\(components.minute!) m"
        } else if (components.minute! >= 1){
            if (numericDates){
                return "1 m"
            } else {
                return "1 m"
            }
        } else if (components.second! >= 3) {
            return "\(components.second!) s"
        } else {
            return "Just now"
        }
        
    }
    
    // Handles dismissing the Messages controller
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        controller.dismiss(animated: true, completion: nil)
    }
}
