RDF::Marmotta
=============

[![Build Status](https://travis-ci.org/dpla/rdf-marmotta.svg?branch=develop)](https://travis-ci.org/dpla/rdf-marmotta) [![Code Climate](https://codeclimate.com/github/dpla/rdf-marmotta/badges/gpa.svg)](https://codeclimate.com/github/dpla/rdf-marmotta) [![Test Coverage](https://codeclimate.com/github/dpla/rdf-marmotta/badges/coverage.svg)](https://codeclimate.com/github/dpla/rdf-marmotta)

A Ruby [RDF::Repository](http://www.rubydoc.info/github/ruby-rdf/rdf/RDF/Repository) implementation for [Apache Marmotta](http://marmotta.apache.org), an open platform for linked data.

Installing & Using
------------------

Add `gem rdf-marmotta` to `Gemfile` and run:

```bash 
  $ bundle install
```

To use, `require rdf/marmotta` and initialize a repository with
`RDF::Marmotta.new('http://path.to/marmotta_base')`.

If you need a simple bundled version of Marmotta and Solr, see
[`marmotta-jetty`](https://github.com/dpla/marmotta-jetty).

NOTE: WIP
---------

This software implements simple RDF::Repository functionality, but is
likely riddled with problems and non-performant. Don't point it at a
datastore you care about.

License
-------

This is free and unencumbered public domain software. For more information,
see <http://unlicense.org/> or the accompanying [UNLICENSE](UNLICENSE) file.