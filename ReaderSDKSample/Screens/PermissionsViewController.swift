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

protocol PermissionsViewControllerDelegate: class {
    /// Called when the user grants all required permissions
    func permissionsViewControllerDidObtainRequiredPermissions(_ permissionsViewController: PermissionsViewController)
}

/**
 * Request system permissions from the user.
 *
 * Square requires microphone access to swipe credit cards using the headphone jack
 * on your device and location (while your app is in use) to protect buyers and sellers.
 */
final class PermissionsViewController: BaseViewController {
    public weak var delegate: PermissionsViewControllerDelegate?
    
    private lazy var microphoneButton = PrimaryButton(title: "Enable Microphone Access", target: self, selector: #selector(microphoneButtonTapped))
    private lazy var locationButton = PrimaryButton(title: "Enable Location Access", target: self, selector: #selector(locationButtonTapped))
    private lazy var locationManager = CLLocationManager()
    
    /// Returns true if all required permissions have been granted by the user.
    static var areRequiredPermissionsGranted: Bool {
        let locationStatus = CLLocationManager.authorizationStatus()
        let isLocationAccessGranted = (locationStatus == .authorizedWhenInUse || locationStatus == .authorizedAlways)
        let isMicrophoneAccessGranted = AVAudioSession.sharedInstance().recordPermission() == .granted
        return (isLocationAccessGranted && isMicrophoneAccessGranted)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        titleLabel.text = "Grant Reader SDK the\nrequired permissions."
        [microphoneButton, locationButton].forEach(buttonsStackView.addArrangedSubview)
        updateMicrophoneButton()
        updateLocationButton()

        // The user may be directed to the Settings app to change their permissions.
        // When they return, update the button titles.
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(updateMicrophoneButton),
                                               name: .UIApplicationWillEnterForeground,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(updateLocationButton),
                                               name: .UIApplicationWillEnterForeground,
                                               object: nil)
    }
    
    // MARK: - Private Methods
    private func openSettings() {
        if let url = URL(string: UIApplicationOpenSettingsURLString) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
}

// MARK: - Microphone Access
extension PermissionsViewController {
    @objc private func microphoneButtonTapped() {
        switch AVAudioSession.sharedInstance().recordPermission() {
        case .denied:
            openSettings()
        case .undetermined:
            requestMicrophoneAccess()
        case .granted:
            return
        }
    }
    
    private func requestMicrophoneAccess() {
        AVAudioSession.sharedInstance().requestRecordPermission { _ in
            DispatchQueue.main.async {
                self.updateMicrophoneButton()
                
                if PermissionsViewController.areRequiredPermissionsGranted {
                    self.delegate?.permissionsViewControllerDidObtainRequiredPermissions(self)
                }
            }
        }
    }
    
    @objc private func updateMicrophoneButton() {
        let title: String
        let isEnabled: Bool
        
        switch AVAudioSession.sharedInstance().recordPermission() {
        case .denied:
            title = "Enable Microphone in Settings"
            isEnabled = true
        case .granted:
            title = "Microphone Enabled"
            isEnabled = false
        case .undetermined:
            title = "Enable Microphone Access"
            isEnabled = true
        }
        
        microphoneButton.setTitle(title, for: [])
        microphoneButton.isEnabled = isEnabled
    }
}

// MARK: - Location Access
extension PermissionsViewController: CLLocationManagerDelegate {
    @objc private func locationButtonTapped() {
        switch CLLocationManager.authorizationStatus() {
        case .denied, .restricted:
            openSettings()
        case .notDetermined:
            requestLocationAccess()
        case .authorizedAlways, .authorizedWhenInUse:
            return
        }
    }
    
    private func requestLocationAccess() {
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        updateLocationButton()
        
        if PermissionsViewController.areRequiredPermissionsGranted {
            delegate?.permissionsViewControllerDidObtainRequiredPermissions(self)
        }
    }
    
    @objc private func updateLocationButton() {
        let title: String
        let isEnabled: Bool
        
        switch CLLocationManager.authorizationStatus() {
        case .denied, .restricted:
            title = "Enable Location in Settings"
            isEnabled = true
        case .authorizedAlways, .authorizedWhenInUse:
            title = "Location Granted"
            isEnabled = false
        case .notDetermined:
            title = "Enable Location Access"
            isEnabled = true
        }
        
        locationButton.setTitle(title, for: [])
        locationButton.isEnabled = isEnabled
    }
}
