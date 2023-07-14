pico-8 cartridge // http://www.pico-8.com
version 41
__lua__
--main
--
--14.07.2023 simplesnake

function _init()
	cartdata("snake")
	
	mode="start"
	setup()
end

function _update()
 	t+=1	
 
 	chk_pad()
 
 	if t%snake.spd==0 and 
 	   mode=="play" then
 		do_snake()
 		do_col()
	end
end

function _draw()
	cls()
 
	draw_field()
	draw_snake()
	draw_food()
	draw_score()
 
	show_msg()
end
-->8
--update

function chk_pad()
	if mode=="play" then
		if btn(0) and snake.dir~="r"
		 	then snake.dir="l" end
		if btn(1) and snake.dir~="l"
			then snake.dir="r" end
		if btn(2) and snake.dir~="d"
			then snake.dir="u" end
		if btn(3) and snake.dir~="u"
			then snake.dir="d" end
	end
	
	local but=(btnp(4) or btnp(5))
	
	if mode=="start" then
		if but then
			mode="play"
		end
	end
	
	if mode=="end" then 
		if score>high then
			high=score
			dset(0,high)
 		end
		if but then 
			setup()
			mode="start"
		end
	end
end

function do_snake()
local s=snake.segs
local newx=0
local newy=0

	if snake.dir=="r" then
		newx=s[1].x+grid
		newy=s[1].y
		if newx>120 then newx=4 end
	elseif snake.dir=="l" then
		newx=s[1].x-grid
		newy=s[1].y
		if newx<4 then newx=120 end
	elseif snake.dir=="u" then
		newx=s[1].x
		newy=s[1].y-grid
		if newy<16 then newy=120 end
	elseif snake.dir=="d" then
		newx=s[1].x
		newy=s[1].y+grid
		if newy>120 then newy=16 end
	end
	
	add(s,{x=newx,y=newy},1)
	if snake.addseg then
	--last seg is not removed
	--length increased
	 	snake.addseg=false
	else
	--remove of last seg moves
	--the snake
		deli(s,#s)
	end
end

function do_col()
local s=snake.segs
local ofs=grid-1
 
	--food x head
	if col(food,s[1],ofs,ofs) then
		snake.addseg=true
		score+=1
		sfx(1)	
		getfruit()
		
		--increase speed every 7 segs
		if #s%7==0 then 
			snake.spd-=1
			if (snake.spd<2) snake.spd=2
		end 
	end
	
		--head x body
	for i=2,#s do
		if col(s[1],s[i],ofs,ofs) then
			sfx(2)
			mode="end"
		end
	end
end

-->8
--draw

function draw_field() 
	rectfill(3,15,124,124,5)
	rect(3,15,124,124,9)
end

function draw_snake()  
local s=snake.segs
	
	--select head sprite
	if snake.dir=="u" then
		head=32
	elseif snake.dir=="r" then
		head=33
	elseif snake.dir=="l" then
		head=34
	elseif snake.dir=="d" then
		head=35
	end
						
	for i=1,#s do
	 if i==1 then
		 spr(head,s[i].x,s[i].y)	
		else
		 spr(36,s[i].x,s[i].y)	
		end
	end
end

function draw_food() 
	spr(getframe(food.ani),food.x,food.y)
end

function draw_score()
local s=snake.segs
	print("score: "..score..
 		  "   high:"..high,4,9,6)
 
	if debug then
		print(s[1].x..","..
			  s[1].y,90,2,6)
		print("segs:"..#s,3,2,6)
		print("f.x:"..food.x..
			  " f.y:"..food.y,75,9,6)
	else
		print("simplesnake",81,9,9)
	end
end
-->8
--setup

function setup()
--dset(0,0) --reset highscore
	high=dget(0)
 
	t=0
	grid=4
 
	--fill the snake with segs
	segcnt=3
	snakesegs={}
 
	for i=segcnt*grid,0,-grid do
 		seg={x=i+grid,y=80}
		add(snakesegs,seg)
	end
	 
	snake={dir="r",spd=5,
 		   addseg=false,
 		   segs=snakesegs}
 
	food={}
	getfruit() 
 
	score=0
 
	debug=false
end
-->8
--support

function getframe(ani)
	--next frame for animation
	return ani[flr(t/12)%#ani+1]
end

function col(a,b,xofs,yofs)
--collision detection
local a_left=a.x
local a_top=a.y
local a_right=a_left+xofs
local a_bottom=a_top+yofs
	
local b_left=b.x
local b_top=b.y
local b_right=b_left+xofs
local b_bottom=b_top+yofs
	
	if a_top>b_bottom or
	   b_top>a_bottom or
	   a_left>b_right or
	   b_left>a_right then 
		return false 
	end
	
	return true
end

function getfruit()
--define new food position
::a::
local x=(flr(rnd(28))+2)*grid
local y=(flr(rnd(25))+4)*grid
--check if position is 
--in snake.segs table
	for seg in all(snake.segs) do
		if seg.x==x and 
	 	   seg.y==y then	
	 	--if so: again
	 		goto a
		end
	end
	
	food={ani={16,19},x=x,y=y}
end

function show_msg()
	if mode=="start" then
		rectfill(20,50,110,60,15)
		rect(20,50,110,60,9)
		print("press button to play",26,53,13)
	end
	if mode=="end" then
		rectfill(26,50,103,60,15)
		rect(26,50,103,60,9)
		print("you bite yourself!",30,53,13)
	end
end
__gfx__
00000000000000000000000000000000000000000000000000000000440000004444444400000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000440000004444444400000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000440000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000440000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000440000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000440000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000440000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000440000000000000000000000000000000000000000000000000000000000000000000000
08800000099000000880000008880000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
88780000997900008878000088778000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
88880000999900008888000088888000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
08800000099000000880000088888000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000008880000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0dd000000f80000008f000000ff00000033000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
86680000ff6d0000d6ff0000ffff00003bb300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
ffff0000ff6d0000d6ff0000866800003bb300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0ff000000f80000008f000000dd00000033000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0001000014130161301613014130121300f1300d130091300613000110061100c11011110161101c1102011024110261000000000000000000000000000000000000000000000000000000000000000000000000
00010000057500b7500e75012750147501575015750157501475012750107500b7500775000750047500b75010750127501375014750147501475014750147501375011750107500d7500a750047500000000000
