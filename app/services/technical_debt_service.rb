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

class TechnicalDebtService
  def self.calculate_td_principal_for_project(project)
    wp_severity_group_count = WorkPackage.where(project_id: project.id).group('td_severity_value').count
    wp_severity_group_total_est = WorkPackage.where(project_id: project.id).group('td_severity_value').sum(:td_estimated_hrs)

    raise "td_severity_group_mismatch" if wp_severity_group_count.keys.sort != wp_severity_group_total_est.keys.sort

    td_principal = wp_severity_group_count.keys.map do |k|
      wp_severity_group_count[k] * project.public_send("td_payback_likelihood_#{k}") * wp_severity_group_total_est[k] * project.td_labour_rate
    end.sum

    project.update(td_principal: td_principal)
  end
end
