# Camp Conquer

Konker? I just met 'er!


# Important Links


Features: <http://sprint.ly/product/41137/dashboard/?statuses=backlog,current,complete&order=priority>

Game Database: <https://docs.google.com/spreadsheets/d/1LY9Iklc3N7RkdJKkiuVNsMJ07TFsBi973VmIqgnLO6c/>


# TODO

- [x] un-protect fitbit callback endpoint

- [ ] login
  - [x] one password, sent in the clear :-O
  - [ ] actual passwords for API and Web
  
- [x] load fitbit data as far back as needed and no further

- [ ] player HTML page -- when logged in, shows activities etc 
  - http://sprint.ly/product/41137/item/338

- [ ] 'control group' players (no team)
  - can see steps etc but no redemption 
  - need UI (Web only, for moderator? or for players too?)

## low priority features

- [ ] check steps in the background at least 1x/day, not just when players connect
  - http://sprint.ly/product/41137/item/333
  - need an extra "worker" process in heroku, $$$

- [ ] round up remainder steps

- [ ] return # of coins received in claim response (coins and gems alike)

- [ ] validate max. one capture per game

- [ ] unequip (or we may not need unequip if i add the rule “only one of each item type can be equipped” )

- [ ] player stats across all seasons in GET player endpoint


## chores
- [ ] `deploy.sh` script which does `git push heroku` and `heroku run rake db:migrate`
- [ ] seed_players should use avatar.csv to determine gear asset
- [ ] remove `current` and `locked` db fields
- [ ] create prod env
- [ ] fixture factories
- [ ] rename *_outcomes to *_results
- [ ] merge Piece into Player in API
- [ ] foreign key indexes for all tables
- [ ] New Relic
- [ ] [upgrade to Rails 5](http://blog.bigbinary.com/2016/08/18/new-framework-defaults-in-rails-5-to-make-upgrade-easier.html)
- [ ] switch from RAML to Swagger? http://swagger.io/
- [ ] make a Procfile https://devcenter.heroku.com/articles/ruby-default-web-server
- [ ] CircleCI? 
- [ ] Alex learns Unity (gratis)
- [ ] kill gear table
- [ ] new player controller for web/auth

# Updating the Seed DB

To update the gear database,

1. go to
<https://docs.google.com/spreadsheets/d/1LY9Iklc3N7RkdJKkiuVNsMJ07TFsBi973VmIqgnLO6c/>
1. select the "Gear" worksheet
1. select "File > Download As > CSV (current sheet)"
1. save as `db/gear.csv`
1. locally run `rake db:seed` (or `rake db:setup` to wipe the local DB first)
1. verify everything locally (`rake spec`, `open http://localhost:3000`, etc.)
1. `git add db; git push; git push heroku`
1. `heroku run rake db:seed`

> `Name` must be unique and remain consistent.
> NEVER remove or change the short name ("Name") of an item that exists inside a player's inventory or a game that has ever been played

(we may want to add a "disabled" flag to the spreadsheet for that scenario, or "upsert" the seeds instead of wiping them and re-inserting them)

> You may be tempted to edit the gear etc. via the admin interface. RESIST THE TEMPTATION. Do it through Google Doc / Export CSV / Git or else local demos, staging, etc. will get out of sync with production.

For paths, similar to above but

1. use the "Paths" sheet
1. save as `db/paths.csv`
1. `git add db; git push; git push heroku` to deploy

(Path changes are file-only; there is no need to re-seed the database.)

This should be obsolete soon, but I wrote a little script to convert Matt's path json into tab-delimited format for easy pasting into the gdoc. Put the various json files in `db` e.g. `db/bluePaths.json` and then...
* run `rails r "Path.print_rows('blue', 'defense')" | pbcopy`
* switch to the gdoc, click on a cell and hit *Cmd-V* to paste

## API Docs

### Atom

1. Install <https://atom.io/>
2. Install <http://apiworkbench.com/> with `apm install api-workbench`
    * **or** open `Settings/Preferences -> Install` and search for `api-workbench`
3. Activate [autosave](https://github.com/atom/autosave):

        autosave:
          enabled: true

4. Read <http://apiworkbench.com/docs/>

<!--
### command-line raml2html

raml2html doesn't fully support RAML 1.0 yet...

First, install [raml2html](https://github.com/raml2html/raml2html)
```
cd ..
git clone git@github.com:raml2html/raml2html.git
cd raml2html
git checkout raml1.0  # may no longer be needed?
chmod a+x ./bin/raml2html
npm install
```

Then go back to this dir and run:

```
../raml2html/bin/raml2html campconquer.raml > campconquer-api.html && open campconquer-api.html
```
-->

### sample request with multiple nested values

```
outcome[winner]:red
outcome[team_outcomes][][team]:red
outcome[team_outcomes][][takedowns]:20
outcome[team_outcomes][][throws]:6
outcome[team_outcomes][][team]:blue
outcome[team_outcomes][][takedowns]:10
outcome[team_outcomes][][throws]:12
```

## Admin

We are using [ActiveAdmin](http://activeadmin.info/) for some non-API UI

<http://activeadmin.info/docs/documentation.html>


## Local Development

### First Time Setup:

* `git clone git@github.com:mattbrand/campconquer.git`
* `cd campconquer`
* `bundle install`
* edit `.env` (see below)
* `rake db:setup`

Optional setup:

Alex recommends [JSON Viewer](https://chrome.google.com/webstore/detail/json-viewer/gbmdgpbipfallnflgajpaliibnhdgobh) for nicely viewing JSON output in Chrome

and [Postman](https://chrome.google.com/webstore/detail/postman/fhbjgbiflinjbdggehcddcbncdddomop?utm_source=chrome-ntp-launcher) for exploring APIs

### Pulling Code

* `git pull`
* `bundle install`
* `rake db:migrate`
* `rake db:seed` (if `seeds.rb` or its data files have changed)
* `rake spec`
* `rails server` or `heroku local`
* `open http://localhost:3000`

### Terminal Commands

| command | description |
|---|---|
| `rake state_machine:draw CLASS=Game` | update the state diagram in `Game_state.png` |
| `rake db:seed_players` | create 50 random players with random roles / positions / paths / etc. (and erases all previous players and games) |``
| `rake db:seed_game` | create 1 random game |
| `rake db:seed` | reload the Gear CSV (and migrate player items) |

### Rails Console Commands

| command | description |
|---|---|
| `rails console` | enter the console |
| `Game.current.destroy!` | destroy the current game and all related pieces/setup |
| `g = Game.current`      | get the current game, creating it if necessary        |
| `g.lock_game!`          | lock the game and copy pieces from the players |
| `g.finish_game! winner: 'red'`  | force a completion (this may break soon) |
| `g.unlock_game!`          | unlock the game and delete the copied pieces |
| `reload!`               | load changed source code (ignores initializers) |
| `reload!; Game.current.destroy!; Game.current.lock_game!` | quick game restart |
| `p = Player.find(123)` | load a player by their id |
| `p = Player.find_by_name('fred')` | load a player by their name |
| `p.buy_gear! 'hat9'`   | buy gear for a player |
| `p.equip_gear! 'hat9'` | equip gear for a player |
| `p.drop_gear! 'hat9'`  | throw away (un-own and un-equip) gear for a player |


####More complicated Rails Console examples:

*show all player names and their owned gear*
```
Player.all.map{|p| [p.name, p.gear_owned]}

=> [["Thatcher", ["hat1", "hat2", "hat3", "shirt0", "shirt1", "shirt2", "shirt3", "shoes0", "hat0"]],
 ["Megan", ["hat1", "hat2", "hat3", "shirt0", "shirt1", "shirt2", "shirt3", "shoes0", "hat0"]], ...
```

*buy (but don't re-buy) the default gear for all players*

```
Player.all.each {|p| Gear.where(owned_by_default: true).each {|g| p.buy_gear! g.name unless p.gear_owned.include?(g.name)}}
```


*set a random path on a player `p`*

```
 path = path: Path.where(team: 'red', role: 'offense').sample
 player.piece.update!(path.points)
```

### Local development with Fitbit

* Create an app for yourself at <https://dev.fitbit.com/apps> named e.g. "Matt's Local CampConquer"
    * Callback URL must be `http://localhost:3000/players/auth-callback`


* Put values inside `.env` in the project dir, e.g.:

        FITBIT_CLIENT_ID=123XXX
        FITBIT_CLIENT_SECRET=abc123abc123abc123abc123abc123abc123
        FITBIT_CALLBACK_URL=http://localhost:3000/players/auth-callback

> Note that FITBIT_CALLBACK_URL **must** correspond with the *Callback URL* on https://dev.fitbit.com/apps/edit/xxxxx

* https://ngrok.com/ may be useful if you want to demo a locally-running app to someone on the wider Internet

# Staging

## Deploy to Heroku

```
git push heroku
heroku run rake db:migrate
```

Change Heroku config vars to match local config vars (you probably don't want to do this):
```
heroku config:set `cat .env`
```

## Fitbit Integration Is (Barely) Functional!

* Create a player: https://campconquer-staging.herokuapp.com/admin/players/new
* **NOTE THE ID** and use it below instead of 999
* Authenticate that player: https://campconquer-staging.herokuapp.com/players/999/auth
* See your profile: https://campconquer-staging.herokuapp.com/players/999/profile
* See your steps for the past 3 months: https://campconquer-staging.herokuapp.com/players/999/steps
* See your activities from yesterday: https://campconquer-staging.herokuapp.com/players/999/activities

Want to see what other Fitbit info is available? Check out https://dev.fitbit.com/docs/activity/ for docs


# Miscellaneous Links

BestHTTP: https://docs.google.com/document/d/181l8SggPrVF1qRoPMEwobN_1Fn7NXOu-VtfjE6wvokg/edit#


Xamarin Studio Community Edition:
https://www.xamarin.com/download

