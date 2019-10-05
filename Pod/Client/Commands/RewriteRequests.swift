//
//  Copyright © 2019 Qonto. All rights reserved.
//

import Foundation

public extension SBTUITestTunnelClient {
    @objc func rewriteRequests(matching match: SBTRequestMatch, rewrite: SBTRewrite) -> String? {
        return rewriteRequests(matching: match, rewrite: rewrite, removeAfterIterations: 0)
    }

    @objc func rewriteRequests(matching match: SBTRequestMatch, rewrite: SBTRewrite, removeAfterIterations iterations: UInt) -> String? {
        let params = [
            SBTUITunnelRewriteMatchRuleKey: base64Serialize(object: match as Any),
            SBTUITunnelRewriteKey: base64Serialize(object: rewrite as Any),
            SBTUITunnelRewriteIterationsKey: NSNumber(value: iterations).stringValue,
        ] as? [String: String]

        return sendSynchronousRequest(withPath: SBTUITunneledApplicationCommandRewriteAndRemoveMatching, params: params)
    }

    @objc func rewriteRequestsRemove(withId rewriteId: String) -> Bool {
        let params = [
            SBTUITunnelRewriteMatchRuleKey: base64Serialize(object: rewriteId),
        ] as? [String: String]

        guard let request = sendSynchronousRequest(withPath: SBTUITunneledApplicationCommandRewriteRequestsRemove, params: params) else {
            return false
        }

        return NSString(string: request).boolValue
    }

    @objc func rewriteRequestsRemove(withIds rewriteIds: [String]) -> Bool {
        return rewriteIds.map { rewriteRequestsRemove(withId: $0) }.allSatisfy { $0 == true }
    }

    @objc func rewriteRequestsRemoveAll() -> Bool {
        guard let request = sendSynchronousRequest(withPath: SBTUITunneledApplicationCommandRewriteRequestsRemoveAll, params: nil) else {
            return false
        }

        return NSString(string: request).boolValue
    }
}
