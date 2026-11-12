class_name StageState
extends RefCounted
const STORY = preload("res://data/story.json")
const ENDINGS = ["promise", "friendly", "declined", "rejected"]
var phase: String = "intro"
var trust: int = 0
var caution: int = 0
var flags: Dictionary = {}
var awards: Dictionary = {}
var ride: int = 1
var history: Array = []
var resume_phase: String = "intro"
var touch_count: int = 0
var shoulder_count: int = 0
var last_gesture: String = ""

func scene() -> Dictionary:
	return STORY.data.get(phase, STORY.data.intro)

func ended() -> bool:
	return phase in ENDINGS

func award(key: String, amount: int) -> void:
	if awards.has(key):
		return
	awards[key] = true
	trust = clampi(trust + amount, 0, 100)

func go(next: String) -> void:
	phase = next
	history.append(next)
	if history.size() > 100:
		history.pop_front()

func act(action: String) -> bool:
	last_gesture = ""
	if action == "new_ride" and ended() and phase != "promise":
		ride += 1
		caution = 0
		touch_count = 0
		shoulder_count = 0
		go("return_wary" if phase == "rejected" else "return")
		return true
	if ended():
		return false
	if action in ["head", "cheek"]:
		if not phase in ["withdraw", "block", "recover"]:
			resume_phase = phase
		touch_count += 1
		caution = mini(3, caution + 1)
		trust = maxi(0, trust - (5 if touch_count > 1 else 0))
		last_gesture = "withdraw" if touch_count == 1 else "block" if touch_count == 2 else "swat"
		go("withdraw" if touch_count == 1 else "block" if touch_count == 2 else "rejected")
		return true
	if action == "shoulder":
		if phase in ["withdraw", "block", "recover"]:
			return false
		last_gesture = "shoulder"
		shoulder_count += 1
		if shoulder_count > 2:
			caution = mini(3,caution+1)
		if phase == "intro":
			go("noticed")
		return true
	if action == "pass" and phase in ["intro", "noticed"]:
		award("pass", 15)
		flags["returned_pass"] = true
		go("thanks")
		last_gesture = "receive"
		return true
	var allowed: Array = []
	for choice in scene().get("choices", []):
		allowed.append(choice[0])
	if not action in allowed:
		return false
	match action:
		"greet", "quiet":
			award("greet", 5)
			flags["name"] = true
			go("name")
		"introduce", "nod":
			award("introduce", 5)
			go("question")
		"usual", "rare", "reserved":
			flags["commute"] = action
			award("answer", 10 if action != "reserved" else 5)
			go("reply_" + action)
		"ask", "listen", "answer_late":
			award("listen", 5)
			go("topic")
		"sport", "scenery":
			flags["topic"] = action
			go(action)
		"respond":
			award("respond", 15)
			flags["schedule"] = true
			go("schedule")
		"interrupt", "self":
			caution = mini(3, caution + 1)
			go("interrupted")
		"repair":
			caution = maxi(0, caution - 1)
			flags["schedule"] = true
			go("schedule")
		"move_on":
			flags["schedule"] = true
			go("schedule")
		"remember":
			award("schedule", 5)
			go("arrival")
		"farewell_early", "bye":
			go("friendly")
		"give_space":
			award("respect_departure", 10)
			go("invite")
		"hold":
			caution = mini(3, caution + 1)
			go("invite_hold")
		"invite":
			if trust >= 60 and caution <= 1 and flags.get("name", false) and flags.get("schedule", false):
				flags["stage2_unlocked"] = true
				go("promise")
			else:
				go("declined")
		"apologize", "wait":
			go("recover")
		"resume":
			caution = maxi(0, caution - 1)
			go(resume_phase)
		"return_greet":
			flags["name"] = true
			go("return_chat")
		"share":
			go("return_shared")
		"return_listen":
			go("return_listen")
		"return_respond":
			award("return_" + str(ride), 15)
			flags["schedule"] = true
			go("schedule")
	return true

func snapshot() -> Dictionary:
	return {"version":1,"phase":phase,"trust":trust,"caution":caution,"flags":flags.duplicate(true),"awards":awards.duplicate(true),"ride":ride,"history":history.duplicate(),"resume_phase":resume_phase,"touch_count":touch_count,"shoulder_count":shoulder_count}

func restore(d: Dictionary) -> bool:
	if d.get("version", 0) != 1 or not STORY.data.has(d.get("phase", "")):
		return false
	if not d.get("flags", null) is Dictionary or not d.get("awards", null) is Dictionary:
		return false
	if not d.get("history", null) is Array:
		return false
	phase = d.phase
	trust = clampi(int(d.get("trust",0)), 0, 100)
	caution = clampi(int(d.get("caution",0)), 0, 3)
	flags = d.flags.duplicate(true)
	awards = d.awards.duplicate(true)
	ride = maxi(1, int(d.get("ride",1)))
	history = d.history.duplicate()
	resume_phase = str(d.get("resume_phase", "intro"))
	if not STORY.data.has(resume_phase):
		resume_phase = "intro"
	touch_count = clampi(int(d.get("touch_count",0)),0,3)
	shoulder_count = clampi(int(d.get("shoulder_count",0)),0,100)
	return true
