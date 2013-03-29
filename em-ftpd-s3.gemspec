# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'em-ftpd-s3/version'

Gem::Specification.new do |spec|
  spec.name          = "em-ftpd-s3"
  spec.version       = EM::FTPD::S3::VERSION
  spec.authors       = ["Nabil Alsharif"]
  spec.email         = ["blit32@gmail.com"]
  spec.description   = %q{An em-ftpd driver for Amazon S3}
  spec.summary       = %q{An em-ftpd driver that stores files on Amazon S3}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "aws-s3", ">= 0.6.3"
  spec.add_dependency "em-ftpd", ">= 0.0.1"
  spec.add_dependency "eventmachine", ">= 1.0.3"

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "vcr", ">= 2.4.0"
  spec.add_development_dependency "webmock", ">= 1.11.0"
  spec.add_development_dependency "rspec", ">= 2.13.0"
  spec.add_development_dependency "cucumber", ">= 1.2.0"
end
