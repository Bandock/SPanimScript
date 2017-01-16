world
	maxx = 10
	maxy = 10
	maxz = 1
	name = "SPanimScript Demo 1"

var
	MasterHUD/Master = new()
	SPanimScript
		Demo1_Script = new('Demo1_Script.txt')

mob
	icon = 'HappyFace.dmi'
	color = rgb(0xFF, 0xFF, 0x00)
	var
		hcolor = "Yellow"
		image/I
	Login()
		..()
		client.screen += Master
		I = image('Bar.dmi', Master)
		I.color = rgb(192, 0, 0)
		var/AnimState/RF = Demo1_Script.GetState("RedFace")
		var/AnimState/YF = Demo1_Script.GetState("YellowFace")
		var/AnimState/RLF = Demo1_Script.GetState("RollingFace")
		var/AnimState/AB = Demo1_Script.GetState("AnimateBar")
		InsertAnimationState("Red", RF)
		InsertAnimationState("Yellow", YF)
		InsertAnimationState("Rolling",RLF)
		InsertAnimationState("Bar",AB)
		src << I
	Click()
		if(hcolor == "Yellow")
			hcolor = "Red"
			StartAnimation("Red")
		else if(hcolor == "Red")
			hcolor = "Yellow"
			StartAnimation("Yellow")
	verb
		Test_Bar()
			StartAnimation("Bar", I)

MasterHUD
	parent_type = /obj
	screen_loc = "CENTER"

client
	Move()
		..()
		mob.StartAnimation("Rolling")