Feature: Normal Session
	In order to test a simple user interaction

	Scenario: Mock uploading a file
		Given I have started a session
		And I have logged in
		When I have uploaded spec/fixtures/test.txt as test.txt
		Then I should be able to download test.txt

	Scenario: Mock creating a directory
		Given I have started a session
		And I have logged in
		When I create a directory called /test_directory
		Then I should be able to cd into /test_directory

	Scenario: Mock deleting a file
		Given I have started a session
		And I have logged in
		When I have uploaded spec/fixtures/test.txt as test.txt
		Then I should be able to delete test.txt
