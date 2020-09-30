import Foundation
import CommonCrypto.CommonDigest

@available(iOS 12.0, *)
public enum PubKeyExtractor {
    public struct PubKey {
        public let data: NSData
        public var base64: String {
            data.base64EncodedString()
        }

        public var sha224Base64: String {
            let sha1Bytes = UnsafeMutablePointer<UInt8>.allocate(capacity: Int(CC_SHA224_DIGEST_LENGTH))
            defer { sha1Bytes.deallocate() }
            CC_SHA224(data.bytes, CC_LONG(data.length), sha1Bytes)
            let sha1Data = Data(bytesNoCopy: sha1Bytes, count: Int(CC_SHA224_DIGEST_LENGTH), deallocator: .none)
            return sha1Data.base64EncodedString()
        }
    }
    private static var instance: PubKeyExtractor?

    public static func getPubKey(url: URL, completion: @escaping (Result<PubKey, Error>) -> Void) {
        instance = PubKeyExtractor(url: url, completion: {
            instance = nil
            completion($0)
        })
    }


    private final class PubKeyExtractor: NSObject, URLSessionDelegate {
        private enum Error: Swift.Error {
            case unknownError
        }
        private var completion: ((Result<PubKey, Swift.Error>) -> Void)?
        private var session: URLSession!

        internal init(url: URL, completion: @escaping (Result<PubKey, Swift.Error>) -> Void) {
            super.init()
            self.completion = completion
            let session = URLSession.init(configuration: .default, delegate: self, delegateQueue: nil)
            session.dataTask(with: url, completionHandler: { (_, _, error) in
                guard let completion = self.completion else { return } // success
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.failure(Error.unknownError))
                }
                self.completion = nil
            }).resume()
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
            completion?(.success(.init(data: publicKeyData)))
            completion = nil
        }
    }
}
