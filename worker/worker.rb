require 'google/apis/sheets_v4'
require 'json'
require_relative 'record'

SPREADSHEET_ID = ENV['SPREADSHEET_ID']
SCOPE = Google::Apis::SheetsV4::AUTH_SPREADSHEETS

def load_sheets
  sheets = JSON.parse(File.read("/sheets.json"), symbolize_names: true)
  p sheets
  sheets
end

def init
  authorization = Google::Auth.get_application_default(SCOPE)
  @service = Google::Apis::SheetsV4::SheetsService.new
  @service.authorization = authorization
  @logger = Logger.new('logs/error.log')
end

def update_sheet(service, spreadsheet_id, sheet_name, sheet_id)
  begin
    range = "#{sheet_name}!A1:V"
    response = service.get_spreadsheet_values(spreadsheet_id, range)
  rescue => e
    p "Skipped #{sheet_name} due to error"
    p e.message
    p e.backtrace.join["\n"]
    return
  end
  ActiveRecord::Base.transaction do
    headers = response.values.first
    response.values[1..].each do |row|
      record_id = row[0].to_i rescue next
      if record_id > 0
        begin
          date = Date.parse(row[19]) rescue nil
          date = nil if !date.nil? and date.year < 2020
          full_info = JSON[Hash[headers[1..].zip(row[1..])]]
          Record.find_or_create_by(record_id: record_id, sheet_id: sheet_id).update!(last_name: row[15], date: date, full_info: full_info)
        rescue => e
          p row
          p e.message
        end
      end
    end

  end
end

def update_all
  p SPREADSHEET_ID
  sheets = load_sheets
  sheets.keys.each { |key| p key; update_sheet @service, SPREADSHEET_ID, sheets[key][:name], sheets.keys.index(key) }
  p Record.all.first
  p Record.all.last
  p Record.count
end


