Panthro: the rubygems proxy cache
=================================

!!! This project is a toy, is not usable for serious !!!
The idea is to speed up the gem command caching gem and spec files.
Rubygems proxy cache Is a rack app that cache static files into a
local machine, where is runing. Is does not cache /api calls.

![Panthro Rubygems proxy cache](img/panthro.jpeg)

Install
=======

```
gem install panthro
panthro --start
```
Once is running you have to point rubygems to this new "mirror"

```
gem sources --add http://localhost:9292
```

And remove rubygems mirror:

```
gem sources --remove https://rubygems.org
```
Then you can start installing gems, and static files like
*.gem *.spec.gz will be cached in ~/.panthro folder.

How it works
============

When you execute for example ```gem install sinatra```
the firsts 2 calls are:

```
HEAD https://index.rubygems.org/versions
200 OK
GET https://index.rubygems.org/info/sinatra
```

to get the dependencies of sinatra, then it needs to get the file
sinatra-4.0.0.gemspec.rz and so, you can see the details runing:
```gem install sinatra --verbose```
The first time that you execute this it will download all the files
from rubygems and saved them into the ~/.panthro folder but if you
run ```gem install sinatra``` again from the other machine in the
same net ( obviously you have to add the source with
gem sources --add http://the-proxy-ip:9292 ), it will do all the
https://index.rubygems.org/quick/Marshal.4.8/ again, but only these, because it already has
all the other files cached:

```
sinatra-4.0.0.gem
tilt-2.4.0.gem
rack-session-2.0.0.gem
rack-protection-4.0.0.gem
mustermann-3.0.3.gem
```

You can use [rumb](http://github.com/gramos/rumb) to test the performance agaisnt using
rubygems.org directly:

```
gem install rumb
rumb rails http://localhost:9292 https://rubygems.org

###--------- RUMB Rubygems Mirror Benchmarks -------------###

=> Removing https://rubygems.org from rubygems sources...
https://rubygems.org removed from sources
=> Adding http://localhost:9292 to sources
http://localhost:9292 added to sources

=> Starting installing sinatra from: http://localhost:9292
Fetching: rack-1.6.0.gem (227328B)
Successfully installed rack-1.6.0
Fetching: tilt-1.4.1.gem (42496B)
Successfully installed tilt-1.4.1
Fetching: rack-protection-1.5.3.gem (18432B)
Successfully installed rack-protection-1.5.3
Fetching: sinatra-1.4.5.gem (346624B)
Successfully installed sinatra-1.4.5
4 gems installed

### --- BENCHMARK RESULTS FOR http://localhost:9292 --- ###
0.000000   0.000000   1.360000 (  5.212372)

=> Removing http://localhost:9292 from rubygems sources...
http://localhost:9292 removed from sources
=> Adding https://rubygems.org to sources
https://rubygems.org added to sources

=> Starting installing sinatra from: https://rubygems.org
Fetching: rack-1.6.0.gem (100%)
Successfully installed rack-1.6.0
Fetching: tilt-1.4.1.gem (100%)
Successfully installed tilt-1.4.1
Fetching: rack-protection-1.5.3.gem (100%)
Successfully installed rack-protection-1.5.3
Fetching: sinatra-1.4.5.gem (100%)
Successfully installed sinatra-1.4.5
4 gems installed

### --- BENCHMARK RESULTS FOR https://rubygems.org --- ###
  0.000000   0.000000   1.320000 ( 20.773610)
```
As you can see it takes 5 seconds using panthro and 20 without it,
obviously it depends on your internet conection.

Similar projects
================

There are other projects that does more or less the same thing,
like [Geminabox proxy support](https://github.com/geminabox/geminabox#rubygems-proxy)
or a regular web proxy like [Squid](http://www.squid-cache.org/). I've made this project
as a Learning project and with purpose of keeping as simple and small as I can,
Panthro only does one thing and is to cache gems.
