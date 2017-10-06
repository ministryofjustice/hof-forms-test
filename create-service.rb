#!/usr/bin/env ruby

@service = ARGV.shift

def main
  add_hof_app(@service)
end

def add_hof_app(service)
  system "hof app #{service.downcase}"
  set_title(service.downcase, "#{service} Service")
end

def set_title(service, title)
  file = "apps/#{service}/translations/src/en/journey.json"
  File.write(file, <<-EOF
    {
      "header": "#{title}",
      "phase": ""
    }
    EOF
  )
end

main

__END__

# TODO

* In add_hof_app, use service.snake_case, in case it has spaces

