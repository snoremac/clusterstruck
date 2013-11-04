module Clusterstruck


	class HadoopClusterConfig

    S3_URI_PATTERN = /s3:\/\//

    PROPERTIES = %w{ 
      ami_version
      bucket
      ec2_key_name
      instance_count
      keep_alive
      log_uri
      master_instance_type
      name
      slave_instance_type
    }

    def bootstrap(path)
      @bootstrap_paths ||= []
      @bootstrap_paths.push path
    end

    def method_missing(method, *args, &block)
      if PROPERTIES.member?(method.to_s)
        if args.count == 0
          instance_variable_get("@#{method}")
        else
          instance_variable_set("@#{method}", *args[0])
        end
      else
        super
      end
    end

    def to_hash
      validate

      config_hash = {
        :name => @name,
        :ami_version => @ami_version || 'latest',
        :log_uri => get_log_uri,
        :instances => {
          :master_instance_type => @master_instance_type || 'm1.small',
          :slave_instance_type => @slave_instance_type || 'm1.small',
          :instance_count => @instance_count || 2,
          :ec2_key_name => @ec2_key_name,
          :keep_job_flow_alive_when_no_steps => @keep_alive || false
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
      return [] unless @bootstrap_paths

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




end