Pod::Spec.new do |spec|

  spec.name         = "URLPubKeyExtractor"
  spec.version      = "1.0.0"
  spec.summary      = "Easy way to extract the hash of a public key from a domain on iOS/macOS"

  spec.description  = <<-DESC
 Easy way to extract a public key from a domain on iOS/macOS

Usage:
let url: URL = URL(string: "https://apple.com")!


let extractor = PubKeyExtractor(url: url, completion: {
    print("base64: \($0)")
})
                   DESC

  spec.homepage     = "https://github.com/ntnmrndn/FoundationURLPubKeyExtractor"
  spec.license      = { :type => "MIT", :file => "LICENSE" }

  spec.author             = { "Marandon Antoine" => "antoine@marandon.fr" }

  spec.source       = { :git => "https://github.com/ntnmrndn/FoundationURLPubKeyExtractor.git", :tag => "#{spec.version}" }

  spec.source_files  = "PubKeyExtractor.swift"
  spec.frameworks = "Foundation"
  spec.ios.deployment_target = '8.0'
  spec.swift_version = "5.3"
end
