
# QEST

[![Build
Status](https://travis-ci.org/mcollina/qest.png)](https://travis-ci.org/mcollina/qest)

Hello geeks!

What you are seeing here is a prototype of a distributed [MQTT](http://mqtt.org) broker which is accessible through REST.
That's a lot of jargon, so let me show you the whole picture!

Here we are dreaming a Web of Things, where you can reach (and interact) with each of your "real" devices using the web,
as it's the Way everybody interacts with a computer these days.
However it's somewhat hard to build these kind of apps, so researchers have written custom protocols for communicating 
with the devices.
The state-of-the-art seems to be [MQTT](http://mqtt.org), which is standard, free of royalties, and widespread: 
there are libraries for all the major platforms.

QEST is a stargate between the universe of devices which speak MQTT, and the universe of apps which
speak HTTP.
In this way you don't have to deal any custom protocol, you just GET and PUT the topic URI, like these:

    $ curl -X PUT -d '{ "hello": 555 }' \
    -H "Content-Type: application/json" \
    http://mqtt.matteocollina.com/topics/prova
    $ curl http://mqtt.matteocollina.com/topics/prova
    { "hello": 555 }

Let's build cool things with MQTT, REST and Arduino!

## Usage

Install [Node.js](http://nodejs.org) version 0.8, and
[Redis](http://redis.io).

```
$ git clone git@github.com:mcollina/qest.git
$ cd qest
$ npm install
$ ./qest.js
```

## Examples

* [NetworkButton](https://github.com/mcollina/qest/wiki/Network-Button-Example)
* [NetworkButtonJSON](https://gist.github.com/mcollina/5337389), same as
  before, but exchanging JSONs.

## Contribute

* Check out the latest master to make sure the feature hasn't been
  implemented or the bug hasn't been fixed yet
* Check out the issue tracker to make sure someone already hasn't
  requested it and/or contributed it
* Fork the project
* Start a feature/bugfix branch
* Commit and push until you are happy with your contribution
* Make sure to add tests for it. This is important so I don't break it
  in a future version unintentionally.
* Please try not to mess with the Cakefile and package.json. If you
  want to have your own version, or is otherwise necessary, that is
  fine, but please isolate to its own commit so I can cherry-pick around
  it.

## Thanks

This work would not have been possible without the support
of the University of Bologna, which funded my Ph.D. program.
Moreover I would like to thank my professors, Giovanni
Emanuele Corazza and Alessandro Vanelli-Coralli for the support
and the feedbacks.

## License

Copyright (c) 2012 Matteo Collina, http://matteocollina.com

Permission is hereby granted, free of charge, to any person
obtaining a copy of this software and associated documentation
files (the "Software"), to deal in the Software without
restriction, including without limitation the rights to use,
copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the
Software is furnished to do so, subject to the following
conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
OTHER DEALINGS IN THE SOFTWARE.
