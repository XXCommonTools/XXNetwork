
Pod::Spec.new do |s|
  s.name             = 'XXNetwork'
  s.version          = '0.2.3'
  s.summary          = 'XXNetwork 是一个离散型的网络请求工具'

  s.description      = 'XXNetwork 是一个离散型的网络请求工具'

  s.homepage         = 'https://github.com/XXCommonTools/XXNetwork'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'yangzi' => '595919268@qq.com' }
  s.source           = { :git => 'https://github.com/XXCommonTools/XXNetwork.git', :tag => s.version.to_s }
  s.ios.deployment_target = '8.0'
  s.source_files = 'XXNetwork/Classes/XXNetwork.h'

s.subspec 'XXNetworkCore' do |ss|

ss.source_files = 'XXNetwork/Classes/XXNetworkCore/*'
ss.dependency 'AFNetworking'
ss.dependency 'XXCategories'
ss.dependency 'XXNetwork/XXNetworkAnimation'

end

s.subspec 'XXNetworkAnimation' do |ss|

ss.source_files = 'XXNetwork/Classes/XXNetworkAnimation/XXNetworkAnimation.{h,m}'
ss.public_header_files = 'XXNetwork/Classes/XXNetworkAnimation/XXNetworkAnimation.h'

end




end
