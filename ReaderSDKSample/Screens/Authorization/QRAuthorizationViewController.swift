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

protocol QRAuthorizationViewControllerDelegate: class {
    func qrAuthorizationViewController(_ qrAuthorizationViewController: QRAuthorizationViewController, didRecognizeAuthorizationCode code: String)
    func qrAuthorizationViewControllerDidCancel(_ qrAuthorizationViewController: QRAuthorizationViewController)
}

class QRAuthorizationViewController: UIViewController {
    public weak var delegate: QRAuthorizationViewControllerDelegate?
    
    lazy var captureSession = AVCaptureSession()
    lazy var previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
    
    lazy var labelContainerView = makeContainerView()
    lazy var label = makeLabel()
    lazy var previewView = makePreviewView()
    lazy var cancelButtonContainerView = makeContainerView()
    lazy var cancelButton = makeCancelButton()

    // MARK: - State
    static var canScanQRCodes: Bool {
        return AVCaptureDevice.default(for: .video) != nil
    }
    
    static var isCameraPermissionGranted: Bool {
        return AVCaptureDevice.authorizationStatus(for: .video) == .authorized
    }
    
    deinit {
        captureSession.stopRunning()
        UIDevice.current.endGeneratingDeviceOrientationNotifications()
    }

    // MARK: - View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        additionalSafeAreaInsets = UIEdgeInsets(top: 0, left: 32, bottom: 32, right: 32)
        view.backgroundColor = .black
        
        labelContainerView.addSubview(label)
        view.addSubview(previewView)
        view.addSubview(labelContainerView)
        cancelButtonContainerView.addSubview(cancelButton)
        view.addSubview(cancelButtonContainerView)
        
        // Observe changes to device orientation
        UIDevice.current.beginGeneratingDeviceOrientationNotifications()
        NotificationCenter.default.addObserver(self, selector: #selector(updateVideoOrientation), name: Notification.Name.UIDeviceOrientationDidChange, object: UIDevice.current)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NSLayoutConstraint.activate([
            previewView.topAnchor.constraint(equalTo: view.topAnchor),
            previewView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            previewView.leftAnchor.constraint(equalTo: view.leftAnchor),
            previewView.rightAnchor.constraint(equalTo: view.rightAnchor),
            
            labelContainerView.topAnchor.constraint(equalTo: view.topAnchor),
            labelContainerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 80),
            labelContainerView.leftAnchor.constraint(equalTo: view.leftAnchor),
            labelContainerView.rightAnchor.constraint(equalTo: view.rightAnchor),
            
            label.bottomAnchor.constraint(equalTo: labelContainerView.bottomAnchor),
            label.leftAnchor.constraint(equalTo: labelContainerView.leftAnchor),
            label.rightAnchor.constraint(equalTo: labelContainerView.rightAnchor),
            label.heightAnchor.constraint(equalToConstant: 80),
            
            cancelButtonContainerView.topAnchor.constraint(equalTo: cancelButtonContainerView.safeAreaLayoutGuide.bottomAnchor, constant: -96),
            cancelButtonContainerView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            cancelButtonContainerView.leftAnchor.constraint(equalTo: view.leftAnchor),
            cancelButtonContainerView.rightAnchor.constraint(equalTo: view.rightAnchor),
            
            cancelButton.bottomAnchor.constraint(equalTo: cancelButtonContainerView.safeAreaLayoutGuide.bottomAnchor),
            cancelButton.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor),
            cancelButton.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor),
        ])
        
        updatePreviewLayerSize()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if QRAuthorizationViewController.isCameraPermissionGranted {
            startCaptureSession()
        } else {
            requestCameraPermission()
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        previewLayer.frame = view.bounds
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        updateVideoOrientation()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        updatePreviewLayerSize()
    }
    
    func updatePreviewLayerSize() {
        // Manually set the frame of the layer
        view.setNeedsLayout()
    }
    
    @objc func updateVideoOrientation() {
        if let connection = previewLayer.connection, connection.isVideoOrientationSupported {
            switch UIDevice.current.orientation {
            case .portrait:
                connection.videoOrientation = .portrait
            case .portraitUpsideDown:
                connection.videoOrientation = .portraitUpsideDown
            case .landscapeLeft:
                connection.videoOrientation = .landscapeRight
            case .landscapeRight:
                connection.videoOrientation = .landscapeLeft
            default:
                break
            }
        }
    }
    
    @objc func cancel() {
        captureSession.stopRunning()
        delegate?.qrAuthorizationViewControllerDidCancel(self)
    }
}

// MARK: - Camera
extension QRAuthorizationViewController: AVCaptureMetadataOutputObjectsDelegate {
    func requestCameraPermission() {
        AVCaptureDevice.requestAccess(for: .video) { (granted) in
            if granted {
                DispatchQueue.main.async {
                    self.startCaptureSession()
                }
            } else if let url = URL(string: UIApplicationOpenSettingsURLString) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
    }
    
    func startCaptureSession() {
        // Add the input to the capture session
        let captureDevice = AVCaptureDevice.default(for: .video)!
        let input = try! AVCaptureDeviceInput(device: captureDevice)
        captureSession.addInput(input)
        
        // Capture metadata output from the session
        let captureMetadataOutput = AVCaptureMetadataOutput()
        captureSession.addOutput(captureMetadataOutput)
        
        // Add ourselves as the delegate, only recognize QR codes
        captureMetadataOutput.setMetadataObjectsDelegate(self, queue: .main)
        captureMetadataOutput.metadataObjectTypes = [AVMetadataObject.ObjectType.qr]
        
        // Add the preview layer and start the capture session
        captureSession.startRunning()
        
        // Update the video orientation to match the current device orientation
        updateVideoOrientation()
    }
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        guard let object = metadataObjects.first as? AVMetadataMachineReadableCodeObject, object.type == .qr,
              let code = object.stringValue else { return }
        
        // Stop capturing frames
        captureSession.stopRunning()
        
        // Notify delegate
        delegate?.qrAuthorizationViewController(self, didRecognizeAuthorizationCode: code)
    }
}

// MARK: - UI
extension QRAuthorizationViewController {
    private func makeContainerView() -> UIView {
        let containerView = UIView()
        containerView.backgroundColor = UIColor.black.withAlphaComponent(0.75)
        containerView.translatesAutoresizingMaskIntoConstraints = false
        return containerView
    }
    
    private func makeLabel() -> UILabel {
        let label = UILabel()
        label.text = "Scan a QR code."
        label.textColor = .white
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 24, weight: .semibold)
        label.layer.cornerRadius = 8
        label.layer.masksToBounds = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }
    
    private func makePreviewView() -> UIView {
        let previewView = UIView()
        previewLayer.videoGravity = .resizeAspectFill
        previewView.layer.insertSublayer(previewLayer, at: 0)
        previewView.translatesAutoresizingMaskIntoConstraints = false
        return previewView
    }
    
    private func makeCancelButton() -> UIButton {
        return SecondaryButton(title: "Cancel", target: self, selector: #selector(cancel))
    }
}
