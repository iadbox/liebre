# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'liebre/version'

Gem::Specification.new do |spec|
  spec.name          = "liebre"
  spec.version       = Liebre::VERSION
  spec.authors       = ["jcabotc"]
  spec.email         = ["jcabot@gmail.com"]
  spec.summary       = %q{Some abstractions to interact with a AMQP broker}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "concurrent-ruby"

  spec.add_development_dependency "bunny"

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "pry"
end
