# measure_rb

## Install

1. `cp -r ./tools/measure.rb path/to/tools/measure.rb`
2. Add redis gem

```diff
group :development do
+ gem "redis"
end
```

3. `INPUT_FILE=path/to/web.rb ruby ./tools/debug_code.rb`
4. Insert measure code

```diff
class Web < sinatra::Base
  configure do
    ...
+   require "./tools/measure.rb"
+   Redis.current = Redis.new(host: "127.0.0.1, port: 6379)
  end

  helpers do
+   def measure(key:, start_time: Time.now)
+     return yield
+   ensure
+     Redis.current.rpush(key, Time.now - start_time)
+   end

    def helper_method
+     measure(key: "helper_method") do
      ...
+     end
    end
  end

+ get "/measure.csv" do
+   headers({
+     "Content-Type"        => "text/csv; charset=UTF-8",
+     "Content-Disposition" => 'attachment; filename="measure.csv"',
+   })
+   Measure.call
+ end

  get "/initialize" do
+   Redis.current.flushall
    ...
  end

  get "/" do
+   measure(key: "GET /") do
    ...
+   end
  end
end
```
