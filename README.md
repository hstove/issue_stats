[![Issue Stats](http://issuestats.com/github/hstove/issue_stats/badge/pr?style=flat)](http://issuestats.com/github/hstove/issue_stats)
[![Issue Stats](http://issuestats.com/github/hstove/issue_stats/badge/issue?style=flat)](http://issuestats.com/github/hstove/issue_stats)

[![Code Climate](http://img.shields.io/codeclimate/github/hstove/issue_stats.svg?style=flat)](https://codeclimate.com/github/hstove/issue_stats)
[![Coverage Status](https://img.shields.io/coveralls/hstove/issue_stats.svg?style=flat)](https://coveralls.io/r/hstove/issue_stats?branch=master)

This is a project for analyzing how long it takes for Github issues and pull
requests to be closed.

[![screen shot 2014-08-01 at 5 21 30 pm](https://cloud.githubusercontent.com/assets/1109058/3786551/135929a8-19db-11e4-98d3-c5b3dc741117.png)](http://issuestats.com/github/rails/rails)

## Badges

This project serves badges like so:

http://issuestats.com/github/rails/rails/badge/pr :
![rails/rails](http://issuestats.com/github/rails/rails/badge/pr)
http://issuestats.com/github/twbs/bootstrap/badge/issue :
![twbs/bootstrap](http://issuestats.com/github/twbs/bootstrap/badge/issue)

You can add `?style=flat` to the url to get a flat badge:

http://issuestats.com/github/nodejs/node/badge/pr?style=flat :
![nodejs/node](http://issuestats.com/github/nodejs/node/badge/pr?style=flat)

`?style=flat-square` is also available:

http://issuestats.com/github/nodejs/node/badge/pr?style=flat-square :
![nodejs/node](http://issuestats.com/github/nodejs/node/badge/pr?style=flat-square)

You can also add `?concise=true` to the URL to get a more concise version: (thanks to [brettwooldridge](https://github.com/brettwooldridge)):

http://issuestats.com/github/rails/rails/badge/pr?style=flat-square&concise=true :
![nodejs/node](http://issuestats.com/github/nodejs/node/badge/pr?style=flat-square&concise=true)

## API

You can get JSON data for a given repository by appending `?format=json` to a repository's Issue Stats URL:

[issuestats.com/github/rails/rails?format=json](http://issuestats.com/github/rails/rails?format=json)

## Contributing

Pull requests and issues are encouraged!

This is a Rails 4.1 project.
You'll need Postgres and Redis on your machine.

To install:

~~~bash
git clone https://github.com/hstove/issue_stats.git
cd issue_stats
bundle install
rake db:create
rake db:migrate
rake db:seed # enqueues a Sidekiq job
guard
~~~

Running [`guard`](https://github.com/guard/guard) will start a few things:

- rails at http://localhost:3006
- a Sidekiq worker a concurrency of 1
- an rspec auto-runner with `guard-rspec`

[ ![Codeship Status for hstove/issue_stats](https://codeship.io/projects/b6aa3c60-f784-0131-0d1e-122c3f72c49d/status?branch=master)](https://codeship.io/projects/28591)
