task :initialize_professional_organizations => "professional_organizations:import" do


end

namespace :professional_organizations do

  task :setup => [:import, :link_colleges, :link_departments, :link_identities]

  task :import => :environment do

    institutions = INSTITUTIONS.map { |k,v| {name: v, org_type: 'institution'} }
    colleges     = COLLEGES.map { |k,v| {name: v, org_type: 'college' } }
    departments  = DEPARTMENTS.map { |k,v| {name: v, org_type: 'department'} }

    ProfessionalOrganization.create( institutions + colleges + departments )

    puts "Created #{institutions.size} institutions"
    puts "Created #{colleges.size} colleges"
    puts "Created #{departments.size} departments"
  end


  task :link_colleges => :environment do
    ProfessionalOrganization.transaction do

      ProfessionalOrganization.where(org_type: 'institution').each do |institution|
	my_colleges = Identity.where(institution: institution.name).select(:college).distinct.map(&:college)

	ProfessionalOrganization.
	  where(org_type: 'college', name: my_colleges).
	  update_all(parent_id: institution.id)

	my_colleges.each { |c| puts c }
	puts "Added to #{institution.name}"
	puts "----"
      end
    end
  end

  task :link_departments => :environment do
    ProfessionalOrganization.transaction do

      ProfessionalOrganization.where(org_type: 'college').each do |college|
	my_departments = Identity.where(college: college.name).select(:department).distinct.map(&:department)

	ProfessionalOrganization.
	  where(org_type: 'department', name: my_departments).
	  update_all(parent_id: college.id)

	my_departments.each { |d| puts d }
	puts "Added to #{college.name}"
	puts "----"
      end
    end
  end

  task :link_identities => :environment do
    Identity.transaction do
      ProfessionalOrganization.where(org_type: 'department').each do |department|
	Identity.where(department: department.name).update_all(professional_organization_id: department.id)
	puts "Updated identities in department #{department.name}"
      end
    end
  end

  task :whoops => :environment do
    puts ""
    puts "#" * 20
    puts "Hey\nI'm going to delete all the professional organizations and remove them from the identites!!\nIf you're sure you want this then type yes then hit enter"

    if "yes" == STDIN.gets.strip
      Identity.update_all(professional_organization_id: nil)
      ProfessionalOrganization.delete_all

      puts "There are #{ProfessionalOrganization.count} professional organizations now"
    else
      puts "Close call there wasn't it"
    end
  end
end
