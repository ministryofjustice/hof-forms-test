#!/usr/bin/env ruby

require 'csv'

class Field
  attr_reader :name, :label, :validation

  def initialize(params)
    @name       = params.fetch(:name)
    @label      = params.fetch(:label)
    @validation = params.fetch(:validation)
  end
end

@service = ARGV.shift

def main
  add_hof_app(@service)
end

def add_hof_app(service)
  svc = service.downcase

  fields = [
    Field.new(name: 'name', label: 'Name', validation: 'required'),
    Field.new(name: 'colour', label: 'Colour', validation: 'required'),
    Field.new(name: 'age', label: 'Age', validation: 'required')
  ]

  system "hof app #{svc}"
  set_title(svc, "#{service} Service")
  write_fields_index_js(svc, fields)
  write_index_js(svc, fields)
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

def write_fields_index_js(service, fields)
  file = "apps/#{service}/fields/index.js"

  js_fields = fields.map {|f| "  #{f.name}: { validate: '#{f.validation}' }"}.join(",\n")

  File.write(file, <<~EOF
      'use strict';

      module.exports = {
      #{js_fields}
      };
    EOF
  )
end

def write_index_js(service, fields)
  service_end = confirm_and_complete()

  File.write("apps/#{service}/index.js", <<~EOF
    'use strict';

    module.exports = {
      name: '#{service}',
      baseUrl: '/#{service}',
      steps: {
        #{steps(fields).join(',')},
        #{service_end}
      }
    };
  EOF
  )
end

def steps(fields)
  field_names = fields.map(&:name)

  [
    step(name: 'name', fields: field_names, next_step: 'confirm')
  ]
end

def confirm_and_complete
  <<EOF
    '/confirm': {
      behaviours: ['complete', require('hof-behaviour-summary-page')],
      next: '/complete'
    },
    '/complete': {
      template: 'confirmation'
    }
EOF
end

def step(params)
  name      = params.fetch(:name)
  fields    = js_string_array(params.fetch(:fields))
  next_step = params.fetch(:next_step)

  <<EOF
    '/#{name}': {
      fields: #{fields},
      next: '/#{next_step}'
    }
EOF
end


def js_string_array(arr)
  csv = arr.to_csv(quote_char: "'", force_quotes: true, row_sep: nil)
  "[#{csv}]"
end

main

__END__

# TODO

* Write translations
* Handle pages
* In add_hof_app, use service.snake_case, in case it has spaces

