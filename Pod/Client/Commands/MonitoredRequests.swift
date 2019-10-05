//
//  Copyright © 2019 Qonto. All rights reserved.
//

import Foundation

public extension SBTUITestTunnelClient {
    @objc func monitorRequests(matching match: SBTRequestMatch) -> String? {
        let params = [
            SBTUITunnelProxyQueryRuleKey: base64Serialize(object: match),
        ] as? [String: String]

        return sendSynchronousRequest(withPath: SBTUITunneledApplicationCommandMonitorMatching, params: params)
    }

    @objc func monitoredRequestsPeekAll() -> [SBTMonitoredNetworkRequest]? {
        guard
            let objectBase64 = sendSynchronousRequest(withPath: SBTUITunneledApplicationCommandMonitorPeek, params: nil),
            let objectData = Data(base64Encoded: objectBase64, options: []) else {
            return nil
        }

        return NSKeyedUnarchiver.unarchiveObject(with: objectData) as? [SBTMonitoredNetworkRequest]
    }

    @objc func monitoredRequestsFlushAll() -> [SBTMonitoredNetworkRequest]? {
        guard
            let objectBase64 = sendSynchronousRequest(withPath: SBTUITunneledApplicationCommandMonitorFlush, params: nil),
            let objectData = Data(base64Encoded: objectBase64, options: []) else {
            return nil
        }

        return NSKeyedUnarchiver.unarchiveObject(with: objectData) as? [SBTMonitoredNetworkRequest]
    }

    @objc func monitorRequestRemove(withId reqId: String) -> Bool {
        let params = [
            SBTUITunnelProxyQueryRuleKey: base64Serialize(object: reqId),
        ] as? [String: String]

        guard let request = sendSynchronousRequest(withPath: SBTUITunneledApplicationCommandMonitorRemove, params: params) else {
            return false
        }

        return NSString(string: request).boolValue
    }

    @objc func monitorRequestRemove(withIds reqIds: [String]) -> Bool {
        return reqIds.map { monitorRequestRemove(withId: $0) }.allSatisfy { $0 == true }
    }

    @objc func monitorRequestRemoveAll() -> Bool {
        guard let request = sendSynchronousRequest(withPath: SBTUITunneledApplicationCommandMonitorRemoveAll, params: nil) else {
            return false
        }

        return NSString(string: request).boolValue
    }

    @objc func waitForMonitoredRequests(matching match: SBTRequestMatch, timeout: TimeInterval) -> Bool {
        return waitForMonitoredRequests(matching: match, timeout: timeout, iterations: 1)
    }

    @objc func waitForMonitoredRequests(matching match: SBTRequestMatch, timeout: TimeInterval, iterations: UInt) -> Bool {
        var result = false
        var done = false

        let doneLock = NSLock()

        waitForMonitoredRequests(matching: match, timeout: timeout, iterations: iterations, completionBlock: { didTimeout in
            result = !didTimeout

            doneLock.lock()
            done = true
            doneLock.unlock()
        })

        while !done {
            RunLoop.current.run(until: Date(timeIntervalSinceNow: 0.5))

            doneLock.lock()
            if done {
                doneLock.unlock()
                break
            }
            doneLock.unlock()
        }

        return result
    }

    @objc func waitForMonitoredRequests(matching match: SBTRequestMatch, timeout: TimeInterval, completionBlock: @escaping (_ timeout: Bool) -> Void) {
        waitForMonitoredRequests(matching: match, timeout: timeout, iterations: 1, completionBlock: completionBlock)
    }

    @objc func waitForMonitoredRequests(matching match: SBTRequestMatch, timeout: TimeInterval, iterations: UInt, completionBlock: @escaping (_ timeout: Bool) -> Void) {
        waitForMonitoredRequestsWith(matchingBlock: { request in
            request?.matches(match) ?? false
        }, timeout: timeout, iterations: iterations, completionBlock: completionBlock)
    }

    @objc func waitForMonitoredRequestsWith(matchingBlock: @escaping (SBTMonitoredNetworkRequest?) -> Bool, timeout: TimeInterval, iterations: UInt, completionBlock: @escaping (Bool) -> Void) {
        DispatchQueue.global(qos: .default).async {
            let start = CFAbsoluteTimeGetCurrent()

            var timedout = false

            while !timedout {
                var localIterations = iterations

                guard let requests = self.monitoredRequestsPeekAll() else {
                    return
                }

                for request in requests {
                    if matchingBlock(request) {
                        localIterations -= 1
                        if localIterations == 0 {
                            break
                        }
                    }
                }

                if localIterations < 1 {
                    break
                } else if CFAbsoluteTimeGetCurrent() - start > timeout {
                    timedout = true
                    break
                }

                Thread.sleep(forTimeInterval: 0.5)
            }

            completionBlock(timedout)
        }
    }
}
