//
//  Copyright © 2019 Qonto. All rights reserved.
//

import CoreLocation
import Foundation
import UserNotifications
import XCTest

@objc public class SBTUITunneledApplication: XCUIApplication, SBTUITestTunnelClientDelegate, SBTUITestTunnelClientProtocol {
    @objc private var client: SBTUITestTunnelClient!

    override init() {
        super.init()

        client = SBTUITestTunnelClient(application: self)
        client.delegate = self
    }

    #if ENABLE_UITUNNEL_SWIZZLING
        class func load() -> XCTestCase {
            struct Static {
                static let instance: XCTestCase = XCTestCase.loadSwizzles()
            }
            return Static.instance
        }
    #endif

    /**
     *  Launch application synchronously waiting for the tunnel server connection to be established.
     *
     *  @param options List of options to be passed on launch.
     *  Valid options:
     *  SBTUITunneledApplicationLaunchOptionResetFilesystem: delete app's filesystem sandbox
     *  SBTUITunneledApplicationLaunchOptionDisableUITextFieldAutocomplete disables UITextField's autocomplete functionality which can lead to unexpected results when typing text.
     *
     *  @param startupBlock Block that is executed before connection is estabilished.
     *  Useful to inject startup condition (user settings, preferences).
     *  Note: commands sent in the completionBlock will return nil
     */
    @objc public func launchTunnel(withOptions options: [String]?, startupBlock: (() -> Void)? = nil) {
        var launchArguments = self.launchArguments

        if let options = options {
            launchArguments.append(contentsOf: options)
        }

        self.launchArguments = launchArguments

        launchTunnel(withStartupBlock: startupBlock)
    }

    // MARK: - SBTUITestTunnelClientDelegate

    @objc public func testTunnelClientIsReady(toLaunch sender: SBTUITestTunnelClient) {
        launch()
    }

    @objc public func testTunnelClient(_: SBTUITestTunnelClient, didShutdownWithError error: Error?) {
        if error != nil {
            assert(false, error!.localizedDescription)
        }
        super.terminate()
    }
}

// MARK: - SBTUITestTunnelClientProtocol

extension SBTUITunneledApplication {
    public func launchTunnel() {
        launchTunnel(withStartupBlock: nil)
    }

    @objc public func launchTunnel(withStartupBlock: (() -> Void)?) {
        client.launchTunnel(withStartupBlock: withStartupBlock)
    }

    public func launchConnectionless(_ command: @escaping (String, [String: String]) -> String) {
        client.launchConnectionless(command)
    }

    public override func terminate() {
        client.terminate()
    }

    public func setConnectionTimeout(_ timeout: TimeInterval) {
        client.setConnectionTimeout(timeout)
    }

    public func quit() {
        client.quit()
    }

    // MARK: - Stub Commands

    @discardableResult
    public func stubRequests(matching match: SBTRequestMatch, response: SBTStubResponse) -> String? {
        return client.stubRequests(matching: match, response: response)
    }

    @discardableResult
    public func stubRequests(matching match: SBTRequestMatch, response: SBTStubResponse, removeAfterIterations iterations: UInt) -> String? {
        return client.stubRequests(matching: match, response: response, removeAfterIterations: iterations)
    }

    @discardableResult
    public func stubRequestsRemove(withId stubId: String) -> Bool {
        return client.stubRequestsRemove(withId: stubId)
    }

    @discardableResult
    public func stubRequestsRemove(withIds stubIds: [String]) -> Bool {
        return client.stubRequestsRemove(withIds: stubIds)
    }

    @discardableResult
    public func stubRequestsRemoveAll() -> Bool {
        return client.stubRequestsRemoveAll()
    }

    // MARK: - Rewrite Commands

    @discardableResult
    public func rewriteRequests(matching match: SBTRequestMatch, rewrite: SBTRewrite) -> String? {
        return client.rewriteRequests(matching: match, rewrite: rewrite)
    }

    @discardableResult
    public func rewriteRequests(matching match: SBTRequestMatch, rewrite: SBTRewrite, removeAfterIterations iterations: UInt) -> String? {
        return client.rewriteRequests(matching: match, rewrite: rewrite, removeAfterIterations: iterations)
    }

    @discardableResult
    public func rewriteRequestsRemove(withId rewriteId: String) -> Bool {
        return client.rewriteRequestsRemove(withId: rewriteId)
    }

