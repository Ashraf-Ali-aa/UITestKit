//
//  Copyright © 2019 Qonto. All rights reserved.
//

import Foundation
import UITestKitCommon
import XCTest

let SBTUITunnelJsonMimeType = "application/json"

let kSBTUITestTunnelErrorDomain = "com.subito.sbtuitesttunnel.error"

@objc public class SBTUITestTunnelClient: NSObject, NetServiceDelegate {
    var userInterfaceAnimationsEnabled = false
    var userInterfaceAnimationSpeed = 0

    private weak var application: XCUIApplication?
    private var connectionPort = 0
    private var connected = false
    private var connectionTimeout: TimeInterval = 0.0
    private var stubOnceIds: [AnyHashable]?
    private var bonjourName: String = ""
    private var bonjourBrowser: NetService?
    private var startupBlock: (() -> Void)?
    private var initialLaunchArguments: [String] = []
    private var initialLaunchEnvironment: [String: String] = [:]
    var connectionlessBlock: ((String, [String: String]) -> String)?
    private var sbtuiTunneledApplicationDefaultTimeout: TimeInterval = 0.0

    public weak var delegate: SBTUITestTunnelClientDelegate?

    private var SBTUITunneledApplicationDefaultTimeout = 30.0

    @objc public init(application: XCUIApplication) {
        super.init()

        initialLaunchArguments = application.launchArguments
        initialLaunchEnvironment = application.launchEnvironment
        self.application = application
        userInterfaceAnimationsEnabled = true
        userInterfaceAnimationSpeed = 1

        resetInternalState()
    }

    @objc func resetInternalState() {
        bonjourBrowser?.stop()

        application?.launchArguments = initialLaunchArguments
        application?.launchEnvironment = initialLaunchEnvironment

        startupBlock = nil

        bonjourName = String(format: "com.subito.test.%d.%.0f", ProcessInfo.processInfo.processIdentifier, Double(CFAbsoluteTimeGetCurrent() * 100_000))
        bonjourBrowser = NetService(domain: "local.", type: "_http._tcp.", name: bonjourName)
        bonjourBrowser?.delegate = self
        connected = false
        connectionPort = 0
        connectionTimeout = SBTUITunneledApplicationDefaultTimeout
    }

    @objc func shutDownWithError(_ error: Error?) {
        sendSynchronousRequest(withPath: SBTUITunneledApplicationCommandShutDown, params: nil, assertOnError: false)

        resetInternalState()

        if delegate?.responds(to: #selector(delegate?.testTunnelClient(_:didShutdownWithError:))) ?? true {
            delegate?.testTunnelClient?(self, didShutdownWithError: error)
        }
    }

    @objc public func launchTunnel() {
        launchTunnel(withStartupBlock: nil)
    }

    @objc public func launchTunnel(withStartupBlock startupBlock: (() -> Void)? = nil) {
        var launchArguments: [String] = application?.launchArguments ?? []
        launchArguments.append(SBTUITunneledApplicationLaunchSignal)

        if startupBlock != nil {
            launchArguments.append(SBTUITunneledApplicationLaunchOptionHasStartupCommands)
        }

        self.startupBlock = startupBlock
        application?.launchArguments = launchArguments

        var launchEnvironment = application?.launchEnvironment
        launchEnvironment?[SBTUITunneledApplicationLaunchEnvironmentBonjourNameKey] = bonjourName

        application?.launchEnvironment = launchEnvironment ?? [:]

        print("[SBTUITestTunnel] Resolving bonjour service \(bonjourName)")
        bonjourBrowser?.resolve(withTimeout: connectionTimeout)

        delegate?.testTunnelClientIsReady(toLaunch: self)

        waitForAppReady()
    }

    @objc func setConnectionTimeout(_ timeout: TimeInterval) {
        assert(timeout > 5.0, "[SBTUITestTunnel] Timeout too short!")
        SBTUITunneledApplicationDefaultTimeout = timeout
    }

    @objc func waitForAppReady() {
        let timeout = Int(connectionTimeout)

        for _ in 0 ..< timeout {
            if isAppCruising() {
                return
            }
            RunLoop.current.run(until: Date(timeIntervalSinceNow: 1.0))
        }

        let error = self.error(withCode: .launchFailed, message: "Failed waiting for app to be ready")
        shutDownWithError(error)
    }

