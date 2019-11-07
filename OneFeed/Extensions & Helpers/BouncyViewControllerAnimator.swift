// Note to ITP 342 grader: this file was adopted from https://github.com/kbpontius/iOSComposeAnimation
//
// Copyright 2014 Scott Logic
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

import UIKit

class BouncyViewControllerAnimator : NSObject, UIViewControllerAnimatedTransitioning {
  var isPresenting: Bool = false
  
  convenience init(isPresenting: Bool = false) {
    self.init()
    self.isPresenting = isPresenting
  }
    
  func transitionDuration(using: UIViewControllerContextTransitioning?) -> TimeInterval {
      return 0.8
  }
  
  func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
    guard let fromView = transitionContext.viewController(forKey: .from)?.view else { return }
    guard let toView = transitionContext.viewController(forKey: .to)?.view else { return }

    var center = toView.center

    if isPresenting {
      toView.center.y = toView.bounds.size.height
      transitionContext.containerView.addSubview(toView)
    } else {
      center.y = toView.bounds.size.height + fromView.bounds.size.height
    }

    UIView.animate(withDuration: self.transitionDuration(using: transitionContext),
      delay: 0,
      usingSpringWithDamping: 300,
      initialSpringVelocity: 10.0,
      options: [],
      animations: {
        if self.isPresenting {
          toView.center = center
          fromView.transform = CGAffineTransform(scaleX: 0.92, y: 0.92)
        } else {
          fromView.center = center
          toView.transform = CGAffineTransform(scaleX: 1, y: 1)
        }
      }) { _ in
        if !self.isPresenting {
          fromView.removeFromSuperview()
        }

        transitionContext.completeTransition(true)
      }
  }
}
