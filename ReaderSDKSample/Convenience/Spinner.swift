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
import QuartzCore

class Spinner: UIView {
    private let imageView = UIImageView(image: #imageLiteral(resourceName: "Spinner"))
    private let rotationKey = "SpinnerRotation"
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = nil
        imageView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(imageView)
        
        NSLayoutConstraint.activate([
            imageView.widthAnchor.constraint(equalTo: widthAnchor),
            imageView.heightAnchor.constraint(equalTo: heightAnchor),
            imageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: centerYAnchor),
        ])
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func startSpinning() {
        DispatchQueue.main.async {
            guard self.imageView.layer.animation(forKey: self.rotationKey) == nil else { fatalError("Already spinning.") }
            
            let spin = CABasicAnimation(keyPath: "transform.rotation")
            spin.fromValue = 0
            spin.toValue = Float.pi * 2
            spin.duration = 1
            spin.repeatCount = .infinity
            
            self.imageView.layer.add(spin, forKey: self.rotationKey)
        }
    }
    
    func stopSpinning() {
        DispatchQueue.main.async {
            if let _ = self.imageView.layer.animation(forKey: self.rotationKey) {
                self.imageView.layer.removeAnimation(forKey: self.rotationKey)
            }
        }
    }
}
