require 'em-ftpd-s3'
require 'aws/s3'
require 'csv'

# NOTICE: Should this be a configuration variable?
PATH_PREFIX = "nabil"
BUCKET_NAME = "em-ftpd-trial"

OBJ_TYPE_DIR="directory"
OBJ_TYPE_FILE="file"

module EM::FTPD::S3
	class Driver

		def initialize(access_key, secret_key, auth_file) 
			# Establish a connection to amazon s3
			AWS::S3::Base.establish_connection!(
				:access_key_id => access_key,
				:secret_access_key => secret_key
			)

			@auth_file = auth_file
			@user = nil
		end

		def change_dir(path, &block)
			object = get_object(path)
			if directory?(object)
				yield true
			else
				yield false
			end
		end

		def dir_contents(path, &block)
			folder = get_object(path)
			if directory?(folder)
				dirs = [] 
				bucket.objects.each do |obj|
					if child_of?(obj, path)
						dirs << s3bucket_to_dir_item(obj)
					end
				end
				yield dirs
			else
				yield nil
			end
		end

		def authenticate(user, pass, &block)
			CSV.foreach(@auth_file) do |row|
				if user == row[0] and pass == row[1]
					@user = user
					yield true
					return
				end
			end
			yield false
		end

		def bytes(path, &block)
			s3obj = get_object(path)
			if not s3obj.nil?
				yield s3obj.size
			else
				yield nil
			end
		end

		def get_file(path, &block)
			s3obj = get_object(path)
			if not s3obj.nil?
				yield s3obj.value
			else
				yield nil
			end
		end

		def delete_dir(path, &block)
			folder = get_object(path)
			if not folder.nil?
				begin
					# Check if there are any subitems
					folder.delete()
					yield true
				rescue AWS::S3::S3Exception
					yield false
				end
			else
				yield false
			end
		end

		def delete_file(path, &block)
			s3obj = get_object(path)
			if (not s3obj.nil?) and (not directory?(s3obj))

				s3obj.delete()
				yield true
			else
				yield false
			end
		end

		def rename(from, to, &block)
			s3obj = get_object(from)
			if not s3obj.nil?
				# TODO: Surround with correct begin/rescue block
				s3obj.rename(translated_path(to),BUCKET_NAME)
				yield true
			else
				yield false
			end
		end

		def make_dir(path, &block)
			begin
				AWS::S3::S3Object.store(translated_path(path), '', BUCKET_NAME)
				obj = get_object(path)
				obj.metadata[:type] = OBJ_TYPE_DIR
				obj.store()
				yield true
			rescue AWS::S3::InvalidBucketName
				yield false
			end
		end

		def put_file(path, tmp_file_path, &block)
			path = translated_path(path)
			begin
				AWS::S3::S3Object.store(path, open(tmp_file_path), BUCKET_NAME)
				yield File.size(tmp_file_path)
			rescue Exception => e
				yield false
			end
		end

		def put_file_streamed(path, datasocket, &block)
			tpath = translated_path(path)
			begin
				AWS::S3::S3Object.store(tpath, datasocket, BUCKET_NAME)
			rescue Exception => e
				yield false
				return
			end
			obj = get_object(path)
			if obj.nil?
				yield false
			else
				yield obj.size
			end
		end

# ---------------------- HELPER FUNCTIONS --------------------------------------
		
		def translated_path(path)
			path = "" if path == "/"

			path = File.join("/", PATH_PREFIX, path)[1, 1024]
			path[1, path.length]
		end

		def get_object(path)
			path = translated_path(path)
			begin
				obj = AWS::S3::S3Object.find(path, BUCKET_NAME)
				return obj
			rescue AWS::S3::NoSuchKey
				return nil
			end
		end

		def directory?(s3obj)
			if not s3obj.nil?
				if s3obj.metadata[:type] == OBJ_TYPE_DIR
					return true
				end
			end
			return false
		end

		def file?(s3obj)
			if not s3obj.nil?
				if s3obj.metadata[:type] == OBJ_TYPE_FILE
					return true
				end
			end
			return false
		end

		def child_of(s3obj, path)
			s3obj.path.starts_with(path)
		end

		def get_bucket()
			return AWS::S3::Bucket.find(BUCKET_NAME)
		end

		def s3object_to_dir_item(path, s3obj)
			name = File.basename(path)
			di
			if directory?(s3obj)
				di = EM::FTPD::DirectoryItem.new(:name => name, :size => 0, :time => s3obj.date)
			else
				# If the item is not a directory just assume it's a file 
				# because it could be uploaded from another source and not have our metadata attached
				di = EM::FTPD::DirectoryItem.new(:name => name, :size => s3obj.size, :time => s3obj.date)
			end
			return di
		end

	end
end
