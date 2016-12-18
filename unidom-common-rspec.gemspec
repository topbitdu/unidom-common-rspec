# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'unidom/common/rspec/version'

Gem::Specification.new do |spec|
  spec.name          = 'unidom-common-rspec'
  spec.version       = Unidom::Common::RSpec::VERSION
  spec.authors       = [ 'Topbit Du' ]
  spec.email         = [ 'topbit.du@gmail.com' ]

  spec.summary       = 'Unidom Common RSpec 是为 Unidom Common 设计的基于 RSpec 的共享测试用例。'
  spec.description   = 'Unidom Common RSpec is a RSpec-based Shared Example for the Unidom Common-based models. Unidom Common RSpec 是为 Unidom Common 设计的基于 RSpec 的共享测试用例。'
  spec.homepage      = 'https://github.com/topbitdu/unidom-common-rspec'
  spec.license       = 'MIT'

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  #if spec.respond_to?(:metadata)
  #  spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"
  #else
  #  raise "RubyGems 2.0 or newer is required to protect against public gem pushes."
  #end

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = [ "lib" ]

  spec.add_development_dependency "bundler", "~> 1.12"
  spec.add_development_dependency "rake",    "~> 10.0"
  spec.add_development_dependency "rspec",   "~> 3.0"
end
