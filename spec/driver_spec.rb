require 'rubygems'
require 'vcr'
require 'yaml'

conf = YAML.load_file('spec/spec_config.yaml')

VCR.configure do |c|
	c.cassette_library_dir = conf['cassette_dir']
	c.hook_into :webmock
end

describe EM::FTPD::S3::Driver, "Authetication" do
	before(:each) do 
		@driver = EM::FTPD::S3::Driver.new(conf['access_key'], conf['secret_key'], conf['auth_file'])
	end

	it "Should autheticate allowed users with correct password" do
		@driver.authenticate(conf['good_user'], conf['good_pass']) do |result|
			result.should eql(true)
		end
	end

	it "Should not authenticate allowed users with incorrect passoword" do
		@driver.authenticate(conf['good_user'], conf['bad_password']) do |result|
			result.should eql(false)
		end
	end

	it "Should not authticate bad users with correct password" do
		@driver.authenticate(conf['bad_user'], conf['good_password']) do |result|
			result.should eql(false)
		end
	end

	it "Should not authticate bad users with incorrect password" do
		@driver.authenticate(conf['bad_user'], conf['bad_password']) do |result|
			result.should eql(false)
		end
	end
end
