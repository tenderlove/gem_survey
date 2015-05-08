require "rubygems"
require "net/http"
require "net/https"
require "uri"
require "digest/sha2"
require "socket"
require "find"

def gem_specs
  if Gem::Specification.respond_to? :_all
    Gem::Specification.to_a
  else
    Gem.source_index.map(&:last)
  end
end

def full_require_paths spec
  if spec.respond_to? :full_require_paths
    spec.full_require_paths
  else
    spec.require_paths.map { |x| File.join spec.full_gem_path, x }
  end
end

def requirable_files spec
  files = []
  full_require_paths(spec).uniq.each do |dir|
    next unless File.directory? dir
    Find.find(dir) do |path|
      unless File.directory? File.expand_path(path)
        files << path
      end
    end
  end
  files
end

def engine_version engine
  return RUBY_ENGINE_VERSION if defined?(RUBY_ENGINE_VERSION)
  case engine
  when 'ruby' then RUBY_VERSION
  when 'jruby' then JRUBY_VERSION
  when 'rbx' then Rubinius::ENGINE_VERSION
  else
    'unknown'
  end
end

sha = Digest::SHA256

# Create a mostly unique anonymous ID
ID = sha.hexdigest [Socket.gethostname,
 IPSocket.getaddress(Socket.gethostname),
 Time.now.getlocal.zone,
 File.expand_path("~"), # Get the home directory (works on 1.8)
].join

# Are we being run inside bundler? If so, create an anonymous ID for the project
BUNDLER = ENV["BUNDLE_GEMFILE"] ? sha.hexdigest(ENV["BUNDLE_GEMFILE"]) : ''

specs = gem_specs

# Count the number of gem specs available
GEM_COUNT = specs.length.to_s

# Get the engine (defined? is for 1.8 compat)
ENGINE = defined?(RUBY_ENGINE) ? RUBY_ENGINE : 'ruby'

HOST_OS = RbConfig::CONFIG['host_os']

files = specs.map { |spec| requirable_files(spec) }.sort

file_counts = files.map(&:length).sort

FILE_COUNT_MIN    = file_counts.first
FILE_COUNT_MAX    = file_counts.last
FILE_COUNT_MEDIAN = file_counts[file_counts.length / 2]
FILE_COUNT_MEAN   = file_counts.inject(:+) / file_counts.length.to_f
FILE_COUNT_STDDEV = Math.sqrt(file_counts.map { |c|
  (c - FILE_COUNT_MEAN) ** 2
}.inject(:+) / file_counts.length.to_f)

ENGINE_VERSION = engine_version(ENGINE)

data = {
 "entry.1712539647" => ID,
 "entry.718926715"  => BUNDLER,
 "entry.1949110369" => GEM_COUNT,
 "entry.983120977"  => ENGINE,
 "entry.252419979"  => RUBY_VERSION,
 "entry.412327531"  => HOST_OS,
 "entry.296903173"  => FILE_COUNT_MIN,
 "entry.1554381816" => FILE_COUNT_MAX,
 "entry.25910843"   => FILE_COUNT_MEDIAN,
 "entry.1991677456" => FILE_COUNT_MEAN,
 "entry.1708019648" => FILE_COUNT_STDDEV,
 "entry.1948357669" => ENGINE_VERSION,
 "entry.1776998325" => Gem::VERSION
}

if $DEBUG
  require 'pp'
  pp data
end

uri = URI.parse 'https://docs.google.com/forms/d/1BlBZY8yZlny1Js6UOVnBos2Qf9pROUgoXN42mgkhLbk/formResponse'

# 1.8 support :(
http = Net::HTTP.new(uri.host, uri.port)
http.use_ssl = true

request = Net::HTTP::Post.new(uri.request_uri)
request.set_form_data(data)
http.request(request)

puts "thank you! <3<3"
