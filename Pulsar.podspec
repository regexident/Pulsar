Pod::Spec.new do |s|

  s.name         = "Pulsar"
  s.version      = "1.0.3"
  s.summary      = "A generic wrapper implementation for copy-on-write data structures written in Swift."

  s.description  = <<-DESC
                   Pulsar is a versatile solution for displaying pulse animations as known from Apple Maps.
                   DESC

  s.homepage     = "https://github.com/regexident/Pulsar"
  s.license      = { :type => 'BSD-3', :file => 'LICENSE' }
  s.author       = { "Vincent Esche" => "regexident@gmail.com" }
  s.source       = { :git => "https://github.com/regexident/Pulsar.git", :tag => '1.0.3' }
  s.source_files  = "Pulsar/Classes/*.{swift,h,m}"
  # s.public_header_files = "Pulsar/*.h"
  s.requires_arc = true
  s.ios.deployment_target = "8.0"
  # s.osx.deployment_target = "10.9"
  
end
