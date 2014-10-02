require 'spec_helper'
$:.unshift File.dirname(__FILE__) + "/../lib/"

require 'rdf'
require 'rdf/spec/repository'
require 'rdf/marmotta'

describe RDF::Marmotta do
  before :each do
    @repository = RDF::Marmotta.new
  end
   
  after :each do
    @repository.clear
  end

  # @see lib/rdf/spec/repository.rb in RDF-spec
  include RDF_Repository
end
