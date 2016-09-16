# Camp Conquer

Konker? I just met 'er!

# TODO

> a partial list

## features

- [x] lock copies equipped gear
- [x] gear buy & equip
- [ ] default gear
  - read from "Default" column of CSV
- [x] season stats endpoint

- [ ] merge vigorous and moderate
- [ ] steps: look back more than 2 days if needed
- [ ] MVP: only role=offense can be attack_mvp et al 

- [ ] player stats (all season(s?))
- make "moves" more efficient
  - [ ] upload
  - [x] download
  - [ ] storage 
- [x] create a separate endpoint for game so that moves don't always get sent
- [x] add player_id to PlayerOutcome in & out
- [ ] paths: kill json, use csv and google doc
  - needs coordination with Unity code
- [x] calculate attack_mvp and defend_mvp

- User Authentication:
    - [ ] API Auth
    - [ ] User Auth for web site
    - [ ] Admin Auth (Devise? we used `rails generate active_admin:install --skip-users`  )
- [ ] de-auth (disconnect) a fitbit

- Avatar Creation

- Stores

- [ ] better splash page
- [ ] add 'last sync time' to player info / store
- [ ] round up remainder steps
- [ ] return # of coins received in claim response (coins and gems alike)
- [ ] 'control group' players (no team)
  - can see steps etc but no redemption 
- [ ] player HTML page -- when logged in, shows activities etc 

- [ ] only one goal: 60 min of combined moderate&vigorous
- [ ] validate max. one capture per game
- [ ] check steps in the background at least 1x/day, not just when players connect
- [ ] unequip (or we may not need unequip if i add the rule “only one of each item type can be equipped” )
- [ ] remove `current` and `locked` db fields

## chores

- [x] state machine for game
- [x] rename gold to coins 
- [ ] create prod env
- [ ] fixture factories
- [x] merge Outcome, TeamOutcome, and PlayerOutcome
- [ ] rename *_outcomes
- [ ] merge Piece into Player in API
- [ ] foreign key indexes for all tables
- [ ] New Relic
- [ ] add `/api` prefix and `ApiController`

- [ ] [upgrade to Rails 5](http://blog.bigbinary.com/2016/08/18/new-framework-defaults-in-rails-5-to-make-upgrade-easier.html)
- [ ] switch from RAML to Swagger? http://swagger.io/
- [ ] make a Procfile https://devcenter.heroku.com/articles/ruby-default-web-server
- [ ] CircleCI? 
- [ ] Alex learns Unity (gratis)

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

> NEVER remove or change the short name ("ObjectId") of an item that exists inside a player's inventory or a game that has ever been played 

(we may want to add a "disabled" flag to the spreadsheet for that scenario, or "upsert" the seeds instead of wiping them and re-inserting them)

> You may be tempted to edit the gear etc. via the admin interface. RESIST THE TEMPTATION. Do it through Google Doc / Export CSV / Git or else local demos, staging, etc. will get out of sync with production.


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

### sample request

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
* `rails server`
* `open http://localhost:3000`

### Terminal Commands

| command | description |
|---|---|
| `rake state_machine:draw CLASS=Game` | update the state diagram in `Game_state.png` |


### Rails Console Commands

| command | description |
|---|---|
| `rails console` | enter the console |
| `Game.current.destroy!` | destroy the current game and all related pieces/setup |
| `g = Game.current`      | get the current game, creating it if necessary        |
| `g.lock_game!`          | lock the game and copy pieces from the players |
| `g.finish_game! winner: 'red'`  | force a completion (this may break soon) |
| `reload!`               | load changed source code (ignores initializers) |
| `reload!; Game.current.destroy!; Game.current.lock_game!` | quick game restart |


### Seeding Players

This makes a new set of 100 players with random roles / positions / paths / etc. :

`rake db:seed_players`

## Local development with Fitbit

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

Game Database:
https://docs.google.com/spreadsheets/d/1LY9Iklc3N7RkdJKkiuVNsMJ07TFsBi973VmIqgnLO6c/

Xamarin Studio Community Edition:
https://www.xamarin.com/download

