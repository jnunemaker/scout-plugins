class CampaignMonitor < Scout::Plugin
  needs 'httparty'
  
  OPTIONS=<<-EOS
  api_key:
    name: API Key
    default: "your-api-key"
  list_id:
    name: List API ID
    default: "your-list-id"
  EOS
  
  def build_report
    api_key = option(:api_key)
    list_id = option(:list_id)
    response = HTTParty.get("https://api.createsend.com/api/api.asmx/List.GetStats?ApiKey=#{api_key}&ListID=#{list_id}", :format => :xml)
    report(:total_active_subscribers => response['anyType']['TotalActiveSubscribers'])
    report(:new_subscribers_today => response['anyType']['NewActiveSubscribersToday'])
  end
end