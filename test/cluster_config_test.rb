require 'test_helper'

describe 'HadoopClusterConfig' do

	def to_hash(&block)
		config = Clusterstruck::HadoopClusterConfig.new
		config.instance_eval(&block)
		config.to_hash
	end

  before do
  end

  it "should validate that the name is set" do
  	assert_raises Clusterstruck::ValidationException do 
			config_hash = to_hash {
				ec2_key_name 'a_key_pair'
			}
		end
	end

  it "should validate that the EC2 key pair name is set" do
  	assert_raises Clusterstruck::ValidationException do 
			config_hash = to_hash {
				name 'test'
			}
		end
	end  

  it "should set sensible defaults" do
		config_hash = to_hash {
			name 'test'
			ec2_key_name 'a_key_pair'
		}
		config_hash.must_equal({
			:name => 'test',
	    :ami_version => 'latest',
	    :log_uri => nil,
	    :instances => {
	      :master_instance_type => 'm1.small',
	      :slave_instance_type => 'm1.small',
	      :instance_count => 2,
	      :ec2_key_name => 'a_key_pair',
	      :keep_job_flow_alive_when_no_steps => false
	    },
	    :bootstrap_actions => [],
	    :steps => []
		})
  end

  it "should set the log URI" do
		config_hash = to_hash {
			name 'test'
			ec2_key_name 'a_key_pair'
			log_uri "s3://bucket.bloke.com/barry/folder"
		}
		config_hash[:log_uri].must_equal "s3://bucket.bloke.com/barry/folder"
  end

  it "should derive the log URI from a bucket name" do
		config_hash = to_hash {
			name 'test'
			ec2_key_name 'a_key_pair'
			bucket "bucket.bob.com"
		}
		config_hash[:log_uri].must_equal "s3://bucket.bob.com/logs"
  end

  it "should prefer the log URI to be set directly" do
		config_hash = to_hash {
			name 'test'
			ec2_key_name 'a_key_pair'
			bucket "bucket.bob.com"
			log_uri "s3://bucket.bloke.com/barry/folder"
		}
		config_hash[:log_uri].must_equal "s3://bucket.bloke.com/barry/folder"
  end

  it "should set the AMI version" do
		config_hash = to_hash {
			name 'test'
			ec2_key_name 'a_key_pair'
			ami_version "2.3"
		}
		config_hash[:ami_version].must_equal "2.3"
  end

  it "should set instance types" do
		config_hash = to_hash {
			name 'test'
			ec2_key_name 'a_key_pair'
			master_instance_type "m1.large"
			slave_instance_type "m3.2xlarge"
		}
		config_hash[:instances][:master_instance_type].must_equal "m1.large"
		config_hash[:instances][:slave_instance_type].must_equal "m3.2xlarge"
  end  

  it "should set number of instances" do
		config_hash = to_hash {
			name 'test'
			ec2_key_name 'a_key_pair'
			instance_count 2
		}
		config_hash[:instances][:instance_count].must_equal 2
  end

  it "should set the EC2 key pair name" do
		config_hash = to_hash {
			name 'test'
			ec2_key_name 'a_key_pair'
		}
		config_hash[:instances][:ec2_key_name].must_equal 'a_key_pair'
  end

  it "should set the keep alive to true or false" do
		config_hash = to_hash {
			name 'test'
			ec2_key_name 'a_key_pair'
			keep_alive true
		}
		config_hash[:instances][:keep_job_flow_alive_when_no_steps].must_equal true
  end

  it "should set a bootstrap action with a qualified URI" do
		config_hash = to_hash {
			name 'test'
			ec2_key_name 'a_key_pair'
			bootstrap 's3://bucket.bloke.com/script.sh'
		}
		config_hash[:bootstrap_actions][0].must_equal({
	        :name => "script.sh",
	        :script_bootstrap_action => {
	            :path => "s3://bucket.bloke.com/script.sh"
	        }			
		})
  end

  it "should derive an unqualified bootstrap action URI from a bucket name" do
		config_hash = to_hash {
			name 'test'
			ec2_key_name 'a_key_pair'
			bucket "bucket.bob.com"
			bootstrap 'script.sh'
		}
		config_hash[:bootstrap_actions][0].must_equal({
	        :name => "script.sh",
	        :script_bootstrap_action => {
	            :path => "s3://bucket.bob.com/bootstrap/script.sh"
	        }			
		})
  end

end
