
clusters {

	hadoop {
		name "hadoop-mapreduce-example"
		bucket "hadoop-mapreduce.example.com"
		ec2_key_name "default"
		keep_alive true
		master_instance_group {
			type 'm1.large'
			bid_price 0.10
		}
		ami_version '3.0.0'
	}

}

jobs {

	s3distcp {
		name "copy"
		source "s3n://hadoop-mapreduce.example.com/sources/input.txt"
		dest "hdfs:///sources/input.txt"
	}

	jar {
		name "mapreduce"
		uri "s3n://hadoop-mapreduce.example.com/lib/java/hadoop-mapreduce.jar"
		job_class "com.example.MapReduceTool"
	}

}
