# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target 'OneFeed' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  # Pods for OneFeed
  pod 'FacebookCore'
  pod 'FacebookLogin'
  pod 'FacebookShare'
  pod 'TwitterKit'
post_install do |installer|
    installer.aggregate_targets.each do |aggregate_target|
      aggregate_target.xcconfigs.each do |config_name, config_file|
        config_file.other_linker_flags[:frameworks].delete("TwitterCore")

        xcconfig_path = aggregate_target.xcconfig_path(config_name)
        config_file.save_as(xcconfig_path)
      end
    end
  end
    

  target 'OneFeedTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'OneFeedUITests' do
    inherit! :search_paths
    # Pods for testing
  end

end
