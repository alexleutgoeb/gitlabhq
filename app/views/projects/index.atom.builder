xml.instruct!
xml.feed "xmlns" => "http://www.w3.org/2005/Atom", "xmlns:media" => "http://search.yahoo.com/mrss/" do
  xml.title   "Recent events"
  xml.link    :href => projects_url(:atom), :rel => "self", :type => "application/atom+xml"
  xml.link    :href => projects_url, :rel => "alternate", :type => "text/html"
  xml.id      projects_url
  xml.updated @events.first.created_at.strftime("%Y-%m-%dT%H:%M:%SZ") if @events.any?

  @events.each do |event|
    xml.entry do
      xml.published event.created_at.strftime("%Y-%m-%dT%H:%M:%SZ")
      xml.updated event.updated_at.strftime("%Y-%m-%dT%H:%M:%SZ")
      xml.media   :thumbnail, :width => "40", :height => "40", :url => gravatar_icon(event.author_email)
      xml.author do |author|
        xml.name event.author_name
        xml.email event.author_email
      end
      
      if event.issue?
        xml.id      project_issue_url(event.project, event.issue, :action => event.action_name)
        xml.link    :href => project_issue_path(event.project, event.issue)
        xml.title   "#{event.author_name} #{event.action_name} issue #{event.issue_title} at #{event.project.name}"
        xml.summary event.issue_description
      
      elsif event.merge_request?
        xml.id      project_merge_request_url(event.project, event.merge_request)
        xml.link    :href => project_merge_request_path(event.project, event.merge_request)
        xml.title   "#{event.author_name} #{event.action_name} merge request #{event.merge_request_title} at #{event.project.name}"
      
      elsif event.push?   
        if event.push_with_commits?
          if event.commits_count > 1
            xml.id      compare_project_commits_url(event.project, :from => event.parent_commit.id, :to => event.last_commit.id)
            xml.link    :href => compare_project_commits_path(event.project, :from => event.parent_commit.id, :to => event.last_commit.id)            
          else
            xml.id      project_commit_url(event.project, :id => event.last_commit.id)
            xml.link    :href => project_commit_path(event.project, :id => event.last_commit.id)            
          end
        else
            # Push without commits, what's our id/link?
        end
      
        xml.title   "#{event.author_name} #{event.push_action_name} #{event.ref_name} at #{event.project.name}"
        xml.summary :type => 'xhtml' do |xhtml|
          xhtml.div(:xmlns => 'http://www.w3.org/1999/xhtml') do |div|
            event.commits.each do |commit|
              div.p "#{commit.author_name} (##{commit.id.to_s[0..10]})"
              div.blockquote { |y| y << simple_format(h(commit.safe_message)) }
            end
          end
        end
        
      end
    end
  end
end
