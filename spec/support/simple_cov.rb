# frozen_string_literal: true

SimpleCov.start do
  add_group 'Connections', 'app/concepts/connections'

  add_filter 'spec/'
end
