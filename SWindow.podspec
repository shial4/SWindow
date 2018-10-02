Pod::Spec.new do |s|
  s.name         = "SWindow"
  s.version      = "0.1.11"
  s.summary      = "Swift view controller presenter."
  s.description  = <<-DESC
    SWindow is an easy to use Swift windows manager. Don't spend hours writing your code to present and dismiss modal view controllers, stop wasting your time on debugging why your modal presentation disapear. Without issues, simple and safe present your controller!
  DESC
  s.homepage     = "https://github.com/shial4/SWindow.git"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author             = { "Szymon Lorenz" => "shial184686@gmail.com" }
  s.social_media_url   = "https://www.facebook.com/SLSolutionsAU/"
  s.ios.deployment_target = "8.0"
  s.source       = { :git => "https://github.com/shial4/SWindow.git", :tag => s.version.to_s }
  s.source_files  = "Sources/**/*.swift"
  s.frameworks  = "UIKit"
end