//
//  Copyright © 2019 Qonto. All rights reserved.
//

import CoreLocation
import Foundation
import UserNotifications

public extension SBTUITestTunnelClient {
    @objc func coreLocationStub(enabled flag: Bool) -> Bool {
        let params = [
            SBTUITunnelObjectValueKey: flag ? "YES" : "NO",
        ]

        guard let request = sendSynchronousRequest(withPath: SBTUITunneledApplicationCommandCoreLocationStubbing, params: params) else {
            return false
        }

        return NSString(string: request).boolValue
    }

    @objc func coreLocationStubAuthorization(status: CLAuthorizationStatus) -> Bool {
        let params = [
            SBTUITunnelObjectValueKey: NSNumber(value: status.rawValue).stringValue,
        ]

        guard let request = sendSynchronousRequest(withPath: SBTUITunneledApplicationCommandCoreLocationStubAuthorizationStatus, params: params) else {
            return false
        }

        return NSString(string: request).boolValue
    }

    @objc func coreLocationStubLocationServices(enabled flag: Bool) -> Bool {
        let params = [
            SBTUITunnelObjectValueKey: flag ? "YES" : "NO",
        ]

        guard let request = sendSynchronousRequest(withPath: SBTUITunneledApplicationCommandCoreLocationStubServiceStatus, params: params) else {
            return false
        }

        return NSString(string: request).boolValue
    }

    @objc func coreLocationNotifyLocationUpdate(locations: [CLLocation]) -> Bool {
        assert(locations.count > 0, "Location array should contain at least one element!")

        let params = [
            SBTUITunnelObjectKey: base64Serialize(object: locations),
        ] as? [String: String]

        guard let request = sendSynchronousRequest(withPath: SBTUITunneledApplicationCommandCoreLocationNotifyUpdate, params: params) else {
            return false
        }

        return NSString(string: request).boolValue
    }

    @objc func coreLocationNotifyLocation(error: Error) -> Bool {
        let params = [
            SBTUITunnelObjectKey: base64Serialize(object: error),
        ] as? [String: String]

        guard let request = sendSynchronousRequest(withPath: SBTUITunneledApplicationCommandCoreLocationNotifyFailure, params: params) else {
            return false
        }

        return NSString(string: request).boolValue
    }
}
