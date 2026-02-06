# Simulate what happens in CI
require 'json'

# Mock data - get actual file list
files = `bundle exec rspec --dry-run --format json spec 2>/dev/null`
data = JSON.parse(files)
all_files = data["examples"].map{|e| e["file_path"]}.uniq

puts "Total unique spec files: #{all_files.size}"
puts ""

# Test the splitting logic for each node
8.times do |node_index|
  ci_node_total = 8
  slice_size = (all_files.size.to_f / ci_node_total).ceil
  group = all_files.each_slice(slice_size).to_a[node_index]
  
  puts "Node #{node_index}: #{group ? group.size : 0} files"
  puts "  First file: #{group&.first}"
  puts "  Last file: #{group&.last}" if group&.size && group.size > 1
end
