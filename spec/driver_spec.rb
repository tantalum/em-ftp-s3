require 'rubygems'
require 'vcr'
require 'yaml'
require "em-ftpd-s3"

def with_cassette
	VCR.use_cassette('s3', :record => :new_episodes) do
		yield
	end
end

conf = YAML.load_file('spec/spec_config.yaml')

VCR.configure do |c|
	c.cassette_library_dir = conf['cassette_dir']
	c.hook_into :webmock
end

describe EM::FTPD::S3::Driver, "Authetication" do
	before(:each) do 
		with_cassette do
			@driver = EM::FTPD::S3::Driver.new(conf['access_key'], conf['secret_key'], conf['auth_file'])
		end
	end

	it "Should autheticate allowed users with correct password" do
		@driver.authenticate(conf['good_user'], conf['good_pass']) do |result|
			result.should eql(true)
		end
	end

	it "Should not authenticate allowed users with incorrect passoword" do
		@driver.authenticate(conf['good_user'], conf['bad_pass']) do |result|
			result.should eql(false)
		end
	end

	it "Should not authticate bad users with correct password" do
		@driver.authenticate(conf['bad_user'], conf['good_pass']) do |result|
			result.should eql(false)
		end
	end

	it "Should not authticate bad users with incorrect password" do
		@driver.authenticate(conf['bad_user'], conf['bad_pass']) do |result|
			result.should eql(false)
		end
	end
end

describe EM::FTPD::S3::Driver, "Files" do
	before(:each) do
		with_cassette do
			@driver = EM::FTPD::S3::Driver.new(conf['access_key'], conf['secret_key'], conf['auth_file'])
		end
	end

	it "Should uplaoad a file with path" do 
		with_cassette do
			@driver.put_file(conf['remote_test_file'], conf['local_test_file']) do |n|
				n.should eql(File.size(conf['local_test_file']))
			end
		end
	end

	it "Should not upload a file with invalid path" do
		with_cassette do
			@driver.put_file(conf['remote_test_file'], conf['invalid_local_test_file']) do |n|
				n.should eql(false)
			end
		end
	end
	
	it "Should stream files" do
		with_cassette do
			@driver.put_file_streamed(conf['remote_test_file'], File.open(conf['local_test_file'])) do |n|
				n.should eql(File.size(conf['local_test_file']))
			end
		end
	end

	context "with file uploaded" do 
		before(:each) do
			with_cassette do
				@driver.put_file(conf['remote_test_file'], conf['valid_local_file']) do |n|
					#Empty block
				end
			end
		end

		it "Should get valid files" do
			with_cassette do
				@driver.get_file(conf['remote_test_file']) do |result|
					result.should_not eql(nil)
				end
			end
		end
			
		it "Should not get non-existant files" do
			with_cassette do
				@driver.get_file(conf['invalid_remote_test_file']) do |result|
					result.should eql(nil)
				end
			end
		end

		it "Should delete valid files" do
			with_cassette do
				@driver.delete_file(conf['remote_test_file']) do |result|
					result.should eql(true)
				end
			end
		end

		it "Should not delete non-existant files" do
			with_cassette do
				@driver.delete_file(conf['invalid_remote_test_file']) do |result|
					result.should eql(false)
				end
			end
		end

		it "Should return the correct number of bytes of a file" do
			with_cassette do
				@driver.bytes(conf['remote_test_file']) do |n|
					n.should eql(File.size(conf['local_test_file']))
				end
			end
		end

		it "Should rename valid files"
		it "Should not rename invalid files"
	end
end

describe EM::FTPD::S3::Driver, "Directories" do
	before(:each) do 
		with_cassette do
			@driver = EM::FTPD::S3::Driver.new(conf['access_key'], conf['secret_key'], conf['auth_file'])
		end
	end
	
	it "Should create directories" do
		with_cassette do
			@driver.make_dir(conf['remote_dir_name']) do |result|
				result.should eql(true)
			end
		end
	end

	# TODO: Implement this
	it "Should not create invalid directores" 

	it "Should change to valid directories" do
		with_cassette do
			@driver.change_dir(conf['remote_dir_name']) do |result|
				result.should eql(true)
			end
		end
	end

	it "Should not chage to invalid directories" do
		with_cassette do
			@driver.change_dir(conf['invalid_remote_dir_name']) do |result|
				result.should eql(false)
			end
		end
	end

	# TODO: Implement this
	it "Should list directory contents"

	it "Should not list invalid directories" do
		with_cassette do
			@driver.dir_contents(conf['invalid_remote_dir_name']) do |result|
				result.should eql(nil)
			end
		end
	end

	it "Should delete valid directories" do 
		with_cassette do
			@driver.delete_dir(conf['remote_dir_name']) do |result|
				result.shoudl eql(true)
			end
		end
	end

	it "Should not delete invalid directories" do
		with_cassette do
			@driver.delete_dir(conf['invalid_remote_dir_name']) do |result|
				result.should eql(false)
			end
		end
	end
end

