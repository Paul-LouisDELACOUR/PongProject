.equ BALL, 0x1000 ; ball state (its position and velocity)
.equ PADDLES, 0x1010 ; paddles position
.equ SCORES, 0x1018 ; game scores
.equ LEDS, 0x2000 ; LED addresses
.equ BUTTONS, 0x2030 ; Button addresses
addi sp, zero, LEDS


; BEGIN:main
main :
	call clear_leds
 ;addi a0, zero , 0x000B
	;addi a1, zero , 0x0006
;call set_pixel

	addi t0, zero , 5
	addi t1, zero , 3
	addi t2, zero , 1
	addi t3, zero, 1

	add v0, zero, zero

	stw t0, BALL(zero)
	stw t1, BALL+4(zero)
	stw t2, BALL+8(zero)
	stw t3, BALL+12(zero)

	stw t0, PADDLES(zero)
	stw t1, PADDLES+4(zero)
	
	stw zero, SCORES(zero) ; On initialise le score du joueur de gauche à 0
	stw zero, SCORES+4(zero) ; On initialisae le score du joueur de droite à 0
	addi t5, zero, 10 ; le score maximal 10*4


loop:
	beq v0, zero, continue ; SI le score n'est pas 0 on doit afficher le score
	
	testGauche:
		ldw t0, SCORES(zero) ; score du joueur de gauche
		addi t1, zero, 1; t1 =1
		bne v0, t1, testDroit ; si T0 = 1 alors on incrémente le score du joueur de gauche
		addi t0, t0, 1
		stw t0, SCORES(zero)	
		br endUpdating

	testDroit:
		ldw t0, SCORES+4(zero) ; score du joueur de droit
		addi t0, t0, 1
		stw t0, SCORES+4(zero)
		
	endUpdating:
	call display_score

	call wait
	call wait
		call wait
		call wait
		call wait
		call wait
		call wait
		call wait
		call wait
		call wait
		call wait
		call wait
		call wait
		call wait
		call wait
		call wait
	call wait
	call wait
	call wait
	call wait
	call wait
	call wait
	call wait

	
	continue:
	ldw t0, SCORES(zero)
	ldw t1, SCORES+4(zero)

	addi t5, zero, 10
	beq t0, t5, maxScore ; si Score de gauche =10 on arrêt
	beq t1,t5, maxScore ; si le score de droite est 10 on arrête

	call hit_test
	call move_paddles
	call move_ball
	

		call wait
		call wait
		call wait
		call wait
		call wait
		call wait
		call wait
		call wait
		call wait
		call wait
		call wait
		call wait
		call wait
		call wait
		call wait
	

	call clear_leds
	bne v0, zero, middlePos	

	ldw a0, BALL(zero)
	ldw a1, BALL +4(zero)
	br next
	
	middlePos :
		addi a0, zero, 6
		addi a1, zero, 3
		stw a0, BALL(zero)
		stw a1, BALL+4(zero)

	next:

	call set_pixel
	call draw_paddles



br loop
maxScore: break

ret
; END:main


	wait:
		addi s5, s5, 0x7FFF
		loopWait:
		addi s5, s5, -1
		bne s5,zero, loopWait
		
	addi s5, zero, 0x7FFF
	ret


; BEGIN:clear_leds
clear_leds :
		stw zero, LEDS(zero) ; set leds[2] to t0 (see Figure 2 for the details)
		stw zero, LEDS+4(zero)
		stw zero, LEDS+8(zero)
ret
; END:clear_leds;	

; BEGIN:set_pixel
set_pixel: 
	addi sp, sp, -8
	stw t0, 0(sp)
	stw t1, 4(sp)

 addi t0 , zero , 0x000C ; For the value between 8 and 11
 and t4, t0, a0 ; on applique le mask1 address que l'on doit ajouter à la LED
 ; a2 contient la position du bit qu'on doit changer
 ; y + x * 8
 andi t7, a0, 0x0003 

 slli t2,t7, 0x0003 ; a2 = 8*x
 add t2, t2 , a1 ; a2= 8*x + y 
 addi t3, zero , 0x0001
 sll t3, t3, t2
 
 ldw t5, LEDS(t4)
 or t5, t5, t3
 stw t5 , LEDS(t4)

