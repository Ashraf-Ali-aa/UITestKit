//
//  Copyright © 2019 Qonto. All rights reserved.
//

import Foundation

public extension SBTUITestTunnelClient {
    @objc func stubRequests(matching match: SBTRequestMatch, response: SBTStubResponse) -> String? {
        return stubRequests(matching: match, response: response, removeAfterIterations: 0)
    }

    @objc func stubRequests(matching match: SBTRequestMatch, response: SBTStubResponse, removeAfterIterations iterations: UInt) -> String? {
        let params = [
            SBTUITunnelStubMatchRuleKey: base64Serialize(object: match),
            SBTUITunnelStubResponseKey: base64Serialize(object: response),
            SBTUITunnelStubIterationsKey: NSNumber(value: iterations).stringValue,
        ] as? [String: String]

        return sendSynchronousRequest(withPath: SBTUITunneledApplicationCommandStubAndRemoveMatching, params: params)
    }

    @objc func stubRequestsRemove(withId stubId: String?) -> Bool {
        let params = [
            SBTUITunnelStubMatchRuleKey: base64Serialize(object: stubId as Any),
        ] as? [String: String]

        guard let request = sendSynchronousRequest(withPath: SBTUITunneledApplicationCommandStubRequestsRemove, params: params) else {
            return false
        }
        return NSString(string: request).boolValue
    }

    @objc func stubRequestsRemove(withIds stubIds: [String]) -> Bool {
        return stubIds.map { stubRequestsRemove(withId: $0) }.allSatisfy { $0 == true }
    }

    @objc func stubRequestsRemoveAll() -> Bool {
        guard let request = sendSynchronousRequest(withPath: SBTUITunneledApplicationCommandStubRequestsRemoveAll, params: nil) else {
            return false
        }
        return NSString(string: request).boolValue
    }
}