    @objc public func netServiceDidResolveAddress(_ service: NetService) {
        if service.name == bonjourName, !connected {
            assert(service.port > 0, "[SBTUITestTunnel] unexpected port 0!")

            connected = true

            print(String(format: "[SBTUITestTunnel] Tunnel established on port %ld", UInt(service.port)))
            connectionPort = service.port

            if startupBlock != nil {
                startupBlock!() // this will eventually add some commands in the startup command queue
            }

            sendSynchronousRequest(withPath: SBTUITunneledApplicationCommandStartupCommandsCompleted, params: [:])
        }
    }

    @objc public func netService(_ sender: NetService, didNotResolve errorDict: [String: NSNumber]) {
        if !connected || !(sender.name == bonjourName) {
            return
        }

        let message = "[SBTUITestTunnel] Failed to connect to client app \(errorDict)"
        let error = self.error(withCode: .connectionToApplicationFailed, message: message)
        shutDownWithError(error)
    }

    @discardableResult
    @objc func sendSynchronousRequest(withPath path: String, params: [String: String]? = [:], assertOnError: Bool) -> String? {
        let options = params ?? [:]

        if connectionlessBlock != nil {
            if Thread.isMainThread {
                return connectionlessBlock!(path, options)
            } else {
                var ret = ""
                weak var weakSelf = self
                DispatchQueue.main.sync {
                    guard let item = weakSelf?.connectionlessBlock else {
                        return
                    }
                    ret = item(path, options)
                }
                return ret
            }
        }

        guard connectionPort != 0 else {
            return nil // connection still not established
        }

        let urlString = "http://\(SBTUITunneledApplicationDefaultHost):\(UInt(connectionPort))/\(path)"

        let url = URL(string: urlString)

        var request: URLRequest?
        var components: URLComponents?
        if let url = url {
            components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        }

        var queryItems: [AnyHashable] = []
        (params as NSDictionary?)?.enumerateKeysAndObjects { key, value, _ in
            let keyItem = key as? String ?? ""
            let valueItem = value as? String ?? ""
            queryItems.append(URLQueryItem(name: keyItem, value: valueItem))
        }
        components?.queryItems = queryItems as? [URLQueryItem]

        if SBTUITunnelHTTPMethod.isEqual("GET") {
            if let URL = components?.url {
                request = URLRequest(url: URL)
            }
        } else if SBTUITunnelHTTPMethod.isEqual("POST") {
            if let url = url {
                request = URLRequest(url: url)
            }

            request?.httpBody = components?.query?.data(using: .utf8)
        }
        request?.httpMethod = SBTUITunnelHTTPMethod

        guard let urlRequest = request else {
            let error = self.error(withCode: .otherFailure, message: "[SBTUITestTunnel] Did fail to create url component")
            shutDownWithError(error)
            return nil
        }

        let synchRequestSemaphore = DispatchSemaphore(value: 0)

        let session = URLSession.shared
        var responseId: String?

        (session.dataTask(with: urlRequest, completionHandler: { data, response, error in
            if (error as NSError?)?.code == -1022 {
                assert(false, "Check that ATS security policy is properly setup, refer to documentation")
            }

            if !(response is HTTPURLResponse) {
                if assertOnError {
                    print("[SBTUITestTunnel] Failed to get http response: \(String(describing: request))")
                    // [weakSelf terminate];
                }
            } else {
                var jsonData: [AnyHashable: Any]?
                do {
                    if let data = data {
                        jsonData = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [AnyHashable: Any]
                    }
                } catch {}
                responseId = jsonData?[SBTUITunnelResponseResultKey] as? String

                if assertOnError {
                    if (response as? HTTPURLResponse)?.statusCode != 200 {
                        print("[SBTUITestTunnel] Message sending failed: \(String(describing: request))")
                    }
                }
            }

            synchRequestSemaphore.signal()
        })).resume()

        _ = synchRequestSemaphore.wait(timeout: DispatchTime.distantFuture) == .success

        return responseId
    }

    @discardableResult
    @objc func sendSynchronousRequest(withPath path: String, params: [String: String]?) -> String? {
        return sendSynchronousRequest(withPath: path, params: params, assertOnError: true)
    }
}
