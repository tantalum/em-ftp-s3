# ###
# Do we want to make a features_conf.yaml?
# ###

conf = YAML.load_file('spec/spec_config.yaml')

Given /^I have started a session$/ do
	@driver = EM::FTPD::S3::Driver.new(conf['access_key'], conf['secret_key'], conf['auth_file'])
end

Given /^I have logged in$/ do
	@driver.authenticate(conf['good_user'], conf['good_pass']) {}
end

When /^I have uploaded (.*) as (.*)$/ do |local, remote|
	@driver.put_file(local, remote) {}
end

Then /^I should be able to download (.*)$/ do |name|
	@driver.get_file(name) do |nbytes|
		nbytes.should_not eql(nil)
	end
end

When /^I create a directory called (.*)$/ do |dirname|
	@driver.make_dir(dirname) {}
end

Then /^I should be able to cd into (.*)$/ do |dirname|
	@driver.change_dir(dirname) do |result|
		result.should eql(true)
	end
end

Then /^I should be able to delete (.*)$/ do |filename|
	@driver.delete_file(filename) do |result|
		result.should eql(true)
	end
end
