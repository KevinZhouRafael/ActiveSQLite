#
# Be sure to run `pod lib lint ZKORM.Swift.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'ZKORM'
  s.version          = '0.8.0'
  s.summary          = 'ZKORM is an helper of GRDB.Swift. It can let you use GRDB.swift easily.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
ZKORM is an helper of GRDB.Swift. It can let you use GRDB.swift easily..
                       DESC

  s.homepage         = 'https://github.com/KevinZhouRafael/ZKORM'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'zhoukai' => 'wumingapie@gmail.com' }
  s.source           = { :git => 'https://github.com/KevinZhouRafael/ZKORM.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.swift_versions = ['5.7']
  s.ios.deployment_target = '13.0'

  s.source_files = 'ZKORM/Classes/**/*'
  
  # s.resource_bundles = {
  #   'ZKORM.Swift' => ['ZKORM.Swift/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  s.dependency 'GRDB.swift' , '6.4.0'
  # s.dependency 'CocoaLumberjack/Swift'
end
