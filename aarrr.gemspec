Gem::Specification.new do |s|
  s.name = "aarrr"
  s.version = "0.0.1"

  s.authors = ["Jacques Crocker"]
  s.summary = "metrics for pirates"
  s.description = "AARRR helps track user lifecycle metrics via MongoDB. It also provides cohort and reporting tools."

  s.email = "railsjedi@gmail.com"
  s.homepage = "http://github.com/railsjedi/aarrr"
  s.rubyforge_project = "none"

  s.require_paths = ["lib"]
  s.files = Dir['lib/**/*',
                'spec/**/*',
                'aarrr.gemspec',
                'Gemfile',
                'Gemfile.lock',
                'Guardfile',
                'LICENSE',
                'Rakefile',
                'README.md']

  s.test_files = Dir['spec/**/*']
  s.rdoc_options = ["--charset=UTF-8"]
  s.extra_rdoc_files = [
    "LICENSE",
    "README.md"
  ]

  s.add_runtime_dependency "rack", ">= 1.2.2"
  s.add_runtime_dependency "mongo", ">= 1.3.1"
  s.add_development_dependency "rspec", ">= 2.0"
end

