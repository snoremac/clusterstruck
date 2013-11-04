require "bundler/gem_tasks"

$: << File.expand_path('../test', __FILE__)
$: << File.expand_path('../lib', __FILE__)

task :test do
	Dir.glob(File.expand_path('../test/**/*_test.rb', __FILE__)).each { |file| require file }	
end
