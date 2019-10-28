# Simulate Memory needs for serving web requests

![](https://www.dropbox.com/s/eqoujwsf8mrc1s1/Screenshot%202019-10-28%2014.07.29.png?raw=1)

## Install

```
$ bundle install
```

## Run

```
$ ruby simulate.rb
```

When you do this a graphic will be generated to the `tmp` directory with the simulation results and if you're on a mac or linux machine the image will pop up.

## Options

Simulate multiple threads:

```
$ THREAD_COUNT=5 ruby simulate.rb
```

Look at the environment variables at the top of `simulate.rb` for more options.
