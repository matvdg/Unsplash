# Uncomment the next line to define a global platform for your project
platform :ios, '13.0'

target 'Demo' do
  # Comment the next line if you don't want to use dynamic frameworks
  #use_frameworks!
  # ignore all warnings from all pods
  inhibit_all_warnings!

  # Pods for Demo
  pod 'UnsplasherSDK'
  pod 'RxSwift'
  pod 'RxCocoa'
  pod 'AlamofireImage'
  pod 'Dip'
  
  post_install do |installer|
      installer.pods_project.targets.each do |target|
          target.build_configurations.each do |config|
              config.build_settings['ENABLE_BITCODE'] = 'NO'
          end
      end
  end
 
  target 'DemoTests' do
    inherit! :search_paths
    # Pods for testing
    pod 'Mockit'
    pod 'RxTest'
  end

end
