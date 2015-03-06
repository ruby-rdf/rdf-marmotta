# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)

Gem::Specification.new do |s|
  s.name        = "rdf-marmotta"
  s.version     = '0.0.6'
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Tom Johnson"]
  s.homepage    = 'https://github.com/dpla/rdf-marmotta'
  s.email       = 'tom@dp.la'
  s.summary     = %q{RDF::Repository layer for Apache Marmotta.}
  s.description = %q{RDF::Repository layer for Apache Marmotta.}
  s.license     = "Unlicense"
  s.required_ruby_version     = '>= 1.9.3'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {spec}/*`.split("\n")

  s.add_dependency('rake')
  s.add_dependency('rdf', '~> 1.1')
  s.add_dependency('sparql-client', '~> 1.1.4')
  s.add_dependency('nokogiri')
  s.add_dependency('rdf-rdfxml', '~> 1.1')
  s.add_development_dependency('jettywrapper')
  s.add_development_dependency('linkeddata')
  s.add_development_dependency('rspec')
  s.add_development_dependency('rspec-its')
  s.add_development_dependency('rdf-spec')
  s.add_development_dependency('pry')

end
