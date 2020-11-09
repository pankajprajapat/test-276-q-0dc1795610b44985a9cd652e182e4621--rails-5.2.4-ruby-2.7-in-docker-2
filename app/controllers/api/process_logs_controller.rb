class Api::ProcessLogsController < ApplicationController
  skip_before_action :verify_authenticity_token

  def create
    begin
      if params[:parallelFileProcessingCount] == 0
        render json: { "status": "failure", "reason": "Parallel File Processing count must be greater than zero!" }
      else
        log_array = []
        output = { response: []}.with_indifferent_access

        Parallel.map(params[:logFiles], in_threads: params[:parallelFileProcessingCount]) do |file_url|
          uri = URI(file_url)
          file_contents = Net::HTTP.get(uri)
          file_contents.split.each_slice(3) do |request_id, timestamp, error_code|
            duration = Time.at(timestamp.to_i).round(15.minutes)
            log_array << [duration, error_code]
          end
        end
        log_array.sort.group_by(&:first).each do |timestamp, values|
          logs = []
          values.group_by { |nested_array| nested_array[1] }.each do |exception, exp_vals|
            logs << { exception: exception, count: exp_vals.count }
          end
          output[:response] << { timestamp: timestamp, logs: logs }
        end
      end
      render json: output
    rescue
      render json: { "status": "failure", "reason": "Something went wrong!" }
    end
  end
end

class Time
  def round(sec=1)
    down = self - (self.to_i % sec)
    up = down + sec
    "#{down.strftime("%H:%M")}-#{up.strftime("%H:%M")}"
  end
end
