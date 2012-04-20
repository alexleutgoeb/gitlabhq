require 'spec_helper'

describe "Projects" do
  before { login_as :user }

  describe "GET /projects" do
    before do
      @project = Factory :project, :owner => @user
      @project.add_access(@user, :read)
      
      @issue = Factory :issue,
        :author => @user,
        :assignee => @user,
        :project => @project        
    end
    
    it "should render atom feed" do
      visit projects_path(:atom)

      page.response_headers['Content-Type'].should have_content("application/atom+xml")
      page.body.should have_selector("title", :text => "Recent events")
      page.body.should have_selector("author email", :text => @issue.author_email)
    end

    it "should render atom feed via private token" do
      logout
      visit projects_path(:atom, :private_token => @user.private_token)

      page.response_headers['Content-Type'].should have_content("application/atom+xml")
      page.body.should have_selector("title", :text => "Recent events")
      page.body.should have_selector("author email", :text => @issue.author_email)
    end
  end
end