ldw t0, 0(sp)
ldw t1, 4(sp)
addi sp, sp , 8

ret
; END:set_pixel

; BEGIN:hit_test
hit_test : 
	addi sp, sp, -20
	stw t0, 0(sp)
	stw t1, 4(sp)
	stw t2, 8(sp)
	stw t3, 12(sp)
	stw ra, 16(sp)
	

	ldw t0,	BALL(zero) ;x
	ldw t1,	BALL+4(zero) ; y
	ldw t2, BALL+8(zero) ; v_x
   	ldw t3,BALL+12(zero) ; v_y

	add v0, zero, zero
	ldw s2, PADDLES(zero) ; PADDLE de Gauche
	ldw s3, PADDLES+4(zero) ; PADDLE de droite

	addi s0, zero, 1 ; contact avec le Paddle Gauche
	addi s1, zero, 10 ; Contact avec le Paddle de Droite

	addi t7, zero, 7 ; t7= 7 position maximale pour Y

wall_test_up :
	bne t1, zero, wall_test_down ; si y=0
	sub t3, zero, t3 	; on change la vY
	
	stw t3, BALL+12(zero)
	call collisionPaddle
	
wall_test_down :
	bne t1, t7, collisionPaddle  ; si y!=7  Si il n'y a pas de collision on peut continuer normalement
	sub t3, zero, t3 ; On inverse la vitesse y

	stw t3, BALL+12(zero)
;	call endHitTest

collisionPaddle:
beq t0, s0, collisionLeft ; si x=1 alors on peut tester la collision
beq t0, s1, collisionRight ; si x=10 alors on peut tester la collision
br endHitTest ; Si il n'y a pas de collision on peut continuer normalement



collisionRight: 
	test_Paddle_rigth_middle : 
		add  t6, t1, t3 ; t6 = y+vY
		bne t6, s3 , test_Paddle_right_corner ; y+vY == paddle1
		sub t2, zero, t2 ; On inverse Vx

		stw t2 , BALL+8(zero)
		call endHitTest

	test_Paddle_right_corner : 
		add t6, t3, t3 ; t6 = 2*Vy
		add t6, t1, t6 ; t6 = y+2Vy	 		

		bne t6, s3, test_Paddle_pixel_up
	 	sub t2, zero, t2 ; On inverse Vx
		sub t3, zero, t3 ; On inverse vY
		
		stw t2, BALL+8(zero)
		stw t3, BALL+12(zero)
		beq t1, zero, stillColliding ; si y =0 on est encore dans une coliision avec le mur 
		beq t1, t7, stillColliding ; si y=7 on est encore dans une coliision avec le mur
		call endHitTest
		
		stillColliding:
		sub t3, zero, t3 ; on inverse Vy
		stw t3, BALL+12(zero)
		call endHitTest	
	
	test_Paddle_pixel_up:
		add  t6, t1, t3 ; t6 = y+vY
		addi s4, s3 , -1 ; pixel du Haut du paddle droit
		bne t6, s4, test_up_outOfPaddleR ; y+vY == pixel du haut Paddle1
		sub t2, zero, t2 ; On inverse Vx
		stw t2 , BALL+8(zero)
		call endHitTest

	test_up_outOfPaddleR:
		bne t1, s4, test_Paddle_pixel_down ; si Y= pixel du haut du paddle
		addi s4, s3, -2 ; 1 pixel haut dessus du paddle
		bne t6, s4, test_Paddle_pixel_down ; si y+vY = pixel au dessus du Paddle
		sub t2, zero, t2 ; On inverse Vx
		stw t2 , BALL+8(zero)
		call endHitTest

	test_Paddle_pixel_down:
		addi s4, s3, 1 ; Pixel du bas du paddle droit
		bne t6, s4, test_down_outOfPaddleR ; y+vY == pixel du bas Paddle1
		sub t2, zero, t2 ; On inverse Vx
		stw t2 , BALL+8(zero)
		call endHitTest

	test_down_outOfPaddleR:
		bne t1, s4, winnerLeft ; si y = pixel du bas du paddle
		addi s4, s3, 2 ; 1 pixel en dessous du paddle
		bne t6, s4, winnerLeft ; si y+vY = pixel en dessous du Paddle
		sub t2, zero, t2 ; On inverse Vx
		stw t2 , BALL+8(zero)
		call endHitTest


	

	winnerLeft: ; si on n'a pas de collision le joueur de gauche gagne
		addi v0, zero ,1
		call endHitTest