    @discardableResult
    public func rewriteRequestsRemove(withIds rewriteIds: [String]) -> Bool {
        return client.rewriteRequestsRemove(withIds: rewriteIds)
    }

    @discardableResult
    public func rewriteRequestsRemoveAll() -> Bool {
        return client.rewriteRequestsRemoveAll()
    }

    // MARK: - Monitor Commands

    @discardableResult
    public func monitorRequests(matching match: SBTRequestMatch) -> String? {
        return client.monitorRequests(matching: match)
    }

    @discardableResult
    public func monitoredRequestsPeekAll() -> [SBTMonitoredNetworkRequest] {
        return client.monitoredRequestsPeekAll()!
    }

    @discardableResult
    public func monitoredRequestsFlushAll() -> [SBTMonitoredNetworkRequest] {
        return client.monitoredRequestsFlushAll()!
    }

    @discardableResult
    public func monitorRequestRemove(withId reqId: String) -> Bool {
        return client.monitorRequestRemove(withId: reqId)
    }

    @discardableResult
    public func monitorRequestRemove(withIds reqIds: [String]) -> Bool {
        return client.monitorRequestRemove(withIds: reqIds)
    }

    @discardableResult
    public func monitorRequestRemoveAll() -> Bool {
        return client.monitorRequestRemoveAll()
    }

    // MARK: - Synchronously Wait for Requests Commands

    public func waitForMonitoredRequests(matching match: SBTRequestMatch, timeout: TimeInterval) -> Bool {
        return client.waitForMonitoredRequests(matching: match, timeout: timeout)
    }

    public func waitForMonitoredRequests(matching match: SBTRequestMatch, timeout: TimeInterval, iterations: UInt) -> Bool {
        return client.waitForMonitoredRequests(matching: match, timeout: timeout, iterations: iterations)
    }

    // MARK: - Throttle Requests Commands

    @discardableResult
    public func throttleRequests(matching match: SBTRequestMatch, responseTime: TimeInterval) -> String? {
        return client.throttleRequests(matching: match, responseTime: responseTime)
    }

    @discardableResult
    public func throttleRequestRemove(withId reqId: String) -> Bool {
        return client.throttleRequestRemove(withId: reqId)
    }

    @discardableResult
    public func throttleRequestRemove(withIds reqIds: [String]) -> Bool {
        return client.throttleRequestRemove(withIds: reqIds)
    }

    @discardableResult
    public func throttleRequestRemoveAll() -> Bool {
        return client.throttleRequestRemoveAll()
    }

    // MARK: - Cookie Block Requests Commands

    @discardableResult
    public func blockCookiesInRequests(matching match: SBTRequestMatch) -> String? {
        return client.blockCookiesInRequests(matching: match)
    }

    @discardableResult
    public func blockCookiesInRequests(matching match: SBTRequestMatch, iterations: UInt) -> String? {
        return client.blockCookiesInRequests(matching: match, iterations: iterations)
    }

    @discardableResult
    public func blockCookiesRequestsRemove(withId reqId: String) -> Bool {
        return client.blockCookiesRequestsRemove(withId: reqId)
    }

    @discardableResult
    public func blockCookiesRequestsRemove(withIds reqIds: [String]) -> Bool {
        return client.blockCookiesRequestsRemove(withIds: reqIds)
    }

    @discardableResult
    public func blockCookiesRequestsRemoveAll() -> Bool {
        return client.blockCookiesRequestsRemoveAll()
    }

    // MARK: - NSUserDefaults Commands

    @discardableResult
    public func userDefaultsSet(object: NSCoding, forKey key: String) -> Bool {
        return client.userDefaultsSet(object: object, forKey: key)
    }

    @discardableResult
    public func userDefaultsRemoveObject(forKey key: String) -> Bool {
        return client.userDefaultsRemoveObject(forKey: key)
    }

    @discardableResult
    public func userDefaultsObject(forKey key: String) -> Any? {
        return client.userDefaultsObject(forKey: key)
    }

    @discardableResult
    public func userDefaultsReset() -> Bool {
        return client.userDefaultsReset()
    }

    @discardableResult
    public func userDefaultsSet(object: NSCoding, forKey key: String, suiteName: String) -> Bool {
        return client.userDefaultsSet(object: object, forKey: key, suiteName: suiteName)
    }

    @discardableResult
    public func userDefaultsRemoveObject(forKey key: String, suiteName: String) -> Bool {
        return client.userDefaultsRemoveObject(forKey: key, suiteName: suiteName)
    }

