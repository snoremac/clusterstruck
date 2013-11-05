module Clusterstruck

	class S3DistCpJob

    include Clusterstruck::Configurable

    def properties
        %w{ 
        }
    end

    def initialize
    end

    def to_hash
      validate

    end

    private

    def validate
    end


	end

end