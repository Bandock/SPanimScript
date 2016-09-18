world
	maxx = 10
	maxy = 10
	maxz = 1
	name = "SPanimScript Demo 1"

var
	SPanimScript
		Demo1_Script = new('Demo1_Script.txt')

mob
	icon = 'HappyFace.dmi'
	color = rgb(0xFF, 0xFF, 0x00)
	var
		hcolor = "Yellow"
	Login()
		..()
		var/AnimState/RF = Demo1_Script.GetState("RedFace")
		var/AnimState/YF = Demo1_Script.GetState("YellowFace")
		var/AnimState/RLF = Demo1_Script.GetState("RollingFace")
		InsertAnimationState("Red", RF)
		InsertAnimationState("Yellow", YF)
		InsertAnimationState("Rolling",RLF)
	Click()
		if(hcolor == "Yellow")
			hcolor = "Red"
			StartAnimation("Red")
		else if(hcolor == "Red")
			hcolor = "Yellow"
			StartAnimation("Yellow")

client
	Move()
		..()
		mob.StartAnimation("Rolling")