    @discardableResult
    public func userDefaultsObject(forKey key: String, suiteName: String) -> Any? {
        return client.userDefaultsObject(forKey: key, suiteName: suiteName)
    }

    @discardableResult
    public func userDefaultsReset(suiteName: String) -> Bool {
        return client.userDefaultsResetSuiteName(suiteName)
    }

    // TODO: Remove Method
    public func userDefaultsResetSuiteName(_ suiteName: String) -> Bool {
        return userDefaultsReset(suiteName: suiteName)
    }

    // MARK: - NSBundle

    @discardableResult
    public func mainBundleInfoDictionary() -> [String: Any]? {
        return client.mainBundleInfoDictionary()
    }

    // MARK: - Copy Commands

    @discardableResult
    @objc public func uploadItem(atPath srcPath: String?, toPath destPath: String?, relativeTo baseFolder: FileManager.SearchPathDirectory) -> Bool {
        return client.uploadItem(atPath: srcPath, toPath: destPath, relativeTo: baseFolder)
    }

    @discardableResult
    public func downloadItems(fromPath path: String, relativeTo baseFolder: FileManager.SearchPathDirectory) -> [Data]? {
        return client.downloadItems(fromPath: path, relativeTo: baseFolder)
    }

    // MARK: - Custom Commands

    @discardableResult
    public func performCustom(commandName: String, object: Any?) -> Any? {
        return client.performCustom(commandName: commandName, object: object)
    }

    // MARK: - Other Commands

    @discardableResult
    public func setUserInterfaceAnimations(enabled: Bool) -> Bool {
        return client.setUserInterfaceAnimations(enabled: enabled)
    }

    @discardableResult
    public func userInterfaceAnimationsEnabled() -> Bool {
        return client.animationsEnabled()
    }

    @discardableResult
    public func setUserInterfaceAnimation(speed: Int) -> Bool {
        return client.setUserInterfaceAnimation(speed: speed)
    }

    @discardableResult
    public func userInterfaceAnimationSpeed() -> Int {
        return client.animationSpeed()
    }

    // MARK: - XCUITest scroll extensions

    @discardableResult
    public func scrollTableView(withIdentifier identifier: String, toRow row: Int, animated flag: Bool) -> Bool {
        return client.scrollTableView(withIdentifier: identifier, toRow: row, animated: flag)
    }

    @discardableResult
    public func scrollCollectionView(withIdentifier identifier: String, toRow row: Int, animated flag: Bool) -> Bool {
        return client.scrollCollectionView(withIdentifier: identifier, toRow: row, animated: flag)
    }

    @discardableResult
    public func scrollScrollView(withIdentifier identifier: String, toElementWitIdentifier targetIdentifier: String, animated flag: Bool) -> Bool {
        return client.scrollScrollView(withIdentifier: identifier, toElementWitIdentifier: targetIdentifier, animated: flag)
    }

    // MARK: - XCUITest 3D touch extensions

    @discardableResult
    public func forcePressView(withIdentifier identifier: String) -> Bool {
        return client.forcePressView(withIdentifier: identifier)
    }

    // MARK: - XCUITest CLLocation extensions

    @discardableResult
    public func coreLocationStub(enabled flag: Bool) -> Bool {
        return client.coreLocationStub(enabled: flag)
    }

    @discardableResult
    public func coreLocationStubAuthorization(status: CLAuthorizationStatus) -> Bool {
        return client.coreLocationStubAuthorization(status: status)
    }

    @discardableResult
    public func coreLocationStubLocationServices(enabled flag: Bool) -> Bool {
        return client.coreLocationStubLocationServices(enabled: flag)
    }

    // MARK: - XCUITest UNUserNotificationCenter extensions

    @discardableResult
    public func coreLocationNotifyLocationUpdate(locations: [CLLocation]) -> Bool {
        return client.coreLocationNotifyLocationUpdate(locations: locations)
    }

    @discardableResult
    public func coreLocationNotifyLocation(error: Error) -> Bool {
        return client.coreLocationNotifyLocation(error: error)
    }

    @discardableResult
    public func notificationCenterStub(enabled flag: Bool) -> Bool {
        return client.notificationCenterStub(enabled: flag)
    }

    @discardableResult
    public func notificationCenterStubAuthorization(status: UNAuthorizationStatus) -> Bool {
        return client.notificationCenterStubAuthorization(status: status)
    }
}
