# Camp Conquer

Konker? I just met 'er!


# Important Links


Features: <http://sprint.ly/product/41137/dashboard/?statuses=backlog,current,complete&order=priority>

Game Database: <https://docs.google.com/spreadsheets/d/1LY9Iklc3N7RkdJKkiuVNsMJ07TFsBi973VmIqgnLO6c/>


# TODO

- [ ] optimization - look at Scout for slow requests

- [x] un-protect fitbit callback endpoint

- [x] API login
  - [x] one password, sent in the clear :-O
  - [x] actual passwords for API
  - [x] login with id or name
  - [x] admin create password function
  - [x] mod role, seed mod player

- [x] Web login
 - [x] allow mutiple sessions
 - [x] expire sessions

- [x] load fitbit data as far back as needed and no further

- [ ] player HTML page -- when logged in, shows activities etc 
  - http://sprint.ly/product/41137/item/338

- [ ] 'control group' players (no team)
  - can see steps etc but no redemption 
  - need UI (Web only, for moderator? or for players too?)

## low priority features

- [x] check steps in the background at least 1x/day, not just when players connect

- [ ] round up remainder steps

- [ ] return # of coins received in claim response (coins and gems alike)

- [ ] validate max. one capture per game

- [ ] player stats across all seasons in GET player endpoint

- [ ] set session token inside WebGL HTML; skip login in client

- [ ] expire session token after X days

## chores
- heroku addons
    - [x] New Relic
    - [x] Scout
    - [x] Papertrail
    - [ ] Honeybadger or Airbrake
    - [ ] CircleCI
- [ ] rename attack_mvp to top_attacker and defense_mvp to top_defender
- [ ] seed_players should use avatar.csv to determine gear asset
- [ ] remove/unify json path files -> paths.csv
- [ ] remove `current` db field
- [ ] create prod env
  - [ ] heroku
  - [ ] fitbit
  - [ ] game client selector UI
- [ ] fixture factories
- [ ] merge Piece into Player in API and DB
- [ ] make a Procfile https://devcenter.heroku.com/articles/ruby-default-web-server
- [ ] Alex learns Unity (gratis)

- [ ] switch from RAML to Swagger? http://swagger.io/
- [ ] [upgrade to Rails 5](http://blog.bigbinary.com/2016/08/18/new-framework-defaults-in-rails-5-to-make-upgrade-easier.html)


# Updating the Seed DB

To update the gear database,

1. go to
<https://docs.google.com/spreadsheets/d/1LY9Iklc3N7RkdJKkiuVNsMJ07TFsBi973VmIqgnLO6c/>
1. select the "Gear" worksheet
1. select "File > Download As > CSV (current sheet)"
1. save as `db/gear.csv`
1. verify everything locally (`rake spec`, `open http://localhost:3000`, etc.)
1. `git add db; git push; ./deploy.sh`

> `Name` must be unique and remain consistent.
> NEVER remove or change the short name ("Name") of an item that already
> exists inside a player's inventory 
> or was used in a game that has ever been played.

(We may want to add a "disabled" flag to the spreadsheet for that scenario in order to retire gear.)

For paths, similar to above but

1. use the "Paths" sheet
1. save as `db/paths.csv`
1. `git add db; git push; ./deploy.sh` to deploy

This should be obsolete soon, but I wrote a little script to convert Matt's path json into tab-delimited format for easy pasting into the gdoc. Put the various json files in `db` e.g. `db/bluePaths.json` and then...
* run `rails r "Path.print_rows('blue', 'defense')" | pbcopy`
* switch to the gdoc, click on a cell and hit *Cmd-V* to paste

## API Docs

Reference doc: [campconquer.raml](campconquer.raml)

### Atom

1. Install <https://atom.io/>
2. Install <http://apiworkbench.com/> with `apm install api-workbench`
    * **or** open `Settings/Preferences -> Install` and search for `api-workbench`
3. Activate [autosave](https://github.com/atom/autosave):

        autosave:
          enabled: true

4. Read <http://apiworkbench.com/docs/>

### command-line raml2html

First, install [raml2html](https://github.com/raml2html/raml2html)
```
cd ..
git clone git@github.com:raml2html/raml2html.git
cd raml2html
chmod a+x ./bin/raml2html
npm install
```

Then go back to this project dir and run:

```
./doc.sh -o
```

and when the server is running later on you can access

<http://localhost:3000/campconquer-api.html> or <http://campconquer-staging.herokuapp.com/campconquer-api.html>



### sample request with multiple nested values

```
outcome[winner]:red
outcome[team_summaries][][team]:red
outcome[team_summaries][][takedowns]:20
outcome[team_summaries][][throws]:6
outcome[team_summaries][][team]:blue
outcome[team_summaries][][takedowns]:10
outcome[team_summaries][][throws]:12
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

### Unity

Open the `campconquer-unity` directory as a project dir in Unity

#### Building a Unity Build in Unity

1. click "Build Settings" (cmd-shift-B)
1. make sure platform is "WebGL" (select it and click "Switch Platform" if it's not)
1. click "Player Settings" button and make sure memory is 2032
1. click "Build" button
1. click on "public" and *Save As "CampConquer"* -- if it doesn't say "Are you sure?" then you clicked wrong

### API Usage

1. Sign in and get a token

    <http://localhost:3000/api/sessions?name=mod&password=xyzzy> =>

        {
          "status": "ok",
          "token": "c1478346db1f93b79030d3d8a7753716ac4c634247af16bd48ab31fa371aee27",
          "player_id": 1024
        }
    
2. Pass that token in to every subsequent call

    <http://localhost:3000/api/players?token=c1478346db1f93b79030d3d8a7753716ac4c634247af16bd48ab31fa371aee27> =>
    
        {
          "status": "ok",
          "players": [
            {
              "id": 1024,
              "name": "mod",
              "team": "red",
              ...
              
3. Use POSTMAN, it's good

### Terminal Commands

| command | description |
|---|---|
| `rake state_machine:draw CLASS=Game` | update the state diagram in `Game_state.png` |
| `rake db:seed_players` | create 50 random players with random roles / positions / paths / etc. (and erases all previous players and games) |``
| `rake db:seed_game` | create 1 random game |


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
| `p.update!(password: '123456')` | sets player's password |


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
./deploy.sh
```

Change Heroku config vars to match local config vars (you probably don't want to do this):
```
heroku config:set `cat .env`
```

## Check Logs

sign in to <https://heroku.com>
visit <https://dashboard.heroku.com/apps/campconquer-staging/resources>
and click on "Papertrail"

## scheduled jobs

We use Heroku Scheduler to run `rake pull_activity` from `lib/tasks/scheduler.rake` 
every night at 5:30 UTC (12:30 or 1:30 Eastern)

see <https://devcenter.heroku.com/articles/scheduler>


## Fitbit Integration Is Functional!

* Create a player: https://campconquer-staging.herokuapp.com/admin/players/new
* Click "Auth" and follow the Fitbit auth flow

Want to see what other Fitbit info is available? Check out https://dev.fitbit.com/docs/activity/ for docs


# Miscellaneous Links

BestHTTP: https://docs.google.com/document/d/181l8SggPrVF1qRoPMEwobN_1Fn7NXOu-VtfjE6wvokg/edit#


Xamarin Studio Community Edition:
https://www.xamarin.com/download

