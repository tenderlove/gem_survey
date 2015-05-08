# Gem survey

Hi, I would like to get some statistics about gem installations so that I can better understand how we should make performance improvements to RubyGems.

# QUICK START

Do this once:

```
$ curl https://raw.githubusercontent.com/tenderlove/gem_survey/master/survey.rb | ruby
```

Then in each project do this:

```
$ curl https://raw.githubusercontent.com/tenderlove/gem_survey/master/survey.rb | bundle exec ruby
```

# Not so quick start

This script gathers some information about the gems that you have installed as well as your Ruby version, RubyGems version and operating system information and uploads them to a Google form anonymously, but with a mostly unique id.  I've outlined exactly what information is collected and why below.

I would like to collect system wide information, as well as per-project information.

## Running the script

You can run via curl or wget as below, or just download the file and run it directly.  It only depends on code in stdlib, so you shouldn't need to install anything.

### System wide statistics

For system wide statistics, run the script like this:

wget:

```
$ wget -qO- https://raw.githubusercontent.com/tenderlove/gem_survey/master/survey.rb | ruby 
```

curl:

```
$ curl https://raw.githubusercontent.com/tenderlove/gem_survey/master/survey.rb | ruby
```

### Per project stats

For per-project statistics, run the script like this:

wget:

```
$ wget -qO- https://raw.githubusercontent.com/tenderlove/gem_survey/master/survey.rb | bundle exec ruby 
```

curl:

```
$ curl https://raw.githubusercontent.com/tenderlove/gem_survey/master/survey.rb | bundle exec ruby
```
## What information is collected?

Here is a table of what information is collected and why:

| Name | Description / Reason |
|------|-------------|
| ID   | A mostly unique id that consists of a SHA256 of your hostname, ip address, time zone, and home directory. This field is to help understand how many projects each person has, and to help weed out duplicate data.|
| BUNDLER | A SHA256 of the project directory *if* the project uses bundler. This field is to help differentiate system wide statistics from per project bundler statistics. It also helps to remove duplicate records of pre project stats |
| GEM_COUNT | The number of gems available for activation. |
| ENGINE | The Ruby implementation that you're using |
| RUBY_VERSION | The version of Ruby that you're using |
| ENGINE_VERSION | The version of the engine that you're using |
| HOST_OS | Your operating system |
| FILE_COUNT_MIN | The fewest files in a gem specification |
| FILE_COUNT_MAX | The most files in a gem specification |
| FILE_COUNT_MEDIAN | The median files per gem specification |
| FILE_COUNT_MEAN | The mean files per gem specification |
| FILE_COUNT_STDDEV | The standard deviation for the files per gem specification |

This data will be posted to a Google form.  I don't have access to access logs, so I shouldn't be able to tell who posted what data.  I'll only have the data listed above.

## What will this data be used for?

I would like to use this data to determine how best to speed up RubyGems.  My goal is to add different types of caches to Ruby Gems, but the type of cache depends on the usage.  If a particular optimization only helps people who have thousands of gems, but *most* people only have hundreds, then maybe the optimization isn't worth while.

I may be able to backport these optimizations to older versions of RubyGems (by using a gem).  But that would depend on the usage.

Finally, I think the things we can do to speed up RubyGems could also be used to speed up Bundler by providing the right APIs.
