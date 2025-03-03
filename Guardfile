# frozen_string_literal: true

guard :shell do
  watch(%r{^lib/micrograd/.*\.rb$}) do |m|
    puts "File #{m[0]} changed, regenerating d2 graph..."
    system("bundle exec ruby lib/micrograd/examples.rb")
  end
end