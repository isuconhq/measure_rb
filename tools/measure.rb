class Measure
  def self.call
    new.call
  end

  def call
    @redis.keys("*").each do |key|
      times = @redis.lrange(key, 0, -1).map {|v| v.to_f }
      @summaries[key] = Summary.new(times)
      @all_count += times.count
    end

    body = "action,count,rate,sum,min,max,avg,p95\n"
    @summaries.each do |k, v|
      body << "#{k},#{v.count},#{v.rate(@all_count)},#{v.sum},#{v.min},#{v.max},#{v.avg},#{v.p95}\n"
    end

    body
  ensure
    @redis.close
  end

  def initialize
    @redis     = Redis.new(host: "127.0.0.1", port: 6379)
    @summaries = {}
    @all_count = 0
  end
end

class Summary
  def initialize(times)
    @times = times
  end

  def count
    @times.count
  end

  def sum
    @times.sum
  end

  def min
    @times.min
  end

  def max
    @times.max
  end

  def avg
    @times.sum / count.to_f
  end

  def rate(all_count)
    count.to_f / all_count
  end

  def p95
    c = (count * 0.95).to_i
    return 0.0 if c.zero?

    @times.sort.reverse.slice(0, c).sum / c.to_f
  end
end
