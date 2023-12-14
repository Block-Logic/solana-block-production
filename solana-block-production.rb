# ruby solana-block-production.rb <input-file.json>

require 'json'
require 'csv'

# Get the json file name from the command line
json_file = ARGV[0]

# Parse the json file
parsed_json = JSON.parse(File.read(json_file))
# Parsed JSON looks like this:
# {"epoch"=>544, "start_slot"=>235008000, "end_slot"=>235439999, "total_slots"=>432000, "total_blocks_produced"=>392554, "total_slots_skipped"=>39446, "leaders"=>[]}
# puts parsed_json

puts "Epoch #{parsed_json['epoch']}"
puts "Total slots: #{parsed_json['total_slots']}"

validator_stats = {}

# Leader stats look like this:
# "leaders": [
#   {
#     "identityPubkey": "12ashmTiFStQ8RGUpi1BTCinJakVyDKWjRL6SWhnbxbT",
#     "leaderSlots": 244,
#     "blocksProduced": 242,
#     "skippedSlots": 2
#   },

parsed_json['leaders'].each do |leader|
  validator_stats[leader['identityPubkey']] = {} unless validator_stats[leader['identityPubkey']]

  validator_stats[leader['identityPubkey']]['leader_slots'] = leader['leaderSlots']
  validator_stats[leader['identityPubkey']]['blocks_produced'] = leader['blocksProduced']
  validator_stats[leader['identityPubkey']]['skipped_slots'] = leader['skippedSlots']
  validator_stats[leader['identityPubkey']]['skipped_after'] = 0
  validator_stats[leader['identityPubkey']]['skip_rate'] = (leader['skippedSlots'].to_f / leader['leaderSlots'].to_f).round(4)
  validator_stats[leader['identityPubkey']]['skip_after_rate'] = 0.0
end

# Slot stats look like this:
# "individual_slot_status": [
#     {
#       "slot": 235008000,
#       "leader": "29B4Ghw6mDuD2GVB8NHobhMWmpvSp4Sz5NWDNJieuBLs",
#       "skipped": false
#     },
# Loop through the indvidual_slots_status with an indexed array so we can look at the previous slot
parsed_json['individual_slot_status'].each_with_index do |slot, index|
  # Skip the first slot
  next if index == 0

  previous_leader = parsed_json['individual_slot_status'][index - 4]['leader']
  # If the previous slot was skipped, increment the previous leader's skipped_after counter
  if slot['skipped'] && previous_leader != slot['leader']
    validator_stats[previous_leader]['skipped_after'] += 1
    validator_stats[previous_leader]['skip_after_rate'] = (validator_stats[previous_leader]['skipped_after'].to_f / validator_stats[previous_leader]['leader_slots'].to_f).round(4)
  end
end

output_csv = json_file.gsub('.json', '.csv')
# Write validator_stats to a CSV file
CSV.open(output_csv, "wb") do |csv|
  csv << [
    'validator',
    'leader_slots',
    'blocks_produced',
    'skipped_slots',
    'skipped_after',
    'skip_rate',
    'skip_after_rate'
  ]
  validator_stats.each do |validator, stats|
    csv << [
      validator,
      stats['leader_slots'],
      stats['blocks_produced'],
      stats['skipped_slots'],
      stats['skipped_after'],
      stats['skip_rate'],
      stats['skip_after_rate']
    ]
  end
end

puts "Wrote #{output_csv}"