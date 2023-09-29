ENV["RACK_ENV"] = "test"

require "minitest/autorun"
require "rack/test"

require_relative "../cms"

class CMSTest < Minitest::Test
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  def test_index
    get "/"
    assert_equal 200, last_response.status
    assert_equal "text/html;charset=utf-8", last_response["Content-Type"]
    assert_includes last_response.body, "about.txt"
    assert_includes last_response.body, "changes.txt"
    assert_includes last_response.body, "history.txt"
    assert_includes last_response.body, "hello.md"
  end

  def test_viewing_history_test_document
    get "/history.txt"
    assert_equal 200, last_response.status
    assert_equal "text/plain", last_response["Content-Type"]
    assert_includes last_response.body, "2015 - Ruby 2.3 released."
  end

  def test_file_name_error
    get "/something.txt" # attempt to access nonexistent file

    assert_equal 302, last_response.status # assert that user was redirected
    
    get last_response["Location"] # request page that user was redirected to

    assert_equal 200, last_response.status
    assert_includes last_response.body, "something.txt does not exist."

    get "/" # reload the page
    refute_includes last_response.body, "something.txt does not exist"
  end

  def test_markdown_viewing
    get "/hello.md"
    assert_equal 200, last_response.status
    assert_equal "text/html;charset=utf-8", last_response["Content-Type"]
    assert_includes last_response.body, "<h1>Here we have a headline!</h1>"
  end
end