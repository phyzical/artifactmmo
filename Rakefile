# frozen_string_literal: true

require 'syntax_tree/rake_tasks'
[SyntaxTree::Rake::CheckTask, SyntaxTree::Rake::WriteTask].each do |klass|
  klass.new { |t| t.source_files = FileList[%w[Gemfile Rakefile **/*.rb]] }
end

require 'rubocop'
require 'rubocop-rake'
require 'rubocop-performance'
require 'rubocop/rake_task'
RuboCop::RakeTask.new

task lint_fix: %i[stree:write rubocop:autocorrect_all]
task lint: %i[stree:check rubocop]
task default: %i[ci]
task ci: %i[lint]
