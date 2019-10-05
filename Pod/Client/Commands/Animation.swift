//
//  Copyright © 2019 Qonto. All rights reserved.
//

import Foundation

public extension SBTUITestTunnelClient {
    @objc func setUserInterfaceAnimations(enabled: Bool) -> Bool {
        userInterfaceAnimationsEnabled = enabled

        let params = [
            SBTUITunnelObjectKey: NSNumber(value: enabled).stringValue,
        ]

        guard let request = sendSynchronousRequest(withPath: SBTUITunneledApplicationCommandSetUserInterfaceAnimations, params: params) else {
            return false
        }

        return NSString(string: request).boolValue
    }

    @objc func animationsEnabled() -> Bool {
        return userInterfaceAnimationsEnabled
    }

    @objc func setUserInterfaceAnimation(speed: Int) -> Bool {
        userInterfaceAnimationSpeed = speed

        let params = [
            SBTUITunnelObjectKey: NSNumber(value: speed).stringValue,
        ]

        guard let request = sendSynchronousRequest(withPath: SBTUITunneledApplicationCommandSetUserInterfaceAnimationSpeed, params: params) else {
            return false
        }

        return NSString(string: request).boolValue
    }

    @objc func animationSpeed() -> Int {
        return userInterfaceAnimationSpeed
    }
}
