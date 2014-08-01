[![Issue Stats](http://issuestats.com/github/hstove/issue_stats/badge/pr?style=flat)](http://issuestats.com/github/hstove/issue_stats)
[![Issue Stats](http://issuestats.com/github/hstove/issue_stats/badge/issue?style=flat)](http://issuestats.com/github/hstove/issue_stats)

[![Code Climate](http://img.shields.io/codeclimate/github/hstove/issue_stats.svg?style=flat)](https://codeclimate.com/github/hstove/issue_stats)
[![Coverage Status](https://img.shields.io/coveralls/hstove/issue_stats.svg?style=flat)](https://coveralls.io/r/hstove/issue_stats?branch=master)

This is a project for analyzing how long it takes for Github issues to
be closed.

This project serves badges like so:

http://issuestats.com/github/rails/rails/badge/pr :
![rails/rails](http://issuestats.com/github/rails/rails/badge/pr)
http://issuestats.com/github/twbs/bootstrap/badge/issue :
![twbs/bootstrap](http://issuestats.com/github/twbs/bootstrap/badge/issue)

You can add `?style=flat` to the url to get a flat badge:

http://issuestats.com/github/joyen/node/badge/pr?style=flat :
![joyen/node](http://issuestats.com/github/joyent/node/badge/pr?style=flat)

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

Running [`gaurd`](https://github.com/guard/guard) will start a few things:

- rails at http://localhost:3006
- a Sidekiq worker a concurrency of 1
- an rspec auto-runner with `guard-rspec`

[ ![Codeship Status for hstove/issue_stats](https://codeship.io/projects/b6aa3c60-f784-0131-0d1e-122c3f72c49d/status?branch=master)](https://codeship.io/projects/28591)