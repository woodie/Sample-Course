#!/usr/bin/env ruby
require "canvas_cc"
require "tmpdir"

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
page.workflow_state = "active"
page.page_name = "Latex Example"
page.body = "<p>When \\(a \\ne 0\\), there are two
solutions to \\(ax^2 + bx + c = 0\\) and they are
\\(x = {-b \\pm \\sqrt{b^2-4ac} \\over 2a}.\\)</p>"
page.identifier = new_identifier
course.pages << page

dir = Dir.mktmpdir
output_file = CanvasCc::CanvasCC::CartridgeCreator.new(course).create(dir)
puts output_file
