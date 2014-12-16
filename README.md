Rubygems Proxy Cache
====================

The idea is to speed up the gem command caching gem and spec files.
Rubygems proxu cahce Is a rack app that cache static files into a
local machine, where is run. Is does not cache /api calls.

Install
=======

```
git clone git@github.com:gramos/rubygems-proxy-cache.git
cd rubygems-proxy-cache
rackup
```

Once is running you have to point rubygems to this new "mirror"

```
gem sources --add http://localhost:9292
```

And remove rubygems mirror:

```
gem sources --remove http://rubygems.org
```
Then you can start installing gems, and static files like
*.gem *.spec.gz will be cached in ./cache folder.

How it works
============

When you execute for example ```gem install sinatra```
as you can see the firsts 2 calls are to https://api.rubygems.org/api/v1/
to get the dependencies fo sinatra then it needs to get the file
sinatra-1.4.5.gemspec.rz and so. The first time that you execute this
it will download all the files from rubygems a saved them into the ./cache
folder but if you run ```gem install sinatra``` a few minutes after this
from the other machine in the same net ( obviously you have to add the source with
gem sources --add http://the-proxy-ip:9292 ), it will do all the
https://api.rubygems.org/api/v1/ again, but only these ones, because it already has
all the other files:


```
sinatra-1.4.5.gemspec.rz
tilt-1.4.1.gemspec.rz
tilt-1.4.1.gem
rack-protection-1.5.3.gemspec.rz
rack-protection-1.5.3.gem
sinatra-1.4.5.gem
```

Http calls when you run ```gem install sinatra```
-------------------------------------------------

```
HEAD https://api.rubygems.org/api/v1/dependencies
200 OK

GET https://api.rubygems.org/api/v1/dependencies?gems=sinatra
200 OK

GET https://api.rubygems.org/quick/Marshal.4.8/sinatra-1.4.5.gemspec.rz
302 Moved Temporarily

GET https://rubygems.global.ssl.fastly.net/quick/Marshal.4.8/sinatra-1.4.5.gemspec.rz
200 OK

GET https://api.rubygems.org/api/v1/dependencies?gems=rack,rack-protection,tilt
200 OK

GET https://api.rubygems.org/quick/Marshal.4.8/tilt-1.4.1.gemspec.rz
302 Moved Temporarily

GET https://rubygems.global.ssl.fastly.net/quick/Marshal.4.8/tilt-1.4.1.gemspec.rz
200 OK

Downloading gem tilt-1.4.1.gem
GET https://api.rubygems.org/gems/tilt-1.4.1.gem
302 Moved Temporarily

GET https://rubygems.global.ssl.fastly.net/gems/tilt-1.4.1.gem
Successfully installed tilt-1.4.1

GET https://api.rubygems.org/quick/Marshal.4.8/rack-protection-1.5.3.gemspec.rz
302 Moved Temporarily

GET https://rubygems.global.ssl.fastly.net/quick/Marshal.4.8/rack-protection-1.5.3.gemspec.rz
200 OK

Downloading gem rack-protection-1.5.3.gem
GET https://api.rubygems.org/gems/rack-protection-1.5.3.gem
302 Moved Temporarily

GET https://rubygems.global.ssl.fastly.net/gems/rack-protection-1.5.3.gem
Fetching: rack-protection-1.5.3.gem (100%)
200 OK
Successfully installed rack-protection-1.5.3

Downloading gem sinatra-1.4.5.gem
GET https://api.rubygems.org/gems/sinatra-1.4.5.gem
302 Moved Temporarily

GET https://bb-m.rubygems.org/gems/sinatra-1.4.5.gem
Fetching: sinatra-1.4.5.gem (100%)
200 OK
Successfully installed sinatra-1.4.5

Parsing documentation for tilt-1.4.1
Parsing sources...
100% [21/21]  lib/tilt/yajl.rb
Installing ri documentation for tilt-1.4.1
Parsing documentation for rack-protection-1.5.3
Parsing sources...
100% [16/16]  lib/rack/protection/xss_header.rb
Installing ri documentation for rack-protection-1.5.3
Parsing documentation for sinatra-1.4.5
Parsing sources...
100% [19/19]  lib/sinatra/version.rb
Installing ri documentation for sinatra-1.4.5
```
