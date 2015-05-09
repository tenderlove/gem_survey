`curl https://raw.githubusercontent.com/tenderlove/gem_survey/master/survey.rb | ruby`

ruby_project_paths = r['**/Gemfile'].map { |s| s.split('/')[0..-2].join('/') }

ruby_project_paths.each { |path|
  Dir.chdir(path)
  `curl https://raw.githubusercontent.com/tenderlove/gem_survey/master/survey.rb | bundle exec ruby`
  File.delete('survey.rb')
}

puts "Thanks for taking the time to give back to Ruby!"
