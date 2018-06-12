//
//  Copyright © 2018 Square, Inc.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import UIKit

protocol SquareLogoAnimationViewControllerDelegate: class {
    func squareLogoAnimationViewControllerDidFinishAnimating(_ squareLogoAnimationViewController: SquareLogoAnimationViewController)
}

class SquareLogoAnimationViewController: UIViewController {
    weak var delegate: SquareLogoAnimationViewControllerDelegate?
    
    private lazy var squareLogoView = makeSquareLogoView()
    
    private lazy var launchScreenSquareLogoConstraints = [
        squareLogoView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        squareLogoView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        squareLogoView.widthAnchor.constraint(equalToConstant: 80),
        squareLogoView.heightAnchor.constraint(equalTo: squareLogoView.widthAnchor),
    ]
    
    private lazy var squareLogoConstraints = [
        squareLogoView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
        squareLogoView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        squareLogoView.widthAnchor.constraint(equalToConstant: 48),
        squareLogoView.heightAnchor.constraint(equalToConstant: 48)
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = SampleApp.backgroundColor
        view.addSubview(squareLogoView)
        
        additionalSafeAreaInsets = SampleApp.additionalSafeAreaInsets
        NSLayoutConstraint.activate(launchScreenSquareLogoConstraints)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        animateSquareLogoFromCenter()
    }
    
    func animateSquareLogoFromCenter() {
        // Animate ✨
        view.layoutIfNeeded()
        UIView.animate(withDuration: 0.7,
                       delay: 0,
                       usingSpringWithDamping: 0.9,
                       initialSpringVelocity: 0,
                       options: [.curveEaseInOut],
                       animations: {
            NSLayoutConstraint.deactivate(self.launchScreenSquareLogoConstraints)
            NSLayoutConstraint.activate(self.squareLogoConstraints)
            self.view.layoutIfNeeded()
        }) { (_) in
            self.delegate?.squareLogoAnimationViewControllerDidFinishAnimating(self)
        }
    }
    
    private func makeSquareLogoView() -> UIImageView {
        let imageView = UIImageView(image: #imageLiteral(resourceName: "Square"))
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }
}
