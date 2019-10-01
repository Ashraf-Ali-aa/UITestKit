//
//  Copyright © 2019 Qonto. All rights reserved.
//

#if ENABLE_UITUNNEL && ENABLE_UITUNNEL_SWIZZLING

    import Foundation

    extension XCTestCase {
        @objc func swz_tearDown() {
            app.terminate()

            swz_tearDown()
        }

        class func loadSwizzles() -> XCTestCase {
            struct Static {
                static let instance: XCTestCase = XCTestCase()
            }
            return Static.instance
        }
    }
#endif
