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

class BaseViewController: UIViewController {
    public lazy var buttonsStackView = makeStackView()
    public lazy var squareLogoView = makeSquareLogoView()
    public lazy var titleLabel = makeTitleLabel()
    public lazy var subtitleLabel = makeSubtitleLabel()
    
    private lazy var constraints = [
        squareLogoView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
        squareLogoView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        squareLogoView.widthAnchor.constraint(equalToConstant: 48),
        squareLogoView.heightAnchor.constraint(equalToConstant: 48),
        
        titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        titleLabel.bottomAnchor.constraint(equalTo: view.centerYAnchor, constant: -5),
        titleLabel.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor),
        
        subtitleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        subtitleLabel.topAnchor.constraint(equalTo: view.centerYAnchor, constant: 5),
        subtitleLabel.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor),
        
        buttonsStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        buttonsStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
        buttonsStackView.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor)
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Add Square logo
        view.addSubview(squareLogoView)
        
        // Add labels
        view.addSubview(titleLabel)
        view.addSubview(subtitleLabel)
        
        // Set background color and add the stack view
        view.backgroundColor = SampleApp.backgroundColor
        view.addSubview(buttonsStackView)
        
        // Set up insets for the view
        additionalSafeAreaInsets = SampleApp.additionalSafeAreaInsets

        // Set up default constraints
        NSLayoutConstraint.activate(constraints)
    }
}

// MARK: - UI
extension BaseViewController {
    private func makeStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .fillProportionally
        stackView.spacing = 16
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }
    
    private func makeSquareLogoView() -> UIImageView {
        let imageView = UIImageView(image: #imageLiteral(resourceName: "Square"))
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }
    
    private func makeTitleLabel() -> UILabel {
        let titleLabel = UILabel()
        titleLabel.font = .systemFont(ofSize: 24, weight: .semibold)
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.numberOfLines = 0
        titleLabel.textAlignment = .center
        titleLabel.textColor = .white
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        return titleLabel
    }
    
    private func makeSubtitleLabel() -> UILabel {
        let subtitleLabel = UILabel()
        subtitleLabel.font = .systemFont(ofSize: 18, weight: .medium)
        subtitleLabel.adjustsFontSizeToFitWidth = true
        subtitleLabel.numberOfLines = 0
        subtitleLabel.textAlignment = .center
        subtitleLabel.textColor = UIColor.white.withAlphaComponent(0.75)
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        return subtitleLabel
    }
}
