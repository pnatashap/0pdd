# encoding: utf-8
#
# Copyright (c) 2016 Yegor Bugayenko
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
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

require 'fileutils'
require 'timeout'

#
# One job.
#
class JobDetached
  def initialize(repo, job)
    @repo = repo
    @job = job
  end

  def proceed
    if ENV['RACK_ENV'] == 'test'
      exclusive
    else
      Process.detach(fork { exclusive })
    end
  end

  private

  def exclusive
    lock = @repo.lock
    FileUtils.mkdir_p(File.dirname(lock))
    f = File.open(lock, File::RDWR | File::CREAT, 0o644)
    Timeout.timeout(15) do
      f.flock(File::LOCK_EX)
      @job.proceed
      f.close
    end
    File.delete(lock)
  end
end