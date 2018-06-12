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

struct SampleApp {
    public static let backgroundColor = #colorLiteral(red: 0.2859145999, green: 0.5706640482, blue: 0.8969199061, alpha: 1)
    
    private static let maxHeight = 812
    public static var additionalSafeAreaInsets: UIEdgeInsets = {
        let idiom = UIDevice.current.userInterfaceIdiom
        if idiom == .pad {
            return UIEdgeInsets(top: 64, left: 64, bottom: 64, right: 64)
        } else {
            return UIEdgeInsets(top: 64, left: 32, bottom: 32, right: 32)
        }
    }()
}
