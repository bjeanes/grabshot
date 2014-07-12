# Grabshot

Mini API to create screenshots of websites and call back with the image data.

**This was a breakable toy that I hacked together as a proof of concept. It's pretty hacky currently, but still pretty young...**

## Using

See [here](http://grabshot.herokuapp.com/#docs) for documentation.

## Running

Make sure you have PhantomJS (>= 1.9.0) installed.

### OS X

On OS X, you can use [Homebrew](https://github.com/mxcl/homebrew) to
install Phantomjs with `brew install phantomjs`.

Then, to run the application:

    bundle install
    bundle exec foreman start

### Heroku

On Heroku, use a buildpack that includes PhantomJS.

I use [heroku-buildpack-multi](https://github.com/ddollar/heroku-buildpack-multi) to combine
[heroku-buildpack-phantomjs](https://github.com/stomita/heroku-buildpack-phantomjs)
and [Heroku's default Ruby buildpack](https://github.com/heroku/heroku-buildpack-ruby)
(look at [`.buildpacks`](.buildpacks)):

    heroku config:add BUILDPACK_URL=https://github.com/ddollar/heroku-buildpack-multi.git`

Depending on the order of the buildpacks and any other buildpacks you have, you may need to
explicitly tweak some environment variables so the app can find `phantomjs`:

    heroku config:add \
      PATH="/usr/local/bin:/usr/bin:/bin:/app/vendor/phantomjs/bin" \
      LD_LIBRARY_PATH="/usr/local/lib:/usr/lib:/lib:/app/vendor/phantomjs/lib"

#### Ruby Engine

Since, for now, the image capturing is done in Threads, using JRuby or
Rubinius is advised.

## TODO

See [here](https://trello.com/board/grabshot/516df20a8e01421844001ad0).

# License

[MIT](http://bjeanes.mit-license.org/)
