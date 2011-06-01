guard 'rspec' do
  watch('spec/spec_helper.rb')                       { "spec" }
  watch(%r{^spec/.+_spec\.rb})
  watch(%r{^lib/(.+)\.rb})                           { "spec" } # { |m| "spec/lib/#{m[1]}_spec.rb" }
end

