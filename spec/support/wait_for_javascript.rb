# Copyright © 2011-2018 MUSC Foundation for Research Development~
# All rights reserved.~

# Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:~

# 1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.~

# 2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following~
# disclaimer in the documentation and/or other materials provided with the distribution.~

# 3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products~
# derived from this software without specific prior written permission.~

# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING,~
# BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT~
# SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL~
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS~
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR~
# TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.~

module WaitForJavascript

  def wait_for_javascript_to_finish(max_wait=Capybara.default_max_wait_time)
    time_limit, interval = (Time.now + max_wait), 0.5
    loop do
      break if finished_all_ajax_requests? && finished_all_animations? && dom_ready?

      sleep interval
      fail "Wait for javascript timed out after waiting for #{max_wait} seconds" if Time.now > time_limit
    end

  end

  def finished_all_ajax_requests?
    page.evaluate_script('jQuery.active') == 0
  end

  def finished_all_animations?
    page.evaluate_script('$(":animated").length') == 0
  end

  def dom_ready?
    uuid = SecureRandom.uuid
    page.find("body")
    page.evaluate_script <<~EOS
      setTimeout(function() {
        jQuery('body').append("<div id='#{uuid}'></div>");
      }, 1);
    EOS
    page.find_by_id(uuid, :visible => :any, :wait => Capybara.default_max_wait_time)
  end
end

RSpec.configure do |config|
  config.include WaitForJavascript, type: :feature
end
