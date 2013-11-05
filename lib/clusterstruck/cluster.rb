module Clusterstruck

	class HadoopCluster

    S3_URI_PATTERN = /s3:\/\//

    include Clusterstruck::Configurable

    def initialize
      @bootstrap_paths = []
      @instance_groups = { 
        :master => InstanceGroup.new(:master)
      }
      @ami_version = :latest
      @keep_alive = false
    end

    def properties
      %w{ 
        ami_version
        bucket
        ec2_key_name
        keep_alive
        log_uri
        name
      }
    end

    def bootstrap(path)
      @bootstrap_paths.push path
    end

    def master_instance_group(&config_block)
      @instance_groups[:master] ||= InstanceGroup.new(:master)
      @instance_groups[:master].instance_eval(&config_block)
    end

    def core_instance_group(&config_block)
      @instance_groups[:core] ||= InstanceGroup.new(:core)
      @instance_groups[:core].instance_eval(&config_block)
    end

    def to_hash
      validate

      config_hash = {
        :name => @name,
        :ami_version => @ami_version.to_s,
        :log_uri => get_log_uri,
        :instances => {
          :ec2_key_name => @ec2_key_name,
          :keep_job_flow_alive_when_no_steps => @keep_alive,
          :instance_groups => @instance_groups.map { |role, group| group.to_hash }
        },
        :bootstrap_actions => get_bootstrap_actions,
        :steps => []
      }
    end

    private

    def validate
    	if !@name
    		raise ValidationException.new("Cluster name must be set.")
    	end
    	if !@ec2_key_name
    		raise ValidationException.new("EC2 key pair name must be set.")
    	end
    end

    def get_log_uri
      return @log_uri if @log_uri
      return "s3://#{@bucket}/logs" if @bucket
      nil
    end

    def get_bootstrap_actions
      @bootstrap_paths.map do |path|
        name = ''
        if (path.rindex('/'))
          name = path.slice(path.rindex('/') + 1, path.length)
        else
          name = path 
        end

        qualified_path = ''
        if S3_URI_PATTERN.match(path)
          qualified_path = path
        else
          qualified_path = "s3://#{@bucket}/bootstrap/#{path}"
        end

        { :name => name, :script_bootstrap_action => { :path => qualified_path } }
      end

    end

  end

  class InstanceGroup

    include Clusterstruck::Configurable

    def initialize(role, type = 'm1.large', count = 1)
      @role = role
      @type = type
      @count = count
    end

    def properties
      %w{
        type
        role
        count
        bid_price
      }
    end

    def to_hash
      validate

      config_hash = {
        :instance_role => @role.to_s.upcase,
        :instance_type => @type,
        :instance_count => @role == :master ? 1 : @count,
        :market => @bid_price ? 'SPOT' : 'ON_DEMAND',
      }

      if @bid_price
        config_hash[:bid_price] = @bid_price.to_s
      end

      config_hash
    end

    private

    def validate
    end

  end




end