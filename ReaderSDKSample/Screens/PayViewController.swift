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
import SquareReaderSDK

protocol PayViewControllerDelegate: class {
    func payViewControllerDidRequestDeauthorization(_ payViewController: PayViewController)
}

/**
 * Start using Square Reader SDK!
 */
final class PayViewController: BaseViewController {
    public weak var delegate: PayViewControllerDelegate?
    
    private lazy var checkoutButton = PrimaryButton(title: "Charge \(format(amount: amount))", target: self, selector: #selector(checkoutButtonTapped))
    private lazy var settingsButton = SecondaryButton(title: "Settings", target: self, selector: #selector(settingsButtonTapped))
    
    private var authorizedLocation: SQRDLocation {
        guard let location = SQRDReaderSDK.shared.authorizedLocation else {
            fatalError("You must authorize Reader SDK before attempting to access `authorizedLocation`.")
        }
        return location
    }
    
    private let amount = 100
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        titleLabel.text = "Take a payment."
        buttonsStackView.addArrangedSubview(checkoutButton)
        buttonsStackView.addArrangedSubview(settingsButton)
    }
    
    @objc private func checkoutButtonTapped() {
        let money = SQRDMoney(amount: amount)
        
        // Create checkout parameters
        let checkoutParameters = SQRDCheckoutParameters(amountMoney: money)
        checkoutParameters.note = "Hello 💳 💰 World!"
        checkoutParameters.additionalPaymentTypes = [.cash]
        
        // Create a checkout controller
        let checkoutController = SQRDCheckoutController(parameters: checkoutParameters, delegate: self)
        
        // Present the Reader Settings controller from the `AppViewController` instance.
        if let presenter = parent {
            checkoutController.present(from: presenter)
        }
    }
    
    @objc private func settingsButtonTapped() {
        let preferredStyle: UIAlertControllerStyle = UIDevice.current.userInterfaceIdiom == .pad ? .alert : .actionSheet
        let alertController = UIAlertController(title: "Location: \(authorizedLocation.name)", message: nil, preferredStyle: preferredStyle)
        
        alertController.addAction(UIAlertAction(title: "Reader Settings", style: .default) { (action) in
            let readerSettingsController = SQRDReaderSettingsController(delegate: self)
            readerSettingsController.present(from: self)
        })
        
        if SQRDReaderSDK.shared.canDeauthorize {
            alertController.addAction(UIAlertAction(title: "Deauthorize", style: .destructive) { (action) in
                self.delegate?.payViewControllerDidRequestDeauthorization(self)
            })
        }
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(alertController, animated: true, completion: nil)
    }
    
    private func format(amount: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = authorizedLocation.currencyCode.isoCurrencyCode
        return formatter.string(from: NSNumber(value: Float(amount) / Float(100)))!
    }
}

extension PayViewController: SQRDCheckoutControllerDelegate {
    func checkoutController(_ checkoutController: SQRDCheckoutController, didFinishCheckoutWith result: SQRDCheckoutResult) {
        // Checkout finished, print the result.
        print(result)
        
        let amountString = format(amount: result.totalMoney.amount)
        showAlert(title: "\(amountString) Successfully Charged", message: "See the Xcode console for transaction details. You can refund transactions from your Square Dashboard.")
    }
    
    func checkoutController(_ checkoutController: SQRDCheckoutController, didFailWith error: Error) {
        /**************************************************************************************************
         * The Checkout controller failed due to an error.
         *
         * Errors from Square Reader SDK always have a `localizedDescription` that is appropriate for displaying to users.
         * Use the values of `userInfo[SQRDErrorDebugCodeKey]` and `userInfo[SQRDErrorDebugMessageKey]` (which are always
         * set for Reader SDK errors) for more information about the underlying issue and how to recover from it in your app.
         **************************************************************************************************/
        
        guard let checkoutError = error as? SQRDCheckoutControllerError,
            let debugCode = checkoutError.userInfo[SQRDErrorDebugCodeKey] as? String,
            let debugMessage = checkoutError.userInfo[SQRDErrorDebugMessageKey] as? String else {
                return
        }
        
        print(debugCode)
        print(debugMessage)
        showAlert(title: "Checkout Error", message: checkoutError.localizedDescription)
    }
    
    func checkoutControllerDidCancel(_ checkoutController: SQRDCheckoutController) {
        print("Checkout cancelled.")
    }
    
    func showAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
}

extension PayViewController: SQRDReaderSettingsControllerDelegate {
    func readerSettingsControllerDidPresent(_ readerSettingsController: SQRDReaderSettingsController) {
        print("The Reader Settings controller did present.")
    }
    
    func readerSettingsController(_ readerSettingsController: SQRDReaderSettingsController, didFailToPresentWith error: Error) {
        /**************************************************************************************************
         * The Reader Settings controller failed due to an error.
         *
         * Errors from Square Reader SDK always have a `localizedDescription` that is appropriate for displaying to users.
         * Use the values of `userInfo[SQRDErrorDebugCodeKey]` and `userInfo[SQRDErrorDebugMessageKey]` (which are always
         * set for Reader SDK errors) for more information about the underlying issue and how to recover from it in your app.
         **************************************************************************************************/
        
        guard let readerSettingsError = error as? SQRDReaderSettingsControllerError,
            let debugCode = readerSettingsError.userInfo[SQRDErrorDebugCodeKey] as? String,
            let debugMessage = readerSettingsError.userInfo[SQRDErrorDebugMessageKey] as? String else {
                return
        }
        
        print(debugCode)
        print(debugMessage)
        fatalError(error.localizedDescription)
    }
}
