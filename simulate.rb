require 'gruff'
require 'pathname'
require 'fileutils'

thread_count = ENV.fetch('THREAD_COUNT') { 1 }.to_i
maximum_memory = !!ENV["DISABLE_MAX_MEMORY"].nil?
request_count_min = ENV.fetch('REQUEST_COUNT_MIN') { 1 }.to_i
request_count_max = ENV.fetch('REQUEST_COUNT_MAX') { 10 }.to_i

puts "Simulating..."
puts "Thread count: #{thread_count}"
puts "Showing Maximum memory: #{maximum_memory}"
puts "Request count min: #{request_count_min}"
puts "Request count max: #{request_count_max}"


entry_hash = Hash.new {|h,k| h[k] = [] }

def simulate_request(request_array: , height_multiply: rand(1..4), duration: rand(10..100), before_start: rand(1..100), after_start: rand(1..100))
  before_start.times.each do
    request_array << 0
  end

  (1...duration).each do |x|
    request_array << x * height_multiply
  end

  after_start.times.each do
    request_array << 0
  end
end

def find_max_count_from_hash(entry_hash)
  max_count = 0
  entry_hash.each do |k,v|
    count = v.length
    max_count = count if count > max_count
  end
  return max_count
end

def pad_entry_hashes_to_be_same_length(entry_hash)
  max_count = find_max_count_from_hash(entry_hash)

  entry_hash.each do |k, v|
    count = v.length
    if count < max_count
      v.fill(0, count...max_count)
    end
  end
end

thread_count.times.each do |thread_number|
  rand(request_count_min..request_count_max).times.each do
    simulate_request(request_array: entry_hash["Thread #{thread_number+1}"])
  end
end

pad_entry_hashes_to_be_same_length(entry_hash)

if maximum_memory
  values = entry_hash.values
  mega_array = values.pop.dup
  values.each do |v_array|
    mega_array = mega_array.zip(v_array)
  end

  if entry_hash.size > 1
    mega_array = mega_array.map(&:sum)
  end

  max_val = 0
  mega_array.each_with_index do |val, i|
    if max_val > val
      mega_array[i] = max_val
    else
      max_val = val
    end
  end

  entry_hash["Max Total"] = mega_array
end

time_name = Time.now.strftime('%Y-%m-%d-%H-%M-%s-%N').to_s

output_dir = Pathname.new("tmp")
FileUtils.mkdir_p(output_dir)

g = Gruff::Line.new(1000, 1000)
g.hide_dots = true
g.title = "Simulating Memory Requirements\nof Requests Over Time"
g.x_axis_label = 'Time (unitless)'
g.y_axis_label = 'Memory use (unitless)'
entry_hash.each do |k, v|
  g.data k, v
end
file_name = output_dir.join("#{time_name}-chart.png")
g.write(file_name)

puts file_name
`open #{file_name}`
