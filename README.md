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

[![Deploy on Heroku](https://i.cloudup.com/sjLqTMcojN.svg)](https://heroku.com/deploy)

#### Ruby Engine

Since, for now, the image capturing is done in Threads, using JRuby or
Rubinius is advised.

## TODO

See [here](https://trello.com/board/grabshot/516df20a8e01421844001ad0).

# License

[MIT](http://bjeanes.mit-license.org/)
