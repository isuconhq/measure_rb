# measure_rb

## Install

### 1. Get measure

```
$ git clone measure_rb
$ cp -r ./measure_rb/tools path/to/sinatra_app
```

### 2. Add redis gem

```diff
group :development do
+ gem "redis"
end
```

### 3. Setup measure for sinatra app

```
$ code web.rb
```

```diff
+ require 'redis'

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

  get "/initialize" do
+   Redis.current.flushall
    ...
  end

+ get "/measure.csv" do
+   headers({
+     "Content-Type"        => "text/csv; charset=UTF-8",
+     "Content-Disposition" => 'attachment; filename="measure.csv"',
+   })
+   Measure.call
+ end
```

### 4.  Insert measure code automatically

```
$ INPUT_FILE=path/to/web.rb ./tools/debug_code.rb
```

you can see the result like this.


```diff
  get "/" do
+   measure(key: "GET /") do
+    ...
+   end
  end
```

### 5. Download csv data

After you launced sinatra app,

you can access `sinatra_root_path/measure.csv` in your web browser.
