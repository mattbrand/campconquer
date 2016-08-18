# Camp Conquer

Konker? I just met 'er!

# TODO

> a partial list

- [ ] API Auth
- [ ] User Auth for web site
- [ ] User Auth for fitbit
- [ ] Admin Auth (Devise? we used `rails generate active_admin:install --skip-users`  )
- [ ] store fitbit user id


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

> You may be tempted to edit the gear etc. via the admin interface. RESIST THE TEMPTATION. Do it through git or local demos, staging, etc. will get out of sync with production.

Currently `rake db:seed` creates lots of random players and positions too... we should probably make a separate rake task for that

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

### Making a New Game
 
```
rails console
g = Game.current
g.lock_game!
g.finish_game! winner: 'red'
```

### Seeding Players

This makes a new set of 100 players with random roles / positions / paths :

`rake db:seed`

(Soon it should be made into a different rake task)


## Local development with FitBit

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
heroku config:set `cat .env`
```

## FitBit Integration Is (Barely) Functional!

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

