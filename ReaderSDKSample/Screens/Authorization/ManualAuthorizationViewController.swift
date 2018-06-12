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

protocol ManualAuthorizationViewControllerDelegate: class {
    func manualAuthorizationViewController(_ manualAuthorizationViewController: ManualAuthorizationViewController, didFinishEnteringAuthorizationCode code: String)
    func manualAuthorizationViewControllerDidCancel(_ manualAuthorizationViewController: ManualAuthorizationViewController)
}

class ManualAuthorizationViewController: UIViewController {
    public weak var delegate: ManualAuthorizationViewControllerDelegate?
    
    lazy var stackView = makeStackView()
    
    lazy var label = makeLabel()
    lazy var textField = makeTextField()
    lazy var authorizeButton = makeAuthorizeButton()
    lazy var cancelButton = makeCancelButton()

    override func viewDidLoad() {
        super.viewDidLoad()

        additionalSafeAreaInsets = SampleApp.additionalSafeAreaInsets
        
        // Add arranged subviews to stack view
        stackView.addArrangedSubview(label)
        stackView.addArrangedSubview(textField)
        stackView.addArrangedSubview(authorizeButton)
        stackView.addArrangedSubview(cancelButton)
        view.addSubview(stackView)
        
        stackView.setCustomSpacing(32.0, after: label)
        NSLayoutConstraint.activate([
            self.stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            self.stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            self.stackView.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor)
        ])
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        textField.becomeFirstResponder()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        textField.resignFirstResponder()
    }
}

// MARK: - Actions
extension ManualAuthorizationViewController {
    @objc func authorizeButtonTapped() {
        let code = textField.text ?? ""
        delegate?.manualAuthorizationViewController(self, didFinishEnteringAuthorizationCode: code)
    }
    
    @objc func cancelButtonTapped() {
        delegate?.manualAuthorizationViewControllerDidCancel(self)
    }
}

// MARK: - UI
extension ManualAuthorizationViewController {
    private func makeStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .fillProportionally
        stackView.spacing = 16
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }
    
    private func makeLabel() -> UILabel {
        let label = UILabel()
        label.text = "Enter an authorization code."
        label.textColor = .white
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 24, weight: .semibold)
        return label
    }
    
    private func makeTextField() -> UITextField {
        let textField = TextField()
        textField.placeholder = "Authorization code"
        return textField
    }
    
    private func makeAuthorizeButton() -> UIButton {
        return PrimaryButton(title: "Authorize", target: self, selector: #selector(authorizeButtonTapped))
    }
    
    private func makeCancelButton() -> UIButton {
        return SecondaryButton(title: "Cancel", target: self, selector: #selector(cancelButtonTapped))
    }
}
