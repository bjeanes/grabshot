# Grabshot

Mini API to create screenshots of websites and call back with the image data.

**This was a breakable toy that I hacked together as a proof of concept. It's pretty hacky currently, but still pretty young...**

## Using

See [here](http://grabshot.herokuapp.com/#docs) for documentation.

## Running

Make sure you have PhantomJS installed.

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

    heorku config:add \
      PATH="/usr/local/bin:/usr/bin:/bin:/app/vendor/phantomjs/bin" \
      LD_LIBRARY_PATH="/usr/local/lib:/usr/lib:/lib:/app/vendor/phantomjs/lib"

#### Ruby Engine

Since, for now, the image capturing is done in Threads, using JRuby or
Rubinius is advised.

The `Gemfile` is already configured to specify Rubinius if the correct
environment variables are set. This allows Heroku to set up the correct Ruby as per
[this article](https://blog.heroku.com/archives/2012/12/13/run_jruby_on_heroku_right_now).

For instance, I run the app on Heroku by doing the following:

    heroku labs:enable user-env-compile # so ENV vars are available when bundling
    heroku config:add RUBY_ENGINE="rbx-2.0.0.rc1" # Bump when 2.0.0 is out
    git push heroku

For more on `user-env-compile`, see [this article](https://devcenter.heroku.com/articles/labs-user-env-compile).

## TODO

See [here](https://trello.com/board/grabshot/516df20a8e01421844001ad0)

# License

The MIT License (MIT)
Copyright © 2013 Bo Jeanes <me@bjeanes.com>

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the “Software”), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
