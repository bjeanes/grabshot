# Grabshot

Mini API to create screenshots of websites and call back with the image data.

## Running

Make sure you have PhantomJS installed.

### OS X

On OS X, you can use [Homebrew](https://github.com/mxcl/homebrew) to
install Phantomjs with `brew install phantomjs`.

Then, to run the application:

    bundle install
    bundle exec foreman start

### Heroku

On Heroku, use a buildpack that includes PhantomJS. For example,
you can use
[ddollar/heroku-buildpack-multi](https://github.com/ddollar/heroku-buildpack-multi) to combine
[heroku-buildpack-phantomjs](https://github.com/stomita/heroku-buildpack-phantomjs)
and Heroku's default Ruby buildpack (already commited in `.buildpacks`:

    heroku config:add BUILDPACK_URL=https://github.com/ddollar/heroku-buildpack-multi.git`
    heorku config:add PATH="/usr/local/bin:/usr/bin:/bin:/app/vendor/phantomjs/bin" LD_LIBRARY_PATH="/usr/local/lib:/usr/lib:/lib:/app/vendor/phantomjs/lib"
