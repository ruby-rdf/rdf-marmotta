# -*- coding: utf-8 -*-
require 'spec_helper'
$:.unshift File.dirname(__FILE__) + "/../lib/"

require 'rdf'
require 'rdf/spec/repository'
require 'rdf/marmotta'

describe RDF::Marmotta do

  let(:port) { '8983' }
  let(:base_url) { "http://localhost:#{port}/marmotta/" }
  let(:opts) { {} }
  let(:statement) { RDF::Statement(RDF::URI('http://api.dp.la/example/item/1234'), RDF::Vocab::DC.title, 'Moomin') }
  let(:statements) {
    nodes = [RDF::Node.new, RDF::Node.new, RDF::Node.new]
    [
     RDF::Statement(RDF::URI('http://dbpedia.org/resource/Moomin'), RDF::URI('http://dbpedia.org/ontology/author'), RDF::URI('http://dbpedia.org/resource/Tove_Jansson')),
     RDF::Statement(RDF::URI('http://dbpedia.org/resource/Moomin'), RDF::URI('http://dbpedia.org/ontology/country'), RDF::URI('http://dbpedia.org/resource/Finland')),
     RDF::Statement(RDF::URI('http://dbpedia.org/resource/Moomin'), RDF::URI('http://dbpedia.org/ontology/country'), RDF::URI('http://dbpedia.org/resource/Finland')),
     RDF::Statement(RDF::URI('http://dbpedia.org/resource/Moomin'), RDF::URI('http://dbpedia.org/ontology/illustrator'), RDF::URI('http://dbpedia.org/resource/Tove_Jansson')),
     RDF::Statement(RDF::URI('http://dbpedia.org/resource/Moomin'), RDF::URI('http://dbpedia.org/ontology/abstract'), RDF::Literal.new("Muminki (szw. Mumintroll, fiń. Muumi) – fikcyjne istoty o antropomorficznej budowie ciała (nieco podobne do hipopotamów, ale dwunożne), zamieszkujące pewną dolinę gdzieś w Finlandii, bohaterowie cyklu dziewięciu książek fińskiej (piszącej po szwedzku) pisarki Tove Jansson. Są one odmianą trolli. Pierwsza książka o Muminkach, Małe trolle i duża powódź, została opublikowana przez Tove Jansson w 1945 (pierwsza wersja powstała już zimą 1939 roku).Wszystkie książki o Muminkach odniosły sukces: zostały przełożone na ponad trzydzieści języków. Muminki doczekały się też swojej wersji teatralnej, filmowej (między innymi serial zrealizowany w Polsce w Studio Małych Form Filmowych Se-ma-for), radiowej, telewizyjnej i komiksowej. Świat, w którym żyją Muminki, pełen jest rozmaitych stworzeń – żyją w nim Paszczaki, Hatifnatowie, Mimble – każde z nich ma swój punkt widzenia na świat, swój charakter i temperament.W Tampere, trzecim co do wielkości fińskim mieście, mieści się Muzeum „Dolina Muminków”. Natomiast w Naantali, miejscowości położonej niedaleko Turku, powstał park rozrywki \"Dolina Muminków\".", :language => 'pl')),
     RDF::Statement(RDF::URI('http://dbpedia.org/resource/Moomin'), RDF::Vocab::DC.relation, nodes[0]),
     RDF::Statement(nodes[0], RDF::Vocab::DC.title, "Comet in Moominland"),
     RDF::Statement(nodes[0], RDF::Vocab::DC.subject, nodes[1]),
     RDF::Statement(nodes[1], RDF::Vocab::SKOS.prefLabel, 'Moomin Valley'),
     RDF::Statement(nodes[0], RDF::Vocab::DC.subject, nodes[2]),
     RDF::Statement(nodes[2], RDF::Vocab::SKOS.prefLabel, 'Astronomical Events (apocryphal)')
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

    let(:node_triple) { RDF::Statement(RDF::Node.new, RDF::Vocab::DC.title, 'Moomin') }

    xit 'deletes only the relevant bnode' do
      subject << node_triple
      subject << [RDF::Node.new, RDF::Vocab::DC.title, 'Moomin']
      subject << [RDF::Node.new, RDF::Vocab::DC.title, 'Moomin']
      subject.delete_statement(node_triple)
      expect(subject.count).to eq 2 # returns 0
    end

    it 'identifies triples with bnodes as existing' do
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
    it 'handles large inserts (marmotta)' do
      expect { subject.insert(*statements) }.not_to raise_error
    end

    it 'handles requests that are too big for a GET url' do
      expect(subject.update_client.request(large_insert)).to be_kind_of Net::HTTPOK
    end

    ##
    # This tests an issue that may be an upstream RDF.rb problem
    it 'handles large inserts (rdf.rb)' do
      expect { subject.insert(*statements) }.not_to raise_error
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
      subject.delete(*statements)
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


def large_insert
  <<EOF
INSERT DATA {
_:b0 <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://id.loc.gov/ontologies/RecordInfo#RecordInfo> .
_:b0 <http://id.loc.gov/ontologies/RecordInfo#languageOfCataloging> <http://id.loc.gov/vocabulary/iso639-2/eng> .
_:b0 <http://id.loc.gov/ontologies/RecordInfo#recordChangeDate> "2008-03-05T05:30:10"^^<http://www.w3.org/2001/XMLSchema#dateTime> .
_:b0 <http://id.loc.gov/ontologies/RecordInfo#recordContentSource> <http://id.loc.gov/vocabulary/organizations/dlc> .
_:b0 <http://id.loc.gov/ontologies/RecordInfo#recordStatus> "revised" .
_:b1 <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://purl.org/vocab/changeset/schema#ChangeSet> .
_:b1 <http://purl.org/vocab/changeset/schema#changeReason> "new" .
_:b1 <http://purl.org/vocab/changeset/schema#createdDate> "1988-04-25T00:00:00"^^<http://www.w3.org/2001/XMLSchema#dateTime> .
_:b1 <http://purl.org/vocab/changeset/schema#creatorName> <http://id.loc.gov/vocabulary/organizations/dlc> .
_:b1 <http://purl.org/vocab/changeset/schema#subjectOfChange> <http://id.loc.gov/authorities/names/n87914041> .
<http://id.loc.gov/authorities/names/n87914041> <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://www.loc.gov/mads/rdf/v1#CorporateName> .
<http://id.loc.gov/authorities/names/n87914041> <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://www.loc.gov/mads/rdf/v1#Authority> .
<http://id.loc.gov/authorities/names/n87914041> <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://www.w3.org/2004/02/skos/core#Concept> .
<http://id.loc.gov/authorities/names/n87914041> <http://id.loc.gov/vocabulary/identifiers/lccn> "n 87914041" .
<http://id.loc.gov/authorities/names/n87914041> <http://id.loc.gov/vocabulary/identifiers/oclcnum> "oca02258986" .
<http://id.loc.gov/authorities/names/n87914041> <http://www.loc.gov/mads/rdf/v1#adminMetadata> _:b20 .
<http://id.loc.gov/authorities/names/n87914041> <http://www.loc.gov/mads/rdf/v1#adminMetadata> _:b0 .
<http://id.loc.gov/authorities/names/n87914041> <http://www.loc.gov/mads/rdf/v1#authoritativeLabel> "American Film Manufacturing Company"@en .
<http://id.loc.gov/authorities/names/n87914041> <http://www.loc.gov/mads/rdf/v1#elementList> _:b13 .
<http://id.loc.gov/authorities/names/n87914041> <http://www.loc.gov/mads/rdf/v1#hasExactExternalAuthority> <http://viaf.org/viaf/sourceID/LC%7Cn+87914041#skos:Concept> .
<http://id.loc.gov/authorities/names/n87914041> <http://www.loc.gov/mads/rdf/v1#hasSource> _:b10 .
<http://id.loc.gov/authorities/names/n87914041> <http://www.loc.gov/mads/rdf/v1#hasSource> _:b17 .
<http://id.loc.gov/authorities/names/n87914041> <http://www.loc.gov/mads/rdf/v1#hasSource> _:b18 .
<http://id.loc.gov/authorities/names/n87914041> <http://www.loc.gov/mads/rdf/v1#hasSource> _:b12 .
<http://id.loc.gov/authorities/names/n87914041> <http://www.loc.gov/mads/rdf/v1#hasVariant> _:b4 .
<http://id.loc.gov/authorities/names/n87914041> <http://www.loc.gov/mads/rdf/v1#hasVariant> _:b8 .
<http://id.loc.gov/authorities/names/n87914041> <http://www.loc.gov/mads/rdf/v1#hasVariant> _:b21 .
<http://id.loc.gov/authorities/names/n87914041> <http://www.loc.gov/mads/rdf/v1#identifiesRWO> _:b2 .
<http://id.loc.gov/authorities/names/n87914041> <http://www.loc.gov/mads/rdf/v1#isMemberOfMADSCollection> <http://id.loc.gov/authorities/names/collection_NamesAuthorizedHeadings> .
<http://id.loc.gov/authorities/names/n87914041> <http://www.loc.gov/mads/rdf/v1#isMemberOfMADSCollection> <http://id.loc.gov/authorities/names/collection_LCNAF> .
<http://id.loc.gov/authorities/names/n87914041> <http://www.loc.gov/mads/rdf/v1#isMemberOfMADSScheme> <http://id.loc.gov/authorities/names> .
<http://id.loc.gov/authorities/names/n87914041> <http://www.w3.org/2004/02/skos/core#altLabel> "American Film Company"@en .
<http://id.loc.gov/authorities/names/n87914041> <http://www.w3.org/2004/02/skos/core#altLabel> "North American Film Corporation"@en .
<http://id.loc.gov/authorities/names/n87914041> <http://www.w3.org/2004/02/skos/core#altLabel> "Flying A Studio"@en .
<http://id.loc.gov/authorities/names/n87914041> <http://www.w3.org/2004/02/skos/core#changeNote> _:b1 .
<http://id.loc.gov/authorities/names/n87914041> <http://www.w3.org/2004/02/skos/core#changeNote> _:b22 .
<http://id.loc.gov/authorities/names/n87914041> <http://www.w3.org/2004/02/skos/core#exactMatch> <http://viaf.org/viaf/sourceID/LC%7Cn+87914041#skos:Concept> .
<http://id.loc.gov/authorities/names/n87914041> <http://www.w3.org/2004/02/skos/core#inScheme> <http://id.loc.gov/authorities/names> .
<http://id.loc.gov/authorities/names/n87914041> <http://www.w3.org/2004/02/skos/core#prefLabel> "American Film Manufacturing Company"@en .
<http://id.loc.gov/authorities/names/n87914041> <http://www.w3.org/2008/05/skos-xl#altLabel> _:b16 .
<http://id.loc.gov/authorities/names/n87914041> <http://www.w3.org/2008/05/skos-xl#altLabel> _:b19 .
<http://id.loc.gov/authorities/names/n87914041> <http://www.w3.org/2008/05/skos-xl#altLabel> _:b7 .
_:b2 <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://www.loc.gov/mads/rdf/v1#RWO> .
_:b2 <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://xmlns.com/foaf/0.1/Organization> .
_:b3 <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://www.loc.gov/mads/rdf/v1#NameElement> .
_:b3 <http://www.loc.gov/mads/rdf/v1#elementValue> "American Film Company"@en .
_:b4 <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://www.loc.gov/mads/rdf/v1#CorporateName> .
_:b4 <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://www.loc.gov/mads/rdf/v1#Variant> .
_:b4 <http://www.loc.gov/mads/rdf/v1#elementList> _:b5 .
_:b4 <http://www.loc.gov/mads/rdf/v1#variantLabel> "American Film Company"@en .
_:b5 <http://www.w3.org/1999/02/22-rdf-syntax-ns#first> _:b3 .
_:b5 <http://www.w3.org/1999/02/22-rdf-syntax-ns#rest> <http://www.w3.org/1999/02/22-rdf-syntax-ns#nil> .
_:b6 <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://www.loc.gov/mads/rdf/v1#NameElement> .
_:b6 <http://www.loc.gov/mads/rdf/v1#elementValue> "North American Film Corporation"@en .
_:b7 <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://www.w3.org/2008/05/skos-xl#Label> .
_:b7 <http://www.w3.org/2008/05/skos-xl#literalForm> "Flying A Studio"@en .
_:b8 <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://www.loc.gov/mads/rdf/v1#CorporateName> .
_:b8 <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://www.loc.gov/mads/rdf/v1#Variant> .
_:b8 <http://www.loc.gov/mads/rdf/v1#elementList> _:b9 .
_:b8 <http://www.loc.gov/mads/rdf/v1#variantLabel> "North American Film Corporation"@en .
_:b9 <http://www.w3.org/1999/02/22-rdf-syntax-ns#first> _:b6 .
_:b9 <http://www.w3.org/1999/02/22-rdf-syntax-ns#rest> <http://www.w3.org/1999/02/22-rdf-syntax-ns#nil> .
_:b10 <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://www.loc.gov/mads/rdf/v1#Source> .
_:b10 <http://www.loc.gov/mads/rdf/v1#citation-note> "credits (American Film Manufacturing Company)"@en .
_:b10 <http://www.loc.gov/mads/rdf/v1#citation-source> "The Rose of San Juan [MP] 1913:" .
_:b10 <http://www.loc.gov/mads/rdf/v1#citation-status> "found" .
_:b11 <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://www.loc.gov/mads/rdf/v1#NameElement> .
_:b11 <http://www.loc.gov/mads/rdf/v1#elementValue> "Flying A Studio"@en .
_:b12 <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://www.loc.gov/mads/rdf/v1#Source> .
_:b12 <http://www.loc.gov/mads/rdf/v1#citation-note> "CIP galley (American Film Manufacturing Co. was popularly known as the Flying A Studio)"@en .
_:b12 <http://www.loc.gov/mads/rdf/v1#citation-source> "Lawton, S. Santa Barbara's Flying A Studio, 1997:" .
_:b12 <http://www.loc.gov/mads/rdf/v1#citation-status> "found" .
_:b13 <http://www.w3.org/1999/02/22-rdf-syntax-ns#first> _:b14 .
_:b13 <http://www.w3.org/1999/02/22-rdf-syntax-ns#rest> <http://www.w3.org/1999/02/22-rdf-syntax-ns#nil> .
_:b14 <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://www.loc.gov/mads/rdf/v1#NameElement> .
_:b14 <http://www.loc.gov/mads/rdf/v1#elementValue> "American Film Manufacturing Company"@en .
_:b15 <http://www.w3.org/1999/02/22-rdf-syntax-ns#first> _:b11 .
_:b15 <http://www.w3.org/1999/02/22-rdf-syntax-ns#rest> <http://www.w3.org/1999/02/22-rdf-syntax-ns#nil> .
_:b16 <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://www.w3.org/2008/05/skos-xl#Label> .
_:b16 <http://www.w3.org/2008/05/skos-xl#literalForm> "American Film Company"@en .
_:b17 <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://www.loc.gov/mads/rdf/v1#Source> .
_:b17 <http://www.loc.gov/mads/rdf/v1#citation-note> "(hdg.: American Film Manufacturing Company)"@en .
_:b17 <http://www.loc.gov/mads/rdf/v1#citation-source> "LC data base, 9-16-87" .
_:b17 <http://www.loc.gov/mads/rdf/v1#citation-status> "found" .
_:b18 <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://www.loc.gov/mads/rdf/v1#Source> .
_:b18 <http://www.loc.gov/mads/rdf/v1#citation-source> "The Great Stanley secret. Chapter 1, The gipsy's trust [MP] 1917 (produced by American Film Company; North American Film Corporation presents)" .
_:b18 <http://www.loc.gov/mads/rdf/v1#citation-status> "found" .
_:b19 <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://www.w3.org/2008/05/skos-xl#Label> .
_:b19 <http://www.w3.org/2008/05/skos-xl#literalForm> "North American Film Corporation"@en .
_:b20 <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://id.loc.gov/ontologies/RecordInfo#RecordInfo> .
_:b20 <http://id.loc.gov/ontologies/RecordInfo#languageOfCataloging> <http://id.loc.gov/vocabulary/iso639-2/eng> .
_:b20 <http://id.loc.gov/ontologies/RecordInfo#recordChangeDate> "1988-04-25T00:00:00"^^<http://www.w3.org/2001/XMLSchema#dateTime> .
_:b20 <http://id.loc.gov/ontologies/RecordInfo#recordContentSource> <http://id.loc.gov/vocabulary/organizations/dlc> .
_:b20 <http://id.loc.gov/ontologies/RecordInfo#recordStatus> "new" .
_:b21 <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://www.loc.gov/mads/rdf/v1#CorporateName> .
_:b21 <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://www.loc.gov/mads/rdf/v1#Variant> .
_:b21 <http://www.loc.gov/mads/rdf/v1#elementList> _:b15 .
_:b21 <http://www.loc.gov/mads/rdf/v1#variantLabel> "Flying A Studio"@en .
_:b22 <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://purl.org/vocab/changeset/schema#ChangeSet> .
_:b22 <http://purl.org/vocab/changeset/schema#changeReason> "revised" .
_:b22 <http://purl.org/vocab/changeset/schema#createdDate> "2008-03-05T05:30:10"^^<http://www.w3.org/2001/XMLSchema#dateTime> .
_:b22 <http://purl.org/vocab/changeset/schema#creatorName> <http://id.loc.gov/vocabulary/organizations/dlc> .
_:b22 <http://purl.org/vocab/changeset/schema#subjectOfChange> <http://id.loc.gov/authorities/names/n87914041> .
}
EOF
end
