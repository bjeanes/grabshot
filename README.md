# Grabshot

Mini API to create screenshots of websites and call back with the image data.

## Running

Make sure you have PhantomJS installed.

On OS X, you can use [Homebrew](https://github.com/mxcl/homebrew) to
install Phantomjs with `brew install phantomjs`.

On Heroku, use a buildpack that includes PhantomJS. For example,
`heroku config:add BUILDPACK_URL=http://github.com/stomita/heroku-buildpack-phantomjs.git`.

To run:

    bundle install
    bundle exec foreman start
