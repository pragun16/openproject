#-- copyright
# OpenProject is an open source project management software.
# Copyright (C) 2012-2023 the OpenProject GmbH
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License version 3.
#
# OpenProject is a fork of ChiliProject, which is a fork of Redmine. The copyright follows:
# Copyright (C) 2006-2013 Jean-Philippe Lang
# Copyright (C) 2010-2013 the ChiliProject Team
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
#
# See COPYRIGHT and LICENSE files for more details.
#++

require 'spec_helper'
require 'rack/test'

RSpec.describe TechnicalDebtService do
  include Rack::Test::Methods
  include Capybara::RSpecMatchers

  let(:project) { create(:project) }
  let(:work_package1) do
    create(:work_package,
           project:,
           story_points: 8,
           td_severity_value: WorkPackage.td_severity_values[:low],
           td_estimated_hrs: 10)
  end
  let(:work_package2) do
    create(:work_package,
           project:,
           story_points: 5,
           td_severity_value: WorkPackage.td_severity_values[:medium],
           td_estimated_hrs: 20)
  end
  let(:work_package3) do
    create(:work_package,
           project:,
           story_points: 8,
           td_severity_value: WorkPackage.td_severity_values[:high],
           td_estimated_hrs: 30)
  end

  before do
    allow(Story).to receive(:types).and_return([work_package1.type_id, work_package2.type_id, work_package3.type_id])
  end

  describe '.calculate_td_principal_for_project' do
    it 'calculates the correct td_principal for a project' do
      # Set td_payback_likelihood values for each severity value (you may need to adjust these values)
      project.td_payback_likelihood_low = 0.1
      project.td_payback_likelihood_medium = 0.2
      project.td_payback_likelihood_high = 0.3
      project.td_labour_rate = 50
      project.save

      # Calculate the expected td_principal manually
      expected_td_principal = (1 * 0.1 * 10 * 50.0) + (1 * 0.2 * 20 * 50.0) + (1 * 0.3 * 30 * 50.0)

      # Call the method
      TechnicalDebtService.calculate_td_principal_for_project(project)

      # Check if the project's td_principal attribute has been updated correctly
      expect(project.reload.td_principal).to eq(expected_td_principal)
    end

    it 'equivalence class testing of td_service' do
      # Set td_payback_likelihood values for each severity value (you may need to adjust these values)
      project.td_payback_likelihood_low = 0.1
      project.td_payback_likelihood_medium = 0.2
      project.td_payback_likelihood_high = 0.3
      project.td_labour_rate = -50
      project.save


      # Call the method
      expect {TechnicalDebtService.calculate_td_principal_for_project(project)}.to raise_error

      project.td_labour_rate = 50
      project.save

      # Call the method
      expect {TechnicalDebtService.calculate_td_principal_for_project(project)}.not_to raise_error
    end
  end
end

