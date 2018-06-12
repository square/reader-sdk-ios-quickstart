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

protocol DeauthorizeViewControllerDelegate: class {
    func deauthorizeViewControllerDidCompleteDeauthorization(_ deauthorizationViewController: DeauthorizeViewController)
    func deauthorizeViewControllerDidFailDeauthorization(_ deauthorizationViewController: DeauthorizeViewController)
}

final class DeauthorizeViewController: UIViewController {
    public weak var delegate: DeauthorizeViewControllerDelegate?
    
    private let spinner = Spinner()
    
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
        
        deauthorize()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        spinner.stopSpinning()
    }
}

private extension DeauthorizeViewController {
    func deauthorize() {
        // Deauthorize Reader SDK
        SQRDReaderSDK.shared.deauthorize { (error) in
            if let deauthError = error as? SQRDAuthorizationError {
                self.handleError(deauthError)
            } else {
                self.handleSuccess()
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
        let alertController = UIAlertController(title: "Deauthorization Error", message: error.localizedDescription, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { (_) in
            // Go back to the pay view controller
            self.delegate?.deauthorizeViewControllerDidFailDeauthorization(self)
        }))
        present(alertController, animated: true, completion: nil)
    }
    
    func handleSuccess() {
        // Go back to the choose authorization method view controller
        self.delegate?.deauthorizeViewControllerDidCompleteDeauthorization(self)
    }
}
