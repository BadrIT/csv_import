$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "csv_import/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "csv_import"
  s.version     = CsvImport::VERSION
  s.authors     = ["Loai Ghoraba"]
  s.email       = ["loai.ghoraba@gmail.com"]
  s.homepage    = "https://github.com/BadrIT/csv_import"
  s.summary     = "Import records to database by transforming them to CSV rows first then inserting them using the database csv specific importer"
  s.description = "Import records to database by transforming them to CSV rows first then inserting them using the database csv specific importer"
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]

  s.add_dependency "rails", "~> 5.0.0", ">= 5.0.0"

  s.add_development_dependency 'mysql2'
end
