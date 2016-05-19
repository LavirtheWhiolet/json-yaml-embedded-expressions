Gem::Specification.new do |s|
  s.name        = 'json-yaml-embedded-expressions'
  s.version     = '0.0.3'
  s.licenses    = ['MIT']
  s.summary     = "Embedded expressions in YAML/JSON/etc."
  s.description = <<-EOF
A library for resolving embedded expressions in YAML, JSON and other. Empower your data with calculations!
  EOF
  s.author      = "Lavir the Whiolet"
  s.email       = 'Lavir.th.Whiolet@gmail.com'
  s.required_ruby_version = '>= 1.9.3'
  s.files       = Dir["lib/**/*.rb"] + ["README.md"]
  s.bindir      = "bin"
  s.homepage    = "http://lavirthewhiolet.github.io/json-yaml-embedded-expressions"
  s.executables << "json-embedded-expressions" << "yaml-embedded-expressions"
end
