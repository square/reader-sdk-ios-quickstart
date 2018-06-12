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
import AVFoundation
import SquareReaderSDK

protocol AuthorizeViewControllerDelegate: class {
    func authorizeViewControllerDidCompleteAuthorization(_ authorizationViewController: AuthorizeViewController)
    func authorizeViewControllerDidFailAuthorization(_ authorizationViewController: AuthorizeViewController)
}

final class AuthorizeViewController: UIViewController {
    public weak var delegate: AuthorizeViewControllerDelegate?
    
    private var authorizationCode: String = ""
    
    private let spinner = Spinner()
    
    convenience init(authorizationCode code: String) {
        self.init(nibName: nil, bundle: nil)
        
        authorizationCode = code
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        spinner.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(spinner)
        NSLayoutConstraint.activate([
            spinner.widthAnchor.constraint(equalToConstant: 60),
            spinner.heightAnchor.constraint(equalTo: spinner.widthAnchor),
            spinner.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            spinner.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        spinner.startSpinning()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        authorize(withCode: authorizationCode)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        spinner.stopSpinning()
    }
}

private extension AuthorizeViewController {
    func authorize(withCode code: String) {
        // Authorize Reader SDK
        SQRDReaderSDK.shared.authorize(withCode: code) { location, error in
            if let authError = error as? SQRDAuthorizationError {
                self.handleError(authError)
            } else if let location = location {
                self.handleSuccess(with: location)
            }
        }
    }
    
    func handleError(_ error: SQRDAuthorizationError) {
        guard let debugCode = error.userInfo[SQRDErrorDebugCodeKey] as? String,
              let debugMessage = error.userInfo[SQRDErrorDebugMessageKey] as? String else { return }
        
        // Print the debug code and message
        print(debugCode)
        print(debugMessage)
        
        // Show the error
        let alertController = UIAlertController(title: "Authorization Error", message: error.localizedDescription, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { (_) in
            // Go back to the start authorization view controller
            self.delegate?.authorizeViewControllerDidFailAuthorization(self)
        }))
        present(alertController, animated: true, completion: {
            // Provide haptic feedback
            self.triggerHaptic(.error)
        })
    }
    
    func handleSuccess(with location: SQRDLocation) {
        triggerHaptic(.success)
        
        // Print the location name
        print("Authorized Reader SDK to take payments for \(location.name)")
        
        // Push to the pay view controller
        self.delegate?.authorizeViewControllerDidCompleteAuthorization(self)
    }
    
    func triggerHaptic(_ type: UINotificationFeedbackType) {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(type)
    }
}
