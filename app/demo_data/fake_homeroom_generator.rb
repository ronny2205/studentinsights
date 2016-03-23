class FakeHomeroomGenerator

  def initialize(school)
    @school = school
    @possible_educator_ids = school.educators.map(&:id).to_set
    @drawn_educator_ids = Set.new
    @last_homeroom_name = 100
  end

  def next
    @last_homeroom_name += 1
    educator_id = (@possible_educator_ids - @drawn_educator_ids).to_a.sample
    @drawn_educator_ids.add(educator_id)

    return {
      name: @last_homeroom_name.to_s,
      grade: sample_grade,
      educator_id: educator_id
    }
  end

  def sample_grade
    (['PK', 'KF'] + (1..8).to_a.map(&:to_s)).sample
  end
end
