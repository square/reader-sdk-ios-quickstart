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
import CoreLocation
import AVFoundation
import SquareReaderSDK

final class AppViewController: UIViewController {
    var currentViewController: UIViewController? {
        return childViewControllers.first
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = SampleApp.backgroundColor
        
        // The user may be directed to the Settings app to change their permissions.
        // When they return, update the current screen.
        NotificationCenter.default.addObserver(self, selector: #selector(updateScreen), name: .UIApplicationWillEnterForeground, object: nil)
        
        // The app finished launching, so show the Square logo animation
        let squareLogoAnimationViewController = SquareLogoAnimationViewController()
        squareLogoAnimationViewController.delegate = self
        show(viewController: squareLogoAnimationViewController)
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return UIDevice.current.userInterfaceIdiom == .pad ? .all : .portrait
    }

    @objc internal func updateScreen() {
        let permissionsGranted = PermissionsViewController.areRequiredPermissionsGranted
        let readerSDKAuthorized = SQRDReaderSDK.shared.isAuthorized
        
        if !permissionsGranted {
            let permissionsViewController = PermissionsViewController()
            permissionsViewController.delegate = self
            show(viewController: permissionsViewController)
            
        } else if !readerSDKAuthorized {
            let chooseAuthorizationMethodViewController = ChooseAuthorizationMethodViewController()
            chooseAuthorizationMethodViewController.delegate = self
            show(viewController: chooseAuthorizationMethodViewController)
            
        } else {
            let payViewController = PayViewController()
            payViewController.delegate = self
            show(viewController: payViewController)
        }
    }
}

extension AppViewController: SquareLogoAnimationViewControllerDelegate {
    func squareLogoAnimationViewControllerDidFinishAnimating(_ squareLogoAnimationViewController: SquareLogoAnimationViewController) {
        updateScreen()
    }
}

extension AppViewController: PermissionsViewControllerDelegate {
    func permissionsViewControllerDidObtainRequiredPermissions(_ permissionsViewController: PermissionsViewController) {
        updateScreen()
    }
}

extension AppViewController: ChooseAuthorizationMethodViewControllerDelegate {
    func chooseAuthorizationMethodViewControllerDidChooseScanQRCode(_ chooseAuthorizationMethodViewController: ChooseAuthorizationMethodViewController) {
        let qrAuthorizationViewController = QRAuthorizationViewController()
        qrAuthorizationViewController.delegate = self
        show(viewController: qrAuthorizationViewController)
    }
    
    func chooseAuthorizationMethodViewControllerDidChooseManualCodeEntry(_ chooseAuthorizationMethodViewController: ChooseAuthorizationMethodViewController) {
        let manualAuthorizationViewController = ManualAuthorizationViewController()
        manualAuthorizationViewController.delegate = self
        show(viewController: manualAuthorizationViewController)
    }
}

extension AppViewController: QRAuthorizationViewControllerDelegate {
    func qrAuthorizationViewController(_ qrAuthorizationViewController: QRAuthorizationViewController, didRecognizeAuthorizationCode code: String) {
        let authorizeViewController = AuthorizeViewController(authorizationCode: code)
        authorizeViewController.delegate = self
        show(viewController: authorizeViewController)
    }
    
    func qrAuthorizationViewControllerDidCancel(_ qrAuthorizationViewController: QRAuthorizationViewController) {
        updateScreen()
    }
}

extension AppViewController: ManualAuthorizationViewControllerDelegate {
    func manualAuthorizationViewController(_ manualAuthorizationViewController: ManualAuthorizationViewController, didFinishEnteringAuthorizationCode code: String) {
        let authorizeViewController = AuthorizeViewController(authorizationCode: code)
        authorizeViewController.delegate = self
        show(viewController: authorizeViewController)
    }
    
    func manualAuthorizationViewControllerDidCancel(_ manualAuthorizationViewController: ManualAuthorizationViewController) {
        updateScreen()
    }
}

extension AppViewController: AuthorizeViewControllerDelegate {
    func authorizeViewControllerDidFailAuthorization(_ finishAuthorizationViewController: AuthorizeViewController) {
        updateScreen()
    }
    
    func authorizeViewControllerDidCompleteAuthorization(_ finishAuthorizationViewController: AuthorizeViewController) {
        updateScreen()
    }
}

extension AppViewController: DeauthorizeViewControllerDelegate {
    func deauthorizeViewControllerDidFailDeauthorization(_ deauthorizationViewController: DeauthorizeViewController) {
        updateScreen()
    }
    
    func deauthorizeViewControllerDidCompleteDeauthorization(_ deauthorizationViewController: DeauthorizeViewController) {
        updateScreen()
    }
}

extension AppViewController: PayViewControllerDelegate {
    func payViewControllerDidRequestDeauthorization(_ payViewController: PayViewController) {
        let deauthorizeViewController = DeauthorizeViewController()
        deauthorizeViewController.delegate = self
        show(viewController: deauthorizeViewController)
    }
}

// MARK: - Transitions
extension AppViewController {
    /// Show the provided view controller
    public func show(viewController newViewController: UIViewController) {
        // If we're already displaying a view controller, transition to the new one.
        if let oldViewController = currentViewController,
            type(of: newViewController) != type(of: oldViewController) {
            transition(from: oldViewController, to: newViewController)
            
        } else if currentViewController == nil {
            // Add the view controller as a child view controller
            addChildViewController(newViewController)
            newViewController.view.frame = view.bounds
            view.addSubview(newViewController.view)
            newViewController.didMove(toParentViewController: self)
        }
    }
    
    /// Transition from one child view controller to another
    private func transition(from fromViewController: UIViewController, to toViewController: UIViewController) {
        // Remove any leftover child view controllers
        childViewControllers.forEach { (childViewController) in
            if childViewController != fromViewController {
                childViewController.willMove(toParentViewController: nil)
                childViewController.view.removeFromSuperview()
                childViewController.removeFromParentViewController()
            }
        }
        
        addChildViewController(toViewController)
        fromViewController.willMove(toParentViewController: nil)
    
        toViewController.view.alpha = 0
        toViewController.view.layoutIfNeeded()
        
        let animations = {
            fromViewController.view.alpha = 0
            toViewController.view.alpha = 1
        }
        
        let completion: (Bool) -> Void = { _ in
            fromViewController.view.removeFromSuperview()
            fromViewController.removeFromParentViewController()
            toViewController.didMove(toParentViewController: self)
        }
        
        transition(from: fromViewController,
                   to: toViewController,
                   duration: 0.25,
                   options: [],
                   animations: animations,
                   completion: completion)
    }
}

