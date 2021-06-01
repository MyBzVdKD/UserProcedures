#pragma rtGlobals=1		// Use modern global access method.

// 09JAN06 AG
// this procedure adds a window hook function which allows you to draw the value (zero by default) into a displayed image.
// To use this window hook you need to assign it to the relevant window, e.g.,
// Setwindow kwTopWin hook(brush)=$"zeroPencilWinHook"
// To disengage the hook function from the window use the command:
// SetWindow kwTopWin userData(lastPoint)=ud
// As its name indicates, the procedure draws as if you have a pencil at the position of the cursor.  The drawing is activated
// when you hold the Shift-Key down while the mouse button is also pressed.
// You can change the pencil "drawing" value by modifying the drawingValue parameter below.
// NOTE:  this procedure allows you to draw only in a single image displayed in a window.  If you apply the hook function
// to a window that contains more than one image, the drawin will affect the first image in the image list.
// The line drawing code is based on the two-step algorithm of Xiaolin Wu which also appears in Graphic Gems I.
Structure ptStruct
	double x
	double y
endStructure


Function zeroPencilWinHook(s)
	STRUCT WMWinHookStruct &s

	Variable rval= 0
	STRUCT ptStruct lastPoint
	String list=ImageNameList(s.winName, ";")
	list=stringFromList(0,list)
	Wave/z w=ImageNameToWaveRef(s.winName,list)
	Variable xx,yy
	xx=AxisValFromPixel(s.winName, "bottom", s.mouseLoc.h )
	yy=AxisValFromPixel(s.winName, "left", s.mouseLoc.v )
	
	Variable drawingValue=200
	// remove evil wave scaling, if any.
	
	String ud
	if(waveExists(w))
		switch(s.eventCode)
			case 3:
			case 4:
				if(s.eventMod&1 && s.eventMod&2)
					ud=GetUserData(s.winName, "","lastPoint" )
					StructGet /S lastPoint,ud
					if(numType(lastPoint.x)==2)
						drawLineOnData(w,xx,yy,xx,yy,drawingValue)
					else
						drawLineOnData(w,lastPoint.x,lastPoint.y,xx,yy,drawingValue)
					endif
					lastPoint.x=xx
					lastPoint.y=yy
					StructPut /S  lastPoint, ud
					SetWindow kwTopWin userData(lastPoint)=ud
					rval=1
				endif		 
			break
			
			case 5:
				lastPoint.x=nan
				lastPoint.y=nan
				StructPut /S  lastPoint, ud
				SetWindow kwTopWin userData(lastPoint)=ud
			break
			
		EndSwitch
	endif
	return rval
End



