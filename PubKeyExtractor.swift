import Foundation

@available(iOS 12.0, *)
public enum PubKeyExtractor {
    private static var instance: PubKeyExtractor?

    public static func getPubKey(url: URL, completion: @escaping (Result<String, Error>) -> Void) {
        instance = PubKeyExtractor(url: url, completion: {
            instance = nil
            completion($0)
        })
    }


    private final class PubKeyExtractor: NSObject, URLSessionDelegate {
        private enum Error: Swift.Error {
            case unknownError
        }
        private var completion: ((Result<String, Swift.Error>) -> Void)?
        private var session: URLSession!

        internal init(url: URL, completion: @escaping (Result<String, Swift.Error>) -> Void) {
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
            let publicKeyString = (publicKeyData as NSData).base64EncodedString(options: [])
            completion?(.success(publicKeyString))
            completion = nil
        }
    }
}
