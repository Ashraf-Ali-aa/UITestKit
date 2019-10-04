//
//  Copyright © 2019 Qonto. All rights reserved.
//

import Foundation

extension SBTUITestTunnelClient {
//    @objc public func launchTunnel() {
//        launchTunnel(withStartupBlock: nil)
//    }

//    @objc public func launchTunnel(withStartupBlock startupBlock: (() -> Void)? = nil) {
//        guard let app = application else {
//            return
//        }
//
//        var launchArguments = app.launchArguments
//        launchArguments.append(SBTUITunneledApplicationLaunchSignal)
//
//        if startupBlock != nil {
//            launchArguments.append(SBTUITunneledApplicationLaunchOptionHasStartupCommands)
//        }
//
//        self.startupBlock   = startupBlock
//        app.launchArguments = launchArguments
//
//        var launchEnvironment = app.launchEnvironment
//
//        launchEnvironment[SBTUITunneledApplicationLaunchEnvironmentBonjourNameKey] = bonjourName
//
//        app.launchEnvironment = launchEnvironment
//
//        print("[SBTUITestTunnel] Resolving bonjour service \(String(bonjourName ?? "Error"))")
//        bonjourBrowser?.resolve(withTimeout: connectionTimeout)
//
//        delegate?.testTunnelClientIsReady(toLaunch: self)
//
//        waitForAppReady()
//    }

    @objc public func launchConnectionless(_ command: @escaping (String, [String: String]) -> String) {
        connectionlessBlock = command
        shutDownWithError(nil)
    }

    @objc public func terminate() {
        shutDownWithError(nil)
    }

//    @objc public static func setConnection(timeout: TimeInterval) {
//        assert(timeout > 5.0, "[SBTUITestTunnel] Timeout too short!");
    ////        SBTUITunneledApplicationDefaultTimeout = timeout
//    }

    @objc public func quit() {
        sendSynchronousRequest(withPath: SBTUITunneledApplicationCommandQuit, params: nil, assertOnError: false)
    }

    @objc public func stubRequests(matching match: SBTRequestMatch, response: SBTStubResponse) -> String? {
        return stubRequests(matching: match, response: response, removeAfterIterations: 0)
    }

//    @objc public func stubRequests(matching match: SBTRequestMatch?, response: SBTStubResponse?, removeAfterIterations iterations: UInt) -> String? {
//        let params = [
//            SBTUITunnelStubMatchRuleKey: base64SerializeObject(match as Any),
//            SBTUITunnelStubResponseKey: base64SerializeObject(response as Any),
//            SBTUITunnelStubIterationsKey: NSNumber(value: iterations).stringValue
//        ]  as? [String: String]
//
//        return sendSynchronousRequest(withPath: SBTUITunneledApplicationCommandStubAndRemoveMatching, params: params)
//    }

    @objc public func stubRequestsRemove(withId stubId: String?) -> Bool {
        let params = [
            SBTUITunnelStubMatchRuleKey: base64SerializeObject(stubId as Any),
        ] as? [String: String]

        guard let request = sendSynchronousRequest(withPath: SBTUITunneledApplicationCommandStubRequestsRemove, params: params) else {
            return false
        }
        return NSString(string: request).boolValue
    }

    @objc public func stubRequestsRemove(withIds stubIds: [String]) -> Bool {
        return stubIds.map { stubRequestsRemove(withId: $0) }.allSatisfy { $0 == true }
    }

//    @objc public func stubRequestsRemoveAll() -> Bool {
//        guard let request = sendSynchronousRequest(withPath: SBTUITunneledApplicationCommandRewriteRequestsRemoveAll, params: nil) else {
//            return false
//        }
//        return NSString(string: request).boolValue
//    }

    @objc public func rewriteRequests(matching match: SBTRequestMatch, rewrite: SBTRewrite) -> String? {
        return rewriteRequests(matching: match, rewrite: rewrite, removeAfterIterations: 0)
    }

    @objc public func rewriteRequests(matching match: SBTRequestMatch, rewrite: SBTRewrite, removeAfterIterations iterations: UInt) -> String? {
        let params = [
            SBTUITunnelRewriteMatchRuleKey: base64SerializeObject(match as Any),
            SBTUITunnelRewriteKey: base64SerializeObject(rewrite as Any),
            SBTUITunnelRewriteIterationsKey: NSNumber(value: iterations).stringValue,
        ] as? [String: String]

        return sendSynchronousRequest(withPath: SBTUITunneledApplicationCommandRewriteAndRemoveMatching, params: params)
    }

