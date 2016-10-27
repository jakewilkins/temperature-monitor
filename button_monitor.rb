require 'aws-sdk'
require 'json'

class ButtonMonitor
  attr_reader :client, :thread
  URL = "https://sqs.us-west-2.amazonaws.com/#{Settings.aws_button_id}/living_room_a_c_switch"
  def initialize
    @client = Aws::SQS::Client.new
    @enabled = true
  end

  def start
    @thread = Thread.new(client) do |tc|
      while @enabled do
        response = tc.receive_message({wait_time_seconds: 20, queue_url: URL})
        process_received_messages(response.messages)
        cleanup_received_messages(response.messages)
      end
    end
  end

  def stop
    @enabled = false
    :ok
  end

  def join
    thread.join
  end

  def dead?
    !%w|sleep run|.include?(thread.status)
  end

  private

  def process_received_messages(messages)
    return unless @enabled

    return if messages.empty?

    body = JSON.load(messages.last.body) rescue {'clickType' => :unknown}

    p body

    case body['clickType']
    when 'SINGLE'
      EventBus.publish(:toggle_requested)
      EventBus.publish(:learn_from_now)
    when 'DOUBLE'
      EventBus.publish(:learn_from_now)
    when 'LONG'
      EventBus.publish(:toggle_requested)
    when :unkown
      puts "event received with bad json?"
    else
      puts "wtf???"
    end
  end

  def cleanup_received_messages(messages)
    deleteable = messages.clone
    while deleteable.length > 0
      batch = deleteable.shift(10)

      client.delete_message_batch({queue_url: URL,
         entries: batch.map {|m| {id: m.message_id, receipt_handle: m.receipt_handle}}
      })
    end
  end
end
