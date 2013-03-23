require 's3ftp'

module S3ftp
	class Driver
		def change_dir(path, &block)
			# TODO: Implement this
		end

		def dir_contents(path, &block)
			# TODO: Implement this
		end

		def authenticate(user, pass, &block)
			# TODO: Implement this
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
			# TODO: Implement this
		end

		def delete_dir(path, &block)
			# TODO: Implement this
		end

		def rename(from, to, &block)
			# TODO: Implement this
		end

		def make_dir(path, &block)
			# TODO: Implement this
		end

		def put_file(path, tmp_file_path, &block)
			# TODO: Implement this
		end

		def put_file_stramed(path, datasocket, &block)
			# TODO: Implement this
		end

	end
end