    @objc public func rewriteRequestsRemove(withId rewriteId: String) -> Bool {
        let params = [
            SBTUITunnelRewriteMatchRuleKey: base64SerializeObject(rewriteId),
        ] as? [String: String]

        guard let request = sendSynchronousRequest(withPath: SBTUITunneledApplicationCommandRewriteRequestsRemove, params: params) else {
            return false
        }

        return NSString(string: request).boolValue
    }

    @objc public func rewriteRequestsRemove(withIds rewriteIds: [String]) -> Bool {
        return rewriteIds.map { rewriteRequestsRemove(withId: $0) }.allSatisfy { $0 == true }
    }

    @objc public func rewriteRequestsRemoveAll() -> Bool {
        guard let request = sendSynchronousRequest(withPath: SBTUITunneledApplicationCommandRewriteRequestsRemoveAll, params: nil) else {
            return false
        }

        return NSString(string: request).boolValue
    }

    @objc public func monitorRequests(matching match: SBTRequestMatch) -> String? {
        let params = [
            SBTUITunnelProxyQueryRuleKey: base64SerializeObject(match),
        ] as? [String: String]

        return sendSynchronousRequest(withPath: SBTUITunneledApplicationCommandMonitorMatching, params: params)
    }

//    @objc public func monitoredRequestsPeekAll() -> [SBTMonitoredNetworkRequest]? {
//        guard
//            let objectBase64 = sendSynchronousRequest(withPath: SBTUITunneledApplicationCommandMonitorPeek, params: nil),
//            let objectData   = Data(base64Encoded: objectBase64, options: []) else {
//            return nil
//        }
//
//        return NSKeyedUnarchiver.unarchiveObject(with: objectData) as? [SBTMonitoredNetworkRequest]
//    }

    @objc public func monitoredRequestsFlushAll() -> [SBTMonitoredNetworkRequest]? {
        guard
            let objectBase64 = sendSynchronousRequest(withPath: SBTUITunneledApplicationCommandMonitorFlush, params: nil),
            let objectData = Data(base64Encoded: objectBase64, options: []) else {
            return nil
        }

        return NSKeyedUnarchiver.unarchiveObject(with: objectData) as? [SBTMonitoredNetworkRequest]
    }

    @objc public func monitorRequestRemove(withId reqId: String) -> Bool {
        let params = [
            SBTUITunnelProxyQueryRuleKey: base64SerializeObject(reqId),
        ] as? [String: String]

        guard let request = sendSynchronousRequest(withPath: SBTUITunneledApplicationCommandMonitorRemove, params: params) else {
            return false
        }

        return NSString(string: request).boolValue
    }

    @objc public func monitorRequestRemove(withIds reqIds: [String]) -> Bool {
        return reqIds.map { monitorRequestRemove(withId: $0) }.allSatisfy { $0 == true }
    }

    @objc public func monitorRequestRemoveAll() -> Bool {
        guard let request = sendSynchronousRequest(withPath: SBTUITunneledApplicationCommandMonitorRemoveAll, params: nil) else {
            return false
        }

        return NSString(string: request).boolValue
    }

    @objc public func waitForMonitoredRequests(matching match: SBTRequestMatch, timeout: TimeInterval) -> Bool {
        return waitForMonitoredRequests(matching: match, timeout: timeout, iterations: 1)
    }

