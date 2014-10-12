# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)

Gem::Specification.new do |s|
  s.name        = "rdf-marmotta"
  s.version     = '0.0.1'
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Tom Johnson"]
  s.homepage    = 'https://github.com/dpla/rdf-marmotta'
  s.email       = 'tom@dp.la'
  s.summary     = %q{RDF::Repository layer for Apache Marmotta.}
  s.description = %q{RDF::Repository layer for Apache Marmotta.}
  s.license     = "undeclared"
  s.required_ruby_version     = '>= 1.9.3'

  s.add_dependency('rdf', '~> 1.1')
  s.add_dependency('nokogiri')
  s.add_dependency('rdf-rdfxml', '~> 1.1')
  s.add_dependency('sparql-client', '~> 1.1')
  s.add_development_dependency('rspec')
  s.add_development_dependency('rspec-its')
  s.add_development_dependency('rdf-spec')
  s.add_development_dependency('pry')
end		
