# Grabshot

Mini API to create screenshots of websites and call back with the image data.

## Using

Post to /snap with the following query params:

* `format`: one of `jpg`, `png`, or `gif` (case-insensitive)
* `url`: the URL to screenshot
* `callback`: the URL you want notified on completion

You will get a response back at the callback shortly after with a JSON body that looks like:

    {
        "url":"http://google.com",
        "callback":"http://example.com/your/callback",
        "title":"Google",
        "imageData":"iVBORw0KGgoAAAANSUhEUgAAAlsAAAG6CAYAAAA/NYPLAAAABHNCSVQICAgIfAhkiAAAAAl...",
        "format":"PNG",
        "status":"success"
    }

The `imageData` key is Base64 encoded.

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

## TODO

* User-Agent support
* Dimension support (currently hardcoded to 1280px wide, arbitrary
  length)
* Tests (born out of a lazy experiment, but interesting enough to test now)
* Security check (essentially passing in params with only loose checks
  into exec calls)
