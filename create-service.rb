#!/usr/bin/env ruby

require 'erb'

@service = ARGV.shift

def main
  add_hof_app(@service)
end

def add_hof_app(service)
  svc = service.downcase
  system "hof app #{svc}"
  set_title(svc, "#{service} Service")
  write_index_js(svc)
end

def set_title(service, title)
  file = "apps/#{service}/translations/src/en/journey.json"
  File.write(file, <<~EOF
    {
      "header": "#{title}",
      "phase": ""
    }
    EOF
  )
end

def write_index_js(service)
  template = <<EOF
'use strict';

module.exports = {
  name: '<%= service %>',
  baseUrl: '/<%= service %>',
  steps: {
    '/name': {
      fields: ['name'],
      next: '/confirm'
    },
    '/confirm': {
      behaviours: ['complete', require('hof-behaviour-summary-page')],
      next: '/complete'
    },
    '/complete': {
      template: 'confirmation'
    }
  }
};
EOF

  renderer = ERB.new(template)

  File.write("apps/#{service}/index.js", renderer.result(binding))
end


main

__END__

# TODO

* In add_hof_app, use service.snake_case, in case it has spaces

