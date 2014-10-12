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

    def initialize(base_url, options = {})
      @endpoints = DEFAULT_OPTIONS
      @endpoints.merge!(options)
      @endpoints.each do |k, v|
        @endpoints[k] = ::URI.join(base_url, v)
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
      def initialize(url, options = {}, &block)
        options[:method] ||= :get
        options[:protocol] ||= '1.1'
        super
      end
    end
  end
end
