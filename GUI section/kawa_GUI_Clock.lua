--====================================================================== 
--[[ 
* ReaScript Name: kawa_GUI_Clock. 
* Version: 2016/06/15 
* Author: kawa_ 
* Author URI: http://forum.cockos.com/member.php?u=105939 
* Repository: GitHub 
* Repository URI: https://github.com/kawaCat/ReaScript-MidiPack 
--]] 
--====================================================================== 
bit32={band=function(a,b)return a&b;end,bor=function(a,b)return a|b;end,bxor=function(a,b)return a~b;end,bnot=function(a)return~a;end,rshift=function(a,n)return a>>n;end,lshift=function(a,n)return a<<n;end,};
if(_DBG_==true)then else function DBG()end end math.randomseed(reaper.time_precise()*os.time()/1e3)function HSVToRGB(r,c,u)local i,n,o,h,l,e,t,s,a local d=r local r=c if(d>360)then d=d-360;elseif(d<0)then d=d+360;end if(r>1)then r=1;elseif(r<0)then r=0;end e=math.floor(255*u)if(e>255)then e=255;elseif(e<0)then e=0;end if(r==0)then i=e;n=e;o=e;else h=math.floor(d/60)l=d/60-h t=math.floor(e*(1-r))if(t<0)then t=0;elseif(t>255)then t=255;end s=math.floor(e*(1-l*r))if(s<0)then s=0;elseif(s>255)then s=255;end a=math.floor(e*(1-(1-l)*r))if(a<0)then a=0;elseif(a>255)then a=255;end if(h==0)then i=e;n=a;o=t;elseif(h==1)then i=s;n=e;o=t;elseif(h==2)then i=t;n=e;o=a;elseif(h==3)then i=t;n=s;o=e;elseif(h==4)then i=a;n=t;o=e;elseif(h==5)then i=e;n=t;o=s;else i=e;n=a;o=t;end end return i,n,o end function RGBToHSV(i,o,a)i,o,a=i/255,o/255,a/255;local t,s=math.max(i,o,a),math.min(i,o,a)local e,r,h=0,0,0 h=(t+s)/2 if(t==s)then e,r=0,0 else local n=t-s local r=0 if(h>.5)then r=n/(2-t-s);else r=n/(t+s);end if(t==i)then e=(o-a)/n if(o<a)then e=e+6;end elseif(t==o)then e=(a-i)/n+2 elseif(t==a)then e=(i-o)/n+4 end e=e/6 end return e*360,r,h end function rotPoint(t,a,o,i,e)local o=o-t local i=i-a local n=o*math.cos(e)-i*math.sin(e)local o=o*math.sin(e)+i*math.cos(e)local e=t+n local t=a+o return e,t end function deepcopy(t)local a=type(t)local e if a=='table'then e={}for a,t in next,t,nil do e[deepcopy(a)]=deepcopy(t)end setmetatable(e,deepcopy(getmetatable(t)))else e=t end return e end function table.toString(a)local function l(e)return string.format("%q",e)end local d="";local function e(e)d=d..e end;local r,t="   ","\n"local h,a={a},{[a]=1}e("return {"..t)for o,n in ipairs(h)do e("-- Table: {"..o.."}"..t)e("{"..t)local s={}for i,o in ipairs(n)do s[i]=true local i=type(o)if i=="table"then if not a[o]then table.insert(h,o)a[o]=#h end e(r.."{"..a[o].."},"..t)elseif i=="string"then e(r..l(o)..","..t)elseif i=="number"then e(r..tostring(o)..","..t)end end for n,i in pairs(n)do if(not s[n])then local s=""local o=type(n)if o=="table"then if not a[n]then table.insert(h,n)a[n]=#h end s=r.."[{"..a[n].."}]="elseif o=="string"then s=r.."["..l(n).."]="elseif o=="number"then s=r.."["..tostring(n).."]="end if(s~="")then o=type(i)end if o=="table"then if not a[i]then table.insert(h,i)a[i]=#h end e(s.."{"..a[i].."},"..t)elseif o=="string"then e(s..l(i)..","..t)elseif o=="number"then e(s..tostring(i)..","..t)elseif o=="boolean"then e(s..tostring(i)..","..t)end end end e("},"..t)end e("}")return d;end function table.fromString(e)local e=load(e);local e=e()if(type(e)~="table")then local e={}return e end for t=1,#e do local i={}for a,o in pairs(e[t])do if type(o)=="table"then e[t][a]=e[o[1]]end if type(a)=="table"and e[a[1]]then table.insert(i,{a,e[a[1]]})end end for o,a in ipairs(i)do e[t][a[2]],e[t][a[1]]=e[t][a[1]],nil end end return e[1]end function createDummyTimer()local e={}e._intervalTime=1;e._lastTime=os.clock();e._callBackFuncTable={};e._diffTime=0;e._isRunning=false;function e:startTimer()self._isRunning=true;self._lastTime=os.clock()-self:getDiffTime();end function e:resetTimer()self._lastTime=os.clock();self:_updateDiffTime();self._isRunning=false;end function e:toggleTimer()if(self._isRunning==true)then self:stopTimer();else self:startTimer();end end function e:stopTimer()self._isRunning=false;end function e:isRunning()return self._isRunning;end function e:update()self:updateAndCheck();end function e:updateAndCheck()if(self:isRunning()==true)then self:_updateDiffTime();if(self:getDiffTime()>=self._intervalTime)then self._lastTime=os.clock();self:_updateDiffTime();self:_timerCallBack();end end end function e:setTimerTime(e)self._intervalTime=e;end function e:getTimerTime()return self._intervalTime;end function e:getIntervalTime()return self:getTimerTime();end function e:addTimerCallBackFunction(t)local e=false;for o,a in ipairs(self._callBackFuncTable)do if(a==t)then e=true;break;end end if(e==false)then table.insert(self._callBackFuncTable,t)end end function e:getDiffTime()return self._diffTime;end function e:getDiffTimeV()return(self:getDiffTime()/self._intervalTime);end function e:timerCallBack()end function e:_timerCallBack()self:timerCallBack();for t,e in ipairs(self._callBackFuncTable)do if(type(e)=="function")then e();end end end function e:_updateDiffTime()local e=os.clock();self._diffTime=(e-self._lastTime);end return e;end function createParticalSingle()local e={};e._fadeInFrame_F=.1;e._fadeOutFrame_F=.1;e.lifeFrameNum=60;e.currentLifeFrame=0;e._lifeCounter=createCounter(e.lifeFrameNum);e.ox=0;e.oy=0;e.fx=1;e.fy=1;e._x=e.ox;e._y=e.oy;e._alpha=.5;e.oRotAngle=0;e.fRotAngle=0;e.radius=3;function e:setAlpha(e)self._alpha=e;return self;end function e:setStartPoint(t,e)self._x=t;self._y=e;return self;end function e:setOrigin(e,t)self.ox=e;self.oy=t;return self;end function e:setForce(t,e)self.fx=t;self.fy=e;return self;end function e:setRotAngleFromOrigin(e)self.oRotAngle=e;return self;end function e:setRotAngle(e)self.fRotAngle=e;return self;end function e:setLifeFrameNum(e)self._lifeCounter={}self._lifeCounter=createCounter(e);self.lifeFrameNum=e;return self;end function e:setRadius(e)self.radius=e;return self;end function e:getAlpha()return self._alpha;end;function e:getOrigin()return self.ox,self.oy;end;function e:getForce()return self.fx,self.fy;end;function e:getRotAngleFromOrigin()return self.oRotAngle;end;function e:getRotAngle()return self.fRotAngle;end;function e:getLifeFrame()return self.lifeFrameNum;end;function e:getCurrentLifeFrame()local e=self._lifeCounter:getValueWithOutStep();self.currentLifeFrame=(e*self:getLifeFrame());return self.currentLifeFrame;end function e:getRadius()return self.radius;end;function e:isFinished()local e=(self:getCurrentLifeFrame()>=self:getLifeFrame());return e;end function e:updateAndDraw()self:_update();self:_draw();end function e:_init()end function e:_update()self.currentLifeFrame=self._lifeCounter:getValue()local e=self:_getFadeInOutTimeValue();self._x=self._x+self.fx*e;self._y=self._y+self.fy*e;local e,t=rotPoint(self.ox,self.oy,self._x,self._y,self.oRotAngle*e);self._x=e;self._y=t;end function e:_draw()gfx.set(1,1,1,self._alpha*self:_getFadeInOutTimeValue(),1);local e=self.radius*self:_getFadeInOutTimeValue();gfx.circle(self._x-e/2,self._y-e/2,e,true,false);end function e:_getFadeInOutTimeValue()local a=self._lifeCounter:getValueWithOutStep();local t=1;if(a<self._fadeInFrame_F)then t=a/self._fadeInFrame_F elseif(a<(1-self._fadeOutFrame_F))then t=1;else local e=(a-(1-self._fadeOutFrame_F));t=1-(e/self._fadeOutFrame_F);if(t<.001)then t=0;end end return t;end e:_init();return e;end function createParticleManager()local e={};e._particals={};e._maxPartiCalNum=300;e._lastAddTime=os.clock();e._safeAddIntervalTime=.02;e._targetRadius=8;function e:setTargetRadiusSize(e)self._targetRadius=math.max(math.min(e,100),2);end function e:getTargetRadiusSize()return self._targetRadius;end;function e:getActiveParticalNum()return#self._particals;end;function e:setOriginePoint_A(a,t)for o,e in ipairs(self._particals)do e:setOrigin(a,t);end end function e:setMaxParticalNum(e)self._maxPartiCalNum=e;end function e:addParticleType1(n,i,o,e,t,s)if(os.clock()-self._lastAddTime<self._safeAddIntervalTime)then return end local e=e or 9.75 local a=e/2 local t=t or 30;local r=t/2;local h=self._targetRadius;local o=o or 5;local s=s or 60;for o=1,o do local o=createParticalSingle();o:setStartPoint(n,i):setOrigin(n,i):setAlpha(.3*math.random()+.5):setForce(math.random()*e-a,math.random()*e-a):setRotAngleFromOrigin(math.rad(math.random()*t-r)):setLifeFrameNum(s*math.random()+30):setRadius(h*math.random());table.insert(self._particals,o)end self:_checkMaxParticalNum();self._lastAddTime=os.clock();end function e:updateAndDraw()for t,e in ipairs(self._particals)do e:updateAndDraw();end self:_checkPrticleLife();end function e:_checkPrticleLife()for t,e in ipairs(self._particals)do if(e:isFinished()==true or(e:_getFadeInOutTimeValue()<=0 and e:getCurrentLifeFrame()>0))then table.remove(self._particals,t);break;end end end function e:_checkMaxParticalNum()while(#self._particals>self._maxPartiCalNum)do table.remove(self._particals,1);end end return e;end function createApp(o,a,t)local e={}e._lastTime=os.clock();e._lastMouseCap=nil e._lastMouseX=0 e._lastMouseY=0 e._lastMouseWheel=0 e.mouseWheelDt=0;e._childComponent={}e._lastMouseLeftDown=false e._lastMouseRightDown=false e.width=a or 380;e.height=t or 500;e.title=o or"app"e._CLASS_TYPE="App"function e:addChildComponent(e)local t=false;for o,a in ipairs(self._childComponent)do if(a==e)then t=true;break;end end if(t==false)then e:setBounds(0,0,self.width,self.height)table.insert(self._childComponent,e)end end function e:resized()self.width=gfx.w self.height=gfx.h for t,e in ipairs(self._childComponent)do e:setBounds(0,0,self.width,self.height)end end function e:onMouseMove(a,t)for o,e in ipairs(self._childComponent)do if(e._MouseMove~=nil)then e:_MouseMove(a,t)end end end function e:onMousePress(t)for a,e in ipairs(self._childComponent)do if(e._MousePress~=nil)then e:_MousePress(t)end end end function e:onMouseRelease(t)for a,e in ipairs(self._childComponent)do if(e._MouseRelease~=nil)then e:_MouseRelease(t)end end end function e:onMouseWheel(t)for a,e in ipairs(self._childComponent)do if(e._MouseWheel~=nil)then e:_MouseWheel(t)end end end function e:onDraw(t)for a,e in ipairs(self._childComponent)do if(e._Draw~=nil)then e:_Draw(t)end end end function e:runLoop()local e=os.clock()-self._lastTime;gfx.update();if(self.width~=gfx.w or self.height~=gfx.h)then self:resized();end if(self._lastMouseX~=gfx.mouse_x or self._lastMouseY~=gfx.mouse_y)then self:onMouseMove(self._lastMouseX,self._lastMouseY)end gfx.set(1,1,1,1)self:onDraw(e);if(self._lastMouseCap~=gfx.mouse_cap)then if(self._lastMouseCap<gfx.mouse_cap and(bit32.band(gfx.mouse_cap,1)==1 or bit32.band(gfx.mouse_cap,2)==2 or bit32.band(gfx.mouse_cap,64)==64))then self:onMousePress(gfx.mouse_cap)else self:onMouseRelease(gfx.mouse_cap)end end if(self._lastMouseWheel~=gfx.mouse_wheel)then if(self._lastMouseWheel<gfx.mouse_wheel)then self.mouseWheelDt=1 else self.mouseWheelDt=-1 end self:onMouseWheel(self.mouseWheelDt)else self.mouseWheelDt=0;gfx.mouse_wheel=0;end if(gfx.getchar()>=0)then reaper.defer(function()self:runLoop()end)end self:_storeGfxInfo();end function e:toggleDock()if(gfx.dock(-1)==1)then gfx.dock(0)else gfx.dock(1)end end function e:isDock()local e=false if(gfx.dock(-1)==1)then e=true;end return e;end function e:changeWindowSize(e,t)self.width=e self.height=t gfx.quit()self:_init()self:resized()end function e:_init()local e={}e.settings={}e.settings.font_size=20 e.settings.docker_id=0 gfx.init(self.title,self.width,self.height,e.settings.docker_id)gfx.setfont(1,"Arial",e.settings.font_size)gfx.clear=3355443 self:_storeGfxInfo()end function e:_storeGfxInfo()self._lastMouseX=gfx.mouse_x;self._lastMouseY=gfx.mouse_y;self._lastMouseWheel=gfx.mouse_wheel;self._lastTime=os.clock();self._lastMouseLeftDown=(bit32.band(gfx.mouse_cap,1)==1)self._lastMouseRightDown=(bit32.band(gfx.mouse_cap,2)==2)self._lastMouseCap=gfx.mouse_cap self.width=gfx.w;self.height=gfx.h;end e:_init()return e;end function createRectangle(t,o,a,i)local e={}e.x=t or 0 e.y=o or 0 e.w=a or 100 e.h=i or 100 e._xyTable={}e._cpoint={};e._CLASS_TYPE="Rectangle"function e:getX()return self.x;end function e:getY()return self.y;end function e:getX2()return self.x+self.w;end function e:getY2()return self.y+self.h;end function e:getWidth()return self.w;end function e:getHeight()return self.h;end function e:getCenterPoint()return self._cpoint;end function e:getRectangle()return createRectangle(self.x,self.y,self.w,self.h)end function e:setX(e)self.x=e;self:_updateXyTable();end function e:setY(e)self.y=e;self:_updateXyTable();end function e:setWidth(e)self.w=e;self:_updateXyTable();end function e:setHeight(e)self.h=e;self:_updateXyTable();end function e:setBounds(e,t,o,a)self.x=e;self.y=t;self.w=o;self.h=a;self:_updateXyTable();end function e:setBoundsFromRect(e)self.x=e.x;self.y=e.y;self.w=e.w;self.h=e.h;self:_updateXyTable();end function e:isContact(n,i)local t=0 local e=self._xyTable;for a=1,#e,1 do local o=a+1 if(a+1>#e)then o=1 end local s=e[o].x-e[a].x;local o=e[o].y-e[a].y;local n=n-e[a].x;local e=i-e[a].y;if(s*e-n*o<0)then t=t+1 else t=t-1 end end if(t<=-#e or t>=#e)then return true end return false end function e:isColisionMouse()return self:isContact(gfx.mouse_x,gfx.mouse_y);end function e:reduce(e,t)self.x=(self.x+e);self.y=(self.y+t);self.w=(self.w-e*2);self.h=(self.h-t*2);self:_updateXyTable();end function e:reduce_2(e,o,t,a)self.x=(self.x+e);self.y=(self.y+t);self.w=(self.w-e-o);self.h=(self.h-t-a);self:_updateXyTable();end function e:expand(t,e)self.x=self.x-t;self.y=self.y-e;self.w=self.w+t*2;self.h=self.h+e*2;self:_updateXyTable();end function e:resized()end function e:_updateXyTable()self._xyTable={}self._xyTable[1]={x=self.x,y=self.y}self._xyTable[2]={x=self.x+self.w,y=self.y}self._xyTable[3]={x=self.x+self.w,y=self.y+self.h}self._xyTable[4]={x=self.x,y=self.y+self.h}self._cpoint={x=self.x+self.w/2,y=self.y+self.h/2};self:resized();end function e:removeFromTop(e)self.y=self.y+e;self.h=self.h-e;self:_updateXyTable();end function e:drawFill()gfx.rect(self.x,self.y,self.w,self.h)end e:_updateXyTable();return e;end function createComponent(t,a,i,e,o)local e=createRectangle(a,i,e,o)e.name=t or""e._childComponentTable={}e._parentComponent=nil e._isMousePressing=false e._fontName="Courier New bold"e._fontSize=20 e.isMouseLeftDown=false e.isMouseRightDown=false e.isMouseMiddleDown=false e.isStartInMouseDown=false e.isControlKeyDown=false e.isShiftKeyDown=false e.isAltKeyDown=false e._componentAlpha=1 e._colors={}e._colors["white"]={1,1,1,1}e._colors["black"]={0,0,0,1}e._colors["blue"]={0,0,1,1}e._colors["red"]={1,0,0,1}e._colors["green"]={0,1,0,1}e._CLASS_TYPE="Component"function e:setComponentAlpha(e)self._componentAlpha=e for a,t in ipairs(self._childComponentTable)do t:setComponentAlpha(e)end end function e:setColor(t,e)self._colors[t]=e;end function e:getColor(e)if(self._colors[e]==nil)then return 1,1,1,1*self._componentAlpha end local t=self._colors[e][1]or 1 local a=self._colors[e][2]or 1 local o=self._colors[e][3]or 1 local e=self._colors[e][4]or 1 e=e*self._componentAlpha return t,a,o,e end function e:getColorAsTable(e)local o,e,a,t=self:getColor(e)return{o,e,a,t}end function e:setFont(e,t)if(e~=""and e~=nil)then self._fontName=e end self._fontSize=t end function e:getName()return self.name;end function e:setName(e)self.name=e;end function e:getParrent()return self._parentComponent;end function e:addChildComponent(e)if(e==nil)then return end local t=false;for o,a in ipairs(self._childComponentTable)do if(a==e)then t=true;break;end end if(t==false)then e._parentComponent=self;table.insert(self._childComponentTable,e)else DBG("cant add component."..e.name.."// check same component.")end end function e:removeChildComponent(e)if(e==nil)then return end for a,t in ipairs(self._childComponentTable)do if(t==e)then t._parentComponent=nil;table.remove(self._childComponentTable,a)break;end end end function e:getFitFontSize(e)local e=e or self.name;local e=#e+1 local e=self.w/e*1.8 local e=math.max(math.min(e,self.h),20);return e;end function e:resized()self:onResized()for t,e in ipairs(self._childComponentTable)do e:resized()end end function e:_MouseMove(e,t)self:onMouseMove(e,t)for o,a in ipairs(self._childComponentTable)do a:_MouseMove(e,t)end end function e:_MousePress(t)if(self:isColisionMouse())then self._isMousePressing=true;self.isMouseLeftDown=(bit32.band(gfx.mouse_cap,1)==1)self.isMouseRightDown=(bit32.band(gfx.mouse_cap,2)==2)self.isMouseMiddleDown=(bit32.band(gfx.mouse_cap,64)==64)self.isStartInMouseDown=true self.isControlKeyDown=(bit32.band(gfx.mouse_cap,4)==4)self.isShiftKeyDown=(bit32.band(gfx.mouse_cap,8)==8)self.isAltKeyDown=(bit32.band(gfx.mouse_cap,16)==16)end self:onMousePress(t)for a,e in ipairs(self._childComponentTable)do if(e:isColisionMouse())then e._isMousePressing=true end e:_MousePress(t)end end function e:_MouseRelease(e)if(self._isMousePressing==true and(bit32.band(gfx.mouse_cap,1)~=1)and(bit32.band(gfx.mouse_cap,2)~=1))then self._isMousePressing=false;end self:onMouseRelease(e)for a,t in ipairs(self._childComponentTable)do t:_MouseRelease(e)end self.isMouseLeftDown=(bit32.band(gfx.mouse_cap,1)==1)self.isMouseRightDown=(bit32.band(gfx.mouse_cap,2)==2)self.isMouseMiddleDown=(bit32.band(gfx.mouse_cap,64)==64)self.isStartInMouseDown=false self.isControlKeyDown=(bit32.band(gfx.mouse_cap,4)==4)self.isShiftKeyDown=(bit32.band(gfx.mouse_cap,8)==8)self.isAltKeyDown=(bit32.band(gfx.mouse_cap,16)==16)end function e:_MouseWheel(e)self:onMouseWheel(e)for a,t in ipairs(self._childComponentTable)do t:_MouseWheel(e)end end function e:_Draw(t)gfx.set(1,1,1,1*self._componentAlpha)gfx.setfont(1,self._fontName,self._fontSize)self:onDraw(t)for a,e in ipairs(self._childComponentTable)do gfx.set(1,1,1,1*self._componentAlpha)gfx.setfont(1,e._fontName,e._fontSize)e:_Draw(t)end gfx.setfont(1,self._fontName,self._fontSize)self:onDraw2(t)end function e:_isMouseDragging()return self._isMousePressing;end function e:onMouseMove(e,e)end function e:onMousePress(e)end function e:onMouseRelease(e)end function e:onMouseWheel(e)end function e:onDraw(e)end function e:onDraw2(e)end function e:onResized()end return e;end function createButton(o,i,a,e,t)local e=createComponent(o,i,a,e,t)e._mouseClickFuncTable={}e._mouseWheelFuncTable={}e._isAutoFontSizeMode=false;e:setColor("text",{0,0,0,1})e:setColor("background",{1,1,1,1})e:setColor("background_onMouse",{0,1,1,1})e._CLASS_TYPE="Button"function e:isAutoFontSizeMode()return self._isAutoFontSizeMode;end function e:setAutoFontSizeMode(e)self._isAutoFontSizeMode=e;end function e:addMouseReleaseFunction(e)if(type(e)~="function")then return end local t=false for o,a in ipairs(self._mouseClickFuncTable)do if(a==e)then t=true end end if(t==false)then table.insert(self._mouseClickFuncTable,e)end end function e:addMouseWheelFunction(e)if(type(e)~="function")then return end local t=false for o,a in ipairs(self._mouseWheelFuncTable)do if(a==e)then t=true end end if(t==false)then table.insert(self._mouseWheelFuncTable,e)end end function e:onMouseRelease(t)if(self:isColisionMouse()and self.isStartInMouseDown==true)then for a,e in ipairs(self._mouseClickFuncTable)do if(type(e)=="function")then e(self,t)end end end end function e:onDraw(e)if(self:isColisionMouse())then gfx.set(self:getColor("background_onMouse"))else gfx.set(self:getColor("background"))end gfx.rect(self.x,self.y,self.w,self.h,true)local a=self:getCenterPoint();local t=#self.name local e=self._fontSize;if(self:isAutoFontSizeMode())then local t=self.w/t;e=math.min(t,self._fontSize);end gfx.set(self:getColor("text"))gfx.setfont(1,self._fontName,e)gfx.x=a.x-(gfx.texth/2)*(t/2)gfx.y=a.y-gfx.texth/2 gfx.drawstr(self.name)end function e:onMouseWheel(t)if(self:isColisionMouse())then for a,e in ipairs(self._mouseWheelFuncTable)do if(type(e)=="function")then e(self,t)end end end end return e;end function createCounter(t)local e={}e.m_value=0;e.m_stepValue=0;e.m_frameNum=t or 60 e._CLASS_TYPE="Counter"function e:setCounterFrame(e)self.m_frameNum=e;self:_calcStepValue();end function e:setForward()self:_calcStepValue()end function e:setBackward()self:_calcStepValue()self:inverse();end function e:inverse()self.m_stepValue=self.m_stepValue*-1;end function e:reset()self:_calcStepValue();self.m_value=0;end function e:isActive()if(self.m_value~=0 and self.m_vakue~=1)then return true;end return false;end function e:isStartTime()return(self:getValueWithOutStep()==0)end function e:isFinished()if(self.m_stepValue>0)then return(self.m_value>=1)else return(self.m_value<=0)end end function e:getValue()self:_step()return self:_inOutCubic(self.m_value)end function e:getValueWithOutStep()return self.m_value;end function e:_calcStepValue()self.m_stepValue=1/self.m_frameNum;end function e:_step()if(self.m_value~=1 and self.m_stepValue>0 or self.m_value~=0 and self.m_stepValue<0)then self.m_value=self.m_value+self.m_stepValue;if(self.m_value>=1)then self.m_value=1;end if(self.m_value<=0)then self.m_value=0;end;end;end function e:_inOutCubic(t)t=t*2 if t<1 then return .5*t*t*t else t=t-2 return .5*(t*t*t+2)end end e:_calcStepValue();return e;end function createTabComponent(e)local e=createComponent(e)e._nextComponentKey=""e._currentComponentKey=""e._components={}e._childTabComponents={}e._buttons={}e._keyStringList={}e._currentKeyStringIdx=0;e:setColor("currentTabButton_background",{.5,.5,1,1})e:setColor("tabButton_backGround",{1,1,1,1})e:setColor("tabButton_backGround_onMouse",{0,1,1,1})e._buttonArea=createRectangle();e._buttonMargin={3,3,3,3}e._isFadeMode=false e._animCounter=createCounter(15)e._CLASS_TYPE="TabComponent"function e:setFadeMode(e)self._isFadeMode=e for a,t in pairs(self._childTabComponents)do t._isFadeMode=e end end function e:setButtonMargin(a,t,o,e)self._buttonMargin={a,t,o,e}end function e:getTabCount()local e=0 for t,t in pairs(self._components)do e=e+1 end return e end function e:getCurrentTabComponent()return self._components[self._currentComponentKey]end function e:addTab(t,e)self._components[t]=e self:_addButton(t)self:_addKeyToKeyStringList(t)self:_resizeButtonComp();self:_resizeCompInTabed(e);if(e._CLASS_TYPE=="TabComponent")then local a=false for i,o in ipairs(self._childTabComponents)do e._keyStr=t;if(o==e)then a=true break;end end if(a==false)then table.insert(self._childTabComponents,e)end end end function e:removeTab(e)self._components[e]=nil self:_removeKeyFromKeyStringList(e)self:_removeButton(e)self:_resizeButtonComp()for a,t in ipairs(self._childTabComponents)do if(t._keyStr==e)then table.remove(self._childTabComponents,a);break;end end end function e:changeTab(e)if((self._animCounter:isFinished()==true or self._animCounter:isStartTime()==true)and self._nextComponentKey~=e and self._currentComponentKey==self._nextComponentKey)then self._nextComponentKey=e self._animCounter:reset()self:_resizeCompInTabed(self._components[e]);end end function e:onResized()self:_resizeButtonComp();self:_resizeCompInTabed(self._components[self._nextComponentKey]);self:_resizeCompInTabed(self._components[self._currentComponentKey]);end function e:onDraw2(e)if(self._isFadeMode==true)then self:_checkCurrentTabChangedWithFade()else self:_checkCurrentTabChanged()end end function e:onMouseWheel(e)if(self._buttonArea:isColisionMouse())then local e=self._currentKeyStringIdx+e if(e<=0)then e=#self._keyStringList end;if(e>#self._keyStringList)then e=1 end;local e=self._keyStringList[e]self:changeTab(e)end end function e:_init()end function e:_checkCurrentTabChanged()if(self._currentComponentKey==self._nextComponentKey)then return end local t=self._components[self._currentComponentKey]local e=self._components[self._nextComponentKey]if(e==nil)then return end self:_syncButtonColor()self:removeChildComponent(t)self:addChildComponent(e)self:_resizeCompInTabed(e);self._currentComponentKey=self._nextComponentKey self._currentKeyStringIdx=self:_getIndexFromKeyStringIndex(self._nextComponentKey)end function e:_checkCurrentTabChangedWithFade()local t=self._components[self._currentComponentKey]local e=self._components[self._nextComponentKey]if(e==nil)then return end if(self._currentComponentKey~=self._nextComponentKey and self._animCounter:isStartTime()==true)then self:addChildComponent(e)self:_resizeCompInTabed(e);end if(self._animCounter:isFinished()==true and self._currentComponentKey~=self._nextComponentKey)then self:removeChildComponent(t)self._currentKeyStringIdx=self:_getIndexFromKeyStringIndex(self._nextComponentKey)self._currentComponentKey=self._nextComponentKey return end if(self._animCounter:isFinished()==true)then return end local a=self._animCounter:getValue()if(t~=nil)then t:setComponentAlpha(1-a)e:setComponentAlpha(a)else e:setComponentAlpha(1)end self:_syncButtonColor()end function e:_addButton(e)local t=createButton(e)t:addMouseReleaseFunction(function(t,t)self:changeTab(e)end)self._buttons[e]=t self:addChildComponent(self._buttons[e])end function e:_removeButton(e)self:removeChildComponent(self._buttons[e])self._buttons[e]=nil end function e:_getButtonAreaHeight()return math.min(self.h/10,40);end function e:_resizeCompInTabed(a)if(a~=nil)then local t=self:_getButtonAreaHeight();local e=createRectangle()e.x=self.x e.y=self.y+t e.w=self.w e.h=self.h-t local t=3 local t=3 a:setBoundsFromRect(e)end end function e:_resizeButtonComp()self._buttonArea=self:getRectangle();self._buttonArea:setHeight(self:_getButtonAreaHeight())local i=self._buttonMargin[1]local s=self._buttonMargin[2]local n=self._buttonMargin[3]local a=self._buttonMargin[4]local o=self:getTabCount()local e=createRectangle()e.x=self.x e.y=self.y e.w=self.w/o e.h=self._buttonArea:getHeight()for h,t in ipairs(self._keyStringList)do local t=self._buttons[t]t:setBoundsFromRect(e)if(o==h)then t:reduce_2(i,s,n,a)else t:reduce_2(i,0,n,a)end e.x=e.x+e.w end end function e:_syncButtonColor()local a=self:getColorAsTable("currentTabButton_background")local i=self:getColorAsTable("tabButton_backGround")local o=self:getColorAsTable("tabButton_backGround_onMouse")local e=self._buttons[self._nextComponentKey]if(e~=nil)then local t=self._buttons[self._currentComponentKey]if(t~=nil)then t:setColor("background",i);t:setColor("background_onMouse",o);end e:setColor("background",a);e:setColor("background_onMouse",a);end end function e:_addKeyToKeyStringList(e)local t=false for o,a in ipairs(self._keyStringList)do if(a==e)then t=true break end end if(t==false)then table.insert(self._keyStringList,e);end end function e:_removeKeyFromKeyStringList(t)for e,a in ipairs(self._keyStringList)do if(a==t)then table.remove(self._keyStringList,e)break end end end function e:_getIndexFromKeyStringIndex(o)local e=1 for a,t in ipairs(self._keyStringList)do if(t==o)then e=a break end end return e end return e end function createSlider(t,o,i,a,e)local e=createComponent(t,o,i,a,e)e.value=.5 e._valueChangeFuncTable={}e.label=t..":";e._meterValueRect=createRectangle()e.maxValue=1 e.minValue=0 e:setColor("text",{0,0,0,1})e:setColor("background",{1,1,1,1})e:setColor("background_onMouse",{0,1,1,1})e:setColor("meter_value",{1,.2,.2,1})e._CLASS_TYPE="Slider"e.meterType=1 function e:addOnValueChangeFunction(e)if(type(e)~="function")then return end local t=false for o,a in ipairs(self._valueChangeFuncTable)do if(a==e)then t=true end end if(t==false)then table.insert(self._valueChangeFuncTable,e)end end function e:setMaxMinValue(t,e)self.maxValue=t self.minValue=e end function e:getValue()return self.value;end function e:setValue(e,t)self.value=e local e=t or true if(self.value>self.maxValue)then self.value=self.maxValue end if(self.value<self.minValue)then self.value=self.minValue end if(e==true)then for t,e in ipairs(self._valueChangeFuncTable)do e(self)end end self:_updateMeterValueRect();end function e:setMeterType(e)self.meterType=e end function e:onResized()self:_updateMeterValueRect()end function e:onMouseMove(t,e)if(self:_isMouseDragging())then local e=self:_xyToValue(t,e)self:setValue(e)end end function e:onMouseWheel(o)if(self:isColisionMouse())then local a=self:_xyToValue(gfx.mouse_x,gfx.mouse_y)local e=self:getValue()local t=1 if(a<e)then t=-1 end e=e+(a-e)/40*o*t self:setValue(e)end end function e:onDraw(e)self:_updateMeterValueRect();self:_drawBackGround()if(self:isHorizontaleMeter())then self:_drawHorizontalMeter()elseif(self:isHorizontalCenterMeter())then self:_drawHorizontalCenterMeter()end self:_drawValueText()end function e:valueToText()return string.format("%0.2f",self.value)end function e:setLabel(e)self.label=e;end function e:isHorizontaleMeter()return(bit32.band(self.meterType,1)~=0)end function e:isHorizontalCenterMeter()return(bit32.band(self.meterType,2)~=0)end function e:_updateMeterValueRect()self._meterValueRect=self:getRectangle()self._meterValueRect:reduce(2,2);if(self:isHorizontaleMeter())then self._meterValueRect.w=self._meterValueRect.w*self.value elseif(self:isHorizontalCenterMeter())then local e=19 local t=self._meterValueRect.w*self.value self._meterValueRect.x=t-e/4 self._meterValueRect.w=e if(self._meterValueRect.x<self.x)then self._meterValueRect.x=self.x+2;end if(self._meterValueRect:getX2()>self:getX2()-2)then self._meterValueRect.w=self:getX2()-self._meterValueRect.x-2;end end self._meterValueRect:_updateXyTable();end function e:_drawBackGround()if(self:isColisionMouse())then gfx.set(self:getColor("background_onMouse"))else gfx.set(self:getColor("background"))end gfx.rect(self.x,self.y,self.w,self.h,true)end function e:_drawValueText()gfx.set(self:getColor("text"))local a=self:getCenterPoint();local t=gfx.texth;local e=self.label..self:valueToText()local o=#e gfx.x=a.x-(t/2)*(o/2)gfx.y=a.y-t/2 gfx.drawstr(e)end function e:_drawHorizontalMeter()gfx.set(self:getColor("meter_value"))gfx.setfont(1,self._fontName,self._fontSize)local e=self._meterValueRect gfx.rect(e.x,e.y,e.w,e.h,true)end function e:_drawHorizontalCenterMeter()gfx.set(self:getColor("meter_value"))gfx.setfont(1,self._fontName,self._fontSize)local e=self._meterValueRect gfx.rect(e.x,e.y,e.w,e.h,true)local e=self:getCenterPoint()gfx.set(self:getColor("black"))gfx.line(e.x,self.y,e.x,self:getY2())self:_drawValueText()end function e:_xyToValue(t,e)local e=0 if(self:isHorizontaleMeter())then local t=t-self.x local t=t/self.w e=t*self.maxValue end if(self:isHorizontalCenterMeter())then local t=t-self.x local t=t/self.w e=t*self.maxValue;end return e end return e;end function createTextPanel(e)local e=createComponent(e,x,y,w,h)e.offsetY=0 e.drawTexts={}e:setColor("text",{0,0,0,1})e:setColor("background",{1,1,1,1})e._marginX=10 e._marginY=10 e._CLASS_TYPE="TextPanel"e._AlIGN_CENTOR_=false;function e:setTextMargin(e,t)self._marginX=e self._marginY=t end function e:setDrawTextsAsCopy(e)self.drawTexts=deepcopy(e)end function e:setTextOffsetLine(e)self.offsetY=e;if(self.offsetY<0)then self.offsetY=0;end if(self.offsetY>#self.drawTexts-1)then self.offsetY=#self.drawTexts-1;end end function e:tryTextShown(e)if(self:_checkNeedOffsetOption())then for t,a in ipairs(self.drawTexts)do if(a==e)then self:setTextOffsetLine(t-1)break;end end else self:setTextOffsetLine(0);end end function e:setDrawTexts(e)self.drawTexts=e end function e:setCentorizeText(e)self._AlIGN_CENTOR_=e;end function e:onMouseWheel(e)if(self:isColisionMouse())then if(self:_checkNeedOffsetOption())then self:setTextOffsetLine(self.offsetY-e)else self:setTextOffsetLine(0);end end end function e:onDraw(e)gfx.set(self:getColor("background"))gfx.rect(self.x,self.y,self.w,self.h,true)gfx.setfont(1,self._fontName,self._fontSize)gfx.set(self:getColor("text"))local t=self._marginX local o=self._marginY for e=self.offsetY+1,#self.drawTexts do local a=self.x+t local t=self.y+gfx.texth*(e-self.offsetY-1)+o if(self._AlIGN_CENTOR_==true)then local o=#self.drawTexts[e];local o=gfx.texth/2*o;a=(self.x+self.w/2)-o/2;t=(self.y+self.h/2)-gfx.texth/2;local e=self.drawTexts[e];local e=self:_checkDrawStrSize(e,self);self:setFont("",e);end if(t>self:getY2()-o)then break;end gfx.x=a gfx.y=t gfx.drawstr(self.drawTexts[e])end end function e:_checkNeedOffsetOption()local e=(self.h-self._marginY)/self._fontSize return(e<#self.drawTexts)end function e:_checkDrawStrSize(t,e)local t=#t+1 local t=e.w/t*1.8 local e=math.max(math.min(t,e.h),20);return e;end return e end function createCursolRect(e)local e=createComponent(e,x,y,w,h)e.movingArea=createRectangle(0,0,gfx.w,gfx.h)e:setColor("background",{1,0,0,1})e:setColor("centerCircle_out",{0,0,0,1})e:setColor("centerCircle",{1,1,1,1})e._rectSize=20;e._onMovedFunction={}e._CLASS_TYPE="CursolRect"function e:addOnMovedFunction(e)if(type(e)~="function")then return end local t=false for o,a in ipairs(self._onMovedFunction)do if(a==e)then t=true end end if(t==false)then table.insert(self._onMovedFunction,e)end end function e:setMovingArea(e)self.movingArea=e end function e:setRectSize(e)self._rectSize=e;self:setWidth(self._rectSize)self:setHeight(self._rectSize)end function e:onDraw(e)local e=self:getCenterPoint();local t=self.w/2 gfx.set(self:getColor("centerCircle_out"))gfx.circle(e.x,e.y-1,t,true)t=self.w/2*.7 gfx.set(self:getColor("centerCircle"))gfx.circle(e.x,e.y-1,t,true)end function e:onMouseMove(t,e)if(self:_isMouseDragging())then self:setX(t-self.w/2)self:setY(e-self.h/2)self:_checkMovingArea();for t,e in ipairs(self._onMovedFunction)do e(self)end end end function e:_checkMovingArea()local e=self.movingArea:getX()local t=self.movingArea:getX2()-self._rectSize local a=self.movingArea:getY()local o=self.movingArea:getY2()-self._rectSize if(self.x>t)then self:setX(t);end if(self.x<e)then self:setX(e);end if(self.y>o)then self:setY(o);end if(self.y<a)then self:setY(a);end end return e end function createXYSlider(e)local e=createComponent(e,x,y,w,h)e._editCursolRect=nil e._editCursolSize=18 e._gridDiv=4 e._labelTable={"A","B","C","D"}e._labelFontSize=24;e._lastXValue=.5 e._lastYValue=.5 e:setColor("background",{1,1,1,1})e:setColor("background_grid",{0,0,0,1})e:setColor("background_grid2",{0,0,0,.3})e:setColor("cursolRectColor",{1,0,0,1})e:setColor("text",{0,0,0,1})e._onValueChangedFunction={}e._CLASS_TYPE="XYSlider"function e:addOnValueChangeFunction(e)if(type(e)~="function")then return end local t=false for o,a in ipairs(self._onValueChangedFunction)do if(a==e)then t=true end end if(t==false)then table.insert(self._onValueChangedFunction,e)end end function e:setLabelTable(e)self._labelTable=e;end function e:getXValue()local t=self._editCursolRect:getCenterPoint()local e=self:getRectangle()e:reduce(self._editCursolSize/2,self._editCursolSize/2)local e=(t.x-e.x)/e.w return e end function e:getYValue()local t=self._editCursolRect:getCenterPoint()local e=self:getRectangle()e:reduce(self._editCursolSize/2,self._editCursolSize/2)local e=(t.y-e.y)/e.h return e end function e:setCursolColor(e)self._editCursolRect:setColor("centerCircle",e)end function e:onResized()self:_updateEditoCursolRect()end function e:onDraw(e)self:_drawBackGround()self:_drawBackgroundGrid()self:_drawEditCursolRectBorder()end function e:onDraw2(e)self:_drawValueInfo()self:_drawLabels()self._lastXValue=self:getXValue()self._lastYValue=self:getYValue()end function e:_init()self._editCursolRect=createCursolRect("editCursolRect");self._editCursolRect:setRectSize(self._editCursolSize);self:addChildComponent(self._editCursolRect)self._editCursolRect:addOnMovedFunction(function(e)self:_valueChanged()end)end function e:_updateEditoCursolRect()local e=self:getRectangle()e:reduce(self._editCursolSize/2,self._editCursolSize/2)local t=e.x+(e.w*self._lastXValue)local e=e.y+(e.h*self._lastYValue)t=t-self._editCursolRect.w/2 e=e-self._editCursolRect.h/2 self._editCursolRect:setX(t)self._editCursolRect:setY(e)self._editCursolRect:setMovingArea(self:getRectangle())end function e:_drawBackGround()gfx.set(self:getColor("background"))gfx.rect(self.x,self.y,self.w,self.h)end function e:_drawBackgroundGrid()gfx.set(self:getColor("background_grid"))local e=self:getCenterPoint();gfx.line(self.x,e.y,self:getX2(),e.y)gfx.line(e.x,self.y,e.x,self:getY2())local t=self._gridDiv local o=self.w/t local a=self.h/t gfx.set(self:getColor("background_grid2"))for e=1,t do local t=self.x+o*e local e=self.y+a*e gfx.line(t,self.y,t,self:getY2())gfx.line(self.x,e,self:getX2(),e)end gfx.set(self:getColor("black"))gfx.circle(e.x,e.y-1,2,true)end function e:_drawEditCursolRectBorder()local e=self._editCursolRect:getCenterPoint()gfx.set(self:getColor("background_grid"))gfx.line(self.x,e.y,self:getX2(),e.y)gfx.line(e.x,self.y,e.x,self:getY2())end function e:_drawValueInfo()gfx.set(self:getColor("text"))gfx.setfont(1,self._fontName,self._fontSize)local e=self:getXValue()local t=self:getYValue()local t=string.format("X %1.2f \nY %1.2f",e,t)local e=self:getCenterPoint()gfx.x=e.x+gfx.texth/2 gfx.y=e.y+gfx.texth/2 gfx.drawstr(t)end function e:_drawLabels()gfx.set(self:getColor("text"))gfx.setfont(1,self._fontName,self._labelFontSize)gfx.x=self.x+gfx.texth/2/2 gfx.y=self.y gfx.drawstr(self._labelTable[1])gfx.x=self:getX2()-gfx.texth*.5-gfx.texth*#self._labelTable[2]/2 gfx.y=self.y gfx.drawstr(self._labelTable[2])gfx.x=self:getX2()-gfx.texth*.5-gfx.texth*#self._labelTable[3]/2 gfx.y=self:getY2()-gfx.texth gfx.drawstr(self._labelTable[3])gfx.x=self.x+gfx.texth/2/2 gfx.y=self:getY2()-gfx.texth gfx.drawstr(self._labelTable[4])gfx.setfont(1,self._fontName,self._fontSize)end function e:_valueChanged()for t,e in ipairs(self._onValueChangedFunction)do e(self)end end e:_init();return e;end
local n=true local o=false local h=180 local r=-60 local i=1 local t=7 local s="Courier New bold"DEFINE_WEEKDAYNAME={"Sun","Mon","Tue","Wed","Thu","Fri","Sat",}if(package.config:sub(1,1)=="\\")then else end function createClockComponent(a,e,n,l,d)local e=createComponent(a,e,n,l,d)e._animTime=0;function e:onResized()end function e:onDraw(e)if(o)then self:_drawBackground()end self:_drwaClock()self:_checkAnimTime(e,5)end function e:_init()end function e:_drawBackground()local e=t;local a=self.w/e local t=1/e;for t=1,e do local i,e,o=HSVToRGB(h+r*(t/e),1,i)gfx.set(i/255,e/255,o/255,1*self._componentAlpha)gfx.rect(a*(t-1)-1,self.y,a+1,self.h,true)end end function e:_checkAnimTime(t,e)self._animTime=self._animTime+(t/e);if(self._animTime>1)then self._animTime=0;end if(self._animTime<0)then self._animTime=0;end end function e:_drwaClock()local t=DEFINE_WEEKDAYNAME[tonumber(os.date("%w"))+1]local t=os.date("%Y/%m/%d("..t..") %H:%M:%S")local a=#t+1 local i=self.w/a*1.8 local i=math.max(math.min(i,self.h),20);gfx.setfont(1,s,i)if(o==false)then gfx.set(self:getColor("white"))else gfx.set(self:getColor("black"))end local o=(a)*gfx.texth/2 local a=self:getCenterPoint()gfx.y=a.y-gfx.texth/2 gfx.x=a.x-o/2-gfx.texth/4 gfx.drawstr(t)end e:_init()return e;end local function t()local e=createApp("Clock",450,100);local t=createClockComponent("panel");e:addChildComponent(t);if(n)then e:toggleDock()end e:runLoop()end if(_INCLUDE_MODE_~=true)then t()end
