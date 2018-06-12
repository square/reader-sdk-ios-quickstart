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

class SecondaryButton: UIButton {
    struct Color {
        static let title = UIColor.white
        static let disabledTitle = #colorLiteral(red: 0.6424661279, green: 0.7832983136, blue: 0.947729528, alpha: 1)
        static let background = UIColor.clear
        static let highlightedBackground = UIColor.white.withAlphaComponent(0.1)
        static let border = UIColor.white.withAlphaComponent(0.7)
    }
    
    override var isHighlighted: Bool {
        didSet {
            backgroundColor = isHighlighted ? Color.highlightedBackground : Color.background
        }
    }
    
    convenience init(title: String, target: Any, selector: Selector) {
        self.init()
        
        // Default state
        setTitle(title, for: [])
        setTitleColor(Color.title, for: [])
        setTitleColor(Color.disabledTitle, for: .disabled)
        titleLabel?.font = .systemFont(ofSize: 20, weight: .semibold)
        backgroundColor = Color.background
        translatesAutoresizingMaskIntoConstraints = false
        heightAnchor.constraint(equalToConstant: 64).isActive = true
        layer.cornerRadius = 8
        layer.masksToBounds = true
        layer.borderColor = SecondaryButton.Color.border.cgColor
        layer.borderWidth = 1.0
        addTarget(target, action: selector, for: .touchUpInside)
    }
}
