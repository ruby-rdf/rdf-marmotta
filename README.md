RDF::Marmotta
=============

A Ruby RDF::Repository implementation for [Apache Marmotta](http://marmotta.apache.org).

Installing & Using
------------------

Add `gem rdf-marmotta` to `Gemfile` and run:

```bash 
  $ bundle install
```

To use, `require rdf/marmotta` and initialize a repository with
`RDF::Marmotta.new('http://path.to/marmotta_base')`.

NOTE: WIP
---------

This software implements simple RDF::Repository functionality, but is
likely riddled with problems and non-performant. Don't point it at a
datastore you care about.
