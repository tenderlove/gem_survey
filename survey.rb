require "rubygems"
require "net/http"
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
  'id'                => ID,
  'bundler'           => BUNDLER,
  'number of gems'    => GEM_COUNT,
  'ruby engine'       => ENGINE,
  'ruby version'      => RUBY_VERSION,
  'os'                => HOST_OS,
  'file count min'    => FILE_COUNT_MIN,
  'file count max'    => FILE_COUNT_MAX,
  'file count median' => FILE_COUNT_MEDIAN,
  'file count mean'   => FILE_COUNT_MEAN,
  'file count stddev' => FILE_COUNT_STDDEV,
  'engine version'    => ENGINE_VERSION,
}
p data
__END__

uri = URI.parse("https://docs.google.com/forms/d/1-GZn_LSCiFCIpkKi2LjDaq72ICxdmhBOYu11LwN1Pl8/formResponse")

# Shortcut
response = Net::HTTP.post_form(uri, {"entry.1933043862" => "42"})
p response
