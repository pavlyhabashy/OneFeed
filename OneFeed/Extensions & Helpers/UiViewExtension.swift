// Name:    Pavly Habashy
// Email:   phabashy@usc.edu
// Project: OneFeed

import Foundation
import UIKit

extension UIView {
    
    // Rounds the corner of a view. Used in conjunction with the overlay transition animation
    func makeCorner(withRadius radius: CGFloat) {
        self.layer.cornerRadius = radius
        self.layer.masksToBounds = true
        self.layer.isOpaque = false
    }
}
