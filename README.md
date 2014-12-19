Panthro: the rubygems proxy cache
=================================

The idea is to speed up the gem command caching gem and spec files.
Rubygems proxu cahce Is a rack app that cache static files into a
local machine, where is runing. Is does not cache /api calls.

![Panthro Rubygems proxy cache](http://mobi-wall.brothersoft.com/files/208208/p/12829034032360.jpg)

Install
=======

```
git clone git@github.com:gramos/panthro.git
cd panthro
rackup
```
Once is running you have to point rubygems to this new "mirror"

```
gem sources --add http://localhost:4732
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
the firsts 2 calls are to https://api.rubygems.org/api/v1/
to get the dependencies of sinatra, then it needs to get the file
sinatra-1.4.5.gemspec.rz and so, you can see the details runing:
```gem install sinatra --verbose```
The first time that you execute this it will download all the files
from rubygems and saved them into the ~/.panthro folder but if you
run ```gem install sinatra``` again from the other machine in the
same net ( obviously you have to add the source with
gem sources --add http://the-proxy-ip:4732 ), it will do all the
https://api.rubygems.org/api/v1/ again, but only these, because it already has
all the other files cached:

```
sinatra-1.4.5.gemspec.rz
tilt-1.4.1.gemspec.rz
tilt-1.4.1.gem
rack-protection-1.5.3.gemspec.rz
rack-protection-1.5.3.gem
sinatra-1.4.5.gem
```

You can use [rumb](http://github.com/gramos/rumb) to test the performance agaisnt using 
rubygems.org directly:

```
gem install rumb
rumb rails http://localhost:4732 https://rubygems.org

###--------- RUMB Rubygems Mirror Benchmarks -------------###

=> Removing https://rubygems.org from rubygems sources...
https://rubygems.org removed from sources
=> Adding http://localhost:4732 to sources
http://localhost:4732 added to sources

=> Starting installing sinatra from: http://localhost:4732
Fetching: rack-1.6.0.gem (227328B)
Successfully installed rack-1.6.0
Fetching: tilt-1.4.1.gem (42496B)
Successfully installed tilt-1.4.1
Fetching: rack-protection-1.5.3.gem (18432B)
Successfully installed rack-protection-1.5.3
Fetching: sinatra-1.4.5.gem (346624B)
Successfully installed sinatra-1.4.5
4 gems installed

### --- BENCHMARK RESULTS FOR http://localhost:4732 --- ###
0.000000   0.000000   1.360000 (  5.212372)

=> Removing http://localhost:4732 from rubygems sources...
http://localhost:4732 removed from sources
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
