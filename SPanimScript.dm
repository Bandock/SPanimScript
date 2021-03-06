SPanimScript
	var
		list
			States = new()
		flag = 0x00
	New(file)
		var/data = file2text(file)
		var/list/dline = splittext(data, "\n")
		var/AnimState/AS
		var/AnimStage/Stage
		var/statename = ""
		var/transformmode = 0
		// var/list/savestates = new()
		for(var/D = 1; D <= length(dline); D++)
			var/list/tokens = splittext(dline[D], regex("\[\\s]"))
			if(length(tokens) == 1)
				if(statename != "")
					States[statename] = AS
				statename = tokens[1]
				AS = new()
				Stage = new()
				/*
				if(length(savestates) > 0)
					if(savestates["transform"] != null)
						Stage.transform = savestates["transform"]
					savestates = new()
				*/
			else
				var/level = 1
				var/textfound = 0
				var/varname
				for(var/T = 1; T <= length(tokens); T++)
					if(textfound == 0)
						if(tokens[T] == "")
							if(level == 1)
								level++
							continue
						else
							textfound = 1
					if(varname == null)
						varname = tokens[T]
						if(T != length(tokens))
							continue
					if(level == 2)
						var/lvn = lowertext(varname)
						if(lvn == "alpha" || lvn == "loop" || lvn == "time" \
						|| lvn == "turn" || lvn == "scale")
							var/value = text2num(tokens[T])
							if(lvn == "alpha")
								Stage.SetAlpha(value)
							else if(lvn == "loop")
								Stage.SetLoop(value)
							else if(lvn == "time")
								Stage.SetTime(value)
							else if(transformmode == 1)
								if(lvn == "turn")
									Stage.Turn(value)
								else if(lvn == "scale")
									Stage.Scale(value)
							else if(transformmode == 0)
								if(lvn == "turn" || lvn == "scale")
									world.log << "Warning:  Transform mode is currently not enabled."
						else if((lvn == "addmatrix" || lvn == "submatrix") && (T + 1) == length(tokens))
							var/name = tokens[T++]
							var/value = text2num(tokens[T])
							if(transformmode == 1)
								if(lvn == "addmatrix")
									Stage.AddMatrix(name, value)
								else if(lvn == "submatrix")
									Stage.SubMatrix(name, value)
							else if(transformmode == 0)
								if(lvn == "addmatrix" || lvn == "submatrix")
									world.log << "Warning:  Transform mode is currently not enabled."
						else if(lvn == "color" && (T + 2) == length(tokens))
							var/r = text2num(tokens[T++])
							var/g = text2num(tokens[T++])
							var/b = text2num(tokens[T])
							Stage.SetColor(r, g, b)
						else if(lvn == "easing")
							var/list/easingtypes = list("linear" = LINEAR_EASING, "sine" = SINE_EASING,\
							"circular" = CIRCULAR_EASING, "quad" = QUAD_EASING, "cubic" = CUBIC_EASING,\
							"bounce" = BOUNCE_EASING, "elastic" = ELASTIC_EASING, "back" = BACK_EASING)
							var/etype = lowertext(tokens[T])
							var/etypefound = 0
							for(var/ET in easingtypes)
								if(etype == ET)
									etypefound = 1
									break
							if(etypefound == 1)
								if((T + 1) == length(tokens))
									var/list/iomodes = list("in" = EASE_IN, "out" = EASE_OUT,\
									"inout" = EASE_IN | EASE_OUT)
									var/eiomode = lowertext(tokens[++T])
									for(var/IO in iomodes)
										if(eiomode == IO)
											etype |= iomodes[IO]
											break
								Stage.SetEasing(easingtypes[etype])
						else if(lvn == "addstage")
							AS.AddStage(Stage)
							Stage = new()
							/*
							if(length(savestates) > 0)
								if(savestates["transform"])
									Stage.transform = savestates["transform"]
								savestates = new()
							*/
						else if(lvn == "transformstart")
							if(transformmode == 0)
								transformmode = 1
							else
								world.log << "Warning:  Transform mode is already enabled."
						else if(lvn == "transformend")
							if(transformmode == 1)
								transformmode = 0
							else
								world.log << "Warning:  Transform Mode is currently not enabled."
						else
							world.log << "Error:  Unknown command at line [D]."
							flag |= 0x01
						/*
						else if(lvn == "save")
							var/type = lowertext(tokens[T])
							if(type == "transform")
								savestates["transform"] = Stage.transform
						*/
			if(D == length(dline) && statename != "")
				States[statename] = AS
	proc
		GetState(statename)
			if(!(flag & 0x01))
				if(States[statename] != null)
					return States[statename]
				else
					world.log << "Error:  There is no state by the name of [statename]."
					return null
			else
				world.log << "Error:  This is state is non-functional due to scripting error(s)."

AnimStage // Animation Stage
	var
		alpha
		color
		transform
		time
		loop
		easing
	proc
		SetAlpha(alpha)
			src.alpha = alpha
		SetColor(r,g,b)
			src.color = rgb(r,g,b)
		SetTime(time)
			src.time = time
		SetLoop(loop)
			src.loop = loop
		SetEasing(easing)
			src.easing = easing
		Turn(angle)
			if(transform == null)
				transform = turn(matrix(), angle)
			else
				transform = turn(transform, angle)
		Scale(factor)
			if(transform == null)
				transform = matrix() * factor
			else
				transform *= factor
		AddMatrix(name, val)
			if(transform == null)
				transform = matrix()
			var/matrix/m = transform
			world << m.vars["[name]"]
			if(m.vars["[name]"] != null)
				m.vars["[name]"] += val
			transform = m
		SubMatrix(name, val)
			if(transform == null)
				transform = matrix()
			var/matrix/m = transform
			if(m.vars["[name]"] != null)
				m.vars["[name]"] -= val
			transform = m
		GetStageArgData()
			var/list/stageargs = new()
			if(alpha != null)
				stageargs["alpha"] = alpha
			if(color != null)
				stageargs["color"] = color
			stageargs["transform"] = transform
			if(time != null)
				stageargs["time"] = time
			if(loop != null)
				stageargs["loop"] = loop
			if(easing != null)
				stageargs["easing"] = easing
			return stageargs

AnimState // Animation State
	var
		list/stages = new() // Animation Stage List
	proc
		AddStage(AnimStage/stage)
			src.stages += stage
		ChangeStage(stage_idx, AnimStage/stage)
			if(stage_idx <= length(stages) && stage_idx >= 1)
				src.stages[stage_idx] = stage
		GetStage(stage_idx)
			return stages[stage_idx]

atom
	var
		list
			animstates = new() // Animation State List
	proc
		InsertAnimationState(as_name, AnimState/anim_state)
			animstates[as_name] = anim_state
		GetAnimationState(as_name)
			return animstates[as_name]
		StartAnimation(as_name, image/img = null)
			var/AnimState/anim_state = animstates[as_name]
			for(var/stage_idx = 1; stage_idx <= length(anim_state.stages); stage_idx++)
				var/AnimStage/stage = anim_state.GetStage(stage_idx)
				var/list/stageargs = new()
				if(stage_idx == 1)
					if(img == null)
						stageargs += src
					else
						stageargs += img
				stageargs += stage.GetStageArgData()
				animate(arglist(stageargs))