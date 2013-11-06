require 'test_helper'

EXAMPLES_DIR = File.join(File.dirname(__FILE__), '../examples')

def example(example_file)
	File.join(EXAMPLES_DIR, example_file)
end

describe 'Config' do

	it "should configure a hadoop cluster" do
    config = Clusterstruck::Config.new
    config.instance_eval(IO.read(example('hadoop.rb')), example('hadoop.rb'))
    
    config.has_cluster_config?("hadoop-mapreduce-example").must_equal true
    config.cluster_config("hadoop-mapreduce-example").bucket.must_equal "hadoop-mapreduce.example.com"
	end

	# it "should configure an s3distcp job" do
 #    config = Clusterstruck::Config.new
 #    config.instance_eval(IO.read(example('hadoop.rb')), example('hadoop.rb'))
    
 #    config.has_job_config?('copy').must_equal true
 #    config.job_config('copy').source.must_equal 's3n://hadoop-mapreduce.example.com/sources/input.txt'
	# end

	# it "should configure a jar job" do
 #    config = Clusterstruck::Config.new
 #    config.instance_eval(IO.read(example('hadoop.rb')), example('hadoop.rb'))
    
 #    config.has_job_config?('mapreduce').must_equal true
 #    config.job_config('mapreduce').uri.must_equal 's3n://hadoop-mapreduce.example.com/lib/java/hadoop-mapreduce.jar'
	# end

end
