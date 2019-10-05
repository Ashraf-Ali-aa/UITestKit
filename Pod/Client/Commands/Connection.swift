//
//  Copyright © 2019 Qonto. All rights reserved.
//

import Foundation

public extension SBTUITestTunnelClient {
    @objc func launchConnectionless(_ command: @escaping (String, [String: String]) -> String) {
        connectionlessBlock = command
        shutDownWithError(nil)
    }

    @objc func terminate() {
        shutDownWithError(nil)
    }

    @objc func quit() {
        sendSynchronousRequest(withPath: SBTUITunneledApplicationCommandQuit, params: nil, assertOnError: false)
    }

    @objc func ping() -> Bool {
        return sendSynchronousRequest(withPath: SBTUITunneledApplicationCommandPing, params: nil, assertOnError: false) == "YES"
    }

    @objc func isAppCruising() -> Bool {
        return sendSynchronousRequest(withPath: SBTUITunneledApplicationCommandCruising, params: nil) == "YES"
    }
}
