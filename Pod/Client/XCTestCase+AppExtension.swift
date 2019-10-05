//
//  Copyright © 2019 Qonto. All rights reserved.
//

import Foundation
import ObjectiveC
import XCTest

private var kAppAssociatedKey = 0

public extension XCTestCase {
    @objc var app: SBTUITunneledApplication {
        var ret = objc_getAssociatedObject(self, &kAppAssociatedKey)

        if ret == nil {
            ret = SBTUITunneledApplication()
            objc_setAssociatedObject(self, &kAppAssociatedKey, ret, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }

        return ret as! SBTUITunneledApplication
    }
}
