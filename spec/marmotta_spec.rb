# -*- coding: utf-8 -*-
require 'spec_helper'
$:.unshift File.dirname(__FILE__) + "/../lib/"

require 'rdf'
require 'rdf/spec/repository'
require 'rdf/marmotta'

describe RDF::Marmotta do

  let(:base_url) { 'http://localhost:8983/marmotta/' }
  let(:opts) { {} }
  let(:statement) { RDF::Statement(RDF::URI('http://api.dp.la/example/item/1234'), RDF::DC.title, 'Moomin') }
  let(:statements) {
    nodes = [RDF::Node.new, RDF::Node.new, RDF::Node.new]
    [
     RDF::Statement(RDF::URI('http://dbpedia.org/resource/Moomin'), RDF::URI('http://dbpedia.org/ontology/author'), RDF::URI('http://dbpedia.org/resource/Tove_Jansson')),
     RDF::Statement(RDF::URI('http://dbpedia.org/resource/Moomin'), RDF::URI('http://dbpedia.org/ontology/country'), RDF::URI('http://dbpedia.org/resource/Finland')),
     RDF::Statement(RDF::URI('http://dbpedia.org/resource/Moomin'), RDF::URI('http://dbpedia.org/ontology/country'), RDF::URI('http://dbpedia.org/resource/Finland')),
     RDF::Statement(RDF::URI('http://dbpedia.org/resource/Moomin'), RDF::URI('http://dbpedia.org/ontology/illustrator'), RDF::URI('http://dbpedia.org/resource/Tove_Jansson')),
     RDF::Statement(RDF::URI('http://dbpedia.org/resource/Moomin'), RDF::URI('http://dbpedia.org/ontology/abstract'), RDF::Literal.new("Muminki (szw. Mumintroll, fiń. Muumi) – fikcyjne istoty o antropomorficznej budowie ciała (nieco podobne do hipopotamów, ale dwunożne), zamieszkujące pewną dolinę gdzieś w Finlandii, bohaterowie cyklu dziewięciu książek fińskiej (piszącej po szwedzku) pisarki Tove Jansson. Są one odmianą trolli. Pierwsza książka o Muminkach, Małe trolle i duża powódź, została opublikowana przez Tove Jansson w 1945 (pierwsza wersja powstała już zimą 1939 roku).Wszystkie książki o Muminkach odniosły sukces: zostały przełożone na ponad trzydzieści języków. Muminki doczekały się też swojej wersji teatralnej, filmowej (między innymi serial zrealizowany w Polsce w Studio Małych Form Filmowych Se-ma-for), radiowej, telewizyjnej i komiksowej. Świat, w którym żyją Muminki, pełen jest rozmaitych stworzeń – żyją w nim Paszczaki, Hatifnatowie, Mimble – każde z nich ma swój punkt widzenia na świat, swój charakter i temperament.W Tampere, trzecim co do wielkości fińskim mieście, mieści się Muzeum „Dolina Muminków”. Natomiast w Naantali, miejscowości położonej niedaleko Turku, powstał park rozrywki \"Dolina Muminków\".", :language => 'pl')),
     RDF::Statement(RDF::URI('http://dbpedia.org/resource/Moomin'), RDF::DC.relation, nodes[0]),
     RDF::Statement(nodes[0], RDF::DC.title, "Comet in Moominland"),
     RDF::Statement(nodes[0], RDF::DC.subject, nodes[1]),
     RDF::Statement(nodes[1], RDF::SKOS.prefLabel, 'Moomin Valley'),
     RDF::Statement(nodes[0], RDF::DC.subject, nodes[2]),
     RDF::Statement(nodes[2], RDF::SKOS.prefLabel, 'Astronomical Events (apocryphal)')
    ]
  }

  subject { RDF::Marmotta.new(base_url, opts) }

  after do
    subject.clear
  end

  describe 'initializing' do
    describe 'webservice endpoints' do
      it 'has sparql endpoint' do
        expect(subject.query_client).to be_a SPARQL::Client
        expect(subject.update_client).to be_a SPARQL::Client
      end
    end
  end

  ##
  # We probably want to pursue skolemization and/or talk to Marmotta
  # folks about how they currently/should handle bnodes.
  describe 'bnode handling' do

    let(:node_triple) { RDF::Statement(RDF::Node.new, RDF::DC.title, 'Moomin') }

    xit 'deletes only the relevant bnode' do
      subject << node_triple
      subject << [RDF::Node.new, RDF::DC.title, 'Moomin']
      subject << [RDF::Node.new, RDF::DC.title, 'Moomin']
      subject.delete_statement(node_triple)
      expect(subject.count).to eq 2 # returns 0
    end

    xit 'identifies triples with bnodes as existing' do
      subject << node_triple
      expect(subject).to have_triple node_triple # returns false
    end
  end

  describe 'inserting' do
    before do
      subject << statement
    end

    it 'writes values' do
      expect(subject.count).to eq 1
    end

    it 'writes correct values' do
      expect(subject).to have_triple statement
    end

    ##
    # This tests an issue that may be an upstream Marmotta problem
    xit 'handles large inserts (marmotta)' do
      expect { subject.insert_statements(statements) }.not_to raise_error
    end

    ##
    # This tests an issue that may be an upstream RDF.rb problem
    xit 'handles large inserts (rdf.rb)' do
      expect { subject << statements }.not_to raise_error
    end
  end

  describe 'deleting' do

    it 'delete triples' do
      subject.delete(statement)
      expect(subject.count).to eq 0
    end

    ##
    # This tests an issue that may be an upstream Marmotta problem.
    # It may be the same issue as above. Could be same issue as above,
    # or at least related.
    xit 'deletes triples even when some are not in store' do
      statement.object = RDF::Literal('Moominpapa')
      subject << statement
      subject.delete_statements(statements)
      expect(subject.count).to eq 0
    end
  end


  # describe 'Repository' do
  #   before do
  #     @repository = subject
  #   end

  #   after do
  #     @repository.clear
  #   end

  #   include RDF_Repository
  # end
end
