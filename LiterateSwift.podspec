#
#  Be sure to run `pod spec lint CommonMark.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see http://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |s|

  # ―――  Spec Metadata  ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  These will help people to find your library, and whilst it
  #  can feel like a chore to fill in it's definitely to your advantage. The
  #  summary should be tweet-length, and the description more in depth.
  #

  s.name         = "LiterateSwift"
  s.version      = "0.0.4"
  s.summary      = "Literate Swift is a framework for doing literate programming in Swift"

  s.description  = <<-DESC
                     This framework is intended to be used in an app, e.g. a GUI app or CLI app.
                   DESC


  s.homepage     = "https://github.com/chriseidhof/literate-swift"
  s.license      = "MIT"
  s.author       = { "Chris Eidhof" => "chris@eidhof.nl" }

  s.platform = :osx, "10.9"

  s.source       = { :git => "https://github.com/chriseidhof/literate-swift.git", :tag => "0.0.4" }

  s.source_files  = "LiterateSwift/*.swift", "LiterateSwift/LiterateSwift.h"

  s.dependency 'CommonMark', '>= 0.0.3'
end
