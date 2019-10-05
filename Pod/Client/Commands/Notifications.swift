//
//  Copyright © 2019 Qonto. All rights reserved.
//

import Foundation
import UserNotifications

public extension SBTUITestTunnelClient {
    @objc func notificationCenterStub(enabled flag: Bool) -> Bool {
        let params = [
            SBTUITunnelObjectValueKey: flag ? "YES" : "NO",
        ]

        guard let request = sendSynchronousRequest(withPath: SBTUITunneledApplicationCommandNotificationCenterStubbing, params: params) else {
            return false
        }

        return NSString(string: request).boolValue
    }

    @objc func notificationCenterStubAuthorization(status: UNAuthorizationStatus) -> Bool {
        let params = [
            SBTUITunnelObjectValueKey: NSNumber(value: status.rawValue).stringValue,
        ]

        guard let request = sendSynchronousRequest(withPath: SBTUITunneledApplicationCommandNotificationCenterStubAuthorizationStatus, params: params) else {
            return false
        }

        return NSString(string: request).boolValue
    }
}
