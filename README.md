# FoundationURLPubKeyExtractor
Easy way to extract a public key from a domain on iOS/macOS

Usage:

```
PubKeyExtractor.getPubKey(url: url, completion: {
    switch $0 {
    case .success(let key):
        print("pubKey: \(key.base64)")
    case .failure(let error):
        print("Could not get key because \(error)")
    }
})
```

Note:

The results will differ from the .pem because .pem include some headers.

Motivations:

Assess the impact of pubkey pinning techniques

Todo: macOS compat (should take a few minutes...)

Cocoapods:

pod 'URLPubKeyExtractor'
