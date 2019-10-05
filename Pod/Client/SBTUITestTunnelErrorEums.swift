//
//  Copyright © 2019 Qonto. All rights reserved.
//

import Foundation

enum SBTUITestTunnelError: UInt {
    case launchFailed = 101
    case connectionToApplicationFailed = 201
    case otherFailure = 301

    func value() -> UInt {
        return rawValue
    }
}
