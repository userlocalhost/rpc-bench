# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rpc_bench/version'

Gem::Specification.new do |spec|
  spec.name          = "rpc-bench"
  spec.version       = RPCBench::VERSION
  spec.authors       = ["Hiroyasu OHYAMA"]
  spec.email         = ["user.localhost2000@gmail.com"]

  spec.summary       = %q{A simple benchmark tools for some kind of RPC frameworks}
  spec.homepage      = "https://github.com/userlocalhost2000/rpc_bench"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "bin"
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "grpc", "0.14.1"
  spec.add_runtime_dependency "grpc-tools", "0.14.1"
  spec.add_runtime_dependency "stomp", "1.4.0"
  spec.add_runtime_dependency "bunny", "2.3.1"
  spec.add_runtime_dependency "ffi-rzmq", "2.0.4"
  spec.add_runtime_dependency "protobuf", "3.6.9"
end
