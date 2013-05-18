# Activerecord::Jdbc::Import

_ActiveRecord library that works with activerecord-jdbc.  It should work with ALL activerecord-jdbc drivers._

I was having a terrible time getting lots of data dumped in my Teradata database.  In the
past, using Java, I always used prepared statements.  Prepared statements are great, but they
force you to declare the type that you are inserting into the database.  This is Ruby (well, JRuby)
and we duck type, so we just want to say 'bulk load this chunk of data'.

This library aims to make loading data fast and easy.  Just call a method, and it loads your data.

## License

MIT.  Do what you want.  If you make changes please contribute them back.

## Installation

Add this line to your application's Gemfile:

    gem 'activerecord-jdbc-import'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install activerecord-jdbc-import

## Usage

    require 'active_record/jdbc/import'
    
    class Product < ActiveRecord::Base
        include ActiveRecord::Jdbc::Import
    end
    
    products = []
    
    1.upto(100) do
        product = Product.new
        product.name = "foobar123"
        products << product
    end
    
    Product.import(products) 
    
    Product.count.should eq(100)
    
It is easy to use, and probably could be easier still.  Feel free to fork the code,
make changes, fix bugs, etc.

## TODO

* The `id` column is currently ignored.  The library assumes that `id` is going to be autoincremented. Make this optional. 
* Test with more databases.  Right now, Teradata, MySQL, and SQLite3 are all working.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
