# CsvImport
CsvImport is a Ruby on Rails gem that allows fast insertion of bulk records to database using the database utility that reads data from CSV file and inserts it. To accomplish this: Given a set of records, it write these records attributes in CSV file(s) and then when ordered to persist, it loads the CSV file(s) to the database.

Currently the only supported database is **Mysql**, however you are encoureged to contribute and add support for more databases.

## Installation
Add this line to your application's Gemfile:

```bash
gem 'csv_import'
```
Add this line your database.yml config under each environment:
```local_infile: true```

So your development config block will be something like: 
```
development:
  database: my_db
  ...
  ...
  local_infile: true
```

## Usage


Initialize activerecord objects that you need to insert/update to the database, and do not call activerecord save method on them, but rather use CsvImport to persist them to database.

Example usage:

```ruby
new_books = 10.times.map{|i| Book.new(# some attrbiutes)}
present_books = Books.where(# some conditions)
present_books.each{|book| book.title= "Some title"; book.published_at= Date.today; #....}

# using block
CsvImport::Importer.new do |importer|
  new_books.each do |book|
    importer.add(book)
  end
  present_books.each do |book|
    importer.add(book)
  end
end

# without using block
importer = CsvImport::Importer.new
some_books.each do |book|
  importer.add(book)
end
importer.persist!

# passing options
default_options =   {
        terminator: "~|", # the terminator string used to seperate columns in generated csv file
        csv_files_dir: "#{Rails.root}/tmp", # the path to store generated csv files
        validate: false, # wheather to validate activerecord objects before persisting them
        delete_csv_files: true # whether to delete csv files after loading them to the database
      }
importer = CsvImport::Importer.new(default_options)

# retrieving inserted new records
imported_records = importer.imported_records # if the importer was used to persist records of the same class


CsvImport::Importer.new do |importer|
  books.each do |book|
    importer.add(book)
  end

  products.each do |product|
    importer.add(product)
  end
end
imported_books = importer.imported_records_for(Book) # if the importer was used to persist records of different classes
```
## Limitations
- Tested against Rails 5 only.
- When CsvImport persist a record, it inserts/updates **this records columns only**, and it doesn't run any callbacks.

## Supported databases
### MySQL

For MySQL, CsvImport uses LOAD DATA INFILE command to insert CSV files. For updating present records, it loads all present records into temporary table, then uses single update query to join the temporary table with the original table (on the id of the records) and update corresponding columns.

## Contributing
Contribution directions go here.

## License
The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
