Pod::Spec.new do |s|

s.name         = "QiscusUI"
s.version      = "0.1.1"
s.summary      = "Qiscus SDK UI for iOS"
s.description  = <<-DESC
QiscusUI SDK for iOS contains Chat User Interface.
DESC
s.homepage     = "https://qiscus.com"
s.license      = "MIT"
s.author       = "Qiscus"
s.source       = { :git => "https://github.com/qiscus/QiscusUI-iOS.git", :tag => "#{s.version}" }
s.source_files  = "QiscusUI/**/*.{swift}"
s.resource_bundles = {
    'QiscusUI' => ['QiscusUI/**/*.{xib,xcassets,imageset,png}']
}
s.platform      = :ios, "10.0"

s.dependency 'QiscusCore', '0.1.2'
s.dependency 'AlamofireImage'
s.dependency 'SwiftyJSON'
s.dependency 'SimpleImageViewer'

end

