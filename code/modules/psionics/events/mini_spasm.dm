/datum/event/minispasm
	startWhen = 60
	endWhen = 90
	var/static/list/psi_operancy_messages = list(
		"There's something in your skull!",
		"Something is eating your thoughts!",
		"You can feel your brain being rewritten!",
		"Something is crawling over your frontal lobe!",
		"<b>THE SIGNAL THE SIGNAL THE SIGNAL THE SIGNAL THE</b>",
		"Something is drilling through your skull!",
		"Your head feels like it's going to implode!",
		"Thousands of ants are tunneling in your head!"
		)

/datum/event/minispasm/announce()
	command_announcement.Announce( \
		"PRIORITY ALERT: SIGMA-[rand(50,80)] NON-STANDARD PSIONIC SIGNAL-WAVE TRANSMISSION DETECTED - 97% MATCH, NON-VARIANT \
		SIGNAL SOURCE TRIANGULATED TO DISTANT SITE: All personnel are advised to avoid \
		exposure to active audio transmission equipment including radio headsets and intercoms \
		for the duration of the signal broadcast.", \
		"Nralakk Federation Observation Probe TC-203 Sensor Array", new_sound = 'sound/misc/announcements/security_level_old.ogg', zlevels = affecting_z)

/datum/event/minispasm/start()
	..()

	var/list/victims = list()
	for(var/obj/item/device/radio/radio in GLOB.listening_objects)
		if(radio.is_on())
			for(var/mob/living/victim in range(radio.canhear_range, radio.loc))
				if(isnull(victims[victim]) && victim.stat == CONSCIOUS && !isdeaf(victim))
					victims[victim] = radio
	for(var/thing in victims)
		var/mob/living/victim = thing
		var/obj/item/device/radio/source = victims[victim]
		do_spasm(victim, source)

/datum/event/minispasm/proc/do_spasm(var/mob/living/victim, var/obj/item/device/radio/source)
	set waitfor = 0
	playsound(source, 'sound/effects/narsie.ogg', 75) //LOUD AS FUCK BOY

	if(!ishuman(victim))
		to_chat(victim, "<span class='notice'>An annoying buzz passes through your head.</span>")
		return

	if(victim.psi)
		to_chat(victim, SPAN_DANGER("A hauntingly familiar sound hisses from [icon2html(source, victim)] \the [source], and your vision flickers!"))
		victim.psi.backblast(rand(5,15))
		victim.Paralyse(5)
		victim.make_jittery(100)
	else
		to_chat(victim, SPAN_DANGER("An indescribable, brain-tearing sound hisses from [icon2html(source, victim)] \the [source], and you collapse in a seizure!"))
		victim.seizure()
		to_chat(victim, SPAN_DANGER(FONT_LARGE("[pick(psi_operancy_messages)]")))
		victim.adjustBrainLoss(rand(10,20))
		victim.set_psi_rank(1)
		victim.psi.update()
	sleep(45)
	victim.psi.check_psionic_trigger(100, "a psionic scream", redactive = TRUE)

/datum/event/minispasm/announce_end()
	. = ..()
	if(.)
		command_announcement.Announce( \
			"PRIORITY ALERT: SIGNAL BROADCAST HAS CEASED. Personnel are cleared to resume use of non-hardened radio transmission equipment. Have a nice day.", \
			"Nralakk Federation Observation Probe TC-203 Sensor Array", new_sound = 'sound/misc/announcements/nightlight_old.ogg', zlevels = affecting_z)
