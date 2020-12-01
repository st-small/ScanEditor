
Pod::Spec.new do |spec|

  spec.name         = "ScanEditor"
  spec.version      = "0.0.2"
  spec.summary      = "ScanEditor will help to select cropping element from images and photos using corner points"

  spec.license      = { :type => "MIT", :file => "LICENSE" }
  spec.homepage         = 'https://github.com/st-small/ScanEditor'
  spec.author       = "Stanislav Shiyanovskiy"
    
  spec.platform     = :ios, "13.0"
  spec.swift_version = '5'

  spec.source       = { :git => "https://github.com/st-small/ScanEditor.git", :tag => "#{spec.version}" }

  spec.source_files  = "ScanEditor/**/*.{h,m,swift}"

end
