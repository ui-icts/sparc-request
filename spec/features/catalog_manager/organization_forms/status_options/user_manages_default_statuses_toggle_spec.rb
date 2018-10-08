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

require 'rails_helper'

RSpec.describe 'User manages status options', js: true do
  let_there_be_lane
  fake_login_for_each_test

  before :each do
    @institution        = create(:institution)
    @provider           = create(:provider, parent_id: @institution.id, process_ssrs: true)
    create(:catalog_manager, organization_id: @institution.id, identity_id: Identity.where(ldap_uid: 'jug2').first.id)
    visit catalog_manager_catalog_index_path
    wait_for_javascript_to_finish
    find("#institution-#{@institution.id}").click
    wait_for_javascript_to_finish
    click_link @provider.name
    wait_for_javascript_to_finish

    click_link 'Status Options'
    wait_for_javascript_to_finish
  end

  def toggle_default_status(yes_or_no)
    should_be_checked = yes_or_no.downcase == "yes"
    within :css, 'div.row#use_default_statuses' do

      if page.has_field?('use_default_statuses', checked: should_be_checked, visible: false)
        #already correct
      else
        retry_until do
          find('div.toggle.btn').click
          wait_until {
            page.document.has_content?("Organization updated successfully.") && page.has_field?('use_default_statuses', checked: should_be_checked, visible: false)
          }
        end
      end
    end
  end

  context 'and changes from Yes to No' do
    before :each do
      toggle_default_status 'Yes'
      toggle_default_status 'No'
    end

    it 'should change Use Default Status option to false' do

      toggle_default_status 'No'

      @provider.reload
      expect(@provider.use_default_statuses).to eq(false)
    end
  end

  context 'and changes from No to Yes' do
    before :each do
      toggle_default_status 'No'
      toggle_default_status 'Yes'
    end

    it 'should change Use Default Status option to true' do
      @provider.reload
      expect(@provider.use_default_statuses).to eq(true)
    end

    it 'should disable all available and editable statuses' do
      expect(page).to have_no_field(class: 'available-status-checkbox', disabled: false, minimum: 1)
      expect(page).to have_no_field(class: 'editable-status-checkbox', disabled: false, minimum: 1)
    end

  end

end
