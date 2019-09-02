require 'json'
require 'csv'
require_relative 'hiptest_api_client.rb'

class HipTestWriter
  attr_accessor :project_id

  def initialize
    self.project_id = ENV['PROJECT_ID'] || 133190
    @api_client = HipTestApiClient.new(project_id)
  end

  def update_scenarios(csv_file: 'temp-mapping-table.csv')
    data = File.read(csv_file)
    rows = CSV.parse(data, :headers => true)

    temp_arr=[]
    rows.each do |current_row|
      matching_rows = rows.find_all { |row| row.to_hash["Scenario ID"] == current_row.to_hash["Scenario ID"] }
      update_scenario_for(matching_rows)
      rows.reject{ |row| row.to_hash["Scenario ID"] == current_row.to_hash["Scenario ID"] }
    end
  end


  private
  def update_scenario_for(rows)
    scenario_id = rows[0]["Scenario ID"]
    description = ""
    rows.each do |row|
      description += row["Github Link"] + "\n"
    end
    puts "Updating for scenario: #{scenario_id}"
    puts "Updating description: #{description}"
    @api_client.update_scenario(scenario_id: scenario_id, description: description)
  end
end
