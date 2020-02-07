Pod::Spec.new do |spec|
  spec.name         = "CocoaWindow"
  spec.version      = "1.0"
  spec.summary      = "Make NSWindow great again ✨"
  spec.homepage     = "https://github.com/Sunnyyoung/CocoaWindow"
  spec.license      = "MIT"
  spec.author       = { "Sunnyyoung" => "iSunnyyoung@gmail.com" }
  spec.platform     = :macos, "10.11"
  spec.source       = { :git => "https://github.com/Sunnyyoung/CocoaWindow.git", :tag => "#{spec.version}" }
  spec.source_files  = "CocoaWindow/CocoaWindow/**/*.{h,m}"
end
