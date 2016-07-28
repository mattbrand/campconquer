# Camp Conquer

Konker? I just met 'er!

# TODO

- [ ] API Auth
- [ ] User Auth
- [ ] Admin Auth (Devise? we used `rails generate active_admin:install --skip-users`  )

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

We are using ActiveAdmin for some non-API UI 

<http://activeadmin.info/docs/documentation.html>


## Local Development Setup

* `git pull`
* `bundle install`
* edit `.env` (see below)
* `rake db:migrate`
* `rails server`

## Local development with FitBit

* Create an app for yourself at <https://dev.fitbit.com/apps>

* Put values inside `.env` in the project dir, e.g.:

      FITBIT_CLIENT_ID=227W5K
      FITBIT_CLIENT_SECRET=d4d5c9c23c517c19ba238851c153f771
      FITBIT_CALLBACK_URL=http://localhost:3000/players/auth-callback

> Note that FITBIT_CALLBACK_URL **must** correspond with the *Callback URL* on https://dev.fitbit.com/apps/edit/xxxxx

* https://ngrok.com/ may be useful if you want to demo a locally-running app to someone on the wider Internet


# Unity links

BestHTTP: https://docs.google.com/document/d/181l8SggPrVF1qRoPMEwobN_1Fn7NXOu-VtfjE6wvokg/edit#
