require 'rdf'
require 'rdf/rdfxml'
require 'sparql/client'
require 'enumerator'

module RDF
  class Marmotta < ::SPARQL::Client::Repository

    attr_accessor :endpoints
    attr_reader :update_client

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
      @options = options.dup
      @endpoints = DEFAULT_OPTIONS
      @endpoints.merge!(options)
      @endpoints.each do |k, v|
        next unless RDF::URI(v.to_s).relative?
        @endpoints[k] = (RDF::URI(base_url.to_s) / v.to_s)
      end
      @client = Client.new(endpoints[:sparql].to_s, options)
      @update_client = Client.new(endpoints[:sparql_update].to_s, options)
    end

    def query_client
      @client
    end

    def delete_statement(statement)
      delete(statement)
    end

    def count
      begin
        binding = client.query("SELECT (COUNT(*) AS ?no) WHERE { ?s ?p ?o }").first.to_hash
        binding[binding.keys.first].value.to_i
      rescue SPARQL::Client::ServerError
        count = 0
        each_statement { count += 1 }
        count
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

      # Do HTTP POST if it's an INSERT
      def request_method(query)
        method = (self.options[:method] || DEFAULT_METHOD).to_sym
        method = :post if query.to_s =~ /INSERT/
        method
      end
    end
  end
end
