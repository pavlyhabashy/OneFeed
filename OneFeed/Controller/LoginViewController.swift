// Name:    Pavly Habashy
// Email:   phabashy@usc.edu
// Project: OneFeed

import UIKit
import TwitterKit

class ViewController: UIViewController {
    
    // Outlets
    @IBOutlet weak var twitterButton: UIButton!
    @IBOutlet weak var oneFeed: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set up the twitter button
        twitterButton.layer.cornerRadius = 30
        twitterButton.clipsToBounds = true
        self.twitterButton.alpha = 0.0
    }
    
    override func viewWillAppear(_ animated: Bool) {
        twitterButton.setTitle("Twitter", for: .normal)
        self.oneFeed.text = ""
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        // Animates "OneFeed" on screen by typing it out
        oneFeed.typeOn(string: "OneFeed")
        
        // Fades in the twitter log in button
        UIView.animate(withDuration: 1.0, delay: 1.0, options: .curveEaseIn, animations: {
            self.twitterButton.alpha = 1.0
        })
    }
    
    // Establishes a session with the current user logged in
    @IBAction func twitterButtonPressed(_ sender: Any) {
        TWTRTwitter.sharedInstance().logIn(completion: { (session, error) in
            if (session != nil) {
//                print("signed in as \(session!.userName)");
//                print(session!.userID)
                self.twitterButton.setTitle("Logged In", for: .normal)
                sleep(1)
                self.performSegue(withIdentifier: "GoToHome", sender: nil)
            } else {
                self.twitterButton.setTitle("Logged In", for: .normal)
                sleep(1)
                self.performSegue(withIdentifier: "GoToHome", sender: nil)
                print("error: \(error!.localizedDescription)");
            }
        })
    }
}
