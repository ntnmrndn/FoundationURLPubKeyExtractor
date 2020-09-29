# FoundationURLPubKeyExtractor
Easy way to extract a public key from a domain on iOS/macOS

Usage:

```
let url: URL = URL(string: "https://apple.com")!


let extractor = PubKeyExtractor(url: url, completion: {
    print("base64: \($0)")
})
```

Note:

The results will differ from the .pem because .pem include some headers.


Cocoapods:

pod 'FoundationURLPubKeyExtractor'
