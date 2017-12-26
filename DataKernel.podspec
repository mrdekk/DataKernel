Pod::Spec.new do |s|
  s.name             = "DataKernel"
  s.version          = "0.4.0"
  s.summary          = "CoreData wrapper written on Swift 4"
  s.homepage         = "https://github.com/mrdekk/DataKernel"
  s.license          = 'MIT'
  s.author           = { "MrDekk" => "mrdekk@yandex.ru" }
  s.source           = { :git => "https://github.com/mrdekk/DataKernel.git", :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/mrdekk'
  s.requires_arc = true

  s.ios.deployment_target = "8.0"
  s.osx.deployment_target = "10.10"
  s.watchos.deployment_target = "2.0"
  s.tvos.deployment_target = '9.0'

  s.frameworks = ['CoreData']

  s.source_files = ['DataKernel/Classes/**/*.{swift}']
end
