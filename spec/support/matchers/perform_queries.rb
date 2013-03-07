RSpec::Matchers.define :perform_queries do |expected|
  match do |block|
    query_count(&block) == expected
  end

  failure_message_for_should do |actual|
    "Expected to run #{expected} queries, got #{@counter.query_count}"
  end

  def query_count(&block)
    @counter = ActiveRecord::QueryCounter.new
    ActiveSupport::Notifications.subscribe('sql.active_record', @counter.to_proc)
    yield
    ActiveSupport::Notifications.unsubscribe(@counter.to_proc)

    @counter.query_count
  end
end
