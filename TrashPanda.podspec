 #
#  Be sure to run `pod spec lint TrashPandaSpecs.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see https://guides.cocoapods.org/syntax/podspec.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |spec|

  # ―――  Spec Metadata  ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  These will help people to find your library, and whilst it
  #  can feel like a chore to fill in it's definitely to your advantage. The
  #  summary should be tweet-length, and the description more in depth.
  #

  spec.platform              = :ios
  spec.ios.deployment_target = '11.0'
  spec.name                  = "TrashPanda"
  spec.version               = "0.1.13"
  spec.summary               = "A Swift lightweight api stack"
  spec.requires_arc          = true


  spec.description  = <<-DESC
  A siwft side project that handles requesting basic api calls throough callBacks
                   DESC

  spec.homepage     = "https://github.com/ohassan443/TrashPanda"
 

  spec.license      = { :type => "MIT", :file => "LICENSE" }

  spec.author             = { "ohassan" => "ohassan443@gmail.com" }


  spec.source       = { :git => "https://github.com/ohassan443/TrashPanda.git", :tag => "#{spec.version}" }

  spec.source_files  =  "TrashPanda/TrashPanda/**/*.{swift}"

  spec.swift_version = "5"
end
