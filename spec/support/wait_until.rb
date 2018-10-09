# Copyright © 2011-2018 MUSC Foundation for Research Development
# All rights reserved.

# Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

# 1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

# 2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following
# disclaimer in the documentation and/or other materials provided with the distribution.

# 3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products
# derived from this software without specific prior written permission.

# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING,
# BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT
# SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR
# TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

class WaitUntilTimedOut < StandardError
end

# Wait up to the specified amount of time and return once the block
# returns a truthy (non-false, non-nil) value.
#
# Raises a WaitUntilTimedOut exception if the specified amount of time
# passes without the block returning a truthy value.
#
# If the block returns a truthy value, returns immediately.
#
# This method is similar to Capybara's old wait_until method (which was
# removed in Capybara 2.0).  This method should not be used in normal
# circumstances; use Capybara's matchers instead.  There are some cases
# where a Capybara matcher does not work or is inconvenient; this method
# is supplied for those cases.
#
def wait_until(seconds=Capybara.default_max_wait_time, &block)
  start_time = Time.now
  end_time = start_time + seconds

  puts "Waiting for #{seconds} seconds until #{end_time}"
  loop do
    if Time.now > end_time
      raise WaitUntilTimedOut, "Timed out" 
    end
    puts "Checking..."
    result = yield
    if result
      return result
    else
      sleep 0.5
      Thread.pass
    end
  end
end

# Like wait_until but keeps going until the block returns without
# raising an exception.
def retry_until(seconds: [Capybara.default_max_wait_time, 30].max, exception: Exception)
  start_time = Time.now
  end_time = start_time + seconds
  puts "Retrying for #{seconds} seconds until #{end_time}"
  last_exception = nil
  num = 0
  loop do
    num += 1
    if Time.now > end_time then
      if last_exception then
        raise last_exception
      else
        raise WaitUntilTimedOut, "Timed out"
      end
    end

    begin
      puts "Checking..."
      result = yield num
      if result
        return result
      else
        puts "Retrying..."
        sleep 0.5
      end
    rescue exception => e
      puts "Retrying Exception..."
      last_exception = e
      sleep 0.5
      Thread.pass
    end
  end
end
