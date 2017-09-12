# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'git_acl_shell/version'

Gem::Specification.new do |spec|
  spec.name          = "git_acl_shell"
  spec.version       = GitAclShell::VERSION
  spec.authors       = ["Cucumber Ltd"]
  spec.email         = ["devs@cucumber.io"]

  spec.summary       = %q{Git ACL Shell}
  spec.description   = %q{Protects access to git, using an ACL HTTP endpoint...}
  spec.homepage      = "https://cucumber.io"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "httparty", "~> 0.15"

  spec.add_development_dependency "bundler", "~> 1.15"
  spec.add_development_dependency "rake", "~> 12.1"
  spec.add_development_dependency "rspec", "~> 3.6"
  spec.add_development_dependency "pact", "~> 1.15"
end
