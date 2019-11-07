// Note to ITP 342 grader: this file was adopted from https://medium.com/@cboynton/achieving-a-type-on-text-effect-in-swift-6934b683d1e9
//
//
import Foundation
import UIKit

extension UITextView {
    func typeOn(string: String) {
        let characterArray = string.characterArray
        var characterIndex = 0
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { (timer) in
            if characterArray[characterIndex] != "$" {
                while characterArray[characterIndex] == " " {
                    self.text.append(" ")
                    characterIndex += 1
                    if characterIndex == characterArray.count {
                        timer.invalidate()
                        return
                    }
                }
                self.text.append(characterArray[characterIndex])
            }
            characterIndex += 1
            if characterIndex == characterArray.count {
                timer.invalidate()
            }
        }
    }
}

extension String {
    var characterArray: [Character]{
        var characterArray = [Character]()
        for character in self.characters {
            characterArray.append(character)
        }
        return characterArray
    }
}
