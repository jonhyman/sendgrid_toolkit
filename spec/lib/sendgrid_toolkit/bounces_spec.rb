require File.expand_path("#{File.dirname(__FILE__)}/../../helper")

describe SendgridToolkit::Bounces do
  before do
    FakeWeb.clean_registry
    @obj = SendgridToolkit::Bounces.new("fakeuser", "fakepass")
  end

  describe "#retrieve" do
    it "returns array of bounced emails" do
      FakeWeb.register_uri(:post, %r|https://sendgrid\.com/api/bounces\.get\.json\?|, :body => '[{"email":"email1@domain.com","status":"5.1.1","reason":"host [127.0.0.1] said: 550 5.1.1 unknown or illegal user: email1@domain.com"},{"email":"email2@domain2.com","status":"5.1.1","reason":"host [127.0.0.1] said: 550 5.1.1 unknown or illegal user: email2@domain2.com"}]')
      bounces = @obj.retrieve
      bounces[0]['email'].should == "email1@domain.com"
      bounces[0]['status'].should == "5.1.1"
      bounces[0]['reason'].should == "host [127.0.0.1] said: 550 5.1.1 unknown or illegal user: email1@domain.com"
    end
  end

  describe "#retrieve_with_timestamps" do
    it "parses timestamps" do
      FakeWeb.register_uri(:post, %r|https://sendgrid\.com/api/bounces\.get\.json\?.*date=1|, :body => '[{"email":"email1@domain.com","status":"5.1.1","reason":"host [127.0.0.1] said: 550 5.1.1 unknown or illegal user: email1@domain.com","created":"2009-06-01 19:41:39"},{"email":"email2@domain2.com","status":"5.1.1","reason":"host [127.0.0.1] said: 550 5.1.1 unknown or illegal user: email2@domain2.com","created":"2009-06-12 19:41:39"}]')
      bounces = @obj.retrieve_with_timestamps
      0.upto(1) do |index|
        bounces[index]['created'].kind_of?(Time).should == true
      end
      bounces[0]['created'].asctime.should == "Mon Jun  1 19:41:39 2009"
      bounces[1]['created'].asctime.should == "Fri Jun 12 19:41:39 2009"
    end
  end

  describe "#delete" do
    it "raises no errors on success" do
      FakeWeb.register_uri(:post, %r|https://sendgrid\.com/api/bounces\.delete\.json\?.*email=.+|, :body => '{"message":"success"}')
      lambda {
        @obj.delete :email => "user@domain.com"
      }.should_not raise_error
    end
    it "raises error when email address does not exist" do
      FakeWeb.register_uri(:post, %r|https://sendgrid\.com/api/bounces\.delete\.json\?.*email=.+|, :body => '{"message":"Email does not exist"}')
      lambda {
        @obj.delete :email => "user@domain.com"
      }.should raise_error SendgridToolkit::BounceEmailDoesNotExist
    end
  end

end