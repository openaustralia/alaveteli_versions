# frozen_string_literal: true

require 'rubocop/rake_task'

RuboCop::RakeTask.new(:rubocop) do |t|
  t.options = ['--display-cop-names']
end

task default: %i[rubocop]