Function  drawLineOnData(w,x0,y0,x1,y1,value)
	Wave w
	Variable x1,y1,x0,y0,value
       
       x0=trunc(x0)
       y0=trunc(y0)
       x1=trunc(x1)
       y1=trunc(y1)
       
	Variable dy = y1 - y0
	Variable dx = x1 - x0
	Variable stepx, stepy
	variable	i
	
	if(dy < 0) 
		dy = -dy
		stepy = -1
	else
		stepy = 1
	endif

	if(dx < 0)
		dx = -dx
		stepx = -1
	else
		stepx = 1
	endif

	w[x0][y0]=value
	w[x1][y1]=value
      
        if(dx > dy)		
            variable length =trunc(dx - 1)/4
            variable extras =trunc(dx - 1) & 3
            variable incr2 =trunc(dy *4) -(dx *2)
            if(incr2 < 0)
                variable c = dy *2
                variable incr1 = c *2
                variable d =  incr1 - dx
                for(i = 0; i < length; i+=1)
	                    x0 += stepx
	                    x1 -= stepx
	                    if(d < 0) 
	                       	w[x0][y0]=value
	                      	x0 += stepx                       
	                       	w[x0][y0]=value
	                       	w[x1][y1]=value
					x1 -= stepx	
	                       	w[x1][y1]=value
	                       	d += incr1
	                    else
	                        if(d < c)
	                       		w[x0][y0]=value
	                       		x0 += stepx
	                       		 y0 += stepy
	                       		w[x0][y0]=value
	                       		w[x1][y1]=value
	                            	 x1 -= stepx
	                            	 y1 -= stepy
	                            	 w[x1][y1]=value
	                        else
	                        		y0 += stepy
	                       		w[x0][y0]=value
	                       		x0 += stepx
	                       		w[x0][y0]=value
	                       		y1 -= stepy
	                            	 w[x1][y1]=value
	                            	 x1 -= stepx
	                            	 w[x1][y1]=value
	                        endif
	                        d += incr2
	                    endif
                endfor
                
                
			if(extras > 0)
				if(d < 0)
					x0 += stepx
					w[x0][y0]=value
					if(extras > 1)
						x0 += stepx
						w[x0][y0]=value
					endif
					if(extras > 2)
						x1 -= stepx
						w[x1][y1]=value
					endif
				else					//(d < 0)
					if(d < c)
						x0 += stepx
						w[x0][y0]=value
						if(extras > 1)
							x0 += stepx
							y0 += stepy
							w[x0][y0]=value
						endif
						if(extras > 2)
							x1 -= stepx
							w[x1][y1]=value
						endif
					else 			//(d < c)
						x0 += stepx
						y0 += stepy
						w[x0][y0]=value
						if(extras > 1)
							x0 += stepx
							w[x0][y0]=value
						endif
						if(extras > 2) 
							x1 -= stepx
							y1 -= stepy
							w[x1][y1]=value
						endif
					endif			//(d < c)
                		endif				//(d < 0)
                	endif					//(extras > 0)
            else 							// incr2<0
			c =(dy - dx) *2
			incr1 = c *2
			d =  incr1 + dx
			for(i = 0; i < length; i+=1)
				x0 += stepx
				x1 -= stepx
				if(d > 0)
					y0 += stepy
					w[x0][y0]=value
					x0 += stepx
					y0 += stepy
					w[x0][y0]=value
					y1 -= stepy
					w[x1][y1]=value
					x1 -= stepx
					y1 -= stepy
					w[x1][y1]=value
					d += incr1
				else 
					if(d < c)
						w[x0][y0]=value
						x0 += stepx
						y0 += stepy
						w[x0][y0]=value
						w[x1][y1]=value
						x1 -= stepx
						y1 -= stepy
						w[x1][y1]=value
					else
						y0 += stepy
						w[x0][y0]=value
						x0 += stepx
						w[x0][y0]=value
						y1 -= stepy
						w[x1][y1]=value
						x1 -= stepx
						w[x1][y1]=value
					endif
					d += incr2
				endif
			endfor
                
			if(extras > 0)
				if(d > 0)
					x0 += stepx
					y0 += stepy
					w[x0][y0]=value
					if(extras > 1) 
						x0 += stepx
						y0 += stepy
						w[x0][y0]=value
					endif
					if(extras > 2) 
						x1 -= stepx
						y1 -= stepy
						w[x1][y1]=value
					endif
				else
					if(d < c)
						x0 += stepx
						w[x0][y0]=value
						if(extras > 1) 
							x0 += stepx
							y0 += stepy
							w[x0][y0]=value
						endif
						if(extras > 2) 
							x1 -= stepx
							w[x1][y1]=value
						endif
					else 
						x0 += stepx
						y0 += stepy
						w[x0][y0]=value
						if(extras > 1)
							x0 += stepx
							w[x0][y0]=value
						endif
						if(extras > 2) 
							if(d > c)
								x1 -= stepx
								y1 -= stepy
								w[x1][y1]=value
							else
								x1 -= stepx
								w[x1][y1]=value
							endif
						endif	
					endif			// d<c
				endif				// d>0
			endif					// extras>0	
           endif							// incr2<0
         
        else							// dx > dy
            length =trunc((dy - 1) / 4)
            extras =(dy - 1) & 3
            incr2 =(dx *4) -(dy *2)
            if(incr2 < 0)
                c = dx *2
                incr1 = c *2
                d =  incr1 - dy
                for(i = 0; i < length; i+=1)
                    y0 += stepy
                    y1 -= stepy
                    if(d < 0)
	 		           	w[x0][y0]=value
	 		           	y0 += stepy
	 		           	w[x0][y0]=value
	 		           	w[x1][y1]=value
	 		           	y1 -= stepy
	 		           	w[x1][y1]=value
                       		 d += incr1
                    else
                        if(d < c)
	 		           	w[x0][y0]=value
                            	x0 += stepx
                            	y0 += stepy
	 		           	w[x0][y0]=value
	 		           	w[x1][y1]=value
                            	x1 -= stepx
                            	y1 -= stepy
 	 		           	w[x1][y1]=value
                       else
                            	x0 += stepx
	 		           	w[x0][y0]=value
                            	y0 += stepy
	 		           	w[x0][y0]=value
                            	x1 -= stepx
 	 		           	w[x1][y1]=value
                            	y1 -= stepy
 	 		           	w[x1][y1]=value
                        endif
                        d += incr2
                   endif
                endfor
                
			if(extras > 0)
				if(d < 0) 
					y0 += stepy
					w[x0][y0]=value
					if(extras > 1) 
						y0 += stepy
						w[x0][y0]=value
					endif
					if(extras > 2) 
						y1 -= stepy
						w[x1][y1]=value
					endif
				else 
					if(d < c)
						y0 += stepy
						w[x0][y0]=value
						if(extras > 1) 
							x0 += stepx
							y0 += stepy
							w[x0][y0]=value
						endif
						if(extras > 2) 
							y1 -= stepy
							w[x1][y1]=value
						endif
					else
						x0 += stepx
						y0 += stepy
						w[x0][y0]=value
						if(extras > 1) 
							y0 += stepy
							w[x0][y0]=value
						endif
						if(extras > 2) 
							x1 -= stepx
							y1 -= stepy
							w[x1][y1]=value
						endif
					endif
				endif
			endif
            else 
                c =(dx - dy) *2
                incr1 = c *2
                d =  incr1 + dy
                for(i = 0; i < length; i+=1)
                    y0 += stepy
                    y1 -= stepy
                    if(d > 0)
                        	x0 += stepx
  	 		       w[x0][y0]=value
                        	x0 += stepx
                        	y0 += stepy
   	 		       w[x0][y0]=value
                       	x1 -= stepx
   	 		       w[x1][y1]=value
                        	x1 -= stepx
                        	y1 -= stepy
   	 		       w[x1][y1]=value
                        	d += incr1
                    else 
                        if(d < c)
  	 		       w[x0][y0]=value
                            x0 += stepx
                            y0 += stepy
  	 		       w[x0][y0]=value
  	 		       w[x1][y1]=value
                            x1 -= stepx
                            y1 -= stepy
   	 		       w[x1][y1]=value
                        else 
                            x0 += stepx
  	 		       w[x0][y0]=value
                            y0 += stepy
  	 		       w[x0][y0]=value
                            x1 -= stepx
  	 		       w[x1][y1]=value
                            y1 -= stepy
  	 		       w[x1][y1]=value
                        endif
                        d += incr2
                    endif
                endfor
                
		if(extras > 0)
			if(d > 0)
				x0 += stepx
				y0 += stepy
				w[x0][y0]=value
				if(extras > 1) 
					x0 += stepx
					y0 += stepy
					w[x0][y0]=value
				endif
				if(extras > 2)
					x1 -= stepx
					y1 -= stepy
					w[x1][y1]=value
				endif
			else
				if(d < c)
					y0 += stepy
					w[x0][y0]=value
					if(extras > 1) 
						x0 += stepx
						y0 += stepy
						w[x0][y0]=value
					endif
					if(extras > 2) 
						y1 -= stepy
						w[x1][y1]=value
					endif
				else
					x0 += stepx
					y0 += stepy
					w[x0][y0]=value
					if(extras > 1) 
						y0 += stepy
						w[x0][y0]=value
					endif
					if(extras > 2) 
						if(d > c)
							x1 -= stepx
							y1 -= stepy
							w[x1][y1]=value
						else
							y1 -= stepy
							w[x1][y1]=value
						endif
					endif
				endif
			endif
		endif
        endif
    endif
End

