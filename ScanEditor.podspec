#
#  Be sure to run `pod spec lint ScanEditor.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.

Pod::Spec.new do |spec|

  spec.name         = "ScanEditor"
  spec.version      = "0.0.1"
  spec.summary      = "ScanEditor to select cropping element using corner points"

  spec.description  = <<-DESC
                   DESC
  spec.license      = "MIT"
  spec.author       = "Stanislav Shiyanovskiy"
    
  spec.platform     = :ios, "11.0"

  spec.source       = :git => "http://st-small/ScanEditor.git"

  spec.source_files  = "Classes", "Classes/**/*.{h,m,swift}"
  spec.exclude_files = "Classes/Exclude"

end
