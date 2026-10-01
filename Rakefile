require 'rake/testtask'

Rake::TestTask.new(:test) do |t|
  t.libs << 'lib'
  t.pattern = 'test/**/*_test.rb'
end

desc 'Check every translation against the English reference'
task :check do
  ruby 'bin/check'
end

task default: %i[test check]
