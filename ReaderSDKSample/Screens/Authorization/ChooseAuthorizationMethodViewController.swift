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

protocol ChooseAuthorizationMethodViewControllerDelegate: class {
    func chooseAuthorizationMethodViewControllerDidChooseScanQRCode(_ chooseAuthorizationMethodViewController: ChooseAuthorizationMethodViewController)
    func chooseAuthorizationMethodViewControllerDidChooseManualCodeEntry(_ chooseAuthorizationMethodViewController: ChooseAuthorizationMethodViewController)
}

final class ChooseAuthorizationMethodViewController: BaseViewController {
    public weak var delegate: ChooseAuthorizationMethodViewControllerDelegate?
    
    private lazy var scanQRCodeButton = PrimaryButton(title: "Scan QR Code", target: self, selector: #selector(scanQRCodeButtonTapped))
    private lazy var manuallyEnterCodeButton = SecondaryButton(title: "Manually Enter Code", target: self, selector: #selector(manuallyEnterCodeButtonTapped))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        titleLabel.text = "Authorize Reader SDK."
        subtitleLabel.text = "Generate an authorization code\nin the Reader SDK tab\nof the Developer Portal."
        
        buttonsStackView.addArrangedSubview(scanQRCodeButton)
        buttonsStackView.addArrangedSubview(manuallyEnterCodeButton)
        
        scanQRCodeButton.isEnabled = QRAuthorizationViewController.canScanQRCodes
    }
    
    @objc func scanQRCodeButtonTapped() {
        delegate?.chooseAuthorizationMethodViewControllerDidChooseScanQRCode(self)
    }
    
    @objc func manuallyEnterCodeButtonTapped() {
        delegate?.chooseAuthorizationMethodViewControllerDidChooseManualCodeEntry(self)
    }
}
