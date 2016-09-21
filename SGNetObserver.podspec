Pod::Spec.new do |spec|

spec.name                  = 'SGNetObserver'

spec.version               = '1.0.0'

spec.ios.deployment_target = '8.0'

spec.license               = 'MIT'

spec.homepage              = 'https://github.com/iOSSinger'

spec.author                = { "iOSSinger" => "747616044@qq.com" }

spec.summary               = 'iOS完美的网络状态判断工具'

spec.source                = { :git => 'https://github.com/iOSSinger/SGNetObserver.git', :tag => spec.version }

spec.source_files          = "SGNetObserver/**/{*.h,*.m}"

spec.frameworks               = 'SystemConfiguration'

spec.requires_arc          = true

end
