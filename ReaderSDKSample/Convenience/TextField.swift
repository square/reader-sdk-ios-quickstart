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

class TextField: UITextField {
    struct Color {
        static let background = #colorLiteral(red: 0.3247028589, green: 0.6497831941, blue: 1, alpha: 1)
        static let placeholder = UIColor.white.withAlphaComponent(0.5)
        static let text = UIColor.white
    }
    
    override var placeholder: String? {
        didSet {
            guard let newValue = placeholder else { return }
            accessibilityLabel = newValue
            attributedPlaceholder = NSAttributedString(string: newValue, attributes: [
                NSAttributedStringKey.foregroundColor: Color.placeholder
            ])
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        font = UIFont.systemFont(ofSize: 20, weight: .regular)
        textAlignment = .left
        autocorrectionType = .no
        
        backgroundColor = Color.background
        tintColor = .white
        textColor = Color.text
        
        layer.cornerRadius = 8
        layer.masksToBounds = true
        
        let heightConstraint = heightAnchor.constraint(greaterThanOrEqualToConstant: 64)
        heightConstraint.priority = UILayoutPriority.defaultHigh
        heightConstraint.isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.insetBy(dx: 16.0, dy: 10.0)
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return textRect(forBounds: bounds)
    }
}
