require 'rdf'
require 'rdf/rdfxml'
require 'sparql/client'
require 'enumerator'

module RDF
  class Marmotta < ::RDF::Repository

    attr_accessor :endpoints

    DEFAULT_OPTIONS = {
      :sparql => 'sparql/select',
      :sparql_update => 'sparql/update',
      :ldpath => 'ldpath'
    }

    ##
    # Supported Accept headers for Marmotta. As of 3.3.0, Marmotta will reject
    # a request if the first content type listed is not suppported.
    #
    # @see https://issues.apache.org/jira/browse/MARMOTTA-585
    CTYPES = RDF::Format.content_types.select do |key, values|
      !(values.map(&:to_s) & ['RDF::RDFXML::Format',
                              'RDF::Turtle::Format',
                              'RDF::TriG::Format',
                              'RDF::TriX::Format',
                              'RDF::N3::Format']).empty?
    end

    def initialize(base_url, options = {})
      @endpoints = DEFAULT_OPTIONS
      @endpoints.merge!(options)
      @endpoints.each do |k, v|
        next unless RDF::URI(v.to_s).relative?
        @endpoints[k] = (RDF::URI(base_url.to_s) / v.to_s)
      end
    end

    def query_client
      @query_client ||= Client.new(endpoints[:sparql])
    end

    def update_client
      @update_client ||= Client.new(endpoints[:sparql_update])
    end

    # @see RDF::Enumerable#each.
    def each(&block)
      query_client.construct([:s, :p, :o]).where([:s, :p, :o]).each_statement(&block)
    end

    # @see RDF::Mutable#insert_statement
    def insert_statement(statement)
      insert_statements([statement])
    end

    def insert_statements(statements)
      update_client.insert_data(statements)
    end

    # @see RDF::Mutable#delete_statement
    def delete_statement(statement)
      delete_statements([statement])
    end

    def delete_statements(statements)
      constant = statements.all? do |value|
        !value.respond_to?(:each_statement) && begin
          statement = RDF::Statement.from(value)
          statement.constant? && !statement.has_blank_nodes?
        end
      end

      if constant
        update_client.delete_data(statements)
      else
        update_client.delete_insert(statements)
      end
    end

    def clear
      update_client.query("DELETE { ?s ?p ?o } WHERE { ?s ?p ?o }")
    end

    class Client < SPARQL::Client
      MARMOTTA_GRAPH_ALL = (Marmotta::CTYPES.keys + ['*/*;p=0.1'])
        .join(', ').freeze

      def initialize(url, options = {}, &block)
        options[:method] ||= :get
        options[:protocol] ||= '1.1'
        super
      end

      ##
      # Limit to accepted content types per comment on RDF::Marmotta::CTYPES
      def request(query, headers={}, &block)
        headers['Accept'] ||= MARMOTTA_GRAPH_ALL if
          (query.respond_to?(:expects_statements?) ?
           query.expects_statements? :
           (query =~ /CONSTRUCT|DESCRIBE|DELETE|CLEAR/))
        super
      end
    end
  end
end
