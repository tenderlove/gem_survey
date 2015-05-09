require 'fileutils'

`curl https://raw.githubusercontent.com/tenderlove/gem_survey/master/survey.rb | ruby`
`curl https://raw.githubusercontent.com/tenderlove/gem_survey/master/survey.rb > /tmp/survey.rb`

ruby_project_paths = Dir['/**/Gemfile'].map { |s| s.split('/')[0..-2].join('/') }

ruby_project_paths.each { |path|
  puts "Running in #{path}"

  Dir.chdir(path)

  begin
    FileUtils.cp('/tmp/survey.rb', "#{path}/survey.rb")
    `bundle exec ruby ./survey.rb 2>/dev/null`
  rescue => e
    puts e
  ensure
    File.delete('survey.rb') if File.exist?('survey.rb')
  end
}

puts "Thanks for taking the time to give back to Ruby!"
