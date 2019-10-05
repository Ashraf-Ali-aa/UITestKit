//
//  Copyright © 2019 Qonto. All rights reserved.
//

import Foundation

public extension SBTUITestTunnelClient {
    @objc func uploadItem(atPath srcPath: String?, toPath destPath: String?, relativeTo baseFolder: FileManager.SearchPathDirectory) -> Bool {
        assert(!(srcPath?.hasPrefix("file:") ?? false), "Call this methon passing srcPath using [NSURL path] not [NSURL absoluteString]!")

        guard let data = try? Data(contentsOf: URL(fileURLWithPath: srcPath ?? "")) else {
            return false
        }

        let params = [
            SBTUITunnelUploadDataKey: base64Serialize(data: data),
            SBTUITunnelUploadDestPathKey: base64Serialize(object: destPath ?? ""),
            SBTUITunnelUploadBasePathKey: NSNumber(value: baseFolder.rawValue).stringValue,
        ] as? [String: String]

        guard let request = sendSynchronousRequest(withPath: SBTUITunneledApplicationCommandUploadData, params: params) else {
            return false
        }

        return NSString(string: request).boolValue
    }

    @objc func downloadItems(fromPath path: String, relativeTo baseFolder: FileManager.SearchPathDirectory) -> [Data]? {
        let params = [
            SBTUITunnelDownloadPathKey: base64Serialize(object: path),
            SBTUITunnelDownloadBasePathKey: NSNumber(value: baseFolder.rawValue).stringValue,
        ] as? [String: String]

        guard
            let itemsBase64 = sendSynchronousRequest(withPath: SBTUITunneledApplicationCommandDownloadData, params: params),
            let itemsData = Data(base64Encoded: itemsBase64, options: []) else {
            return nil
        }

        return NSKeyedUnarchiver.unarchiveObject(with: itemsData) as? [Data]
    }
}
