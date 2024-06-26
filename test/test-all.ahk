SetBatchLines, -1
#SingleInstance, force
#NoTrayIcon
#Requires AutoHotkey v1.1.33+
#Include %A_ScriptDir%\..\export.ahk
#Include %A_ScriptDir%\..\node_modules
#Include expect.ahk\export.ahk

stringc := new stringc()
assert := new expect()

;; Test Vars
testVar := stringc.compareAll(["levenshtein","matching","similarity"], "similar")
testVar2 := stringc.compareAll([" hard to    ","hard to","Hard 2"], "Hard to")


;; Test compare()
assert.category := "compare"
assert.label("check functional")
assert.true((stringc.compare("The eturn of the king", "The Return of the King") > 0.90 ))
assert.test((stringc.compare("set", "ste") = 0 ), true)

assert.label("Check if case matters")
assert.true((stringc.compare("The Mask", "the mask") = 1 ))
assert.true(stringc.compare("thereturnoftheking", "TheReturnoftheKing") = 1 )
StringCaseSense, On
assert.true(stringc.compare("thereturnoftheking", "TheReturnoftheKing") = 1 )
StringCaseSense, Off

assert.label("function argument")
assert.true((stringc.compare("    The Return of the King   ", "The Return of the King") != 1 ))
assert.true((stringc.compare("    The Return of the King   ", "The Return of the King", func("fn_trimSpaces")) == 1 ))
fn_trimSpaces(param_input) {
	return trim(param_input)
}
assert.label("function argument using all four parameters")
stringc.compare("", "", func("fn_allTwoArgs"))
fn_allTwoArgs(param_input*) {
	global assert
	assert.true((param_input.count() == 2))
}


;; Test compareAll()
assert.category := "rate"
assert.label("ratings object")
assert.test(testVar.ratings.count(), 3)
assert.test(testVar.ratings[1].target, "similarity")
assert.test(testVar.ratings[1].rating, 0.80)
assert.test(testVar.ratings[2].target, "matching")
assert.test(testVar.ratings[2].rating, 0)
assert.test(testVar.ratings[3].target, "levenshtein")
assert.test(testVar.ratings[3].rating, 0)

assert.label("bestMatch object")
assert.test(testVar.bestMatch.target, "similarity")
assert.test(testVar.bestMatch.rating, 0.80)
assert.test(testVar2.bestMatch.target, "hard to")
assert.test(testVar2.bestMatch.rating, 1)

assert.label("function argument using all four parameters")
stringc.compareAll(["levenshtein","matching","similarity"], "The Return of the King", func("fn_allFourArgs"))
stringc.compareAll([], "", func("fn_allFourArgs"))
fn_allFourArgs(param_input*) {
	global assert
	assert.true((param_input.count() == 4))
}


;; Test bestMatch()
assert.category := "bestMatch"
assert.label("basic usage")
assert.test(stringc.bestMatch(["ste","one","set"], "setting"), "set")
assert.test(stringc.bestMatch(["smarts","smrt","clip-art"], "Smart"), "smarts")
assert.test(stringc.bestMatch(["green Subaru Impreza","table in very good","mountain bike with"], "Olive-green table"), "table in very good")
assert.test(stringc.bestMatch(["For sale: green Subaru Impreza, 210,000 miles"
	, "For sale: table in very good condition, olive green in colour."
	, "Wanted: mountain bike with at least 21 gears."], "Olive-green table for sale, in extremely good condition.")
	, "For sale: table in very good condition, olive green in colour.")
stringc.bestMatch([], "", func("fn_allFourArgs"))


assert.final()
;; Display test results in GUI
assert.fullReport()
assert.writeTestResultsToFile()

exitApp
