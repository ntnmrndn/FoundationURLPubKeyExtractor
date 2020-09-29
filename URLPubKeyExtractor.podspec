Pod::Spec.new do |spec|

  spec.name         = "URLPubKeyExtractor"
  spec.version      = "1.0.0"
  spec.summary      = "Easy way to extract the hash of a public key from a domain on iOS/macOS"

  spec.description  = <<-DESC
                   DESC

  spec.homepage     = "https://github.com/ntnmrndn/FoundationURLPubKeyExtractor"
  spec.license      = { :type => "MIT", :file => "LICENSE" }

  spec.author             = { "Marandon Antoine" => "antoine@marandon.fr" }

  spec.source       = { :git => "https://github.com/ntnmrndn/FoundationURLPubKeyExtractor.git", :tag => "#{spec.version}" }

  spec.source_files  = "PubKeyExtractor.swift"
  spec.frameworks = "Foundation", "CryptoKit"

end
