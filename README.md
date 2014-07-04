# Robo Racer

[![Build Status](https://travis-ci.org/bforma/robo-racer.svg?branch=master)](https://travis-ci.org/bforma/robo-racer)
[![Coverage Status](https://coveralls.io/repos/bforma/robo-racer/badge.png)](https://coveralls.io/r/bforma/robo-racer)

## Getting started

### Prerequisites

```
brew install redis   # Key-Value Store
brew install mongodb # Document database
gem install bundler  # Ruby gem dependency manager
gem install foreman  # Process manager
```

### Installation

```
git clone git@github.com:bforma/event-pusher.git
git clone git@github.com:bforma/robo-racer.git

cd event-pusher
npm install

cd ../robo-racer
bundle install
foreman start
```
And point your browser to http://localhost:3000

## Running tests

`rspec spec`
