
Pod::Spec.new do |s|
  s.name             = 'XXNetwork'
  s.version          = '0.1.7'
  s.summary          = 'XXNetwork 是一个离散型的网络请求工具'

  s.description      = 'XXNetwork 是一个离散型的网络请求工具'

  s.homepage         = 'https://github.com/XXCommonTools/XXNetwork'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'yangzi' => '595919268@qq.com' }
  s.source           = { :git => 'https://github.com/XXCommonTools/XXNetwork.git', :tag => s.version.to_s }
  s.ios.deployment_target = '8.0'
  s.source_files = 'XXNetwork/Classes/**/*'

  s.dependency 'AFNetworking'
  s.dependency 'XXCategories'

  s.subspec 'XXNetworkAnimation' do |ss|

   ss.source_files = 'XXNetwork/Classes/XXNetworkAnimation/**/*'

  end

end
