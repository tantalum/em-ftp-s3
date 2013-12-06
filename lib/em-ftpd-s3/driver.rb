require 'em-ftpd-s3'
require 'aws/s3'
require 'csv'
require 'time'

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
      if directory?(object) || path == "/" #<-- TLD might not be marked as a directory
        yield true
      else
        yield false
      end
    end

    def dir_contents(path, &block)
      bucket = get_bucket()
      path = translated_path_with_slash(path)

      if not bucket.nil?
        dirs = []
        bucket.objects(:prefix=>path).each do |obj|
          if child_of?(obj, path)
            dirs << s3object_to_dir_item(obj)
          end
        end

        yield dirs if not dirs.empty?
        yield nil if dirs.empty?
      else
        # TODO: Need a better way of reporting errors
        # But we are limited by the driver specs for em-ftpd
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
      path_to = translated_path(to)

      if not s3obj.nil? and not directory?(s3obj)
        # TODO: Surround with correct begin/rescue block
        AWS::S3::S3Object.rename(s3obj.key, path_to, BUCKET_NAME, {})
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
      rescue
        yield false
      end
    end

    def put_file(path, tmp_file_path, &block)
      tpath = translated_path(path)
      begin
        AWS::S3::S3Object.store(tpath, open(tmp_file_path), BUCKET_NAME)
        obj = get_object(path)
        yield obj.size
      rescue 
        yield false
      end
    end

    def put_file_streamed(path, stream, &block)
      tpath = translated_path(path)
      begin
        AWS::S3::S3Object.store(tpath, stream, BUCKET_NAME)
        obj = get_object(path)
        yield obj
      rescue
        yield false
      end
    end

    # ---------------------- HELPER FUNCTIONS --------------------------------------
    
    def translated_path(path)
      path = "" if path == "/"

      path = File.join("/", PATH_PREFIX, path)[1, 1024]
      return path
    end

    def translated_path_with_slash(path)
      path = translated_path(path)
      path[path.length] = '/' if path[path.length-1] != "/"
      return path
    end

    def get_object(path)
      path = translated_path(path)
      begin
        obj = AWS::S3::S3Object.find(path, BUCKET_NAME)
        return obj
      rescue 
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

    def child_of?(s3obj, path)
      path = File.join("/",BUCKET_NAME, path)
      if s3obj.path.start_with?(path)
        reduced_path = s3obj.path.gsub(path, '')
        if not reduced_path.empty? and reduced_path.split('/').length == 1
          return true
        end
      end
      return false
    end

    def get_bucket()
      bucket = nil
      begin
        bucket = AWS::S3::Bucket.find(BUCKET_NAME)
      rescue 
        bucket = nil
      end
      return bucket
    end

    def s3object_to_dir_item(s3obj)
      name = File.basename(s3obj.key)
      time = Time.parse(s3obj.about['date'])
      di = EM::FTPD::DirectoryItem.new(:name => name, :size => 0, :time => time)
      if not directory?(s3obj)
        # If the item is not a directory just assume it's a file 
        # because it could be uploaded from another source and not have our metadata attached
        di.size = s3obj.size
      else
        di.directory = true
      end
      return di
    end

  end
end
