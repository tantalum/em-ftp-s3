require 'em-ftpd-s3'
require 'aws/s3'

# NOTICE: Should this be a configuration variable?
BUCKET_PREFIX = "em-ftpd-trial-assignment/nabil"

module EM::FTPD::S3
	class Driver

		def initialize(access_key, secret_key) 
			# Establish a connection to amazon s3
			AWS::S3::Base.establish_connection!(
				:access_key_id => access_key,
				:secret_access_key => secret_key
			)
		end

		def change_dir(path, &block)
			bucket = get_bucket(path)
			yield (not bucket.nil?)

		end

		def dir_contents(path, &block)
			bucket = get_bucket(path)
			if bucket.nil?
				yield nil
			else
				dirs = [] 
				bucket.objects.each do |obj|
					dirs << s3bucket_to_dir_item(obj)
				end
				yield dirs
			end
		end

		def authenticate(user, pass, &block)
			# TODO: Implement this
			yield false
		end

		def bytes(path, &block)
			# TODO: Implement this
		end

		def get_file(path, &block)
			# TODO: Implement this
		end

		def put_file(path, &block)
			# TODO: Implement this
		end

		def delete_file(path, &block)
			s3obj = get_object(path)
			if not s3obj.nil?
				begin
					s3obj.delete
					yield true
				rescue ResponseError
					yield false
				end
			end
			yield false
		end

		def delete_dir(path, &block)
			#TODO: Surround this with the apporopriate begin/rescue block
			AWS::S3::Bucket.delete(translate_path(path), :force => true)
			yield true
		end

		def rename(from, to, &block)
			# TODO: Implement this
		end

		def make_dir(path, &block)
			begin
				AWS::S3::Bucekt.create(translate_path(path))
				yield true
			rescue AWS::S3::BucketAlreadyExists
				yield false
			end
		end

		def put_file(path, tmp_file_path, &block)
			# TODO: Implement this
		end

		def put_file_stramed(path, datasocket, &block)
			# TODO: Implement this
		end

# ---------------------- HELPER FUNCTIONS --------------------------------------
		def translated_path(path)
			path = "" if path == "/"

			File.join("/", BUCKET_PREFIX, path)[1, 1024]
		end

		def get_bucket(path)
			path = translated_path(path)
			bucket = nil
			begin 
				bucket = AWS::S3::Bucket.find(path)
			rescue AWS::S3::PermanentRedirect
				bucket = nil
			end
			return bucket
		end

		def s3bucket_to_dir_item(s3bucket) 
			EM::FTPD::DirectoryItem.new(:name => s3bucket.name, :directory => true, :size => 0)
		end

		def s3object_to_dir_item(name, s3obj)
			EM::FTPD::DirectoryItem.new(:name => s3obj.path, :size => s3obj.size)
		end

	end
end