    @objc public func waitForMonitoredRequests(matching match: SBTRequestMatch, timeout: TimeInterval, iterations: UInt) -> Bool {
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

    @objc public func throttleRequests(matching match: SBTRequestMatch, responseTime: TimeInterval) -> String? {
        let params = [
            SBTUITunnelProxyQueryRuleKey: base64SerializeObject(match),
            SBTUITunnelProxyQueryResponseTimeKey: NSNumber(value: responseTime).stringValue,
        ] as? [String: String]

        return sendSynchronousRequest(withPath: SBTUITunneledApplicationCommandThrottleMatching, params: params)
    }

    @objc public func throttleRequestRemove(withId reqId: String) -> Bool {
        let params = [
            SBTUITunnelProxyQueryRuleKey: base64SerializeObject(reqId),
        ] as? [String: String]

        guard let request = sendSynchronousRequest(withPath: SBTUITunneledApplicationCommandThrottleRemove, params: params) else {
            return false
        }

        return NSString(string: request).boolValue
    }

    @objc public func throttleRequestRemove(withIds reqIds: [String]) -> Bool {
        return reqIds.map { throttleRequestRemove(withId: $0) }.allSatisfy { $0 == true }
    }

    @objc public func throttleRequestRemoveAll() -> Bool {
        guard let request = sendSynchronousRequest(withPath: SBTUITunneledApplicationCommandThrottleRemoveAll, params: nil) else {
            return false
        }

        return NSString(string: request).boolValue
    }

    public func blockCookiesInRequests(matching match: SBTRequestMatch) -> String? {
        return blockCookiesInRequests(matching: match, iterations: 0)
    }

    @objc public func blockCookiesInRequests(matching match: SBTRequestMatch, iterations: UInt) -> String? {
        let params = [
            SBTUITunnelCookieBlockMatchRuleKey: base64SerializeObject(match),
            SBTUITunnelCookieBlockQueryIterationsKey: NSNumber(value: iterations).stringValue,
        ] as? [String: String]

        return sendSynchronousRequest(withPath: SBTUITunneledApplicationCommandCookieBlockAndRemoveMatching, params: params)
    }

    @objc public func blockCookiesRequestsRemove(withId reqId: String) -> Bool {
        let params = [
            SBTUITunnelCookieBlockMatchRuleKey: base64SerializeObject(reqId),
        ] as? [String: String]

        guard let request = sendSynchronousRequest(withPath: SBTUITunneledApplicationCommandCookieBlockRemove, params: params) else {
            return false
        }

        return NSString(string: request).boolValue
    }

    @objc public func blockCookiesRequestsRemove(withIds reqIds: [String]) -> Bool {
        return reqIds.map { blockCookiesRequestsRemove(withId: $0) }.allSatisfy { $0 == true }
    }

    @objc public func blockCookiesRequestsRemoveAll() -> Bool {
        guard let request = sendSynchronousRequest(withPath: SBTUITunneledApplicationCommandCookieBlockRemoveAll, params: nil) else {
            return false
        }

        return NSString(string: request).boolValue
    }

    @objc public func userDefaultsSetObject(_ object: NSCoding, forKey key: String) -> Bool {
        return userDefaultsSetObject(object, forKey: key, suiteName: "")
    }

    @objc public func userDefaultsRemoveObject(forKey key: String) -> Bool {
        return userDefaultsRemoveObject(forKey: key, suiteName: "")
    }

    @objc public func userDefaultsObject(forKey key: String) -> Any? {
        return userDefaultsObject(forKey: key, suiteName: "")
    }

    @objc public func userDefaultsReset() -> Bool {
        return userDefaultsResetSuiteName("")
    }

    @objc public func userDefaultsSetObject(_ object: NSCoding, forKey key: String, suiteName: String) -> Bool {
        let params = [
            SBTUITunnelObjectKeyKey: key,
            SBTUITunnelObjectKey: base64SerializeObject(object),
            SBTUITunnelUserDefaultSuiteNameKey: suiteName,
        ] as? [String: String]

        guard let request = sendSynchronousRequest(withPath: SBTUITunneledApplicationCommandNSUserDefaultsSetObject, params: params) else {
            return false
        }

        return NSString(string: request).boolValue
    }

    @objc public func userDefaultsRemoveObject(forKey key: String, suiteName: String) -> Bool {
        let params = [
            SBTUITunnelObjectKeyKey: key,
            SBTUITunnelUserDefaultSuiteNameKey: suiteName,
        ]

        guard let request = sendSynchronousRequest(withPath: SBTUITunneledApplicationCommandNSUserDefaultsRemoveObject, params: params) else {
            return false
        }

        return NSString(string: request).boolValue
    }

    @objc public func userDefaultsObject(forKey key: String, suiteName: String) -> Any? {
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

    @objc public func userDefaultsResetSuiteName(_ suiteName: String) -> Bool {
        let params = [
            SBTUITunnelUserDefaultSuiteNameKey: suiteName,
        ]

        guard let request = sendSynchronousRequest(withPath: SBTUITunneledApplicationCommandNSUserDefaultsReset, params: params) else {
            return false
        }

        return NSString(string: request).boolValue
    }

    @objc public func mainBundleInfoDictionary() -> [String: Any]? {
        guard
            let objectBase64 = sendSynchronousRequest(withPath: SBTUITunneledApplicationCommandMainBundleInfoDictionary, params: nil),
            let objectData = Data(base64Encoded: objectBase64, options: []) else {
            return nil
        }

        return NSKeyedUnarchiver.unarchiveObject(with: objectData) as? [String: Any]
    }

//    @objc public func uploadItem(atPath srcPath: String, toPath destPath: String?, relativeTo baseFolder: FileManager.SearchPathDirectory) -> Bool {
//
//        assert(!(srcPath.hasPrefix("file:")), "Call this methon passing srcPath using [NSURL path] not [NSURL absoluteString]!")
//
//
//        guard let data = try? Data(contentsOf: URL(fileURLWithPath: srcPath)) else {
//            return false
//        }
//
//        let params = [
//            SBTUITunnelUploadDataKey: base64SerializeObject(data),
//            SBTUITunnelUploadDestPathKey: base64SerializeObject(destPath ?? ""),
//            SBTUITunnelUploadBasePathKey: NSNumber(value: baseFolder.rawValue).stringValue
//        ] as? [String: String]
//
//        guard let request = sendSynchronousRequest(withPath: SBTUITunneledApplicationCommandUploadData, params: params) else {
//            return false
//        }
//
//        return NSString(string: request).boolValue
//    }
//
//    @objc public func downloadItems(fromPath path: String, relativeTo baseFolder: FileManager.SearchPathDirectory) -> [Data]? {
//        let params = [
//            SBTUITunnelDownloadPathKey: base64SerializeObject(path),
//            SBTUITunnelDownloadBasePathKey: NSNumber(value: baseFolder.rawValue).stringValue
//        ] as? [String: String]
//
//        guard
//            let itemsBase64 = sendSynchronousRequest(withPath: SBTUITunneledApplicationCommandDownloadData, params: params),
//            let itemsData  = Data(base64Encoded: itemsBase64, options: []) else {
//            return nil
//        }
//
//        return NSKeyedUnarchiver.unarchiveObject(with: itemsData) as? [Data]
//    }

    @objc public func performCustomCommandNamed(_ commandName: String, object: Any?) -> Any? {
        let params = [
            SBTUITunnelCustomCommandKey: commandName,
            SBTUITunnelObjectKey: base64SerializeObject(object),
        ] as? [String: String]

        guard
            let objectBase64 = sendSynchronousRequest(withPath: SBTUITunneledApplicationCommandCustom, params: params),
            let objectData = Data(base64Encoded: objectBase64, options: []) else {
            return nil
        }

        return NSKeyedUnarchiver.unarchiveObject(with: objectData)
    }

//    TODO: Import for Objective C
//
//    @objc public func setUserInterfaceAnimationsEnabled(_ enabled: Bool) -> Bool {
//        return true
//    }
//
//    @objc public func setUserInterfaceAnimationSpeed(_ speed: Int) -> Bool {
//        return true
//    }
//
//    @objc public func scrollTableView(withIdentifier identifier: String, toRow row: Int, animated flag: Bool) -> Bool {
//        return true
//    }
//
//    @objc public func scrollCollectionView(withIdentifier identifier: String, toRow row: Int, animated flag: Bool) -> Bool {
//        return true
//    }
//
//    @objc public func scrollScrollView(withIdentifier identifier: String, toElementWitIdentifier targetIdentifier: String, animated flag: Bool) -> Bool {
//        return true
//    }
//
//    @objc public func forcePressView(withIdentifier identifier: String) -> Bool {
//        return true
//    }
//
//    @objc public func coreLocationStubEnabled(_ flag: Bool) -> Bool {
//        return true
//    }
//
//    @objc public func coreLocationStubAuthorizationStatus(_ status: CLAuthorizationStatus) -> Bool {
//        return true
//    }
//
//    @objc public func coreLocationStubLocationServicesEnabled(_ flag: Bool) -> Bool {
//        return true
//    }
//
//    @objc public func coreLocationNotifyLocationUpdate(_ locations: [CLLocation]) -> Bool {
//        return true
//    }
//
//    @objc public func coreLocationNotifyLocationError(_ error: Error) -> Bool {
//        return true
//    }
//
//    @objc public func notificationCenterStubEnabled(_ flag: Bool) -> Bool {
//        return true
//    }
//
//    @objc public func notificationCenterStubAuthorizationStatus(_ status: UNAuthorizationStatus) -> Bool {
//        return true
//    }
//
//    @objc public func userInterfaceAnimationsEnabled() -> Bool {
//        return true
//    }
//
//    @objc public func userInterfaceAnimationSpeed() -> Int {
//        return 0
//    }
}
