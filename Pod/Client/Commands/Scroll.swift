//
//  Copyright © 2019 Qonto. All rights reserved.
//

import Foundation

public extension SBTUITestTunnelClient {
    @objc func scrollTableView(withIdentifier identifier: String, toRow row: Int, animated flag: Bool) -> Bool {
        assert(identifier.count > 0, "Invalid empty identifier!")

        let params = [
            SBTUITunnelObjectKey: identifier,
            SBTUITunnelObjectValueKey: NSNumber(value: row).stringValue,
            SBTUITunnelObjectAnimatedKey: NSNumber(value: flag).stringValue,
        ]

        guard let request = sendSynchronousRequest(withPath: SBTUITunneledApplicationCommandXCUIExtensionScrollTableView, params: params) else {
            return false
        }

        return NSString(string: request).boolValue
    }

    @objc func scrollCollectionView(withIdentifier identifier: String, toRow row: Int, animated flag: Bool) -> Bool {
        assert(identifier.count > 0, "Invalid empty identifier!")

        let params = [
            SBTUITunnelObjectKey: identifier,
            SBTUITunnelObjectValueKey: NSNumber(value: row).stringValue,
            SBTUITunnelObjectAnimatedKey: NSNumber(value: flag).stringValue,
        ]

        guard let request = sendSynchronousRequest(withPath: SBTUITunneledApplicationCommandXCUIExtensionScrollCollectionView, params: params) else {
            return false
        }

        return NSString(string: request).boolValue
    }

    @objc func scrollScrollView(withIdentifier identifier: String, toElementWitIdentifier targetIdentifier: String, animated flag: Bool) -> Bool {
        assert(identifier.count > 0, "Invalid empty identifier!")
        assert(targetIdentifier.count > 0, "Invalid empty target identifier!")

        let params = [
            SBTUITunnelObjectKey: identifier,
            SBTUITunnelObjectValueKey: targetIdentifier,
            SBTUITunnelObjectAnimatedKey: NSNumber(value: flag).stringValue,
        ]

        guard let request = sendSynchronousRequest(withPath: SBTUITunneledApplicationCommandXCUIExtensionScrollScrollView, params: params) else {
            return false
        }

        return NSString(string: request).boolValue
    }
}
