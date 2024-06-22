#!/usr/bin/env ruby
require "canvas_cc"
require "dom"
require "securerandom"
require "tmpdir"

course = CanvasCc::CanvasCC::Models::Course.new
course.title = "Canvas CC Gem Course"
course.identifier = SecureRandom.hex

ag = CanvasCc::CanvasCC::Models::AssignmentGroup.new
ag.title = "Assignment Group"
ag.identifier = SecureRandom.hex
course.assignment_groups << ag

gs = CanvasCc::CanvasCC::Models::GradingStandard.new
gs.title = "Grading Standard"
gs.identifier = SecureRandom.hex
course.grading_standards = [gs]

[ # creats assignments with a mix of submission_types
  ["Known", "Displays", "online_text_entry"],
  ["Unknown", "Has no", "n/a"],
  ["Missing", "Has no", nil]
].each do |data|
  assignment = CanvasCc::CanvasCC::Models::Assignment.new
  assignment.assignment_group_identifier_ref = ag.identifier
  assignment.title = "Course with #{data[0]} Submission Type"
  assignment.body = "#{data[1]} submission type".dom(:p)
  assignment.submission_types << data[2] if data[2]
  assignment.points_possible = 10
  assignment.workflow_state = "active"
  assignment.identifier = SecureRandom.hex
  course.assignments << assignment
end

dir = Dir.mktmpdir
output_file = CanvasCc::CanvasCC::CartridgeCreator.new(course).create(dir)
puts output_file
