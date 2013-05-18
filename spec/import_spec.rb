require 'spec_helper'

describe ActiveRecord::Jdbc::Import do

  before(:all) do
    CreateProducts.up
  end

  it 'should import 1 row' do 

    products = []

    product = Product.new
    product.code = "Code"
    product.name = "Name"
    product.vendor = "Vendor"
    product.price = 100.00

    products << product
 
    Product.import(products)

    Product.count.should eq(1)

    Product.delete_all
    
  end

  it 'should import 100 rows of data' do
    products = []
    1.upto(100) do
      product = Product.new
      product.code = Faker::Lorem.word
      product.name = Faker::Name.name
      product.vendor = Faker::Name.name
      product.price = "#{rand(1000)}.#{rand(99)}".to_f
      products << product
    end

    Product.import(products)
    Product.count.should eq(100)

  end

  after(:all) do
    CreateProducts.down
  end

end
