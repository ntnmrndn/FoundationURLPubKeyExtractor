import Foundation
#if canImport(CryptoKit)
import CryptoKit
#endif

@available(iOS 13.0, *)
final class PubKeyExtractor: NSObject, URLSessionDelegate {
    let completion: (String) -> Void
    private var session: URLSession!

    public init(url: URL, completion: @escaping (String) -> Void) {
        self.completion = completion
        super.init()
        let session = URLSession.init(configuration: .default, delegate: self, delegateQueue: nil)
        session.dataTask(with: url).resume()
    }

    private static func getPubKey(serverTrust: SecTrust) -> SecKey? {
        if #available(iOS 14.0, *) {
            return SecTrustCopyKey(serverTrust)
        } else {
            guard SecTrustGetCertificateCount(serverTrust) > 1,
                  let certificate = SecTrustGetCertificateAtIndex(serverTrust, 0)
            else { return nil }
            return SecCertificateCopyKey(certificate)
        }
    }

    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        guard challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust,
              let serverTrust = challenge.protectionSpace.serverTrust,
              let publicKey = Self.getPubKey(serverTrust: serverTrust),
              let publicKeyData = SecKeyCopyExternalRepresentation(publicKey, nil)
        else { return }
        let publicKeyHash = SHA256.hash(data: publicKeyData as Data)
        let hashString = publicKeyHash.compactMap { String(format: "%02x", $0) }.joined()
        completion(hashString)
    }
}
