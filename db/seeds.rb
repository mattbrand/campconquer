# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).

# This is a little dangerous;
# we have to make sure not to leave any gear lists / refs containing
# obsolete gear names
Gear.destroy_all
Gear.create!([
               {name: 'hat1',
                display_name: 'Trucker Cap',
                description: 'good for long rides',
                health_bonus: 0,
                speed_bonus: 0,
                range_bonus: 4,
               },
             ])

