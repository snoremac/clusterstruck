require 'aws-sdk'

require "clusterstruck/version"
require "clusterstruck/cluster_config"

module Clusterstruck

  AWS_ACCESS_KEY = ENV['AWS_ACCESS_KEY']
  AWS_SECRET_KEY = ENV['AWS_SECRET_KEY']
  AWS_REGION = ENV['AWS_REGION']

  AWS.config(:access_key_id => AWS_ACCESS_KEY, :secret_access_key => AWS_SECRET_KEY)

  def self.launch(config_file, *args)
    @config = Config.new
    @config.instance_eval(IO.read(config_file), config_file)

    config_name = args[0]
    if not @config.has_launch_config(config_name)
      raise ArgumentError.new("No launch configuration with name #{config_name}")
    end

    emr = AWS::EMR.new(:region => AWS_REGION)
    config_hash = @config.launch_config(config_name).to_hash
    puts config_hash
    #response = emr.client.run_job_flow(config_hash)
    #puts "Job flow ID: #{response[:job_flow_id]}"
  end

  def self.job(config_file, *args)
  end

  def self.terminate(config_file, *args)
  end

  class Config

    attr_reader :launch_configs
    attr_reader :job_configs

    def initialize
      @launch_configs = {}
      @job_configs = {}
    end

    def hadoop(&config_block)
      hadoop_config = HadoopClusterConfig.new()
      hadoop_config.instance_eval(&config_block)
      @launch_configs[hadoop_config.name] = hadoop_config
    end

    def has_launch_config(name)
      launch_configs.member? name
    end

    def has_job_config(name)
      job_configs.member? name
    end

    def launch_config(name)
      launch_configs[name]
    end

    def job_config(name)
      job_configs[name]
    end

  end
  
  class ValidationException < Exception
  end

end