collisionLeft:
	test_hit_Paddle_left_middle :
		;add t6, t5, t2 ; t6 = x +vx : la prochaine position	
		add  t6, t1, t3 ; t6 = y+vY
		bne t6 , s2, test_Paddle_left_corner ; y+Vy == paddle0
		sub t2, zero, t2 ; On inverse Vx
		
		stw t2, BALL+8(zero)
		call endHitTest 
	
	test_Paddle_left_corner :
		add t6, t3, t3 ; t6 = 2*Vy
		add t6, t1, t6 ; t6 = y+2Vy	 
	
		bne t6, s2, test_PaddleL_pixel_up ;x+2Vx == paddle0 cas où il y aura collision avec un coin du paddle gauche
	 	sub t2, zero, t2 ; On inverse Vx
		sub t3, zero, t3 ; On inverse vY

		stw t2, BALL+8(zero)
		stw t3, BALL+12(zero)
		
		beq t1, zero, stillCollidingLeft ; si y =0 on est encore dans une coliision avec le mur 
		beq t1, t7, stillCollidingLeft ; si y=7 on est encore dans une coliision avec le mur
		call endHitTest
		
		stillCollidingLeft:
		sub t3, zero, t3 ; on inverse Vy
		stw t3, BALL+12(zero)
		call endHitTest	

		call endHitTest

	test_PaddleL_pixel_up:
		add  t6, t1, t3 ; t6 = y+vY
		addi s4, s2 , -1 ; pixel de Haut du paddle droit
		bne t6, s4, test_up_outOfPaddleL ; y+vY == pixel du haut Paddle1
		sub t2, zero, t2 ; On inverse Vx
		stw t2 , BALL+8(zero)
		call endHitTest

	test_up_outOfPaddleL:
		bne t1, s4, test_PaddleL_pixel_down ; si Y= pixel du haut du paddle
		addi s4, s2, -2 ; 1 pixel au dessus du paddle
		bne t6, s4, test_PaddleL_pixel_down ; si y+vY = pixel au dessus du Paddle
		sub t2, zero, t2 ; On inverse Vx
		stw t2 , BALL+8(zero)
		call endHitTest

	test_PaddleL_pixel_down:
		addi s4, s2, 1 ; Pixel du bas du paddle droit
		bne t6, s4, test_down_outOfPaddleL ; y+vY == pixel du bas Paddle1
		sub t2, zero, t2 ; On inverse Vx
		stw t2 , BALL+8(zero)
		call endHitTest

	test_down_outOfPaddleL:
		bne t1, s4, winnerRight ; si y = pixel du bas du paddle
		addi s4, s2, 2 ; 1 pixel en dessous du paddle
		bne t6, s4, winnerRight ; si y+vY = pixel en dessous du Paddle
		sub t2, zero, t2 ; On inverse Vx
		stw t2 , BALL+8(zero)
		call endHitTest

	
	winnerRight:
		addi v0, zero, 2



endHitTest: 
	ldw t0 , 0(sp)
	ldw t1, 4(sp)
	ldw t2 ,8(sp)
	ldw t3, 12(sp)
	ldw ra, 16 (sp)
	addi sp, sp, 20
	ret
; END:hit_test

; BEGIN:move_ball
move_ball : 
	ldw t0 , BALL+0(zero) ; x
	ldw t1, BALL+4(zero) ; y
	ldw t2, BALL+8(zero) ; v_x
	ldw t3, BALL+12(zero) ; : v_y
	
	add t0, t0 , t2
	add t1, t1, t3

	stw t0, BALL+0(zero)
	stw t1, BALL+4(zero)

ret
; END:move_ball;



