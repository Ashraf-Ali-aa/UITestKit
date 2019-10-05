//
//  Copyright © 2019 Qonto. All rights reserved.
//

import Foundation

public extension SBTUITestTunnelClient {
    @objc func throttleRequests(matching match: SBTRequestMatch, responseTime: TimeInterval) -> String? {
        let params = [
            SBTUITunnelProxyQueryRuleKey: base64Serialize(object: match),
            SBTUITunnelProxyQueryResponseTimeKey: NSNumber(value: responseTime).stringValue,
        ] as? [String: String]

        return sendSynchronousRequest(withPath: SBTUITunneledApplicationCommandThrottleMatching, params: params)
    }

    @objc func throttleRequestRemove(withId reqId: String) -> Bool {
        let params = [
            SBTUITunnelProxyQueryRuleKey: base64Serialize(object: reqId),
        ] as? [String: String]

        guard let request = sendSynchronousRequest(withPath: SBTUITunneledApplicationCommandThrottleRemove, params: params) else {
            return false
        }

        return NSString(string: request).boolValue
    }

    @objc func throttleRequestRemove(withIds reqIds: [String]) -> Bool {
        return reqIds.map { throttleRequestRemove(withId: $0) }.allSatisfy { $0 == true }
    }

    @objc func throttleRequestRemoveAll() -> Bool {
        guard let request = sendSynchronousRequest(withPath: SBTUITunneledApplicationCommandThrottleRemoveAll, params: nil) else {
            return false
        }

        return NSString(string: request).boolValue
    }
}
