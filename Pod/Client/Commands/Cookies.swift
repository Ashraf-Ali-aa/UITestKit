//
//  Copyright © 2019 Qonto. All rights reserved.
//

import Foundation

public extension SBTUITestTunnelClient {
    func blockCookiesInRequests(matching match: SBTRequestMatch) -> String? {
        return blockCookiesInRequests(matching: match, iterations: 0)
    }

    @objc func blockCookiesInRequests(matching match: SBTRequestMatch, iterations: UInt) -> String? {
        let params = [
            SBTUITunnelCookieBlockMatchRuleKey: base64Serialize(object: match),
            SBTUITunnelCookieBlockQueryIterationsKey: NSNumber(value: iterations).stringValue,
        ] as? [String: String]

        return sendSynchronousRequest(withPath: SBTUITunneledApplicationCommandCookieBlockAndRemoveMatching, params: params)
    }

    @objc func blockCookiesRequestsRemove(withId reqId: String) -> Bool {
        let params = [
            SBTUITunnelCookieBlockMatchRuleKey: base64Serialize(object: reqId),
        ] as? [String: String]

        guard let request = sendSynchronousRequest(withPath: SBTUITunneledApplicationCommandCookieBlockRemove, params: params) else {
            return false
        }

        return NSString(string: request).boolValue
    }

    @objc func blockCookiesRequestsRemove(withIds reqIds: [String]) -> Bool {
        return reqIds.map { blockCookiesRequestsRemove(withId: $0) }.allSatisfy { $0 == true }
    }

    @objc func blockCookiesRequestsRemoveAll() -> Bool {
        guard let request = sendSynchronousRequest(withPath: SBTUITunneledApplicationCommandCookieBlockRemoveAll, params: nil) else {
            return false
        }

        return NSString(string: request).boolValue
    }
}
