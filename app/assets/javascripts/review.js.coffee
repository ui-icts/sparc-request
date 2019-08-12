# Copyright © 2011-2019 MUSC Foundation for Research Development
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

$(document).ready ->
  if $('#serviceCalendarReview').length
    adjustCalendarHeaders()

  survey_offered = false
  if $('#use_system_satisfaction').val() == 'true'
    $(document).one 'click', '.submit-request', (event) ->
      button = $(this)
      if !survey_offered
        event.preventDefault()
        $.ajax
          method: 'get'
          dataType: 'script'
          url: '/service_request/system_satisfaction_survey'
          data:
            srid: getSRId()

        $(document).one 'hide.bs.modal', '#modalContainer', ->
          form = document.getElementById('serviceRequestForm')
          Rails.fire(form, 'submit')

    $(document).one 'click', '.get-a-cost-estimate', (event) ->
      button = $(this)
      if !survey_offered
        event.preventDefault()
        $.ajax
          method: 'get'
          dataType: 'script'
          url: '/service_request/system_satisfaction_survey'
          data:
            srid: getSRId()

        $(document).one 'hide.bs.modal', '#modalContainer', ->
          window.location = button.prop('href')
