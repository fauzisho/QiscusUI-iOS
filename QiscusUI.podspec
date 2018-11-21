Pod::Spec.new do |s|

s.name         = "QiscusUI"
s.version      = "0.2.1"
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
s.dependency 'QiscusCore', '0.2.0'
s.dependency 'AlamofireImage', '~ 3.4.0'
s.dependency 'SwiftyJSON', '~ 4.2.0'
s.dependency 'SimpleImageViewer', '~ 1.1.1'

end
