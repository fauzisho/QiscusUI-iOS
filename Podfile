# Uncomment the next line to define a global platform for your project
platform :ios, '10.0'

def pod_release
    pod 'QiscusCore', '0.1.2'
end

def pod_test
    pod 'QiscusCore', :path => '../QiscusCore/Cocoapods'
    pod 'QiscusRealtime', :path => '../QiscusRealtime/Cocoapods'
end

def pod_dev
    pod 'QiscusCore', :path => '../QiscusCore'
    pod 'QiscusRealtime', :path => '../QiscusRealtime'
end

target 'Example' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!
  pod 'QiscusUI', :path => '.'
pod_release
pod_dev
pod_test
end
