
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "autopods/version"

Gem::Specification.new do |spec|
  spec.name          = "autopods"
  spec.version       = Autopods::VERSION
  spec.authors       = ["LByy"]
  spec.email         = ["36357962@qq.com"]

  spec.summary       = %q{iOS application modulize into pods, improvement for develop modules.}
  spec.description   = %q{iOS application modulize into pods, improvement for develop modules. 
    CMD:
    1.git-check merge
    2.pod sort and check dependency cycle
  }
  spec.homepage      = "https://github.com/LByy"
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "bin"
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "gli", "~> 2.16"
  spec.add_runtime_dependency "cocoapods"
  spec.add_runtime_dependency "colorize"
  spec.add_runtime_dependency "cocoapods-packager"
end
