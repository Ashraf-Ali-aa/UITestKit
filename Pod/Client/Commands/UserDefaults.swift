//
//  Copyright © 2019 Qonto. All rights reserved.
//

import Foundation

public extension SBTUITestTunnelClient {
    @objc func userDefaultsSet(object: NSCoding, forKey key: String) -> Bool {
        return userDefaultsSet(object: object, forKey: key, suiteName: "")
    }

    @objc func userDefaultsRemoveObject(forKey key: String) -> Bool {
        return userDefaultsRemoveObject(forKey: key, suiteName: "")
    }

    @objc func userDefaultsObject(forKey key: String) -> Any? {
        return userDefaultsObject(forKey: key, suiteName: "")
    }

    @objc func userDefaultsReset() -> Bool {
        return userDefaultsResetSuiteName("")
    }

    @objc func userDefaultsSet(object: NSCoding, forKey key: String, suiteName: String) -> Bool {
        let params = [
            SBTUITunnelObjectKeyKey: key,
            SBTUITunnelObjectKey: base64Serialize(object: object),
            SBTUITunnelUserDefaultSuiteNameKey: suiteName,
        ] as? [String: String]

        guard let request = sendSynchronousRequest(withPath: SBTUITunneledApplicationCommandNSUserDefaultsSetObject, params: params) else {
            return false
        }

        return NSString(string: request).boolValue
    }

    @objc func userDefaultsRemoveObject(forKey key: String, suiteName: String) -> Bool {
        let params = [
            SBTUITunnelObjectKeyKey: key,
            SBTUITunnelUserDefaultSuiteNameKey: suiteName,
        ]

        guard let request = sendSynchronousRequest(withPath: SBTUITunneledApplicationCommandNSUserDefaultsRemoveObject, params: params) else {
            return false
        }

        return NSString(string: request).boolValue
    }

    @objc func userDefaultsObject(forKey key: String, suiteName: String) -> Any? {
        let params = [
            SBTUITunnelObjectKeyKey: key,
            SBTUITunnelUserDefaultSuiteNameKey: suiteName,
        ]

        guard
            let objectBase64 = sendSynchronousRequest(withPath: SBTUITunneledApplicationCommandNSUserDefaultsObject, params: params),
            let objectData = Data(base64Encoded: objectBase64, options: []) else {
            return nil
        }

        return NSKeyedUnarchiver.unarchiveObject(with: objectData)
    }

    @objc func userDefaultsResetSuiteName(_ suiteName: String) -> Bool {
        let params = [
            SBTUITunnelUserDefaultSuiteNameKey: suiteName,
        ]

        guard let request = sendSynchronousRequest(withPath: SBTUITunneledApplicationCommandNSUserDefaultsReset, params: params) else {
            return false
        }

        return NSString(string: request).boolValue
    }
}
