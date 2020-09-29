import Foundation
import CryptoKit

final class PubKeyExtractor: NSObject, URLSessionDelegate {
    let completion: (String) -> Void
    private var session: URLSession!

    public init(url: URL, completion: @escaping (String) -> Void) {
        self.completion = completion
        super.init()
        let session = URLSession.init(configuration: .default, delegate: self, delegateQueue: nil)
        session.dataTask(with: url).resume()
    }

    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        guard challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust,
              let serverTrust = challenge.protectionSpace.serverTrust,
              let publicKey = SecTrustCopyKey(serverTrust),
              let publicKeyData = SecKeyCopyExternalRepresentation(publicKey, nil)
        else { return }
        let publicKeyHash = SHA256.hash(data: publicKeyData as Data)
        let hashString = publicKeyHash.compactMap { String(format: "%02x", $0) }.joined()
        completion(hashString)
    }
}
