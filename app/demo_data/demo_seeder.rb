require "#{Rails.root}/db/seeds/database_constants"

class DemoSeeder
  def seed!
    puts "Creating demo schools, homerooms, interventions..."
    raise "empty yer db" if School.count > 0 ||
                            Student.count > 0 ||
                            InterventionType.count > 0 ||
                            Assessment.count > 0

    healey = School.create(name: "Arthur D Healey")

    # The local demo data setup uses the Somerville database constants
    # (eg., the set of `ServiceType`s) for generating local demo data and
    # for tests.
    puts 'Seeding database constants for Somerville...'
    DatabaseConstants.new.seed!

    puts 'Creating demo educators...'
    seed_educators!(healey)

    puts 'Creating homerooms and students...'
    seed_homerooms_and_students!(healey)

    puts 'Precomputing queries...'
    precompute_and_update!

    puts 'Done.'
  end

  private
  def seed_educators!(school)
    Educator.destroy_all
    Educator.create!([{
      email: "demo@example.com",
      full_name: 'Principal, Laura',
      password: "demo-password",
      local_id: '350',
      schoolwide_access: true,
      school: school,
      admin: true
    }, {
      email: "fake-fifth-grade@example.com",
      full_name: 'Teacher, Sarah',
      password: "demo-password",
      local_id: '450',
      school: school,
      admin: false
    }])
  end

  def seed_homerooms_and_students!(school)
    homeroom_count = 30
    homeroom_generator = FakeHomeroomGenerator.new(school)
    homeroom_count.times do
      homeroom = Homeroom.new(homeroom_generator.next)
      homeroom.save!
      puts "Created homeroom: #{homeroom.name}"
      student_count = rand(5..25)
      student_count.times { student = FakeStudent.new(homeroom).create!; puts "Created student: #{student.id}" }
    end
  end

  # Precompute some values in student tables that would 
  # be done during the nightly rake task
  def precompute_and_update!
    Student.update_risk_levels
    Student.update_student_school_years
    Student.update_recent_student_assessments
  end
end