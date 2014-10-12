require 'spec_helper'
$:.unshift File.dirname(__FILE__) + "/../lib/"

require 'rdf'
require 'rdf/spec/repository'
require 'rdf/marmotta'

describe RDF::Marmotta do

  let(:base_url) { 'http://localhost:8080/marmotta/' }
  let(:opts) { {} }
  let(:statements) { RDF::Spec.quads }

  subject { RDF::Marmotta.new(base_url, opts) }

  describe 'initializing' do
    let(:opts) { { sparql: 'sparql' } }

    it 'accepts marmotta configuration' do
      expect { subject }.not_to raise_error
    end

    describe 'webservice endpoints' do
      it 'has sparql endpoint' do
        expect(subject.query_client).to be_a SPARQL::Client
        expect(subject.update_client).to be_a SPARQL::Client
      end
    end
  end

  describe 'Repository' do
    before do
      @repository = subject
    end

    after do
      @repository.clear
    end

    include RDF_Repository
  end
end
