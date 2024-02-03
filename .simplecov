# Copyright (c) 2016-2024 Yegor Bugayenko
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the 'Software'), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

SimpleCov.formatter = if Gem.win_platform?
                        SimpleCov::Formatter::MultiFormatter[
                          SimpleCov::Formatter::HTMLFormatter
                        ]
                      else
                        SimpleCov::Formatter::MultiFormatter.new(
                          SimpleCov::Formatter::HTMLFormatter
                        )
                      end

SimpleCov.enable_for_subprocesses true
SimpleCov.at_fork do |pid|
  # This needs a unique name so it won't be overwritten
  SimpleCov.command_name "#{SimpleCov.command_name} (subprocess: #{pid})"
  # be quiet, the parent process will be in charge of output and checking coverage totals
  SimpleCov.print_error_status = true
  SimpleCov.formatter SimpleCov::Formatter::SimpleFormatter
  SimpleCov.minimum_coverage 10
  # start
  SimpleCov.start
end

SimpleCov.start do
  puts "SimpleCov start #{Process.pid}"
  add_filter '/test/'
  add_filter '/test-assets/'
  add_filter '/assets/'
  add_filter '/dynamodb-local/'
  add_filter '/public/'
  minimum_coverage 34 if ENV['RACK_ENV'] == 'test'
end

SimpleCov.at_exit do
  SimpleCov.result.format!
  puts "SimpleCov exit #{Process.pid}"

  SimpleCov.command_name 'test:unit' if ENV['RACK_ENV'] == 'test'
  SimpleCov.start
end
