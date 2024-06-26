#!/usr/bin/env ruby
require "canvas_cc"
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
gs.data = [["A", 0.9], ["B", 0.8], ["C", 0.7], ["D", 0.6], ["E", 0.0]]
gs.version = '2'
gs.identifier = SecureRandom.hex
course.grading_standards = [gs]

[ # creats assignments with a mix of submission_types
  ["Known", "online_text_entry"],
  ["Unknown", "n/a"],
  ["Missing", nil]
].each do |data|
  assignment = CanvasCc::CanvasCC::Models::Assignment.new
  assignment.assignment_group_identifier_ref = ag.identifier
  assignment.title = "Course with #{data.first} Submission Type"
  assignment.body = "<p>This is assignment content.</p>"
  assignment.submission_types << data.last unless data.last.nil?
  assignment.points_possible = 10
  assignment.workflow_state = "active"
  assignment.identifier = SecureRandom.hex
  course.assignments << assignment
end

dir = Dir.mktmpdir
output_file = CanvasCc::CanvasCC::CartridgeCreator.new(course).create(dir)
puts output_file
