# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).

# This is a little dangerous;
# we have to make sure not to leave any gear lists / refs containing
# obsolete gear names
Gear.destroy_all

# To update the gear database, go to
# https://docs.google.com/spreadsheets/d/1LY9Iklc3N7RkdJKkiuVNsMJ07TFsBi973VmIqgnLO6c/
# select "File > Download As > CSV (current sheet)"
# save as db/gear.csv

f = File.expand_path("gear.csv", File.dirname(__FILE__))
gears = CSV.read(f, headers: :first_row)

gears.each do |row|
  Gear.create!([
                 {name: row["ObjectId"],
                  display_name: row["Item Name"],
                  description: row["Description"],
                  health_bonus: row["Health Bonus"],
                  speed_bonus: row["Speed Bonus"],
                  range_bonus: row["Range Bonus"],
                  # todo: type, gold, gems, level, asset_name, icon_name
                 },
               ])

end


