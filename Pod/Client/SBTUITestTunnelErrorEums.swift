//
//  Copyright © 2019 Qonto. All rights reserved.
//

import Foundation

@objc public enum SBTUITestTunnelError: Int {
    case launchFailed                  = 101
    case connectionToApplicationFailed = 201
    case otherFailure                  = 301
}
