//
//  Copyright © 2019 Qonto. All rights reserved.
//

import Foundation

public extension SBTUITestTunnelClient {
    @objc func forcePressView(withIdentifier identifier: String) -> Bool {
        assert(identifier.count > 0, "Invalid empty identifier!")

        let params = [
            SBTUITunnelObjectKey: identifier,
        ]

        guard let request = sendSynchronousRequest(withPath: SBTUITunneledApplicationCommandXCUIExtensionForceTouchView, params: params) else {
            return false
        }

        return NSString(string: request).boolValue
    }

    @objc func mainBundleInfoDictionary() -> [String: Any]? {
        guard
            let objectBase64 = sendSynchronousRequest(withPath: SBTUITunneledApplicationCommandMainBundleInfoDictionary, params: nil),
            let objectData = Data(base64Encoded: objectBase64, options: []) else {
            return nil
        }

        return NSKeyedUnarchiver.unarchiveObject(with: objectData) as? [String: Any]
    }

    @objc func performCustom(commandName: String, object: Any?) -> Any? {
        let objectValue = object == nil ? "nil" : base64Serialize(object: object)

        let params = [
            SBTUITunnelCustomCommandKey: commandName,
            SBTUITunnelObjectKey: objectValue,
        ] as? [String: String]

        guard
            let objectBase64 = sendSynchronousRequest(withPath: SBTUITunneledApplicationCommandCustom, params: params),
            let objectData = Data(base64Encoded: objectBase64, options: []) else {
            return nil
        }

        return NSKeyedUnarchiver.unarchiveObject(with: objectData)
    }

    @objc func base64Serialize(object: Any?) -> String? {
        guard let object = object else {
            return nil
        }

        let objData = NSKeyedArchiver.archivedData(withRootObject: object)

        return base64Serialize(data: objData)
    }

    @objc func base64Serialize(data: Data?) -> String {
        guard let data = data else {
            let error = self.error(withCode: .otherFailure, message: "[SBTUITestTunnel] Failed to serialize object")
            shutDownWithError(error)
            return ""
        }

        return data.base64EncodedString(options: []).addingPercentEncoding(withAllowedCharacters: CharacterSet.alphanumerics) ?? ""
    }

    // TODO: Update method name
    internal func error(withCode code: SBTUITestTunnelError, message: String?) -> Error? {
        let kSBTUITestTunnelErrorDomain = "com.subito.sbtuitesttunnel.error"

        return NSError(
            domain: kSBTUITestTunnelErrorDomain,
            code: Int(code.hashValue),
            userInfo: [
                NSLocalizedDescriptionKey: message ?? "",
            ]
        )
    }
}
