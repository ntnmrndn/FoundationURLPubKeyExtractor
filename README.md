# FoundationURLPubKeyExtractor
Easy way to extract the hash of a public key from a domain on iOS/macOS

Usage:

```
let url: URL = URL(string: "https://apple.com")!


let extractor = PubKeyExtractor(url: url, completion: {
    print("hash: \($0)")
})
```

Cocoapods:

pod 'FoundationURLPubKeyExtractor'
