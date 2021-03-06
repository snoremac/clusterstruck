module Clusterstruck

	module Configurable
	
    def method_missing(method, *args, &block)
      if properties.member?(method.to_s)
        if args.count == 0
          instance_variable_get("@#{method}")
        else
          instance_variable_set("@#{method}", *args[0])
        end
      else
        super
      end
    end

	end

  class Config

    attr_reader :cluster_configs
    attr_reader :job_configs

    def initialize
      @cluster_configs = {}
      @job_configs = {}
    end

    def clusters(&config_block)
      self.instance_eval(&config_block)
    end

    def jobs(&config_block)
      self.instance_eval(&config_block)
    end

    def hadoop(&config_block)
      hadoop_config = HadoopCluster.new
      hadoop_config.instance_eval(&config_block)
      @cluster_configs[hadoop_config.name] = hadoop_config
    end

    def s3distcp(&config_block)
    end

    def jar(&config_block)
    end

    def has_cluster_config?(name)
      cluster_configs.member? name
    end

    def has_job_config?(name)
      job_configs.member? name
    end

    def cluster_config(name)
      cluster_configs[name]
    end

    def job_config(name)
      job_configs[name]
    end

  end
  
  class ValidationException < Exception
  end


end
