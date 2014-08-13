Pod::Spec.new do |s|

  s.name         = "HessianObjC"
  s.version      = "1.0"
  s.summary      = "A short description of HessianObjC."

  s.description  = <<-DESC
                   A longer description of HessianObjC in Markdown format.

                   * Think: Why did you write this? What is the focus? What does it do?
                   * CocoaPods will be using this to generate tags, and improve search results.
                   * Try to keep it short, snappy and to the point.
                   * Finally, don't worry about the indent, CocoaPods strips it!
                   DESC

  s.homepage     = "https://github.com/Haidora/hessianobjc"
  s.license      = "MIT (example)"
  # s.license      = { :type => "MIT", :file => "FILE_LICENSE" }
  s.author             = { "mrdaios" => "mrdaios@gmail.com" }
 
  s.platform     = :ios
  s.platform     = :ios, "6.0"

  #  When using multiple platforms
  # s.ios.deployment_target = "5.0"
  # s.osx.deployment_target = "10.7"

  s.source       = { :git => "https://github.com/Haidora/hessianobjc.git", :branch => "developer" }
  s.source_files  = "Source", "Source/**/*.{h,m}"
  
  s.requires_arc = true

end
