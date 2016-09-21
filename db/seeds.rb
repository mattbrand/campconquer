# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).

# This is a little dangerous;
# we have to make sure not to leave any gear lists / refs containing
# obsolete gear names
Gear.destroy_all

# To update the gear database, see README.md

f = File.expand_path("gear.csv", File.dirname(__FILE__))

begin
  Gear.read_csv f
rescue ActiveRecord::RecordInvalid => invalid
  puts "Error loading gear.csv: #{invalid.message}"
  ap invalid.record.attributes
  exit 1
end

