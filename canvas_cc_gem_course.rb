#!/usr/bin/env ruby
require "canvas_cc"
require "tmpdir"
require "pry"
require "csv"

@i = 0
def new_identifier = (6000**10 + @i += 1).to_s(16)

course = CanvasCc::CanvasCC::Models::Course.new
course.title = "Canvas CC Gem Course"
course.identifier = new_identifier

ag = CanvasCc::CanvasCC::Models::AssignmentGroup.new
ag.title = "Assignment Group"
ag.identifier = new_identifier
course.assignment_groups << ag

gs = CanvasCc::CanvasCC::Models::GradingStandard.new
gs.title = "Grading Standard"
gs.data = [["A", 0.9], ["B", 0.8], ["C", 0.7], ["D", 0.6], ["E", 0.0]]
gs.version = "2"
gs.identifier = new_identifier
course.grading_standards = [gs]

[ # creats assignments with a mix of submission_types
  ["Known", "online_text_entry"],
  ["Unknown", "n/a"],
  ["Missing", nil]
].each do |label, type|
  assignment = CanvasCc::CanvasCC::Models::Assignment.new
  assignment.assignment_group_identifier_ref = ag.identifier
  assignment.title = "Course with #{label} Submission Type"
  assignment.body = "<p>This is assignment content.</p>"
  assignment.submission_types << type unless type.nil?
  assignment.points_possible = 10
  assignment.workflow_state = "active"
  assignment.identifier = new_identifier
  course.assignments << assignment
end

page = CanvasCc::CanvasCC::Models::Page.new
page.page_name = "Latex Example"
page.body = "<p>When \\(a \\ne 0\\), there are two
solutions to \\(ax^2 + bx + c = 0\\) and they are
\\(x = {-b \\pm \\sqrt{b^2-4ac} \\over 2a}.\\)</p>"
page.workflow_state = "active"
page.identifier = new_identifier
course.pages << page

banks = {} # create questions banks
CSV.parse(File.read("bank.csv"), headers: true,
  header_converters: :symbol).each do |row|
  bank = row[:category]
  banks[bank] = [] unless banks.has_key?(bank)
  banks[bank] << row
end

banks.each do |category, bank|
  embeded = %w[F M].include?(category[0])
  question_bank = CanvasCc::CanvasCC::Models::QuestionBank.new
  question_bank.title = "#{category} Question Bank"
  questions = []
  bank.each do |row|
    question = CanvasCc::CanvasCC::Models::Question.create("text_only_question")
    question.points_possible = 1
    question.material = row[:question]
    question.title = row[:question]
    question.identifier = new_identifier
    questions << question
  end
  question_bank.questions = questions
  question_bank.identifier = new_identifier
  course.question_banks << question_bank unless embeded

  question_group = CanvasCc::CanvasCC::Models::QuestionGroup.new
  question_group.sourcebank_ref = question_bank.identifier
  question_group.points_per_item = 1
  question_bank.question_groups << question_group
  question_group.identifier = new_identifier
  course.question_banks << question_bank

  assessment = CanvasCc::CanvasCC::Models::Assessment.new
  assessment.title = "#{category} Course Assessment"
  assessment.description = "This is a #{category.downcase} assessment"
  assessment.workflow_state = "active"
  assessment.assignment = course.assignments.first
  assessment.allowed_attempts = 2
  assessment.quiz_type = "assignment"
  assessment.shuffle_answers = false
  assessment.items = embeded ? questions : [question_group]
  assessment.points_possible = 10
  assessment.identifier = new_identifier
  course.assessments << assessment
end

dir = Dir.mktmpdir
output_file = CanvasCc::CanvasCC::CartridgeCreator.new(course).create(dir)
puts output_file
