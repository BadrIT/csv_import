require 'test_helper'

class CsvImport::Test < ActiveSupport::TestCase
  setup do
    Book.delete_all
    Product.delete_all
    @books_count = 10
    @books = []
  end

  def book_attributes(i)
    {
      title: "Title '#{i}",
      description: nil,
      tags: ["Tag #{rand(10)}", "Tag #{rand(10)}"],
      options: {
        option_1: "Option_1 #{rand(10)}",
        option_2: "Option_2 #{rand(10)}",
      },
      date: Date.today + rand(1000).days,
      number_of_pages: rand(1000),
      price: rand(100) + 0.5,
      hard_cover: [true, false].sample
    }
  end

  def build_dummy_books
    @books_count.times do |i|
      @books << Book.new(book_attributes(i))
    end
  end

  def create_dummy_books
    build_dummy_books
    @books.each(&:save)
  end

  def change_dummy_books_values
    @books.each_with_index do |book, i|
      book.attributes = book_attributes(i)
    end
  end

  def assert_same_content base_records, imported_records, created_or_updated
    assert_equal base_records.count, imported_records.count
    base_records.each_with_index do |base_record, index|
      imported_record = imported_records[index]
      base_record_attributes = base_record.attributes.except("updated_at")
      imported_record_attributes = imported_record.attributes.except("updated_at")
      if created_or_updated == :created
        base_record_attributes = base_record_attributes.except("id", "created_at")
        imported_record_attributes = imported_record_attributes.except("id", "created_at")
      end
      assert_equal base_record_attributes, imported_record_attributes
    end
  end

  test "should insert new records using block" do
    build_dummy_books

    importer = CsvImport::Importer.new do |i|
      @books.each do |book|
        i.add(book)
      end
    end

    assert_same_content @books, importer.imported_records, :created
  end

  test "should insert new records without using block " do
    build_dummy_books
    
    importer = CsvImport::Importer.new
    @books.each do |book|
      importer.add(book)
    end
    importer.persist!

    assert_same_content @books, importer.imported_records, :created
  end

  test "should update present records" do
    create_dummy_books
    change_dummy_books_values

    CsvImport::Importer.new do |i|
      @books.each do |book|
        i.add(book)
      end  
    end

    assert_same_content @books, Book.where(id: @books.pluck(:id)), :updated
  end

  test "shouldn't create invalid records if validation option is set to true" do
    book = Book.new # empty title (invalid record)

    importer = CsvImport::Importer.new(validate: true) do |i|
      i.add(book)
    end

    assert importer.imported_records.empty?
  end

  test "should create invalid records if validation option is set to false" do
    book = Book.new # empty title (invalid record)

    importer = CsvImport::Importer.new(validate: false) do |i|
      i.add(book)
    end

    assert_same_content [book], importer.imported_records, :created
  end

  test "should handle records of different types" do
    build_dummy_books
    @products = 10.times.map{|i| Product.new(name: "Product #{i}", price: rand(10 + i*10))}

    importer = CsvImport::Importer.new do |i|
      @books.each do |book|
        i.add(book)
      end

      @products.each do |product|
        i.add(product)
      end
    end

    assert_same_content @books, importer.imported_records_for(Book), :created
    assert_same_content @products, importer.imported_records_for(Product), :created
  end

  test "should be able to specify a different terminator option" do
    build_dummy_books
    importer = CsvImport::Importer.new(terminator: ";") do |i|
      @books.each do |book|
        i.add(book)
      end
    end

    assert_same_content @books, importer.imported_records, :created
  end

end