; BEGIN:move_paddles
move_paddles : 
	ldw t0,	PADDLES(zero)
	ldw t1, PADDLES+4(zero)
	ldw t2, BUTTONS(zero)
	ldw t3, BUTTONS+4(zero) ; edgecapture


	
	andi t4 , t3, 15 ; On mask avec 1111
	
	addi t5, zero ,1
	addi t6 , zero ,6 

;paddle left case up
	paddleLeft_up :
		andi t7, t4, 1
			beq t7, zero , paddleLeft_down
				beq t0, t5, paddleLeft_down ; si t0 est 1 on est au max
				addi t0, t0, -1
				stw t0 , PADDLES(zero)
		
	paddleLeft_down : 
		andi t7, t4, 2 ; on mask avec 10	
			beq t7, zero , paddleRight_down
				beq t0, t6, paddleRight_down ; si t0 est 6 est au min possible
				addi t0, t0, 1
				stw t0, PADDLES(zero)

	paddleRight_down : 
		andi t7 , t4, 4 ; On mask avec 100 
			beq t7, zero , paddleRight_up
				beq t1, t6, paddleRight_up ; si t1 est 6 on est au min possible
				addi t1, t1, 1
				stw t1, PADDLES+4(zero)
	paddleRight_up :
		andi t7, t4, 8 ; On mask avec 1000
			beq t7, zero, end2
				beq t1, t5, end2  ; si t1 est 1 on est au max possible		
				addi t1 , t1, -1
				stw t1, PADDLES+4(zero)


end2: stw zero, BUTTONS+4(zero)
	ret

; END:move_paddles

; BEGIN:draw_paddles
draw_paddles:

	addi sp ,sp , -12 
	stw a0, 0(sp)
	stw a1, 4(sp)
	stw ra, 8(sp)

	addi a0, zero, 0
	ldw a1 , PADDLES(zero) ; pixel du milieu
	call set_pixel

	addi a1 , a1, -1 ; pixel du haut
	call set_pixel
		
	addi a1, a1, 2 ; pixel du bas
	call set_pixel

	addi a0, zero, 11
	ldw a1, PADDLES+4(zero) 
	call set_pixel
	
	addi a1, a1, -1
	call set_pixel

	addi a1, a1, 2
	call set_pixel

	ldw a0 , 0(sp)
	ldw a1, 4(sp)
	ldw ra ,8(sp)
	addi sp, sp, 12
ret
; END:draw_paddles

; BEGIN:display_score
display_score:
addi sp, sp, -20
	stw t3, 0(sp)
	stw t4, 4(sp)
	stw ra, 8(sp)
	stw t5, 12(sp)
	stw t6, 16(sp)
	
	ldw s4, font_data+64(zero) ; Le separateur est à la 16 lignes et 16*4 = 64

	incrementation:
		ldw t5, SCORES(zero)
		ldw t6, SCORES+4(zero)
			
		slli t5, t5,2  ; On multiplie par 4
		slli t6, t6, 2 ; On multiplie par 4
				
			ldw t3, font_data(t5)
			ldw t4, font_data(t6)
			stw t3,LEDS(zero) ; le score du joueur gauche
			stw s4, LEDS+4(zero) ; le separateur
			stw t4,LEDS+8(zero) ; le score du joueur de droite
	
	endDisplay:	

		ldw t3, 0(sp)
		ldw t4, 4(sp)
		ldw ra, 8(sp)
		ldw t5, 12(sp)
		ldw t6, 16(sp)
		addi sp, sp, 20
		ret	
; END:display_score




font_data:
.word 0x7E427E00 ; 0
.word 0x407E4400 ; 1
.word 0x4E4A7A00 ; 2
.word 0x7E4A4200 ; 3
.word 0x7E080E00 ; 4
.word 0x7A4A4E00 ; 5
.word 0x7A4A7E00 ; 6
.word 0x7E020600 ; 7
.word 0x7E4A7E00 ; 8
.word 0x7E4A4E00 ; 9
.word 0x7E127E00 ; A
.word 0x344A7E00 ; B
.word 0x42423C00 ; C
.word 0x3C427E00 ; D
.word 0x424A7E00 ; E
.word 0x020A7E00 ; F
.word 0x00181800 ; separator


		