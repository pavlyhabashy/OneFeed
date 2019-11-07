// Name:    Pavly Habashy
// Email:   phabashy@usc.edu
// Project: OneFeed

import UIKit
import TwitterKit

class ComposeViewController: UIViewController, UITextViewDelegate {
    
    // Outlets
    @IBOutlet weak var closeButtonOutlet: UIButton!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var characterCount: UILabel!
    @IBOutlet weak var tweetButtonOutlet: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Makes the view corner round
        self.view.makeCorner(withRadius: 10.0)
        
        // Makes a slight adjustment to the close button size because the button is too big
        closeButtonOutlet.imageEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        
        // Set up the text view
        textView.text = "What's happening?"
        textView.textColor = UIColor.lightGray
        
        // Disable the tweet button
        tweetButtonOutlet.isEnabled = false
        
        textView.selectedTextRange = textView.textRange(from: textView.beginningOfDocument, to: textView.beginningOfDocument)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        textView.becomeFirstResponder()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        textView.resignFirstResponder()
    }
    
    // Function to handle the POST call to make a tweet
    func tweet(status: String) {
        let client: TWTRAPIClient?
        var statusesShowEndpoint = ""
        let status = status.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
        statusesShowEndpoint = "https://api.twitter.com/1.1/statuses/update.json?status=\(status)"
        
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
    
    // Handles the character count and disabling the tweet button
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let currentText:String = textView.text
        let updatedText = (currentText as NSString).replacingCharacters(in: range, with: text)
        
        if updatedText.isEmpty {
            textView.text = "What's happening?"
            textView.textColor = UIColor.lightGray
            textView.selectedTextRange = textView.textRange(from: textView.beginningOfDocument, to: textView.beginningOfDocument)
            characterCount.text = "280"
            tweetButtonOutlet.isEnabled = false
        } else if textView.textColor == UIColor.lightGray && !text.isEmpty {
            textView.textColor = UIColor.black
            textView.text = text
            characterCount.text = String(280 - text.count)
            tweetButtonOutlet.isEnabled = true
        } else if updatedText == "What's happening?" {
            characterCount.text = "280"
            tweetButtonOutlet.isEnabled = false
            return true
        } else {
            if (updatedText.count > 280) {
                return false
            }
            else if (updatedText.count == 280) {
                characterCount.textColor = .red
            } else {
                characterCount.textColor = .lightGray
                tweetButtonOutlet.isEnabled = true
            }
            characterCount.text = String(280 - updatedText.count)
            
            return true && updatedText.count <= 280
        }
        return false
    }
    
    func textViewDidChangeSelection(_ textView: UITextView) {
        if self.view.window != nil {
            if textView.textColor == UIColor.lightGray {
                textView.selectedTextRange = textView.textRange(from: textView.beginningOfDocument, to: textView.beginningOfDocument)
            }
        }
    }
    
    // Handles the animation when pressing the compose button
    @IBAction func handleDismissedPressed(sender: AnyObject) {
        presentingViewController?.dismiss(animated: true)
    }
    
    // Tweets when the button is pressed
    @IBAction func tweetButtonPressed(_ sender: Any) {
        tweet(status: textView.text as String)
        presentingViewController?.dismiss(animated: true)
    }

}
