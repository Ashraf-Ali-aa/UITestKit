//
//  Copyright © 2019 Qonto. All rights reserved.
//

import Foundation

/**
 *  Create an instance of SBTUITestTunnelClientDelegate.
 *
 *  The methods adopted by the object you use to manage the application life-cycle usually an instance of XCUIApplication.
 */
@objc public protocol SBTUITestTunnelClientDelegate: NSObjectProtocol {
    /**
     Informs the delegate that it should launch the XCUIApplication under-test before the tunnel is established.
     It's required that you avoid launching until the delegate is called.

     @param sender An instance of the object sending the message.
     */
    func testTunnelClientIsReady(toLaunch sender: SBTUITestTunnelClient)

    /**
     Informs the delegate than the tunnel did shutdown.

     @param sender An instance of the object sending the message.
     @param error If shutdown was due to an error will be non-nil, if shutdown was normal and expected then error will be nil.
     */
    @objc optional func testTunnelClient(_ sender: SBTUITestTunnelClient, didShutdownWithError error: Error?)
}
