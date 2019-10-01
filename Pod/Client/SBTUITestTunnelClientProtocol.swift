//
//  Copyright © 2019 Qonto. All rights reserved.
//

#if DEBUG
    #if !ENABLE_UITUNNEL
        let ENABLE_UITUNNEL = 1
    #endif

    #if !ENABLE_UITUNNEL_SWIZZLING
        let ENABLE_UITUNNEL_SWIZZLING = 1
    #endif
#endif

#if ENABLE_UITUNNEL

    import CoreLocation
    import Foundation
    import UITestKitCommon
    import UserNotifications

    @objc public protocol SBTUITestTunnelClientProtocol: NSObjectProtocol {
        /**
         *  Launch application synchronously waiting for the tunnel server connection to be established.
         */
        @objc public func launchTunnel()

        /**
         *  Launch application synchronously waiting for the tunnel server connection to be established.
         *
         *  @param startupBlock Block that is executed before connection is estabilished.
         *  Useful to inject startup condition (user settings, preferences).
         *  Note: commands sent in the completionBlock will return nil
         */
        @objc func launchTunnel(withStartupBlock startupBlock: (() -> Void)?)

        /**
         *  Internal, don't use.
         */
        @objc func launchConnectionless(_ command: @escaping (String, [String: String]) -> String)

        /**
         * Terminates the tunnel by tidying up the internal state. Informs the delegate once complete so that the delegate can then terminate the application.
         */
        @objc func terminate()

        // MARK: - Timeout

        /**
         *  Change the default timeout for the tunnel connection. Should be used only as a workaround when using the tunnel on very slow hardwares
         *
         *  @param timeout Timeout in seconds
         */
        @objc static func setConnectionTimeout(_ timeout: TimeInterval)

        // MARK: - Quit Command

        @objc func quit()

        // MARK: - Stub Commands

        /**
         *  Stub a request matching a regular expression pattern. The rule is checked against the URL.absoluteString of the request
         *
         *  @param match The match object that contains the matching rules
         *  @param response The object that represents the stubbed response
         *
         *  @return If nil request failed. Otherwise an identifier associated to the newly created stub. Should be used when removing stub using -(BOOL)stubRequestsRemoveWithId:
         */
        @objc func stubRequests(matching match: SBTRequestMatch, response: SBTStubResponse) -> String?

        // MARK: - Stub And Remove Commands

        /**
         *  Stub a request matching a regular expression pattern for a limited number of times. The rule is checked against the URL.absoluteString of the request
         *
         *  @param match The match object that contains the matching rules
         *  @param response The object that represents the stubbed response
         *  @param iterations number of matches after which the stub will be automatically removed
         *
         *  @return `YES` on success
         */
        @objc func stubRequests(matching match: SBTRequestMatch, response: SBTStubResponse, removeAfterIterations iterations: Int) -> String?

        // MARK: - Stub Remove Commands

        /**
         *  Remove a specific stub
         *
         *  @param stubId The identifier that was returned when adding the stub
         *
         *  @return `YES` on success If `NO` the specified identifier wasn't associated to an active stub or request failed
         */
        @objc func stubRequestsRemove(withId stubId: String) -> Bool

        /**
         *  Remove a list of stubs
         *
         *  @param stubIds The identifiers that were returned when adding the stub
         *
         *  @return `YES` on success If `NO` one of the specified identifier were not associated to an active stub or request failed
         */
        @objc func stubRequestsRemove(withIds stubIds: [String]) -> Bool

        /**
         *  Remove all active stubs
         *
         *  @return `YES` on success
         */
        @objc func stubRequestsRemoveAll() -> Bool

        // MARK: - Rewrite Commands

        /**
         *  Rewrite a request matching a regular expression pattern. The rule is checked against the SBTRequestMatch object
         *
         *  @param match The match object that contains the matching rules
         *  @param rewrite The object that represents the rewrite rules
         *
         *  @return If nil request failed. Otherwise an identifier associated to the newly created rewrite. Should be used when removing rewrite using -(BOOL)rewriteRequestsRemoveWithId:
         */
        @objc func rewriteRequests(matching match: SBTRequestMatch, rewrite: SBTRewrite) -> String?

        // MARK: - Rewrite And Remove Commands

        /**
         *  Rewrite a request matching a regular expression pattern for a limited number of times. The rule is checked against the SBTRequestMatch object
         *
         *  @param match The match object that contains the matching rules
         *  @param rewrite The object that represents the rewrite reules
         *  @param iterations number of matches after which the rewrite will be automatically removed
         *
         *  @return `YES` on success
         */
        @objc func rewriteRequests(matching match: SBTRequestMatch, rewrite: SBTRewrite, removeAfterIterations iterations: Int) -> String?

        // MARK: - Rewrite Remove Commands

        /**
         *  Remove a specific rewrite
         *
         *  @param rewriteId The identifier that was returned when adding the rewrite
         *
         *  @return `YES` on success If `NO` the specified identifier wasn't associated to an active rewrite or request failed
         */
        @objc func rewriteRequestsRemove(withId rewriteId: String) -> Bool

        /**
         *  Remove a list of rewrites
         *
         *  @param rewriteIds The identifiers that were returned when adding the rewrite
         *
         *  @return `YES` on success If `NO` one of the specified identifier were not associated to an active rewrite or request failed
         */
        @objc func rewriteRequestsRemove(withIds rewriteIds: [String]) -> Bool

        /**
         *  Remove all active rewrites
         *
         *  @return `YES` on success
         */
        @objc func rewriteRequestsRemoveAll() -> Bool

        // MARK: - Monitor Requests Commands

        /**
         *  Start monitoring requests matching a regular expression pattern. The rule is checked against the SBTRequestMatch object
         *
         *  The monitored events can be successively polled using the monitoredRequestsFlushAll method.
         *
         *  @param match The match object that contains the matching rules
         *
         *  @return If nil request failed. Otherwise an identifier associated to the newly created monitor probe. Should be used when using -(BOOL)monitorRequestRemoveWithId:
         */
        @objc func monitorRequests(matching match: SBTRequestMatch) -> String?

        /**
         *  Peek (retrieve) the current list of collected requests
         *
         *  @return The list of monitored requests
         */
        @objc func monitoredRequestsPeekAll() -> [SBTMonitoredNetworkRequest]

        /**
         *  Flushes (retrieve + clear) the current list of collected requests
         *
         *  @return The list of monitored requests
         */
        @objc func monitoredRequestsFlushAll() -> [SBTMonitoredNetworkRequest]

        /**
         *  Remove a request monitor
         *
         *  @param reqId The identifier that was returned when adding the monitor request
         *
         *  @return `YES` on success If `NO` one of the specified identifier was not associated to an active monitor request or request failed
         */
        @objc func monitorRequestRemove(withId reqId: String) -> Bool

        /**
         *  Remove a list of request monitors
         *
         *  @param reqIds The identifiers that were returned when adding the monitor requests
         *
         *  @return `YES` on success If `NO` one of the specified identifier were not associated to an active monitor request or request failed
         */
        @objc func monitorRequestRemove(withIds reqIds: [String]) -> Bool

        /**
         *  Remove all active request monitors
         *
         *  @return `YES` on success
         */
        @objc func monitorRequestRemoveAll() -> Bool

        // MARK: - Synchronously Wait for Requests Commands

        /**
         *  Synchronously wait for a request to happen once on the app target. The rule is checked against the SBTRequestMatch object
         *
         *  Note: you have to start a monitor request before calling this method
         *
         *  @param match The match object that contains the matching rules. The method will look if the specified rules match the existing monitored requests
         *  @param timeout How long to wait for the request to happen
         *
         *  @return `YES` on success, `NO` on timeout
         */
        @objc func waitForMonitoredRequests(matching match: SBTRequestMatch, timeout: TimeInterval) -> Bool

        /**
         *  Synchronously wait for a request to happen a certain number of times on the app target. The rule is checked against the SBTRequestMatch object
         *
         *  Note: you have to start a monitor request before calling this method
         *
         *  @param match The match object that contains the matching rules. The method will look if the specified rules match the existing monitored requests
         *  @param timeout How long to wait for the request to happen
         *  @param iterations How often the request should happen before timing out
         *
         *  @return `YES` on success, `NO` on timeout
         */
        @objc func waitForMonitoredRequests(matching match: SBTRequestMatch, timeout: TimeInterval, iterations: Int) -> Bool

        // MARK: - Throttle Requests Commands

        /**
         *  Start throttling requests matching a regular expression pattern. The rule is checked against the SBTRequestMatch object
         *
         *  The throttled events can be successively polled using the throttledRequestsFlushAll method.
         *
         *  @param match The match object that contains the matching rules
         *  @param responseTime If positive, the amount of time used to send the entire response. If negative, the rate in KB/s at which to send the response data. Use SBTUITunnelStubsDownloadSpeed* constants
         *
         *  @return If nil request failed. Otherwise an identifier associated to the newly created throttle request. Should be used when using -(BOOL)throttleRequestRemoveWithId:
         */
        @objc func throttleRequests(matching match: SBTRequestMatch, responseTime: TimeInterval) -> String?

        /**
         *  Remove a request throttle
         *
         *  @param reqId The identifier that was returned when adding the throttle request
         *
         *  @return `YES` on success If `NO` one of the specified identifier was not associated to an active throttle request or request failed
         */
        @objc func throttleRequestRemove(withId reqId: String) -> Bool

        /**
         *  Remove a list of request throttles
         *
         *  @param reqIds The identifiers that were returned when adding the throttle requests
         *
         *  @return `YES` on success If `NO` one of the specified identifier were not associated to an active throttle request or request failed
         */
        @objc func throttleRequestRemove(withIds reqIds: [String]) -> Bool

        /**
         *  Remove all active request throttles
         *
         *  @return `YES` on success
         */
        @objc func throttleRequestRemoveAll() -> Bool

        // MARK: - Cookie Block Requests Commands

        /**
         *  Block all cookies found in requests matching a regular expression pattern. The rule is checked against the SBTRequestMatch object
         *
         *  @param match The match object that contains the matching rules
         *
         *  @return If nil request failed. Otherwise an identifier associated to the newly created throttle request. Should be used when using -(BOOL)throttleRequestRemoveWithId:
         */
        @objc func blockCookiesInRequests(matching match: SBTRequestMatch) -> String?

        /**
         *  Block all cookies found in requests matching a regular expression pattern. The rule is checked against the SBTRequestMatch object
         *
         *  @param match The match object that contains the matching rules
         *  @param iterations How often the request should happen before timing out
         *
         *  @return If nil request failed. Otherwise an identifier associated to the newly created throttle request. Should be used when using -(BOOL)throttleRequestRemoveWithId:
         */
        @objc func blockCookiesInRequests(matching match: SBTRequestMatch, iterations: Int) -> String?

        /**
         *  Remove a cookie block request
         *
         *  @param reqId The identifier that was returned when adding the cookie block request
         *
         *  @return `YES` on success If `NO` one of the specified identifier was not associated to an active cookie block request or request failed
         */
        @objc func blockCookiesRequestsRemove(withId reqId: String) -> Bool

        /**
         *  Remove a list of cookie block requests
         *
         *  @param reqIds The identifiers that were returned when adding the cookie block requests
         *
         *  @return `YES` on success If `NO` one of the specified identifier were not associated to an active cookie block request or request failed
         */
        @objc func blockCookiesRequestsRemove(withIds reqIds: [String]) -> Bool

        /**
         *  Remove all cookie block requests
         *
         *  @return `YES` on success
         */
        @objc func blockCookiesRequestsRemoveAll() -> Bool

        // MARK: - NSUserDefaults Commands

        /**
         *  Add object to NSUSerDefaults.
         *
         *  @param object Object to be added
         *  @param key Key associated to object
         *
         *  @return `YES` on success
         */
        @objc func userDefaultsSetObject(_ object: NSCoding, forKey key: String) -> Bool

        /**
         *  Remove object from NSUSerDefaults.
         *
         *  @param key Key associated to object
         *
         *  @return `YES` on success
         */
        @objc func userDefaultsRemoveObject(forKey key: String) -> Bool

        /**
         *  Get object from NSUserDefaults
         *
         *  @param key Key associated to object
         *
         *  @return The retrieved object.
         */
        @objc func userDefaultsObject(forKey key: String, suiteName: String) -> AnyObject?

        /**
         *  Reset NSUserDefaults
         *
         *  @return `YES` on success
         */
        @objc func userDefaultsReset()

        /**
         *  Add object to NSUSerDefaults.
         *
         *  @param object Object to be added
         *  @param key Key associated to object
         *  @param suiteName user defaults database name
         *
         *  @return `YES` on success
         */
        @objc func userDefaultsSetObject(object: AnyObject<NSCoding>, forKey key: string, suiteName: String) -> Bool

        /**
         *  Remove object from NSUSerDefaults.
         *
         *  @param key Key associated to object
         *  @param suiteName user defaults database name
         *
         *  @return `YES` on success
         */
        @objc func userDefaultsRemoveObject(forKey key: String, suiteName: String) -> Bool

        /**
         *  Get object from NSUserDefaults
         *
         *  @param key Key associated to object
         *  @param suiteName user defaults database name
         *
         *  @return The retrieved object.
         */
        @objc func userDefaultsObject(forKey key: String, suiteName: String) -> AnyObject?

        /**
         *  Reset NSUserDefaults
         *
         *  @param suiteName user defaults database name
         *  @return `YES` on success
         */
        @objc func userDefaultsReset(suiteName: String) -> Bool

        // MARK: - NSBundle

        @objc func mainBundleInfoDictionary() -> [String: Any?]?

        // MARK: - Copy Commands

        /**

         *  Upload item to remote host
         *
         *  @param srcPath source path
         *  @param destPath destination path relative to baseFolder
         *  @param baseFolder base folder for destPath
         *
         *  @return `YES` on success
         */
        @objc func uploadItemAtPath(srcPath: String, toPath destPath: String, relativeTo baseFolder: NSSearchPathDirectory) -> Bool

        /**
         *  Download one or more files from remote host
         *
         *  @param path source path (may include wildcard *, i.e ('*.jpg')
         *  @param baseFolder base folder for destPath
         *
         *  @return The data associated to the requested item
         */
        @objc func downloadItemsFromPath(path: String, relativeTo baseFolder: NSSearchPathDirectory) -> [Data]?

        // MARK: - Custom Commands

        /**
         *  Perform custom command.
         *
         *  @param commandName custom name that will match [SBTUITestTunnelServer registerCustomCommandNamed:block:]
         *  @param object optional data to be attached to request
         *
         *  @return object returned from custom block
         */
        @objc func performCustom(commandName: String, object: AnyObject) -> AnyObject?

        // MARK: - Other Commands

        /**
         *  Set user iterface animations through [UIView setAnimationsEnabled:]. Should imporve test execution speed When enabled
         *  Sometimes useful as per https://forums.developer.apple.com/thread/6503
         *
         *  @param enabled enable animations
         *
         *  @return `YES` on success
         */
        @objc func setUserInterfaceAnimations(enabled: Bool) -> Bool

        /**
         *  Get user iterface animations through [UIView setAnimationsEnabled:]. Should imporve test execution speed When enabled
         *  Sometimes useful as per https://forums.developer.apple.com/thread/6503
         *
         *  @return `YES` on when animations are enabled
         */
        @objc func userInterfaceAnimationsEnabled() -> Bool

        /**
         *  Set user iterface animations through UIApplication.sharedApplication.keyWindow.layer.speed. Should imporve test execution speed When enabled
         *
         *  @param speed speed of animation animations
         *
         *  @return `YES` on success
         */
        @objc func setUserInterfaceAnimationSpeed(speed: Int) -> Bool

        /**
         *  Get user iterface animations through UIApplication.sharedApplication.keyWindow.layer.speed. Should imporve test execution speed When enabled
         *
         *  @return current animation speed
         */
        @objc func userInterfaceAnimationSpeed() -> Int

        // MARK: - XCUITest scroll extensions

        /**
         *  Scroll UITablewViews view to the specified row (flattening sections if any).
         *
         *  @param identifier accessibilityIdentifier of the UITableView
         *  @param row the row to scroll the element to. This value flattens sections (if more than one is returned by the dataSource) and is best effort meaning it will stop at the last cell if the passed number if larger than the available cells. Passing NSIntegerMax guarantees to scroll to last cell.
         *  @param flag pass YES to animate the scroll; otherwise, pass NO
         *
         *  @return `YES` on success
         */
        @objc func scrollTableView(WithIdentifier identifier: String, toRow row: Int, animated flag: Bool) -> Bool

        /**
         *  Scroll UICollection view to the specified row (flattening sections if any).
         *
         *  @param identifier accessibilityIdentifier of the UICollectionView
         *  @param row the row to scroll the element to. This value flattens sections (if more than one is returned by the dataSource) and is best effort meaning it will stop at the last cell if the passed number if larger than the available cells. Passing NSIntegerMax guarantees to scroll to last cell.
         *  @param flag pass YES to animate the scroll; otherwise, pass NO
         *
         *  @return `YES` on success
         */
        @objc func scrollCollectionView(WithIdentifier identifier: String, toRow row: Int, animated flag: Bool) -> Bool

        /**
         *  Scroll UIScrollView view to the specified element
         *
         *  @param identifier accessibilityIdentifier of the UIScrollView
         *  @param targetIdentifier accessibilityIdentifier of the element the scroll view should scroll to
         *  @param flag pass YES to animate the scroll; otherwise, pass NO
         *
         *  @return `YES` on success
         */
        @objc func scrollScrollView(WithIdentifier identifier: String, toElementWitIdentifier targetIdentifier: String, animated flag: Bool) -> Bool

        // MARK: - XCUITest 3D touch extensions

        /**
         *  Perform force touch pop interaction on the specified element
         *
         *  @param identifier accessibilityIdentifier of the element to force press
         *
         *  @return `YES` on success
         */
        @objc func forcePressView(withIdentifier identifier: String) -> Bool

        // MARK: - XCUITest CLLocation extensions

        /**
         *  Enable CLLocationManager stubbing
         *
         *  @param flag stubbing status
         *
         *  @return `YES` on success
         */
        @objc func coreLocationStubEnabled(flag: Bool) -> Bool

        /**
         *  Stub CLLocationManager authorizationStatus
         *
         *  @param status location authorization status. The default value returned by `+[CLLocationManager authorizationStatus]` when enabling core location stubbing is kCLAuthorizationStatusAuthorizedAlways
         *
         *  @return `YES` on success
         */
        @objc func coreLocationStubAuthorization(status: CLAuthorizationStatus) -> Bool

        /**
         *  Stub CLLocationManager locationServicesEnabled
         *
         *  @param flag location service status. The default value returned `+[CLLocationManager locationServicesEnabled]` by  when enabling core location stubbing is YES
         *
         *  @return `YES` on success
         */
        @objc func coreLocationStubLocationServicesEnabled(flag: Bool) -> Bool

        /**
         *  Tells all active CLLocationManager's delegates that the location manager
         *  has a new location data available.
         *
         *  @param locations an array of CLLocation objects containing the location data. This array should always contains at least one object representing the current location
         *
         *  @return `YES` on success
         */
        @objc func coreLocationNotifyLocationUpdate(location: [CLLocation]) -> Bool

        /**
         *  Tells all active CLLocationManager's delegates that the location manager
         *  was unable to retrieve a location value.
         *
         *  @param error the error object containing the reason the location or heading could not be retrieved.
         *
         *  @return `YES` on success
         */
        @objc func coreLocationNotifyLocation(error: Error) -> Bool

        // MARK: - XCUITest UNUserNotificationCenter extensions

        /**
         *  Enable UNUserNotificationCenter stubbing
         *
         *  @param flag stubbing status
         *
         *  @return `YES` on success
         */
        @available(iOS 10, *)
        @objc func notificationCenterStubEnabled(_ flag: Bool) -> Bool

        /**
         *  Stub UNUserNotificationCenter authorizationStatus
         *
         *  @param status notification center authorization status. The default value returned by `UNNotificationSettings.authorizationStatus` when enabling notication center stubbing is UNAuthorizationStatusAuthorized
         *
         *  @return `YES` on success
         */
        @available(iOS 10, *)
        @objc func notificationCenterStubAuthorization(status: UNAuthorizationStatus) -> Bool
    }

#endif
