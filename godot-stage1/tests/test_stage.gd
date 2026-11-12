extends SceneTree
const State = preload("res://scripts/stage_state.gd")
var failures: Array[String] = []
func check(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)
func route(s, actions: Array) -> void:
	for action in actions:
		check(s.act(action), "Action unavailable: " + action + " at " + s.phase)
func _init() -> void:
	var s = State.new()
	check(s.trust == 0, "Start at zero")
	check(not s.act("invite"), "Cannot skip to invitation")
	route(s,["pass","greet","introduce","usual","ask","sport","respond","remember","give_space","invite"])
	check(s.phase == "promise" and s.flags.stage2_unlocked, "Good route reaches promise")
	check(s.trust == 70, "Good route trust")
	check(not s.act("head"), "Endings reject interaction")
	var loaded = State.new()
	check(loaded.restore(s.snapshot()), "Restore completed save")
	check(loaded.snapshot() == s.snapshot(), "Save roundtrip")
	var r = State.new()
	route(r,["head","apologize","resume"])
	check(r.phase == "intro" and r.trust == 0 and r.caution == 0, "Recovery restores previous event, no farming")
	route(r,["head","cheek"])
	check(r.phase == "rejected", "Repeated rejection ends ride")
	route(r,["new_ride","return_greet","share","return_respond","remember","give_space","invite"])
	check(r.phase == "declined", "Low trust cannot unlock promise")
	var quiet = State.new()
	route(quiet,["pass","quiet","nod","rare","listen","scenery","respond","farewell_early"])
	check(quiet.phase == "friendly", "Ordinary goodbye available")
	var before = quiet.trust
	route(quiet,["new_ride","return_greet","return_listen","return_respond","remember","give_space","invite"])
	check(quiet.phase == "promise", "Later ride can complete stage")
	check(quiet.trust > before, "New ride has new conversation")
	var bad = State.new()
	route(bad,["pass","greet","introduce","usual","ask","interrupt","move_on","remember","hold"])
	check(bad.phase=="invite_hold", "Holding departure has a distinct response")
	route(bad,["invite"])
	check(bad.phase == "declined", "Caution and weak conversation block invitation")
	var farm = State.new()
	farm.award("same",15)
	farm.award("same",15)
	check(farm.trust == 15, "One-time reward cannot repeat")
	check(not farm.restore({"version":1,"phase":"missing"}), "Invalid save rejected")
	if failures.is_empty():
		print("PASS: full route, branches, refusal, recovery, retry, gating, save, reward limits")
		quit(0)
	else:
		for failure in failures:
			push_error(failure)
		quit(1)
