--====================================================================== 
--[[ 
* ReaScript Name: kawa_GUI_GonioMeter_EX_Single. 
* Version: 2016/06/15 
* Author: kawa_ 
* Author URI: http://forum.cockos.com/member.php?u=105939 
* Repository: GitHub 
* Repository URI: https://github.com/kawaCat/ReaScript-MidiPack 
--]] 
--====================================================================== 

--====================================================================
local DEFINE_LOADING_FX_NAME = "JS: Goniometer_EX" ;
--====================================================================
-- options
--====================================================================
local DEFINE_BACKGROUND_COLOR_HUE = 0 -- 0~ 360 ( 0 ==red, 120 == Green,240 == blue)
local DEFINE_BACKGROUND_COLOR_HUE_WIDTH = 60 -- color width(-360~360)
local DEFINE_BACKGROUND_COLOR_SATURATION = 0.6 -- 0.0 ~1.0
local DEFINE_BACKGROUND_COLOR_BRIGHTNESS = 0.8 -- 0.0 ~1.0
--====================================================================
-- waveline thickness and color
--====================================================================
local WaveThickNess_  = 1; -- 1~10; -- waveline thickness
local WaveColor_Red   = 1.0; -- 0.0~1.0
local WaveColor_Green = 1.0; --
local WaveColor_Blue  = 1.0; --
local WaveColor_Alpha = 0.6; --
--====================================================================
-- direction ingicator thickness and color
--====================================================================
local DirectionThickNess_  = 1; -- 1~10; -- waveline thickness
local DirectionColor_Red   = 0.0; -- 0.0~1.0
local DirectionColor_Green = 0.0; --
local DirectionColor_Blue  = 1.0; --
local DirectionColor_Alpha = 1.0; --
--====================================================================
local DirectionSmoozeValue_1 = 10; -- Direction line smooze Value ( not zero )
--local DirectionSmoozeValue_2 = 30; -- Direction Circle smooze Value ( not zero )
--====================================================================
local DEFINE_BUFFER_NUM = 64 ; -- 256,512,1024,2048, -- on Start bbuffer num

--====================================================================
--_DBG_ =true
--====================================================================

-- for debug
--====================================================================
if ( _DBG_ == true )
then
    --================================================================
    dofile(reaper.GetResourcePath().."\\Scripts\\ReaScript_MIDI\\_kawa_DBG.lua")
    --================================================================
else
    function DBG()end
end
--====================================================================

--====================================================================
math.randomseed(reaper.time_precise()*os.time()/1000);
--====================================================================
-- util
--====================================================================
function HSVToRGB (hue_, saturation_ , value) --hue_: 0~360 ,saturation_:0.0~1.0 value: 0.0~1.0 brightness ,return 255/..
    --================================================================
    local r,g,b,h,f,v,p,q,t
    local hue = hue_
    local saturation =saturation_
    --================================================================
    if    (hue > 360)  then hue = hue - 360;
    elseif(hue < 0)    then hue = hue + 360;  end
    --================================================================
    if     (saturation > 1)  then saturation = 1.0;
    elseif ( saturation < 0) then saturation = 0.0; end
    --================================================================
    v = math.floor( 255 * value)
    --================================================================
    if    (v > 255)then v = 255;
    elseif(v < 0)  then v = 0  ; end
    --================================================================
    if(saturation == 0)
    then
        r = v ; g = v; b = v;
    else
        --============================================================
        h = math.floor( hue / 60)
        f = hue / 60-h
        p = math.floor( v * (1-saturation))
        --============================================================
        if    ( p < 0)  then p = 0;
        elseif( p > 255)then p = 255; end
        --============================================================
        q = math.floor( v * (1-f * saturation))
        --============================================================
        if    ( q < 0 )  then  q = 0;
        elseif( q > 255 )then  q = 255;  end
        --============================================================
        t=math.floor( v * (1-(1-f) * saturation))
        --============================================================
        if    ( t < 0 )  then t = 0;
        elseif( t > 255 )then t = 55; end
        --============================================================
        if     (h==0)then r=v;g=t;b=p;
        elseif (h==1)then r=q;g=v;b=p;
        elseif (h==2)then r=p;g=v;b=t;
        elseif (h==3)then r=p;g=q;b=v;
        elseif (h==4)then r=t;g=p;b=v;
        elseif (h==5)then r=v;g=p;b=q;
        else              r=v;g=t;b=p;
        end
        --============================================================
    end
    --================================================================
    return r,g,b
end
--====================================================================
function RGBToHSV(r,g,b)
    r,g,b = r/255,g/255,b/255 ;
    local max,min =math.max(r,g,b),math.min(r,g,b)
    local h,s,l=0,0,0
    --================================================================
    -- brightness
    l = m(max+min)/2
    --================================================================
    if ( max ==min )
    then
        h,s = 0,0
    else
        local d = max - min
        local s =0
        --============================================================
        --saturation
        if (l >0.5)then s =d/(2-max-min); else s=d/(max+min); end
        --============================================================
        if ( max == r )then
            h =( g - b ) /d
            --========================================================
            if ( g < b) then h = h+6; end
            --========================================================
        elseif( max == g ) then  h =( b - r ) / d + 2
        elseif( max == b ) then  h =( r - g ) / d + 4
        end
        --============================================================
        h = h / 6
    end
    --================================================================
    return h*360 ,s,l
    --================================================================
end
--====================================================================
function rotPoint(ox,oy,x,y,angleRad) -- originX ,originY,x,y,angleRadian
    local lx = x -ox
    local ly = y -oy
    local px = lx * math.cos(angleRad) - ly *math.sin(angleRad)
    local py = lx * math.sin(angleRad) + ly *math.cos(angleRad)
    local rotX = ox+px
    local rotY = oy+py
    return rotX,rotY
end
--====================================================================
-- from http://lua-users.org/wiki/CopyTable
--====================================================================
function deepcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[deepcopy(orig_key)] = deepcopy(orig_value)
        end
        setmetatable(copy, deepcopy(getmetatable(orig)))
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end
--====================================================================
-- from http://lua-users.org/wiki/SaveTableToFile (mod)
--====================================================================
function table.toString(tbl)
    --================================================================
    local function exportstring( s )
        return string.format("%q", s)
    end
    --================================================================
    local outStr ="";
    local function _addStr(str)outStr = outStr .. str end;
    --================================================================
    local charS,charE = "   ","\n"
    --================================================================
    -- initiate variables for save procedure
    local tables,lookup = { tbl },{ [tbl] = 1 }
    --================================================================
    _addStr( "return {"..charE )
    --================================================================
    for idx,t in ipairs( tables )
    do
        _addStr( "-- Table: {"..idx.."}"..charE )
        _addStr( "{"..charE )
        --============================================================
        local thandled = {}
        --============================================================
        for i,v in ipairs( t )
        do
            thandled[i] = true
            local stype = type( v )
            --========================================================
            -- only handle value
            --========================================================
            if stype == "table"
            then
                if not lookup[v]
                then
                    table.insert( tables, v )
                    lookup[v] = #tables
                end
                --====================================================
                _addStr( charS.."{"..lookup[v].."},"..charE )
            elseif stype == "string"
            then
                _addStr(  charS..exportstring( v )..","..charE )
            elseif stype == "number"
            then
                _addStr(  charS..tostring( v )..","..charE )
            end
        end
        --============================================================
        for i,v in pairs( t )
        do
            -- escape handled values
            if (not thandled[i])
            then
                --====================================================
                local str = ""
                local stype = type( i )
                -- handle index
                if stype == "table"
                then
                    if not lookup[i]
                    then
                        table.insert( tables,i )
                        lookup[i] = #tables
                    end
                    str = charS.."[{"..lookup[i].."}]="
                elseif stype == "string"
                then
                    str = charS.."["..exportstring( i ).."]="
                elseif stype == "number"
                then
                    str = charS.."["..tostring( i ).."]="
                end
                --====================================================
                if (str ~= ""  )
                then
                    stype = type( v )
                    -- handle value
                end
                --====================================================
                if stype == "table"
                then
                    if not lookup[v] then
                        table.insert( tables,v )
                        lookup[v] = #tables
                    end
                    _addStr( str.."{"..lookup[v].."},"..charE )
                elseif stype == "string"
                then
                    _addStr( str..exportstring( v )..","..charE )
                elseif stype == "number"
                then
                    _addStr( str..tostring( v )..","..charE )
                elseif stype =="boolean"
                then
                    _addStr( str..tostring( v )..","..charE )
                end
                --====================================================
            end
        end
        --============================================================
        _addStr( "},"..charE )
    end
    --================================================================
    _addStr( "}" )
    --================================================================
    return outStr;
end
--====================================================================
function table.fromString( str )
    --================================================================
    local ftables = load(str); -- load str as function
    --================================================================
    local tables = ftables() --
    --================================================================
    if ( type ( tables) ~= "table")
    then
        local out = {} -- empty table
        return out -- {}
    end
    --================================================================
    for idx = 1,#tables
    do
        local tolinki = {}
        --============================================================
        for i,v in pairs( tables[idx] )
        do
            if type( v ) == "table"
            then
                tables[idx][i] = tables[v[1]]
            end
            if type( i ) == "table" and tables[i[1]]
            then
                table.insert( tolinki,{ i,tables[i[1]] } )
            end
        end
        --============================================================
        -- link indices
        for _,v in ipairs( tolinki )
        do
            tables[idx][v[2]],tables[idx][v[1]] =  tables[idx][v[1]],nil
        end
        --============================================================
    end
    --================================================================
    return tables[1]
end
--====================================================================

--====================================================================
-- main App
--====================================================================
function createApp(titleStr,width,height)
    --================================================================
    local App ={}
    --================================================================
    App._lastTime = os.clock();
    App._lastMouseCap = nil
    App._lastMouseX = 0
    App._lastMouseY = 0
    App._lastMouseWheel = 0
    App.mouseWheelDt = 0;
    App._childComponent ={}
    App._lastMouseLeftDown = false
    App._lastMouseRightDown = false
    App.width  = width  or 380 ;
    App.height = height or 500;
    App.title = titleStr or "app"
    --================================================================
    App._CLASS_TYPE = "App"
    --================================================================
    function App:addChildComponent( component_) -- as top level component
        --============================================================
        local isDouble = false;
        --============================================================
        for i,v in ipairs ( self._childComponent)
        do
            if ( v == component_)
            then
                isDouble =true;
                break;
            end
        end
        --============================================================
        if ( isDouble == false)
        then
            component_:setBounds(0,0,self.width,self.height)
            table.insert (self._childComponent, component_)
        end
        --============================================================
    end
    --================================================================
    function App:resized()
        --============================================================
        self.width  = gfx.w
        self.height = gfx.h
        --============================================================
        for i,v in ipairs ( self._childComponent)
        do
            -- top Level component
            v:setBounds(0,0,self.width,self.height)
        end
        --============================================================
    end
    --================================================================
    function App:onMouseMove(mouse_ox,mouse_oy)
        --============================================================
        for i,v in ipairs ( self._childComponent)
        do
            if ( v._MouseMove ~= nil)
            then
                v:_MouseMove(mouse_ox,mouse_oy)
            end
        end
        --============================================================
    end
    --================================================================
    function App:onMousePress(mouseCap)
        --============================================================
        for i,v in ipairs ( self._childComponent)
        do
            if ( v._MousePress ~= nil)
            then
                v:_MousePress(mouseCap)
            end
        end
        --============================================================
    end
    --================================================================
    function App:onMouseRelease(mouseCap)
        --============================================================
        for i,v in ipairs ( self._childComponent)
        do
            if ( v._MouseRelease ~= nil)
            then
                v:_MouseRelease(mouseCap)
            end
        end
        --============================================================
    end
    --================================================================
    function App:onMouseWheel(wheel_Y_dt)
        --============================================================
        for i,v in ipairs ( self._childComponent)
        do
            if ( v._MouseWheel ~= nil)
            then
                v:_MouseWheel(wheel_Y_dt)
            end
        end
        --============================================================
    end
    --================================================================
    function App:onDraw(deltaTime)
        --============================================================
        for i,v in ipairs ( self._childComponent)
        do
            --========================================================
            if ( v._Draw ~= nil)
            then
                v:_Draw(deltaTime)
            end
        end
        --============================================================
    end
    --================================================================
    function App:runLoop()
        --============================================================
        local dt = os.clock() - self._lastTime;
        --============================================================
        gfx.update();
        --============================================================
        if (   self.width  ~= gfx.w
            or self.height ~= gfx.h)
        then
            self:resized();
        end
        --============================================================
        if (   self._lastMouseX ~= gfx.mouse_x
            or self._lastMouseY ~= gfx.mouse_y  )
        then
            self:onMouseMove(self._lastMouseX,self._lastMouseY)
        end
        --============================================================
        gfx.set(1,1,1,1) --color reset
        --============================================================
        self:onDraw(dt);
        --============================================================

        --============================================================
        if (  self._lastMouseCap ~= gfx.mouse_cap )
        then
            --========================================================
            if ( self._lastMouseCap < gfx.mouse_cap
                and (   gfx.mouse_cap&1 ==1
                     or gfx.mouse_cap&2 ==2
                     or gfx.mouse_cap&64 ==64 )
                )
            then
                self:onMousePress(gfx.mouse_cap)
            else
                self:onMouseRelease(gfx.mouse_cap)
            end
            --========================================================
        end
        --============================================================
        if (self._lastMouseWheel ~= gfx.mouse_wheel)
        then
            if (self._lastMouseWheel <gfx.mouse_wheel)
            then
                self.mouseWheelDt = 1
            else
                self.mouseWheelDt = -1
            end
            self:onMouseWheel(self.mouseWheelDt )
        else
            self.mouseWheelDt  =0;
            gfx.mouse_wheel = 0;
        end
        --============================================================

        --============================================================
        if ( gfx.getchar() >= 0 )
        then
            reaper.defer( function () self:runLoop() end )
        end
        --============================================================

        --============================================================
        self:_storeGfxInfo(); --store as last value
        --============================================================
    end
    --================================================================
    function App:toggleDock()
        -- is Docked ?
        if ( gfx.dock(-1) == 1.0)
        then
            gfx.dock(0) -- undock
        else
            gfx.dock(1) -- to dock
        end
    end
    --================================================================
    function App:isDock()
        local out = false
        --============================================================
        if ( gfx.dock(-1) == 1.0) then  out = true; end
        --============================================================
        return out;
    end
    --================================================================
    function App:changeWindowSize(width,height)
        self.width = width
        self.height = height
        gfx.quit()
        --============================================================

        --============================================================
        self:_init()
        self:resized()
        --runloop.??
    end
    --================================================================

    --================================================================
    -- private
    --================================================================
    function App:_init()
        --============================================================
        local gui = {}
        --============================================================
        -- from http://forum.cockos.com/showthread.php?t=161557
        --============================================================
        -- Add stuff to "gui" table
        --============================================================
        gui.settings = {}                 -- Add "settings" table to "gui" table
        gui.settings.font_size = 20       -- font size
        gui.settings.docker_id = 0        -- try 0, 1, 257, 513, 1027 etc.
        --============================================================
        -- Initialize gfx window --
        --============================================================
        gfx.init(self.title, self.width, self.height, gui.settings.docker_id)
        gfx.setfont(1,"Arial", gui.settings.font_size)
        gfx.clear = 3355443  -- matches with "FUSION: Pro&Clean Theme :: BETA 01" http://forum.cockos.com/showthread.php?t=155329
        --============================================================
        self:_storeGfxInfo()
        --============================================================
    end
    --================================================================
    function App:_storeGfxInfo()
        --============================================================
        self._lastMouseX = gfx.mouse_x;
        self._lastMouseY = gfx.mouse_y;
        self._lastMouseWheel =  gfx.mouse_wheel;
        self._lastTime = os.clock();
        --============================================================
        self._lastMouseLeftDown  = (gfx.mouse_cap&0x01 == 0x01)
        self._lastMouseRightDown = (gfx.mouse_cap&0x02 == 0x02)
        self._lastMouseCap  = gfx.mouse_cap
        --============================================================
        self.width  = gfx.w;
        self.height = gfx.h;
        --============================================================
    end
    --================================================================
    App:_init()
    --================================================================
    return App;
    --================================================================
end
--====================================================================

--====================================================================
-- Rectangle
--====================================================================
function createRectangle(x,y,width,height)
    --================================================================
    local Rectangle ={}
    --================================================================
    Rectangle.x = x or 0
    Rectangle.y = y or 0
    Rectangle.w = width or 100
    Rectangle.h = height or 100
    Rectangle._xyTable ={}
    Rectangle._cpoint = {};
    Rectangle._CLASS_TYPE = "Rectangle"
    --================================================================
    function Rectangle:getX()          return self.x;end
    function Rectangle:getY()          return self.y;end
    function Rectangle:getX2()         return self.x +self.w;end
    function Rectangle:getY2()         return self.y +self.h;end
    function Rectangle:getWidth()      return self.w;end
    function Rectangle:getHeight()     return self.h;end
    function Rectangle:getCenterPoint()return self._cpoint; end
    --================================================================
    function Rectangle:getRectangle()
        return createRectangle(self.x,self.y,self.w,self.h)
    end
    --================================================================
    function Rectangle:setX(val)     self.x=val;self:_updateXyTable();end
    function Rectangle:setY(val)     self.y=val;self:_updateXyTable();end
    function Rectangle:setWidth(val) self.w=val;self:_updateXyTable();end
    function Rectangle:setHeight(val)self.h=val;self:_updateXyTable();end
    --================================================================
    function Rectangle:setBounds(x,y,w,h)
        self.x = x ;
        self.y = y ;
        self.w = w ;
        self.h = h ;
        --============================================================
        self:_updateXyTable();
        --============================================================
    end
    --================================================================
    function Rectangle:setBoundsFromRect(rectangle)
        self.x = rectangle.x ;
        self.y = rectangle.y ;
        self.w = rectangle.w ;
        self.h = rectangle.h ;
        --============================================================
        self:_updateXyTable();
        --============================================================
    end
    --================================================================
    function Rectangle:isContact(ox,oy) -- is contact point
        --============================================================
        local cnt = 0
        --============================================================
        local xyTable = self._xyTable;
        --============================================================
        for i=1,#xyTable,1
        do
            local next =i+1
            --========================================================
            if ( i+1 >#xyTable ) then next =1 end
            local x1 = xyTable[next].x - xyTable[i].x;
            local y1 = xyTable[next].y - xyTable[i].y;
            local x2 = ox - xyTable[i].x;
            local y2 = oy - xyTable[i].y;
            --========================================================
            if (x1 * y2 - x2 * y1 < 0)
            then
                cnt = cnt+1
            else
                cnt = cnt-1
            end
            --========================================================
        end
        --============================================================
        if (cnt <=-#xyTable or cnt >= #xyTable)
        then
            return true
        end
        --============================================================
        return false
    end
    --================================================================
    function Rectangle:isColisionMouse()
        return self:isContact(gfx.mouse_x,gfx.mouse_y );
    end
    --================================================================
    function Rectangle:reduce(rx,ry)--reduce size to center
        self.x = (self.x +rx);
        self.y = (self.y +ry);
        self.w = (self.w -rx*2);
        self.h = (self.h -ry*2);
        --============================================================
        self:_updateXyTable();
    end
    --================================================================
    function Rectangle:reduce_2(l,r,t,b)--reduce size to center
        self.x = (self.x +l);
        self.y = (self.y +t);
        self.w = (self.w -l -r );
        self.h = (self.h -t -b );
        --============================================================
        self:_updateXyTable();
    end
    --================================================================
    function Rectangle:expand(ex,ey)
        self.x = self.x -ex;
        self.y = self.y -ey;
        self.w = self.w +ex*2;
        self.h = self.h +ey*2;
        --============================================================
        self:_updateXyTable();
    end
    --================================================================
    function Rectangle:resized() end -- = 0 -- virtual
    --================================================================
    function Rectangle:_updateXyTable() -- x1,y1, x2,y2, x3,y3, x4,y4
        --============================================================
        self._xyTable ={}
        --============================================================
        self._xyTable[1] = {x=self.x       ,y=self.y}
        self._xyTable[2] = {x=self.x+self.w,y=self.y}
        self._xyTable[3] = {x=self.x+self.w,y=self.y+self.h}
        self._xyTable[4] = {x=self.x       ,y=self.y+self.h}
        --============================================================
        self._cpoint = {x=self.x+self.w/2 ,y=self.y+self.h/2};
        --============================================================
        self:resized();
    end
    --================================================================
    --
    --================================================================
    Rectangle:_updateXyTable();
    --================================================================
    return Rectangle;
    --================================================================
end
--====================================================================

--====================================================================
-- Component
--====================================================================
function createComponent(componentName,x,y,w,h)
    --================================================================
    local Component = createRectangle(x,y,w,h)
    Component.name  = componentName or ""
    Component._childComponentTable = {} -- to do
    Component._parentComponent = nil
    Component._isMousePressing = false
    --================================================================
    Component._fontName = "Courier New bold" --monospace
    Component._fontSize = 20
    Component.isMouseLeftDown = false
    Component.isMouseRightDown = false
    Component.isMouseMiddleDown = false
    Component.isStartInMouseDown = false
    --================================================================
    Component._componentAlpha = 1
    Component._colors = {} -- like map
    Component._colors["white"] = {1,1,1,1} -- r,g,b,a
    Component._colors["black"] = {0,0,0,1} -- r,g,b,a
    --================================================================
    Component._CLASS_TYPE = "Component"
    --================================================================
    function Component:setComponentAlpha(newAlpha)--0.0~1.0
        self._componentAlpha =  newAlpha
        --============================================================
        for i,v in ipairs ( self._childComponentTable)
        do
            v:setComponentAlpha(newAlpha)
        end
        --============================================================
    end
    --================================================================
    function Component:setColor(colorIDStr,colorTable) --colorTable
        self._colors[colorIDStr] = colorTable;
    end
    --================================================================
    function Component:getColor(colorIDStr)
        --============================================================
        if ( self._colors[colorIDStr]== nil ) then return 1,1,1,1* self._componentAlpha end
        --============================================================
        local r = self._colors[colorIDStr][1] or 1
        local g = self._colors[colorIDStr][2] or 1
        local b = self._colors[colorIDStr][3] or 1
        local a = self._colors[colorIDStr][4] or 1
        --============================================================
        a = a * self._componentAlpha
        return r,g,b,a
    end
    --================================================================
    function Component:getColorAsTable(colorIDStr)
        --============================================================
        local r,g,b,a = self:getColor(colorIDStr)
        return {r,g,b,a}
        --============================================================
    end
    --================================================================
    function Component:setFont(fontName,newFontSize)
        if (fontName ~= "" and fontName ~=nil )
        then
            self._fontName = fontName
        end
        self._fontSize = newFontSize
    end
    --================================================================
    function Component:getName() return self.name ;end
    --================================================================
    function Component:setName(name) self.name = name ;end
    --================================================================
    function Component:getParrent() --return nil or parrent
        return self._parentComponent;
    end
    --================================================================
    function Component:addChildComponent(child)
        --============================================================
        if( child ==nil )then return end
        --============================================================
        local isDouble = false;
        --============================================================
        for i,v in ipairs ( self._childComponentTable)
        do
            if ( v == child)
            then
                isDouble =true;
                break;
            end
        end
        --============================================================
        if ( isDouble == false)
        then
            child._parentComponent = self;
            table.insert (self._childComponentTable, child)
        else
            DBG("cant add component." .. child.name .."// check same component.")
        end
        --============================================================
    end
    --================================================================
    function Component:removeChildComponent(child)
        --============================================================
        if( child ==nil )then return end
        --============================================================
        for i,v in ipairs ( self._childComponentTable)
        do
            if ( v == child)
            then
                v._parentComponent =nil;
                table.remove( self._childComponentTable,i)
                break;
            end
        end
    end
    --================================================================

    --================================================================
    -- override
    --================================================================
    function Component:resized()
        --============================================================
        self:onResized()
        --============================================================
        for i,v in ipairs ( self._childComponentTable)
        do
            v:resized()
        end
        --============================================================
    end
    --================================================================

    --================================================================
    -- private
    --================================================================
    function Component:_MouseMove(mouse_ox,mouse_oy)
        --============================================================
        self:onMouseMove(mouse_ox,mouse_oy)
        --============================================================
        for i,v in ipairs ( self._childComponentTable)
        do
            v:_MouseMove(mouse_ox,mouse_oy)
        end
    end
    --================================================================
    function Component:_MousePress(mouseCap)
        --============================================================
        if ( self:isColisionMouse())
        then
            self._isMousePressing = true;
            self.isMouseLeftDown  = ( mouseCap &1 ==1)
            self.isMouseRightDown = ( mouseCap &2 ==2)
            self.isMouseMiddleDown = ( mouseCap &64 ==64)
            self.isStartInMouseDown = true
        end
        --============================================================
        self:onMousePress(mouseCap)
        --============================================================
        for i,v in ipairs ( self._childComponentTable)
        do
            if ( v:isColisionMouse())
            then
                v._isMousePressing = true
            end
            v:_MousePress(mouseCap)
        end
        --============================================================
    end
    --================================================================
    function Component:_MouseRelease(mouseCap)
        --============================================================
        if (    self._isMousePressing ==true
            and (gfx.mouse_cap&1 ~= 1) --left
            and (gfx.mouse_cap&2 ~= 1))--right
        then
            self._isMousePressing =false;
        end
        --============================================================
        self:onMouseRelease(mouseCap)
        --============================================================
        for i,v in ipairs ( self._childComponentTable)
        do
            v:_MouseRelease(mouseCap)
        end
        --============================================================
        self.isMouseLeftDown = (mouseCap  &1 ==1)
        self.isMouseRightDown = (mouseCap &2 ==2)
        self.isMouseMiddleDown = ( mouseCap &64 ==64)
        self.isStartInMouseDown = false
        --============================================================
    end
    --================================================================
    function Component:_MouseWheel(wheel_Y_dt)
        --============================================================
        self:onMouseWheel(wheel_Y_dt)
        --============================================================
        for i,v in ipairs ( self._childComponentTable)
        do
            v:_MouseWheel(wheel_Y_dt)
        end
    end
    --================================================================
    function Component:_Draw(deltaTime)
        --============================================================
        gfx.set(1,1,1,1*self._componentAlpha) --color reset
        gfx.setfont(1,self._fontName,self._fontSize) --color reset
        --============================================================
        self:onDraw(deltaTime)
        --============================================================
        for i,v in ipairs ( self._childComponentTable)
        do
            gfx.set(1,1,1,1*self._componentAlpha) --color reset
            gfx.setfont(1,v._fontName,v._fontSize) --color reset
            --========================================================
            --too font size
            v:_Draw(deltaTime)
        end
        --============================================================
        gfx.setfont(1,self._fontName,self._fontSize) --color reset
        --============================================================
        self:onDraw2(deltaTime)
        --============================================================
    end
    --================================================================
    function Component:_isMouseDragging()
        return self._isMousePressing;
    end
    --================================================================

    --================================================================
    -- virutal
    --================================================================
    function Component:onMouseMove(mouse_ox,mouse_oy) end
    function Component:onMousePress(mouseCap) end
    function Component:onMouseRelease(mouseCap) end
    function Component:onMouseWheel(wheel_Y_dt) end
    function Component:onDraw(deltaTime) end
    function Component:onDraw2(deltaTime)end --after call
    function Component:onResized() end
    --================================================================
    return Component;
    --================================================================
end
--====================================================================

--====================================================================
-- Button
--====================================================================
function createButton(compnentName,x,y,w,h)
    --================================================================
    local Button = createComponent(compnentName,x,y,w,h)
    --================================================================
    Button._mouseClickFuncTable ={}
    Button._mouseWheelFuncTable ={}
    Button._isAutoFontSizeMode =false;
    --================================================================
    Button:setColor("text",{0,0,0,1})
    Button:setColor("background",{1,1,1,1})
    Button:setColor("background_onMouse",{0,1,1,1})
    --================================================================
    Button._CLASS_TYPE = "Button"
    --================================================================
    function Button:isAutoFontSizeMode() return self._isAutoFontSizeMode;end
    --================================================================
    function Button:setAutoFontSizeMode(bool_)
        self._isAutoFontSizeMode = bool_;
    end
    --================================================================
    function Button:addMouseReleaseFunction(func) -- callback | function (button,mousecap) ~~ end |
        --============================================================
        if (type(func) ~="function" )then return end
        --============================================================
        local  isDouble =false
        for i,v in ipairs( self._mouseClickFuncTable)
        do
            if ( v ==func )
            then
                isDouble =true
            end
        end
        --============================================================
        if ( isDouble == false)
        then
           table.insert (self._mouseClickFuncTable,func)
        end
        --============================================================
    end
    --================================================================
    function Button:addMouseWheelFunction(func) -- callback | function (button,wheel_Rot) ~~ end |
        --============================================================
        if (type(func) ~="function" )then return end
        --============================================================
        local  isDouble =false
        for i,v in ipairs( self._mouseWheelFuncTable)
        do
            if ( v ==func )
            then
                isDouble =true
            end
        end
        --============================================================
        if ( isDouble == false)
        then
           table.insert (self._mouseWheelFuncTable,func)
        end
        --============================================================
    end
    --================================================================
    -- override
    --================================================================
    function Button:onMouseRelease(mouseCap)
        --============================================================
        if (    self:isColisionMouse()
            and self.isStartInMouseDown ==true)
        then
            for i,v in ipairs( self._mouseClickFuncTable)
            do
                if ( type (v) =="function")
                then
                    v (self,mouseCap)
                end
            end
        end
        --============================================================
    end
    --================================================================
    function Button:onDraw(deltaTime)
        --============================================================
        if ( self:isColisionMouse() )
        then
            gfx.set(self:getColor("background_onMouse"))
        else
            gfx.set(self:getColor("background"))
        end
        --============================================================
        gfx.rect(self.x,self.y,self.w,self.h,true)
        --============================================================
        local cpoint = self:getCenterPoint();
        local strLen = #self.name
        --============================================================
        local buttonNameFontSize = self._fontSize;
        --============================================================
        if (self:isAutoFontSizeMode())
        then
            local adustFontSize = self.w/strLen;
            buttonNameFontSize =math.min(adustFontSize,self._fontSize);
        end
        --============================================================
        gfx.set(self:getColor("text"))
        gfx.setfont(1,self._fontName, buttonNameFontSize)
        --============================================================
        gfx.x = cpoint.x -( gfx.texth/2)*(strLen/2)
        gfx.y = cpoint.y - gfx.texth/2
        gfx.drawstr(self.name)
    end
    --================================================================
    function Button:onMouseWheel(wheel_Y_dt)
        --============================================================
        if ( self:isColisionMouse())
        then
            for i,v in ipairs( self._mouseWheelFuncTable)
            do
                if ( type (v) =="function")
                then
                    v (self,wheel_Y_dt)
                end
            end
        end
        --============================================================
    end
    --================================================================
    return Button;
    --================================================================
end
--====================================================================

-- Animation Counter
--====================================================================
function createCounter(frameNum)
    local Counter ={}
    Counter.m_value =0;
    Counter.m_stepValue = 0;
    Counter.m_frameNum = frameNum or 60
    Counter._CLASS_TYPE = "Counter"
    --================================================================
    function Counter:setCounterFrame(newFrameNum)
        self.m_frameNum = newFrameNum;
        self:_calcStepValue();
    end
    --================================================================
    function Counter:setForward()
        self:_calcStepValue()
    end
    --================================================================
    function Counter:setBackward()
        self:_calcStepValue()
        self:inverse();
    end
    --================================================================
    function Counter:inverse() --togle step
        self.m_stepValue = self.m_stepValue * -1;
    end
    --================================================================
    function Counter:reset()
        self:_calcStepValue();
        self.m_value =0;
    end
    --================================================================
    function Counter:isActive()
        if (    self.m_value ~= 0.0
            and self.m_vakue ~= 1.0)
        then
            return true;
        end
        return false;
    end
    --================================================================
    function Counter:isStartTime()
       return (self:getValueWithOutStep() ==0.0)
    end
    --================================================================
    function Counter:isFinished()
        if ( self.m_stepValue > 0)
        then
            return (self.m_value >= 1.0)
        else
            return (self.m_value <= 0)
        end
    end
    --================================================================
    function Counter:getValue() --with step()
        --============================================================
        self:_step()
        --============================================================
        --return self.m_value;
        return self:_inOutCubic(self.m_value)
        --============================================================
    end
    --================================================================
    function Counter:getValueWithOutStep()
        return self.m_value;
    end
    --================================================================

    --================================================================
    -- private
    --================================================================
    function Counter:_calcStepValue()
        self.m_stepValue = 1.0 / self.m_frameNum;
    end
    --================================================================
    function Counter:_step()
        --============================================================
        if (    self.m_value ~= 1.0 and self.m_stepValue > 0
            or  self.m_value ~= 0.0 and self.m_stepValue < 0 )
        then
            self.m_value = self.m_value + self.m_stepValue;
            if ( self.m_value >= 1.0) then self.m_value = 1.0; end
            if ( self.m_value <= 0.0) then self.m_value = 0.0; end ;
        end ;
        --============================================================
    end
    --================================================================
    function Counter:_inOutCubic(t)
        t = t  * 2
        if t < 1
        then
            return 0.5 * t * t * t
        else
            t = t - 2
            return 0.5 * (t * t * t + 2)
        end
    end
    --================================================================

    --================================================================
    Counter:_calcStepValue();
    --================================================================
    return Counter;
end
--====================================================================

-- Tab Component
--====================================================================
function createTabComponent(compnentName)
    --================================================================
    local TabComponent = createComponent(compnentName)
    --================================================================
    TabComponent._nextComponentKey =""
    TabComponent._currentComponentKey =""
    --================================================================
    TabComponent._components ={}
    TabComponent._childTabComponents ={}
    TabComponent._buttons ={}
    TabComponent._keyStringList ={}
    TabComponent._currentKeyStringIdx = 0;
    --================================================================
    TabComponent:setColor("currentTabButton_background",{0.5,0.5,1,1})
    TabComponent:setColor("tabButton_backGround",{1,1,1,1})
    TabComponent:setColor("tabButton_backGround_onMouse",{0,1,1,1})
    --================================================================
    TabComponent._buttonArea = createRectangle();
    TabComponent._buttonMargin ={3,3,3,3} -- l,r,top,bottom
    TabComponent._isFadeMode = false
    --================================================================
    TabComponent._animCounter = createCounter(15) -- frame
    TabComponent._CLASS_TYPE = "TabComponent"
    --================================================================
    function TabComponent:setFadeMode(bool_)
        --============================================================
        self._isFadeMode = bool_
        --============================================================
        for key,v in pairs(self._childTabComponents)
        do
            v._isFadeMode = bool_
        end
        --============================================================
    end
    --================================================================
    function TabComponent:setButtonMargin(l,r,top,bottom)
        self._buttonMargin = {l,r,top,bottom}
    end
    --================================================================
    function TabComponent:getTabCount()
        local count = 0
        for key,v in pairs(self._components)
        do
            count =  count+1
        end
        --============================================================
        return count
    end
    --================================================================
    function TabComponent:getCurrentTabComponent()
       return  self._components[self._currentComponentKey]
    end
    --================================================================
    function TabComponent:addTab(keyStr,component)
        --============================================================
        self._components[keyStr] = component
        self:_addButton(keyStr)
        --============================================================
        self:_addKeyToKeyStringList(keyStr)
        self:_resizeButtonComp();
        self:_resizeCompInTabed(component);
        --============================================================
        if (component._CLASS_TYPE =="TabComponent" )
        then
            local isDouble =false
            for i,v in ipairs(self._childTabComponents)
            do
                component._keyStr = keyStr;
                if ( v == component)
                then
                    isDouble =true
                    break;
                end
            end
            --========================================================
            if ( isDouble==false)
            then
                table.insert (self._childTabComponents,component)
            end
        end
        --============================================================
    end
    --================================================================
    function TabComponent:removeTab(keyStr)
        --============================================================
        self._components[keyStr] = nil
        self:_removeKeyFromKeyStringList(keyStr)
        self:_removeButton(keyStr)
        self:_resizeButtonComp()
        --============================================================
        for i,v in ipairs(self._childTabComponents)
        do
            if ( v._keyStr == keyStr)
            then
                table.remove(self._childTabComponents,i );
                break;
            end
        end
        --============================================================
    end
    --================================================================
    function TabComponent:changeTab(kerStr)
        --============================================================
        if (   (   self._animCounter:isFinished() ==true
                or self._animCounter:isStartTime()==true)
            and self._nextComponentKey ~= kerStr
            and self._currentComponentKey == self._nextComponentKey )
        then
            self._nextComponentKey = kerStr
            --========================================================
            self._animCounter:reset()
            self:_resizeCompInTabed(self._components[kerStr]);
        end
        --============================================================
    end
    --================================================================
    function TabComponent:onResized()
        --============================================================
        self:_resizeButtonComp();
        --============================================================
        self:_resizeCompInTabed(self._components[self._nextComponentKey]);
        self:_resizeCompInTabed(self._components[self._currentComponentKey]);
        --============================================================
    end
    --================================================================
    function TabComponent:onDraw2(deltaTime)
        --============================================================
        if ( self._isFadeMode ==true)
        then
            self:_checkCurrentTabChangedWithFade()
        else
            self:_checkCurrentTabChanged()
        end
        --============================================================
    end
    --================================================================
    function TabComponent:onMouseWheel(wheel_Y_dt)
        --============================================================
        if ( self._buttonArea:isColisionMouse())
        then
            --========================================================
            local nextIdx = self._currentKeyStringIdx+wheel_Y_dt
            --========================================================
            if ( nextIdx <= 0)then nextIdx=#self._keyStringList end;
            if ( nextIdx > #self._keyStringList )then nextIdx=1 end ;
            --========================================================
            local nextKeyStr = self._keyStringList[nextIdx]
            --========================================================
            self:changeTab(nextKeyStr)
            --========================================================
        end
        --============================================================
    end
    --================================================================

    --================================================================
    -- private
    --================================================================
    function TabComponent:_init()
        --============================================================
    end
    --================================================================
    function TabComponent:_checkCurrentTabChanged()
        --============================================================
        if (self._currentComponentKey == self._nextComponentKey)
        then
            return
        end
        --============================================================
        local current_ = self._components[self._currentComponentKey]
        local next_ = self._components[self._nextComponentKey]
        --============================================================
        if ( next_==nil)then return end
        --============================================================
        self:_syncButtonColor()
        --============================================================
        self:removeChildComponent(current_)
        --============================================================
        self:addChildComponent(next_)
        --============================================================
        self:_resizeCompInTabed(next_);
        self._currentComponentKey = self._nextComponentKey
        --============================================================
        self._currentKeyStringIdx = self:_getIndexFromKeyStringIndex(self._nextComponentKey)
        --============================================================
    end
    --================================================================
    function TabComponent:_checkCurrentTabChangedWithFade()
        --============================================================
        local current_ = self._components[self._currentComponentKey]
        local next_ = self._components[self._nextComponentKey]
        --============================================================
        if ( next_== nil)then return end
        --============================================================
        if (     self._currentComponentKey ~= self._nextComponentKey
            and  self._animCounter:isStartTime()==true)
        then
            --========================================================
            self:addChildComponent(next_)
            self:_resizeCompInTabed(next_);
            --========================================================
        end
        --============================================================

        --============================================================
        if (    self._animCounter:isFinished() ==true
            and self._currentComponentKey ~= self._nextComponentKey)
        then
            --========================================================
            self:removeChildComponent(current_)
            self._currentKeyStringIdx = self:_getIndexFromKeyStringIndex(self._nextComponentKey)
            self._currentComponentKey = self._nextComponentKey
            --========================================================
            return
        end
        --============================================================

        --============================================================
        if ( self._animCounter:isFinished() ==true)
        then
            return
        end
        --============================================================
        local newAlpha = self._animCounter:getValue()
        --============================================================
        if (current_ ~= nil )
        then
            current_:setComponentAlpha ( 1-newAlpha)
            next_:setComponentAlpha ( newAlpha)
        else
            next_:setComponentAlpha(1.0)
        end
        --============================================================
        self:_syncButtonColor()
        --============================================================
    end
    --================================================================

    --================================================================
    function TabComponent:_addButton(keyStr)
        --============================================================
        local bt =createButton(keyStr)
        --============================================================
        bt:addMouseReleaseFunction(
            function (button,mousecaps)
                self:changeTab(keyStr)
            end
        )
        --============================================================
        self._buttons[keyStr] = bt
        --============================================================
        self:addChildComponent(self._buttons[keyStr])
        --============================================================
    end
    --================================================================
    function TabComponent:_removeButton(keyStr)
        --============================================================
        self:removeChildComponent(self._buttons[keyStr])
        --============================================================
        self._buttons[keyStr] =nil --remove
        --============================================================
    end
    --================================================================
    function TabComponent:_getButtonAreaHeight()
        return math.min(self.h/10,40);
    end
    --================================================================
    function TabComponent:_resizeCompInTabed(comp)
        --============================================================
        if ( comp ~= nil )
        then
            --========================================================
            local buttonAreaHeight = self:_getButtonAreaHeight();
            --========================================================
            local componentArea = createRectangle()
            componentArea.x = self.x
            componentArea.y = self.y + buttonAreaHeight
            componentArea.w = self.w
            componentArea.h = self.h -buttonAreaHeight
            --========================================================
            local mx = 3
            local my = 3
            comp:setBoundsFromRect(componentArea)
            --========================================================
        end
    end
    --================================================================
    function TabComponent:_resizeButtonComp()
        --============================================================
        self._buttonArea = self:getRectangle();
        self._buttonArea:setHeight(self:_getButtonAreaHeight() )
        --============================================================
        local m_l = self._buttonMargin[1]
        local m_r = self._buttonMargin[2]
        local m_t = self._buttonMargin[3]
        local m_b = self._buttonMargin[4]
        --============================================================
        local tabCount = self:getTabCount()
        --============================================================
        local buttonArea = createRectangle()
        buttonArea.x = self.x
        buttonArea.y = self.y
        buttonArea.w = self.w/tabCount
        buttonArea.h = self._buttonArea:getHeight()
        --============================================================
        for i,v in ipairs ( self._keyStringList)
        do
            local bt = self._buttons[v]
            bt:setBoundsFromRect(buttonArea)
            --========================================================
            if ( tabCount == i) --button End
            then
                bt:reduce_2(m_l,m_r,m_t,m_b)
            else
                bt:reduce_2(m_l,0,m_t,m_b)
            end
            buttonArea.x = buttonArea.x + buttonArea.w
        end
        --============================================================
    end
    --================================================================
    function TabComponent:_syncButtonColor()
        --============================================================
        local currentBt_BackColor = self:getColorAsTable("currentTabButton_background")
        local bt_backColor =  self:getColorAsTable("tabButton_backGround")
        local bt_backColor_OnMouse =  self:getColorAsTable("tabButton_backGround_onMouse")
        --============================================================
        local currentBt = self._buttons[self._nextComponentKey]
        --============================================================
        if (currentBt~=nil )
        then
            local lastBt =self._buttons[self._currentComponentKey]
            --========================================================
            if ( lastBt~= nil)
            then
                lastBt:setColor("background",bt_backColor);
                lastBt:setColor("background_onMouse",bt_backColor_OnMouse);
            end
            --========================================================
            currentBt:setColor("background",currentBt_BackColor);
            currentBt:setColor("background_onMouse",currentBt_BackColor);
            --========================================================
        end
        --============================================================
    end
    --================================================================
    function TabComponent:_addKeyToKeyStringList(keyStr)
        --============================================================
        local isDouble =false
        --============================================================
        for i,v in ipairs(self._keyStringList)
        do
            if (v == keyStr)
            then
                isDouble=true
                break
            end
        end
        --============================================================
        if ( isDouble ==false)
        then

            table.insert (self._keyStringList,keyStr);
        end
    end
    --================================================================
    function TabComponent:_removeKeyFromKeyStringList(keyStr)
        --============================================================
        for i,v in ipairs(self._keyStringList)
        do
            if (v == keyStr)
            then
                table.remove(self._keyStringList,i)
                break
            end
        end
        --============================================================
    end
    --================================================================
    function TabComponent:_getIndexFromKeyStringIndex(keyStr)
        --============================================================
        local idx =1
        --============================================================
        for i,v in ipairs(self._keyStringList)
        do
            if (v == keyStr)
            then
                idx = i
                break
            end
        end
        --============================================================
        return idx
    end
    --================================================================

    --================================================================
    return TabComponent
end
--====================================================================

--====================================================================
-- slider
--====================================================================
function createSlider(compnentName,x,y,w,h)
    --================================================================
    local Slider = createComponent(compnentName,x,y,w,h)
    --================================================================
    Slider.value = 0.5
    Slider._valueChangeFuncTable ={}
    Slider.label = compnentName .. ":";
    Slider._meterValueRect = createRectangle()
    --================================================================
    Slider.maxValue = 1.0
    Slider.minValue = 0.0
    --================================================================
    Slider:setColor("text",{0,0,0,1})
    Slider:setColor("background",{1,1,1,1})
    Slider:setColor("background_onMouse",{0,1,1,1})
    Slider:setColor("meter_value",{1,0.2,0.2,1})
    --================================================================
    Slider._CLASS_TYPE = "Slider"
    --================================================================
    Slider.meterType = 0x01 -- 0x01=horizontale, 0x02=horizontalCenter
    --================================================================
    function Slider:addOnValueChangeFunction(func) -- callback | function (slider) ~~ end |
        --============================================================
        if (type(func) ~="function" )then return end
        --============================================================
        local  isDouble =false
        for i,v in ipairs( self._valueChangeFuncTable)
        do
            if ( v ==func )
            then
                isDouble =true
            end
        end
        --============================================================
        if ( isDouble == false)
        then
           table.insert (self._valueChangeFuncTable,func)
        end
        --============================================================
    end
    --================================================================
    function Slider:setMaxMinValue(max,min)
       self.maxValue = max
       self.minValue = min
    end
    --================================================================
    function Slider:getValue() return self.value ; end
    --================================================================
    function Slider:setValue(val,isNotifyCallback)
        --============================================================
        self.value = val
        local _isNotify = isNotifyCallback or true
        --============================================================
        if (self.value > self.maxValue ) then self.value =self.maxValue end
        if (self.value < self.minValue) then  self.value =self.minValue end
        --============================================================
        if (_isNotify == true )
        then
            --========================================================
            for i,v in ipairs ( self._valueChangeFuncTable)
            do
                v(self)
            end
            --========================================================
        end
        --============================================================
        self:_updateMeterValueRect();
    end
    --================================================================
    function Slider:setMeterType(type_)--type_ =0x01 or 0x02
        self.meterType = type_
    end
    --================================================================
    -- override
    --================================================================
    function Slider:onResized()
        --============================================================
        self:_updateMeterValueRect()
    end
    --================================================================
    function Slider:onMouseMove(mouse_ox,mouse_oy)
        --============================================================
        if ( self:_isMouseDragging() )
        then
            --========================================================
            local newValue = self:_xyToValue(mouse_ox,mouse_oy)
            --========================================================
            self:setValue(newValue)
            --========================================================
        end
        --============================================================
    end
    --================================================================
    function Slider:onMouseWheel(wheel_Y_dt)
        --============================================================
        if ( self:isColisionMouse())
        then
            --========================================================
            local newValue = self:_xyToValue(gfx.mouse_x,gfx.mouse_y)
            --========================================================
            local currentValue = self:getValue()
            --========================================================
             local inverseWheel = 1
            if ( newValue < currentValue)then inverseWheel = -1 end
            --========================================================
            currentValue = currentValue + (newValue-currentValue) /40*wheel_Y_dt*inverseWheel
            --========================================================
            self:setValue(currentValue)
            --========================================================
        end
        --============================================================
    end
    --================================================================
    function Slider:onDraw(deltaTime)
        --============================================================

        --============================================================
        self:_drawBackGround()
        --============================================================
        if(self:isHorizontaleMeter())
        then
            self:_drawHorizontalMeter()
        elseif (self:isHorizontalCenterMeter())
        then
            self:_drawHorizontalCenterMeter()
        end
        --============================================================
        self:_drawValueText()
        --============================================================
    end
    --================================================================

    --================================================================
    -- virtual
    --================================================================
    function Slider:valueToText() -- virtual
        return string.format("%0.2f",self.value)
    end
    --================================================================
    function Slider:setLabel(labelStr)
        self.label = labelStr;
    end
    --================================================================
    function Slider:isHorizontaleMeter()
        return (self.meterType & 0x01 ~= 0x00 )
    end
    --================================================================
    function Slider:isHorizontalCenterMeter()
        return (self.meterType & 0x02 ~= 0x00 )
    end
    --================================================================

    --================================================================
    -- private
    --================================================================
    function Slider:_updateMeterValueRect()
        --============================================================
        self._meterValueRect = self:getRectangle()
        self._meterValueRect:reduce(2,2);
        --============================================================
        if ( self:isHorizontaleMeter())
        then
            --========================================================
            self._meterValueRect.w = self._meterValueRect.w*self.value
            --========================================================
        elseif(self:isHorizontalCenterMeter())
        then
            --========================================================
            local pointWidth = 19--math.max(self._meterValueRect.w/40,15);
            --========================================================
            local vPx = self._meterValueRect.w*self.value
            self._meterValueRect.x = vPx - pointWidth/4
            self._meterValueRect.w = pointWidth
            --========================================================
            if ( self._meterValueRect.x < self.x )
            then
                self._meterValueRect.x = self.x+2;
            end
            --========================================================
            if ( self._meterValueRect:getX2() > self:getX2()-2 )
            then
                self._meterValueRect.w =self:getX2() - self._meterValueRect.x-2;
            end
            --========================================================
        end
        --============================================================
        self._meterValueRect:_updateXyTable();
        --============================================================
    end
    --================================================================
    function Slider:_drawBackGround()
        --============================================================
        if ( self:isColisionMouse() )
        then
            --========================================================
            gfx.set(self:getColor("background_onMouse"))
            --========================================================
        else
            gfx.set(self:getColor("background"))
        end
        --============================================================
        gfx.rect(self.x,self.y,self.w,self.h,true) --background
    end
    --================================================================
    function Slider:_drawValueText()
        --============================================================
        gfx.set(self:getColor("text"))
        --============================================================
        local cpoint = self:getCenterPoint();
        local fontsize = gfx.texth ;
        local drawStr = self.label ..self:valueToText()
        local strLen = #drawStr
        gfx.x = cpoint.x -(fontsize/2)*(strLen/2)
        gfx.y = cpoint.y - fontsize/2
        gfx.drawstr(drawStr )
        --============================================================
    end
    --================================================================
    function Slider:_drawHorizontalMeter()
        --============================================================
        gfx.set(self:getColor("meter_value"))
        gfx.setfont(1,self._fontName, self._fontSize)
        --============================================================
        local valueRect = self._meterValueRect
        gfx.rect(valueRect.x,valueRect.y,valueRect.w,valueRect.h,true) --value
        --============================================================
    end
    --================================================================
    function Slider:_drawHorizontalCenterMeter()
        --============================================================
        gfx.set(self:getColor("meter_value"))
        gfx.setfont(1,self._fontName, self._fontSize)
        --============================================================
        local valueRect = self._meterValueRect
        --============================================================
        gfx.rect(valueRect.x,valueRect.y,valueRect.w,valueRect.h,true) --value
        --============================================================
        local centerPoint = self:getCenterPoint()
        gfx.set(self:getColor("black"))
        gfx.line (centerPoint.x,self.y,centerPoint.x,self:getY2())
        --============================================================
        self:_drawValueText()
        --============================================================
    end
    --================================================================
    function Slider:_xyToValue(xx,yy)
        --============================================================
        local out = 0.0
        --============================================================
        if ( self:isHorizontaleMeter())
        then
            local relX = xx - self.x
            local value = relX /self.w
            --========================================================
            out =  value * self.maxValue
        end
        --============================================================
        if ( self:isHorizontalCenterMeter())
        then
            local relX = xx - self.x
            local value = relX /self.w
            --========================================================
            out =  value* self.maxValue;
        end
        --============================================================
        return out
    end
    --================================================================

    --================================================================
    return Slider ;
end
--====================================================================

--====================================================================
-- textPanel
--====================================================================
function createTextPanel(componentName)
    --================================================================
    local TextPanel =  createComponent(componentName,x,y,w,h)
    --================================================================
    TextPanel.offsetY = 0
    TextPanel.drawTexts ={}
    --================================================================
    TextPanel:setColor("text",{0,0,0,1})
    TextPanel:setColor("background",{1,1,1,1})
    --================================================================
    TextPanel._marginX = 10
    TextPanel._marginY = 10
    --================================================================
    TextPanel._CLASS_TYPE = "TextPanel"
    --================================================================
    function TextPanel:setTextMargin(marginX,marginY)
        self._marginX = marginX
        self._marginY = marginY
    end
    --================================================================
    function TextPanel:setDrawTextsAsCopy(drawTextsTable)
        self.drawTexts = deepcopy(drawTextsTable)
    end
    --================================================================
    function TextPanel:setTextOffsetLine(offsetLineY)
        self.offsetY = offsetLineY;
        if (self.offsetY <0 ) then self.offsetY = 0;end
        if (self.offsetY > #self.drawTexts-1 ) then self.offsetY = #self.drawTexts-1;end
    end
    --================================================================
    function TextPanel:tryTextShown(targetText)
        --============================================================
        if ( self:_checkNeedOffsetOption())
        then
            --========================================================
            for i,v in ipairs (self.drawTexts)
            do
                if ( v == targetText)
                then
                    self:setTextOffsetLine( i -1)
                    break;
                end
            end
        else
            --========================================================
            self:setTextOffsetLine(0);
        end
        --============================================================
    end
    --================================================================
    function TextPanel:setDrawTexts(drawTextsTable)
        self.drawTexts = drawTextsTable
    end
    --================================================================
    -- override
    --================================================================
    function TextPanel:onMouseWheel(wheel_Y_dt)
        --============================================================
        if (    self:isColisionMouse())
        then
            --========================================================
            if ( self:_checkNeedOffsetOption())
            then
                self:setTextOffsetLine( self.offsetY  -wheel_Y_dt)
            else
                self:setTextOffsetLine(0);
            end
            --========================================================
        end
        --============================================================
    end
    --================================================================
    function TextPanel:onDraw(deltaTime)
        --============================================================
        gfx.set(self:getColor("background"))
        --============================================================
        gfx.rect(self.x,self.y,self.w,self.h,true) --background
        --============================================================
        gfx.setfont(1,self._fontName, self._fontSize)
        --============================================================
        gfx.set(self:getColor("text") )
        --============================================================
        local marginX = self._marginX
        local marginY = self._marginY
        --============================================================
        for i = self.offsetY+1,#self.drawTexts
        do
            local x = self.x + marginX
            local y = self.y + gfx.texth*(i-self.offsetY-1) +marginY
            --========================================================
            if ( y > self:getY2()-marginY)
            then
                break;
            end
            --========================================================
            gfx.x = x
            gfx.y = y
            gfx.drawstr(self.drawTexts[i])
            --========================================================
        end
        --============================================================
    end
    --================================================================
    -- private
    --================================================================
    function TextPanel:_checkNeedOffsetOption()
        --============================================================
        local showingLineNum = (self.h -self._marginY)/self._fontSize
        --============================================================
        return (showingLineNum < #self.drawTexts )
        --============================================================
    end
    --================================================================

    --================================================================
    return TextPanel
end
--====================================================================

--====================================================================
-- mouse xy RectAngle
--====================================================================
function createCursolRect(componentName)
    --================================================================
    local CursolRect = createComponent(componentName,x,y,w,h)
    --================================================================
    CursolRect.movingArea =createRectangle(0,0,gfx.w,gfx.h)
    --================================================================
    CursolRect:setColor("background",{1,0,0,1})
    CursolRect:setColor("centerCircle_out",{0,0,0,1})
    CursolRect:setColor("centerCircle",{1,1,1,1})
    --================================================================
    CursolRect._rectSize = 20;
    --================================================================
    CursolRect._onMovedFunction ={}
    --================================================================
    CursolRect._CLASS_TYPE = "CursolRect"
    --================================================================
    function CursolRect:addOnMovedFunction(func)-- callback | function (CursolRect) ~~ end |
        --============================================================
        if (type(func) ~="function" )then return end
        --============================================================
        local  isDouble =false
        for i,v in ipairs( self._onMovedFunction)
        do
            if ( v == func )
            then
                isDouble =true
            end
        end
        --============================================================
        if ( isDouble == false)
        then
           table.insert (self._onMovedFunction,func)
        end
        --============================================================
    end
    --================================================================
    function CursolRect:setMovingArea(rectangle)
       self.movingArea = rectangle
    end
    --================================================================
    function CursolRect:setRectSize(size)
        self._rectSize = size;
        self:setWidth(self._rectSize)
        self:setHeight(self._rectSize)
    end
    --================================================================
    -- override
    --================================================================
    function CursolRect:onDraw(deltaTime)
        --============================================================
        local centerP = self:getCenterPoint();
        local radius = self.w/2
        gfx.set(self:getColor("centerCircle_out"))
        gfx.circle(centerP.x,centerP.y-1,radius,true)
        --============================================================
        radius = self.w/2*0.7
        gfx.set(self:getColor("centerCircle"))
        gfx.circle(centerP.x,centerP.y-1,radius,true)
        --============================================================
    end
    --================================================================
    function CursolRect:onMouseMove(mouse_ox,mouse_oy)
        --============================================================
        if ( self:_isMouseDragging() )
        then
            self:setX(mouse_ox-self.w/2)
            self:setY(mouse_oy-self.h/2)
            --========================================================
            self:_checkMovingArea();
            --========================================================
            for i,v in ipairs(self._onMovedFunction)
            do
                v(self)
            end
            --========================================================
        end
        --============================================================
    end
    --================================================================

    --================================================================
    -- private
    --================================================================
    function CursolRect:_checkMovingArea()
        --============================================================
        local minX = self.movingArea:getX()
        local maxX = self.movingArea:getX2()-self._rectSize
        local minY = self.movingArea:getY()
        local maxY = self.movingArea:getY2()-self._rectSize
        --============================================================
        if ( self.x > maxX )then self:setX(maxX) ;end
        if ( self.x < minX )then self:setX(minX) ;end
        if ( self.y > maxY )then self:setY(maxY) ;end
        if ( self.y < minY )then self:setY(minY) ;end
        --============================================================
    end
    --================================================================

    --================================================================
    return CursolRect
end
--====================================================================

--====================================================================
-- XY Slider
--====================================================================
function createXYSlider(componentName)
    --================================================================
    local XYSlider = createComponent(componentName,x,y,w,h)
    --================================================================
    XYSlider._editCursolRect = nil
    XYSlider._editCursolSize = 18
    XYSlider._gridDiv = 4
    --================================================================
    XYSlider._labelTable = {"A","B","C","D"}
    XYSlider._labelFontSize = 0x18;
    --================================================================
    XYSlider._lastXValue = 0.5
    XYSlider._lastYValue = 0.5
    --================================================================
    XYSlider:setColor("background",{1,1,1,1})
    XYSlider:setColor("background_grid",{0,0,0,1})
    XYSlider:setColor("background_grid2",{0,0,0,0.3})
    XYSlider:setColor("cursolRectColor",{1,0,0,1})
    XYSlider:setColor("text",{0,0,0,1})
    --================================================================
    XYSlider._onValueChangedFunction ={}
    --================================================================
    XYSlider._CLASS_TYPE = "XYSlider"
    --================================================================
    function XYSlider:addOnValueChangeFunction(func)-- callback | function (XYSlider) ~~ end |
        --============================================================
        if (type(func) ~="function" )then return end
        --============================================================
        local  isDouble =false
        for i,v in ipairs( self._onValueChangedFunction)
        do
            if ( v == func )
            then
                isDouble =true
            end
        end
        --============================================================
        if ( isDouble == false)
        then
           table.insert (self._onValueChangedFunction,func)
        end
        --============================================================
    end
    --================================================================
    function XYSlider:setLabelTable(labelTable)
        self._labelTable = labelTable;
    end
    --================================================================
    function XYSlider:getXValue() --normalised
        --============================================================
        local editP = self._editCursolRect:getCenterPoint()
        local reducedRect = self:getRectangle()
        reducedRect:reduce(self._editCursolSize/2,self._editCursolSize/2)
        local xVal = (editP.x -reducedRect.x) / reducedRect.w
        --============================================================
        return xVal
    end
    --================================================================
    function XYSlider:getYValue() --normalised
        --============================================================
        local editP = self._editCursolRect:getCenterPoint()
        local reducedRect = self:getRectangle()
        reducedRect:reduce(self._editCursolSize/2,self._editCursolSize/2)
        local yVal = (editP.y -reducedRect.y) / reducedRect.h
        --============================================================
        return yVal
    end
    --================================================================
    function XYSlider:setCursolColor(colorTable)
        self._editCursolRect:setColor("centerCircle",colorTable)
    end
    --================================================================

    --================================================================
    -- override
    --================================================================
    function XYSlider:onResized()
        --============================================================
        self:_updateEditoCursolRect()
    end
    --================================================================
    function XYSlider:onDraw(deltaTime)
        --============================================================
        self:_drawBackGround()
        --============================================================
        self:_drawBackgroundGrid()
        --============================================================
        self:_drawEditCursolRectBorder()
        --============================================================
    end
    --================================================================
    function XYSlider:onDraw2(deltaTime)
        --============================================================
        self:_drawValueInfo()
        --============================================================
        self:_drawLabels()
        --============================================================
        self._lastXValue = self:getXValue()
        self._lastYValue = self:getYValue()
        --============================================================
    end
    --================================================================

    --================================================================
    -- private
    --================================================================
    function XYSlider:_init()
        --============================================================
        self._editCursolRect = createCursolRect("editCursolRect");
        self._editCursolRect:setRectSize(self._editCursolSize);
        --============================================================
        self:addChildComponent( self._editCursolRect )
        --============================================================
        self._editCursolRect:addOnMovedFunction(
            --========================================================
            function (editCursolRect_p)
                self:_valueChanged()
            end
        )
        --============================================================
    end
    --================================================================
    function XYSlider:_updateEditoCursolRect()
        --============================================================
        local reducedRect = self:getRectangle()
        reducedRect:reduce(self._editCursolSize/2,self._editCursolSize/2)
        --============================================================
        local newX  = reducedRect.x+(reducedRect.w*self._lastXValue)
        local newY  = reducedRect.y+(reducedRect.h*self._lastYValue)
        --============================================================
        newX = newX-self._editCursolRect.w/2
        newY = newY-self._editCursolRect.h/2
        --============================================================
        self._editCursolRect:setX(newX)
        self._editCursolRect:setY(newY)
        --============================================================
        self._editCursolRect:setMovingArea(self:getRectangle())
    end
    --================================================================
    function XYSlider:_drawBackGround()
        --============================================================
        gfx.set(self:getColor("background"))
        gfx.rect(self.x,self.y,self.w,self.h)
        --============================================================
    end
    --================================================================
    function XYSlider:_drawBackgroundGrid()
        --============================================================
        gfx.set(self:getColor("background_grid"))
        --============================================================
        local centerP = self:getCenterPoint();
        --============================================================
        gfx.line(self.x,centerP.y,self:getX2(),centerP.y)
        gfx.line(centerP.x,self.y,centerP.x,self:getY2())
        --============================================================
        local div = self._gridDiv
        local dW = self.w /div
        local dH = self.h /div
        --============================================================
        gfx.set(self:getColor("background_grid2"))
        --============================================================
        for i =1 ,div
        do
            local xx =self.x+ dW*i
            local yy =self.y+ dH*i
            gfx.line(xx,self.y,xx,self:getY2())
            gfx.line(self.x,yy,self:getX2(),yy)
        end
        --============================================================
        gfx.set(self:getColor("black"))
        gfx.circle(centerP.x,centerP.y-1,2,true)
        --============================================================
    end
    --================================================================
    function XYSlider:_drawEditCursolRectBorder()
        --============================================================
        local editP = self._editCursolRect:getCenterPoint()
        --============================================================
        gfx.set(self:getColor("background_grid"))
        --============================================================
        gfx.line(self.x,editP.y,self:getX2(),editP.y)
        gfx.line(editP.x,self.y,editP.x,self:getY2())
    end
    --================================================================
    function XYSlider:_drawValueInfo()
        --============================================================
        gfx.set(self:getColor("text"))
        gfx.setfont(1,self._fontName,self._fontSize)
        --============================================================
        local xVal = self:getXValue()
        local yVal = self:getYValue()
        local str = string.format("X %1.2f \nY %1.2f",xVal,yVal)
        --============================================================
        local centerP = self:getCenterPoint()
        --============================================================
        gfx.x = centerP.x +gfx.texth/2
        gfx.y = centerP.y +gfx.texth/2
        gfx.drawstr(str)
    end
    --================================================================
    function XYSlider:_drawLabels()
        --============================================================
        gfx.set(self:getColor("text"))
        gfx.setfont(1,self._fontName,self._labelFontSize)
        --============================================================
        gfx.x = self.x +gfx.texth/2/2
        gfx.y = self.y
        gfx.drawstr(self._labelTable[1])
        --============================================================
        gfx.x = self:getX2()-gfx.texth*0.5 -gfx.texth *#self._labelTable[2]/2
        gfx.y = self.y
        gfx.drawstr(self._labelTable[2])
        --============================================================
        gfx.x = self:getX2()-gfx.texth*0.5 -gfx.texth *#self._labelTable[3]/2
        gfx.y = self:getY2()-gfx.texth
        gfx.drawstr(self._labelTable[3])
        --============================================================
        gfx.x = self.x +gfx.texth/2/2
        gfx.y = self:getY2()-gfx.texth
        gfx.drawstr(self._labelTable[4])
        --============================================================
        gfx.setfont(1,self._fontName,self._fontSize)
    end
    --================================================================
    function XYSlider:_valueChanged() -- callback
        --============================================================
        for i,v in ipairs( self._onValueChangedFunction )
        do
            v(self)
        end
        --============================================================
    end
    --================================================================

    XYSlider:_init();
    --================================================================
    return XYSlider;
    --================================================================
end
--====================================================================

--====================================================================
function createGonioMeter_EX (Name,x,y,w,h)
    --================================================================
    local CustomComponent = createComponent(Name,x,y,w,h)
    --================================================================
    CustomComponent._animTime = 0;
    --================================================================
    CustomComponent._track = nil
    CustomComponent._reaperArray ={}
    CustomComponent._sumpleBuffer ={}
    CustomComponent._bufferNum =DEFINE_BUFFER_NUM;
    --================================================================
    -- for smooze
    CustomComponent._lastAngleDeg  = 0.0;
    CustomComponent._lastMax_L = 0.0;
    CustomComponent._lastMax_R = 0.0;
    CustomComponent._lastSize = 0.0;
    --================================================================
    CustomComponent._jsFx_InL = 0.0;
    CustomComponent._jsFx_InR = 0.0;
    CustomComponent._jsFx_maxAbsL = 0.0;
    CustomComponent._jsFx_maxAbsR = 0.0;
    CustomComponent._jsFx_LRC_direction = 0.0;
    CustomComponent._jsFx_DirectionAngle_Speed = 4.0;
    CustomComponent._jsFx_Value_Speed = 4.0;

    --================================================================
    CustomComponent._drawTypeState = 0; -- 0 diamond,1 elipse line ,2 elipsebox,3 elipseDia,4 all,5 off
    CustomComponent._animationState =false;
    --================================================================
    CustomComponent._isDrawBackGridFill =false;
    --================================================================

    --================================================================
    function CustomComponent:onResized()end
    --================================================================
    function CustomComponent:onDraw(deltaTime)
        --============================================================
        self:_drawBackground()
        --============================================================
        self:_checkAnimTime(deltaTime,5)
        --============================================================
        self:_drawPlayTime();
        --============================================================
        self:_getJSFXParame();
        --============================================================
        self:_drawBuffer();
        --============================================================
        self:_drawGrid();
        --============================================================
    end
    --================================================================
    function CustomComponent:onMousePress(mouseCap)
        --============================================================
        if (self.isMouseLeftDown )
        then
            DEFINE_BACKGROUND_COLOR_HUE = math.random()*360
            --========================================================
        elseif ( self.isMouseRightDown )
        then
            self:stepDrawState();
            --========================================================
        elseif ( self.isMouseMiddleDown )
        then
            self:toggleAnimationState();
            --========================================================
        end
    end
    --================================================================
    function CustomComponent:onMouseWheel(wheel_Y_dt)
        DEFINE_BACKGROUND_COLOR_HUE = DEFINE_BACKGROUND_COLOR_HUE+wheel_Y_dt*20;
        if (DEFINE_BACKGROUND_COLOR_HUE >360)then DEFINE_BACKGROUND_COLOR_HUE =0; end ;
        if (DEFINE_BACKGROUND_COLOR_HUE < 0)then DEFINE_BACKGROUND_COLOR_HUE =360; end ;
    end
    --================================================================

    --================================================================
    function CustomComponent:stepDrawState()
        --============================================================
        self._drawTypeState = self._drawTypeState+1;
        --============================================================
        if ( self._drawTypeState > 5)then self._drawTypeState = 0;end
        -- if ( self._drawTypeState < 0)then self._drawTypeState = 4;end
        --============================================================
    end
    --================================================================
    function CustomComponent:toggleAnimationState()
        self._animationState = (self._animationState == false) or false;
    end
    --================================================================

    --================================================================
    -- private
    --================================================================
    function CustomComponent:_init()
        --============================================================
        self:_crearBuffer();
        --============================================================
    end
    --================================================================
    function CustomComponent:_crearBuffer()
        --============================================================
        self._sumpleBuffer ={}
        --============================================================
        for i=1,self._bufferNum
        do
            self._sumpleBuffer[i] = {l=0,r=0}
        end
        --============================================================
    end
    --================================================================
    function CustomComponent:_stepAnimationColor()
        --============================================================
        DEFINE_BACKGROUND_COLOR_HUE = DEFINE_BACKGROUND_COLOR_HUE-1.5;
        if (DEFINE_BACKGROUND_COLOR_HUE >360)then DEFINE_BACKGROUND_COLOR_HUE =0; end ;
        if (DEFINE_BACKGROUND_COLOR_HUE < 0)then DEFINE_BACKGROUND_COLOR_HUE =360; end ;
        --============================================================
    end
    --================================================================
    function CustomComponent:_drawBackground()
        --============================================================
        local barNum = 5;
        local oneBarWidth = math.ceil(self.w / barNum)
        --============================================================
        local colDt = 1.0/barNum;
        --============================================================
        if ( self._animationState)
        then
            self:_stepAnimationColor();
        end
        --============================================================
        local saturation = math.max( 1 , DEFINE_BACKGROUND_COLOR_SATURATION
                                       + (1-DEFINE_BACKGROUND_COLOR_SATURATION)*(self._lastMax_L+self._lastMax_R)*1.4 )
        local brigthNess = math.min( 1 , DEFINE_BACKGROUND_COLOR_BRIGHTNESS
                                       + (1-DEFINE_BACKGROUND_COLOR_BRIGHTNESS)*(self._lastMax_L+self._lastMax_R)*1.4 )
        --============================================================
        for i =1, barNum
        do
            local r,g,b = HSVToRGB(   DEFINE_BACKGROUND_COLOR_HUE
                                    + DEFINE_BACKGROUND_COLOR_HUE_WIDTH *(i/barNum)
                                   ,  saturation
                                   ,  brigthNess )
            gfx.set(r/255,g/255,b/255,1*self._componentAlpha)
            --========================================================
            gfx.rect( oneBarWidth * (i-1) -1
                    , self.y
                    , oneBarWidth
                    , self.h,true)
        end
        --============================================================
        if ( self._isDrawBackGridFill)
        then
            local cx = self:getCenterPoint().x
            local cy = self:getCenterPoint().y
            gfx.set(gfx.r,gfx.g,gfx.b,-0.1*self._componentAlpha,0x01);
            self:_drawEllipseBackGround(cx, cy, self.w, self.h,45)
        end
        --============================================================
        gfx.set(gfx.r,gfx.g,gfx.b,1*self._componentAlpha,0x00);
        --============================================================
    end
    --================================================================
    function CustomComponent:_checkAnimTime(deltaTime,speedDiv)
        --============================================================
        self._animTime = self._animTime + (deltaTime/speedDiv);
        --============================================================
        if ( self._animTime > 1.0)then self._animTime=0;end
        if ( self._animTime < 0.0)then self._animTime=0;end
        --============================================================
    end
    --================================================================
    -- http://www.softist.com/programming/drawcircle/drawcircle.htm
    function CustomComponent:_drawEllipseBackGround(cx_, cy_, a_, b_,rad_,division_AB)
        --============================================================
        local division_ = division_AB or 8;
        local _xx = a_ * division_;
        local _yy = 0;
        local _x  = _xx / division_;
        local _y  = _yy / division_;
        local radAngle = rad_ or 0;
        --============================================================
        gfx.x = cx_;
        gfx.y = cy_;
        --============================================================
        while (_xx >= 0)
        do
            _x = _xx / division_;
            _y = _yy / division_;
            --========================================================
            local _xrot,_yrot = rotPoint(cx_,cy_, cx_ + _x, cy_ + _y,math.rad(radAngle));
            gfx.lineto( _xrot,_yrot)
            gfx.x = _xrot;gfx.y = _yrot;
            --========================================================
            _xrot,_yrot = rotPoint(cx_,cy_, cx_ - _x, cy_ + _y,math.rad(radAngle));
            gfx.lineto( _xrot,_yrot)
            gfx.x = _xrot;gfx.y = _yrot;
            --========================================================
            _xrot,_yrot = rotPoint(cx_,cy_, cx_ - _x, cy_ - _y,math.rad(radAngle));
            gfx.lineto( _xrot,_yrot)
            gfx.x = _xrot;gfx.y = _yrot;
            --========================================================
            _xrot,_yrot = rotPoint(cx_,cy_, cx_ + _x, cy_ - _y,math.rad(radAngle));
            gfx.lineto( _xrot,_yrot)
            gfx.x = _xrot;gfx.y = _yrot;
            --========================================================
            _yy =_yy + (_xx * b_ / a_ / division_ );
            _xx =_xx - (_yy * a_ / b_ / division_ +0.001);
            --========================================================
        end
        --============================================================
    end
    --================================================================
    function CustomComponent:_drawEllipseBox(cx_, cy_, a, b,size_,rad_,division )
        --============================================================
        local minV = math.min(a,b);
        local maxV = math.max(a,b)+0.0000001; --//reject zero
        local _tempV = (minV /maxV)*size_/2 ;
        local a_ = _tempV  / math.log(2) ;
        local b_ = size_ ;
        --============================================================
        local _xx = a_ * division;
        local _yy = 0;
        local _x  = _xx / division;
        local _y  = _yy / division;
        --============================================================
        gfx.x = cx_;gfx.y = cy_;
        --============================================================
        while (_xx >= 0)
        do
            _x = _xx / division;
            _y = _yy / division;
            --========================================================
            local p1x = cx_ + _x;
            local p1y = cy_ - _y;
            local p2x = cx_ - _x;
            local p2y = cy_ - _y;
            local p3x = cx_ - _x;
            local p3y = cy_ + _y;
            local p4x = cx_ + _x;
            local p4y = cy_ + _y;
            --========================================================
            local rP1x_ ,rP1y_ = rotPoint(cx_,cy_,p1x,p1y,rad_);
            local rP2x_ ,rP2y_ = rotPoint(cx_,cy_,p2x,p2y,rad_);
            local rP3x_ ,rP3y_ = rotPoint(cx_,cy_,p3x,p3y,rad_);
            local rP4x_ ,rP4y_ = rotPoint(cx_,cy_,p4x,p4y,rad_);
            --========================================================
            gfx.line(rP1x_ ,rP1y_,rP2x_ ,rP2y_);
            gfx.line(rP2x_ ,rP2y_,rP3x_ ,rP3y_);
            gfx.line(rP3x_ ,rP3y_,rP4x_ ,rP4y_);
            gfx.line(rP4x_ ,rP4y_,rP1x_ ,rP1y_);
            --========================================================
            _yy =_yy + ( _xx * b_ / a_ / division );
            _xx =_xx - ( (_yy * a_ / b_ / division )+0.1);
            --========================================================
        end
    end
    --================================================================
    function CustomComponent:_drawEllipseOutLine(cx_, cy_, a, b,size_,rad_,division )
        --============================================================
        local minV = math.min(a,b);
        local maxV = math.max(a,b)+0.0000001; --//reject zero
        local _tempV = (minV /maxV)*size_/2 ;
        local a_ = _tempV  / math.log(2) ;
        local b_ = size_ ;
        --============================================================
        local _xx = a_ * division;
        local _yy = 0;
        local _x  = _xx / division;
        local _y  = _yy / division;
        --============================================================
        gfx.x = cx_;gfx.y = cy_;
        local pBuf_1 ={};
        local pBuf_2 ={};
        local pBuf_3 ={};
        local pBuf_4 ={};
        --============================================================
        while (_xx >= 0)
        do
            _x = _xx / division;
            _y = _yy / division;
            --========================================================
            local p1x = cx_ + _x;
            local p1y = cy_ - _y;
            local p2x = cx_ - _x;
            local p2y = cy_ - _y;
            local p3x = cx_ - _x;
            local p3y = cy_ + _y;
            local p4x = cx_ + _x;
            local p4y = cy_ + _y;
            --========================================================
            local rP1x_ ,rP1y_ = rotPoint(cx_,cy_,p1x,p1y,rad_);
            local rP2x_ ,rP2y_ = rotPoint(cx_,cy_,p2x,p2y,rad_);
            local rP3x_ ,rP3y_ = rotPoint(cx_,cy_,p3x,p3y,rad_);
            local rP4x_ ,rP4y_ = rotPoint(cx_,cy_,p4x,p4y,rad_);
            table.insert (pBuf_1,{x = rP1x_,y=rP1y_} );
            table.insert (pBuf_2,{x = rP2x_,y=rP2y_} );
            table.insert (pBuf_3,{x = rP3x_,y=rP3y_} );
            table.insert (pBuf_4,{x = rP4x_,y=rP4y_} );
            --========================================================
            _yy =_yy + ( _xx * b_ / a_ / division );
            _xx =_xx - ( (_yy * a_ / b_ / division )+0.1);
            --========================================================
        end
        --============================================================
        local function _lineTo_(buf_xy)
            gfx.x = buf_xy[1].x;
            gfx.y = buf_xy[1].y;
            --========================================================
            local count = 1;
            while ( count <= #buf_xy)
            do
                gfx.lineto(buf_xy[count].x ,buf_xy[count].y);
                count= count+1;
            end
        end
        --============================================================
        _lineTo_(pBuf_1);
        _lineTo_(pBuf_2);
        _lineTo_(pBuf_3);
        _lineTo_(pBuf_4);
        --============================================================
    end
    --================================================================
    function CustomComponent:_drawEllipseAndDiamond(cx_, cy_, a, b,size_,rad_,division )
        --============================================================
        local minV = math.min(a,b);
        local maxV = math.max(a,b)+0.0000001; --//reject zero
        local _tempV = (minV /maxV)*size_/2 ;
        local a_ = _tempV  / math.log(2) ;
        local b_ = size_ ;
        --============================================================
        local _xx = a_ * division;
        local _yy = 0;
        local _x  = _xx / division;
        local _y  = _yy / division;
        --============================================================
        gfx.x = cx_;gfx.y = cy_;
        local pBuf_1 ={};
        local pBuf_2 ={};
        local pBuf_3 ={};
        local pBuf_4 ={};
        --============================================================
        while (_xx >= 0)
        do
            _x = _xx / division;
            _y = _yy / division;
            --========================================================
            local p1x = cx_ + _x;
            local p1y = cy_ - _y;
            local p2x = cx_ - _x;
            local p2y = cy_ - _y;
            local p3x = cx_ - _x;
            local p3y = cy_ + _y;
            local p4x = cx_ + _x;
            local p4y = cy_ + _y;
            --========================================================
            local rP1x_ ,rP1y_ = rotPoint(cx_,cy_,p1x,p1y,rad_);
            local rP2x_ ,rP2y_ = rotPoint(cx_,cy_,p2x,p2y,rad_);
            local rP3x_ ,rP3y_ = rotPoint(cx_,cy_,p3x,p3y,rad_);
            local rP4x_ ,rP4y_ = rotPoint(cx_,cy_,p4x,p4y,rad_);
            table.insert (pBuf_1,{x = rP1x_,y=rP1y_} );
            table.insert (pBuf_2,{x = rP2x_,y=rP2y_} );
            table.insert (pBuf_3,{x = rP3x_,y=rP3y_} );
            table.insert (pBuf_4,{x = rP4x_,y=rP4y_} );
            --========================================================
            _yy =_yy + ( _xx * b_ / a_ / division );
            _xx =_xx - ( (_yy * a_ / b_ / division )+0.1);
            --========================================================
        end
        --============================================================
        local function _lineTo_(buf_xy)
            gfx.x = buf_xy[1].x;
            gfx.y = buf_xy[1].y;
            --========================================================
            local count = #buf_xy;
            while ( count > 0)
            do
                gfx.lineto(buf_xy[count].x ,buf_xy[count].y);
                count= count-1;
            end
        end
        --============================================================
        _lineTo_(pBuf_1);
        _lineTo_(pBuf_2);
        _lineTo_(pBuf_3);
        _lineTo_(pBuf_4);
        --============================================================
    end
    --================================================================
    function CustomComponent:_drawDiamond(cx_,cy_,a_,b_,size_,rad)
        --============================================================
        local minV = math.min(a_,b_);
        local maxV = math.max(a_,b_)+0.0000001; --reject zero
        local _tempV = (minV /maxV)*size_* math.log(2);
        --============================================================
        local p1x = cx_ ;
        local p1y = cy_ - size_;
        local p2x = cx_ +_tempV;
        local p2y = cy_;
        local p3x = cx_ +(cx_-p1x);
        local p3y = cy_ +(cy_-p1y);
        local p4x = cx_ -_tempV;
        local p4y = cy_;
        --============================================================
        local rP1x_ ,rP1y_ = rotPoint(cx_,cy_,p1x,p1y,rad);
        local rP2x_ ,rP2y_ = rotPoint(cx_,cy_,p2x,p2y,rad);
        local rP3x_ ,rP3y_ = rotPoint(cx_,cy_,p3x,p3y,rad);
        local rP4x_ ,rP4y_ = rotPoint(cx_,cy_,p4x,p4y,rad);
        --============================================================
        gfx.line(rP1x_ ,rP1y_,rP2x_ ,rP2y_);
        gfx.line(rP2x_ ,rP2y_,rP3x_ ,rP3y_);
        gfx.line(rP3x_ ,rP3y_,rP4x_ ,rP4y_);
        gfx.line(rP4x_ ,rP4y_,rP1x_ ,rP1y_);
        --============================================================
    end
    --================================================================
    --http://dspguru.com/dsp/tricks/fixed-point-atan2-with-self-normalization
    function CustomComponent:_atan2(x_,y_)
        --============================================================
        local coeff_1 = math.pi /4;
        local coeff_2 = 3 * coeff_1;
        local abs_y = math.abs(y_)+1e-10      -- kludge to prevent 0/0 condition
        local angle = 0;
        --============================================================
        if ( x_>=0)
        then
            local r = (x_ - abs_y) / (x_ + abs_y);
            angle = coeff_1 - coeff_1 * r;
        else
            local r = (x_ + abs_y) / (abs_y - x_);
            angle = coeff_2 - coeff_1 * r;
        end
        --============================================================
        if (y_ < 0)
        then
            angle = -angle;     -- negate if in quad III or IV
        end
        --============================================================
        return angle;
    end
    --================================================================
    function CustomComponent:_lineToWithThicNess_X(x1,y1,x2,y2,thick)
        --force thickness
        for i=0,thick
        do
            local offset = 0.5* i -(0.5*thick/2)
            gfx.x = x1+offset
            gfx.y = y1
            gfx.lineto(x2+offset,y2)
        end
        --============================================================
    end
    --================================================================
    function CustomComponent:_lineToWithThicNess_Y(x1,y1,x2,y2,thick)
        --force thickness
        for i=0,thick
        do
            local offset = 0.5* i -(0.5*thick/2)
            gfx.x = x1
            gfx.y = y1+offset
            gfx.lineto(x2,y2+offset)
        end
        --============================================================
    end
    --================================================================
    function CustomComponent:_drawBuffer()
        --============================================================
        -- meter Value draw
        --============================================================
        local _movewidth = math.min(self.w,self.h)/2 -10;
        local cx = self:getCenterPoint().x;
        local cy = self:getCenterPoint().y;
        gfx.x = cx;
        gfx.y = cy;
        --============================================================
        local max_L = 0;
        local max_R = 0;
        local lastX = cx;
        local lastY = cy;

        --============================================================
        for i,v in ipairs (self._sumpleBuffer)
        do
            gfx.set( WaveColor_Red
                    ,WaveColor_Green
                    ,WaveColor_Blue
                    ,WaveColor_Alpha * self._componentAlpha*(1-1/#self._sumpleBuffer*i) -- alpha fadeOut
                    ,0x00);
            --========================================================
            local x = cx + v.l* _movewidth *0.9 ;-- or * math.log(2) ?? or 0.6 ~ ??
            local y = cy + v.r* _movewidth *0.9 ;
            --========================================================
            max_L =math.max(math.abs(v.l),max_L);
            max_R =math.max(math.abs(v.r),max_R);
            --========================================================
            local rotX,rotY = rotPoint(cx,cy,x,y,math.rad(45));
            --========================================================
            self:_lineToWithThicNess_X(lastX,lastY,rotX,rotY,WaveThickNess_)
            --========================================================
            lastX = rotX;
            lastY = rotY;
            --========================================================
        end
        --============================================================
        gfx.lineto(cx,cy);
        --============================================================
        -- direction line
        --============================================================
        gfx.set( DirectionColor_Red
                ,DirectionColor_Green
                ,DirectionColor_Blue
                ,DirectionColor_Alpha * self._componentAlpha,0x00); -- alpha fadeOut
        --============================================================

        --============================================================
        local angleDeg = 90* self._jsFx_LRC_direction ;
        --============================================================
        self._lastAngleDeg = self._lastAngleDeg +(angleDeg- self._lastAngleDeg)/self._jsFx_DirectionAngle_Speed;
        --============================================================
        local rotXMax1,rotYMax1 = rotPoint(cx,cy,cx,cy-_movewidth*0.9,math.rad(self._lastAngleDeg-45));
        local rotXMax2,rotYMax2 = rotPoint(cx,cy,cx,cy+_movewidth*0.9,math.rad(self._lastAngleDeg-45));
        --============================================================
        self:_lineToWithThicNess_X(rotXMax1,rotYMax1,rotXMax2,rotYMax2,DirectionThickNess_)
        --============================================================
        -- dirction bounds area
        --============================================================
        local size = (self._lastMax_L+self._lastMax_R)/2;
        self._lastSize = self._lastSize  + (size -self._lastSize ) / self._jsFx_Value_Speed ;
        --============================================================
        if ( self._drawTypeState == 0)
        then
            --========================================================
            self:_drawDiamond( cx, cy
                             , _movewidth/3 * self._lastMax_L
                             , _movewidth/3 * self._lastMax_R
                             , _movewidth*0.7 * self._lastSize,math.rad(self._lastAngleDeg-45)  )
            --========================================================
        elseif(self._drawTypeState == 1 )
        then
            --========================================================
            self:_drawEllipseOutLine( cx, cy
                                    , _movewidth *self._lastMax_L
                                    , _movewidth *self._lastMax_R
                                    , _movewidth*0.7 * self._lastSize
                                    , math.rad(self._lastAngleDeg-45),8 )
            --========================================================
        elseif(self._drawTypeState == 2 )
        then
            self:_drawEllipseBox( cx, cy
                                , _movewidth *self._lastMax_L
                                , _movewidth *self._lastMax_R
                                , _movewidth*0.7 * self._lastSize
                                , math.rad(self._lastAngleDeg-45),6 )
        elseif(self._drawTypeState == 3 )
        then
            self:_drawEllipseAndDiamond( cx, cy
                                       , _movewidth *self._lastMax_L
                                       , _movewidth *self._lastMax_R
                                       , _movewidth*0.7 * self._lastSize
                                       , math.rad(self._lastAngleDeg-45),8 )
            --========================================================
        elseif(self._drawTypeState == 4 )
        then
            self:_drawEllipseBox( cx, cy
                                , _movewidth *self._lastMax_L
                                , _movewidth *self._lastMax_R
                                , _movewidth*0.7 * self._lastSize
                                , math.rad(self._lastAngleDeg-45),8 );
            --========================================================
            self:_drawEllipseAndDiamond( cx, cy
                                       , _movewidth *self._lastMax_L
                                       , _movewidth *self._lastMax_R
                                       , _movewidth*0.7 * self._lastSize
                                       , math.rad(self._lastAngleDeg-45),8 );
            --========================================================
        end
        --============================================================
        self._lastMax_L = self._lastMax_L + (self._jsFx_maxAbsL -self._lastMax_L)/1.8;
        self._lastMax_R = self._lastMax_R + (self._jsFx_maxAbsR -self._lastMax_R)/1.8;
        --============================================================
    end
    --================================================================
    function CustomComponent:_drawGrid()
        --============================================================
        local _movewidth = math.min(self.w,self.h)/2 -10;
        local cx = self:getCenterPoint().x
        local cy = self:getCenterPoint().y
        local radius = 1
        --============================================================
        -- grid
        --============================================================
        gfx.set(0,0,0,0.8*self._componentAlpha);
        gfx.setfont(1,"Arial", 15) --font
        --============================================================
        local function _drawGridLine_(width_)
            --========================================================
            local rotX1,rotY1 = rotPoint(cx,cy,cx,cy+width_,math.rad(45));
            local rotX2,rotY2 = rotPoint(cx,cy,cx,cy+width_,math.rad(225));
            --========================================================
            local xx1 = cx-_movewidth
            local yy1 = cy-_movewidth
            local xx2 = cx+_movewidth
            local yy2 = cy+_movewidth
            gfx.line (rotX1,rotY1,rotX2,rotY2)
            gfx.line (rotX2,rotY1,rotX1,rotY2)
            --========================================================
            gfx.x = rotX1 -gfx.texth /2
            gfx.y = rotY2 -gfx.texth
            gfx.drawstr ("L" )
            --========================================================
            gfx.x = rotX2
            gfx.y = rotY2 -gfx.texth
            gfx.drawstr ("R" )
            --========================================================
        end
        --============================================================
        local function _drawMoviengCircle(rad,width)
            --========================================================
            local rotX,rotY = rotPoint(cx,cy,cx,cy+width,rad );
            --========================================================
            gfx.circle(rotX,rotY,3.2,true,true)
            --========================================================
        end
        --============================================================
        _drawGridLine_(_movewidth);
        --============================================================
        gfx.set(1,1,1,0.9*self._componentAlpha);
        --============================================================
        local num_ =5
        for i=1,num_
        do
            _drawMoviengCircle( math.rad( self._animTime*360 - 360/num_*i )    ,_movewidth)
        end
        --============================================================

        --============================================================
        gfx.set(0,0,0,0.8*self._componentAlpha);
        gfx.x = gfx.texth -- /2
        gfx.y = cy -gfx.texth/2
        gfx.drawstr ("+S")
        gfx.x = gfx.w -gfx.texth*2 -- /2
        gfx.y = cy -gfx.texth/2
        gfx.drawstr ("-S")
        --============================================================
        gfx.x = cx -gfx.texth/4
        gfx.y = cy -_movewidth*0.97 + gfx.texth/6
        gfx.drawstr ("M")
        --============================================================
    end
    --================================================================
    function CustomComponent:_getJSFXParame()
        --============================================================
        --self.targetTrack = reaper.GetTrack(proj, self.lastTrackID -1); --
        --============================================================
        self._track = reaper.GetSelectedTrack2(0, 0, true) --selection track
        --============================================================
        local function _insertSampleTable(L_,R_)
            local temp = {}
            temp.l = L_;
            temp.r = R_;
            --========================================================
            --like circle buffer
            table.remove(self._sumpleBuffer,#self._sumpleBuffer);
            table.insert(self._sumpleBuffer,1,temp );
            --========================================================
        end
        --============================================================
        function string._kawaMatch(str1,str2)
            -- remove white space
            local _w_str1 = string.gsub(str1," ","");
            local _w_str2 = string.gsub(str2," ","");
            -- lower match
            -- return ( string.match(string.lower(_w_str1),string.lower(_w_str2) )  )
            return ( _w_str1 == _w_str2 ) --all check
        end
        --============================================================
        self._isExistTargetFx = false;
        --============================================================
        if ( self._track ~= nil)
        then
            --========================================================
            local _totalFxNum =reaper.TrackFX_GetCount( self._track );
            --========================================================
            local fxCount = 0;
            local l0,l1,l2,l3,l4 r0,r1,r2,r3,r4 = 0;
            while (fxCount <_totalFxNum)
            do
                --====================================================
                local check_S,
                _name = reaper.TrackFX_GetFXName(self._track,fxCount,"")
                --====================================================
                if (  string.match(string.lower(_name)
                                  ,string.lower(DEFINE_LOADING_FX_NAME) ) ~= nil ) -- didnt string.find()
                -- if ( DEFINE_LOADING_FX_NAME == _name )
                then

                    --================================================
                    -- how to check fx param name and fx param index.
                    --================================================
                    -- if (ONE_TIME_CALL_CHECK_ABCDEFG_ ~= true) -- then first call
                    -- then
                    --     local paramNum = reaper.TrackFX_GetNumParams(self._track, fxCount)
                    --     local pCount = 0;
                    --     --============================================
                    --     while ( pCount <paramNum)
                    --     do
                    --         -- need DBG ()
                    --         DBG( pCount,reaper.TrackFX_GetParamName(self._track, fxCount, pCount, ""))
                    --         pCount = pCount+1;
                    --     end
                    --     --============================================
                    --     ONE_TIME_CALL_CHECK_ABCDEFG_ = true; --
                    -- end
                    --================================================

                    --================================================
                    -- check by parameter name.
                    --================================================
                    local totalParamCount =  reaper.TrackFX_GetNumParams(self._track,fxCount );
                    local paramCount = 0
                    --================================================
                    while ( paramCount < totalParamCount)
                    do
                        local check_pName
                            , parameterName = reaper.TrackFX_GetParamName( self._track
                                                                         , fxCount
                                                                         , paramCount,"");
                        --============================================
                        if ( check_pName ~= true )
                        then    break;
                            --========================================
                        elseif ( string._kawaMatch(parameterName,"Stereo Direction( L-C-R )") )
                        then     self._jsFx_LRC_direction = reaper.TrackFX_GetParam(self._track, fxCount, paramCount);
                            --========================================
                        elseif ( string._kawaMatch(parameterName,"In L sample") )
                        then     self._jsFx_InL = reaper.TrackFX_GetParam(self._track, fxCount, paramCount);
                            --========================================
                        elseif ( string._kawaMatch(parameterName,"In R sample") )
                        then     self._jsFx_InR = reaper.TrackFX_GetParam(self._track, fxCount, paramCount);
                            --========================================
                        elseif ( string._kawaMatch(parameterName,"Max L abs Value") )
                        then     self._jsFx_maxAbsL = reaper.TrackFX_GetParam(self._track, fxCount, paramCount);
                            --========================================
                        elseif ( string._kawaMatch(parameterName,"Max R abs Value") )
                        then     self._jsFx_maxAbsR = reaper.TrackFX_GetParam(self._track, fxCount, paramCount);
                            --========================================
                        elseif ( string._kawaMatch(parameterName,"Direction Angle Speed") )
                        then     self._jsFx_DirectionAngle_Speed = reaper.TrackFX_GetParam(self._track, fxCount, paramCount);
                            --========================================
                        elseif ( string._kawaMatch(parameterName,"Value Speed") )
                        then     self._jsFx_Value_Speed = reaper.TrackFX_GetParam(self._track, fxCount, paramCount);
                            --========================================
                        elseif ( string._kawaMatch(parameterName," Buffer S i z e ( x 2 0 ) ") ) --white space test
                        -- elseif ( string._kawaMatch(parameterName,"Bufer Size ABCDEFG ( x 20)") ) --test
                        then
                            --========================================
                            if (self._bufferNum  ~= math.floor( reaper.TrackFX_GetParam(self._track, fxCount, paramCount) ) )
                            then
                                self._bufferNum = math.floor( reaper.TrackFX_GetParam(self._track, fxCount, paramCount) );
                                self:_crearBuffer();
                            end
                            --========================================

                            --========================================
                        elseif ( string._kawaMatch(parameterName,"In L sample 0") )
                        then    l0 = reaper.TrackFX_GetParam(self._track, fxCount,paramCount);-- head sample L
                            --========================================
                        elseif (string._kawaMatch(parameterName,"In L sample 1") )
                        then    l1 = reaper.TrackFX_GetParam(self._track, fxCount,paramCount);
                            --========================================
                        elseif (string._kawaMatch(parameterName,"In L sample 2") )
                        then    l2 = reaper.TrackFX_GetParam(self._track, fxCount,paramCount);
                            --========================================
                        elseif (string._kawaMatch(parameterName,"In L sample 3") )
                        then    l3 = reaper.TrackFX_GetParam(self._track, fxCount,paramCount);
                            --========================================
                        elseif (string._kawaMatch(parameterName,"In L sample 4") )
                        then    l4 = reaper.TrackFX_GetParam(self._track, fxCount,paramCount);-- 4 sample delayed
                            --========================================

                            --========================================
                        elseif ( string._kawaMatch(parameterName,"In R sample 0") )
                        then    r0 = reaper.TrackFX_GetParam(self._track, fxCount,paramCount);-- head sample R
                            --========================================
                        elseif (string._kawaMatch(parameterName,"In R sample 1") )
                        then    r1 = reaper.TrackFX_GetParam(self._track, fxCount,paramCount);
                            --========================================
                        elseif (string._kawaMatch(parameterName,"In R sample 2") )
                        then    r2 = reaper.TrackFX_GetParam(self._track, fxCount,paramCount);
                            --========================================
                        elseif (string._kawaMatch(parameterName,"In R sample 3") )
                        then    r3 = reaper.TrackFX_GetParam(self._track, fxCount,paramCount);
                            --========================================
                        elseif (string._kawaMatch(parameterName,"In R sample 4") )
                        then    r4 = reaper.TrackFX_GetParam(self._track, fxCount,paramCount);-- 4 sample delayed
                            --========================================
                        end
                        --============================================
                        paramCount = paramCount + 1;
                    end
                    --================================================
                    --================================================
                    _insertSampleTable(l0,r0); -- 1
                    _insertSampleTable(l1,r1); -- 2
                    _insertSampleTable(l2,r2); -- 3
                    _insertSampleTable(l3,r3); -- 4
                    _insertSampleTable(l4,r4); -- 5
                    --================================================
                    self._isExistTargetFx =true;
                    --================================================
                    break; -- check only first plugin
                    --================================================
                end
                --====================================================
                fxCount = fxCount +1;
            end
            --========================================================
        end
        --============================================================
        if (self._isExistTargetFx ==false )
        then
            -- to reset
            self._jsFx_InL =0.0;
            self._jsFx_InR =0.0;
            self._jsFx_maxAbsL = 0.0;
            self._jsFx_maxAbsR = 0.0;
            self._jsFx_LRC_direction = 0.5; --centor;
            --========================================================
            _insertSampleTable(0,0); -- 1
            _insertSampleTable(0,0); -- 2
            _insertSampleTable(0,0); -- 3
            _insertSampleTable(0,0); -- 4
            _insertSampleTable(0,0); -- 5
        end
        --============================================================
    end
    --================================================================
    function CustomComponent:_drawPlayTime()
        --============================================================
        local fontsize = math.max (math.min(self.w,self.h)/12,20);
        --============================================================
        gfx.setfont(1,"Arial", fontsize) --font
        gfx.set(0,0,0,1*self._componentAlpha) --color r,g,b,a
        --============================================================
        local playTime = reaper.GetPlayPosition();
        --============================================================
        local min  = math.floor(playTime / 60 )
        local sec  = math.floor(playTime % 60 )
        local msec = playTime - math.floor(playTime)
        msec = math.floor ( msec*100)
        --============================================================
        local minStr  = tostring (min )
        local secStr  = tostring (sec )
        local msecStr = tostring (msec )
        if (#minStr <2 )  then minStr  = "0" .. minStr ;end
        if (#secStr <2 )  then secStr  = "0" .. secStr ;end
        if (#msecStr <2 ) then msecStr = "0" .. msecStr ;end
        --============================================================
        local playTimeStr = string.format("%s:%s:%s",minStr,secStr,msecStr);
        --============================================================
        gfx.y = gfx.h- gfx.texth
        gfx.x = gfx.w - (#playTimeStr-1) * gfx.texth/2 -5-- monospace
        gfx.drawstr(playTimeStr)
        --============================================================
        fontsize = math.min (math.min(self.w,self.h)/12,16);
        gfx.setfont(1,"Arial", fontsize) --font
        --============================================================
        --check L R string  text
        --============================================================
        local LR_Str = ""
        --============================================================
        if ( self._lastAngleDeg-45 <0)
        then
            LR_Str = string.format("%.1f %%",(self._lastAngleDeg-45) /-45 * 100 ).. " : L" ;
        elseif( self._lastAngleDeg-45 ==0)
        then
            LR_Str ="C : "
        else
            LR_Str = string.format("%.1f %%",(self._lastAngleDeg-45) / 45 * 100 ).. " : R" ;
        end
        --============================================================
        -- LR_Str = LR_Str .. string.format(" %2.2f deg",(self._lastAngleDeg-45) )
        --============================================================
        gfx.x = gfx.w - (#LR_Str-1) * gfx.texth/2 -- monospace;
        gfx.y = self.y + 5
        gfx.drawstr (LR_Str);
        --============================================================

        -- Type and animation
        --============================================================
        _drawTypeState = 0; -- 0 diamond,1 elipse line ,2 elipsebox,3 elipseDia,4 all
        local typeText = "";
        --============================================================
        if     (self._drawTypeState == 0)then typeText = "Diamondo" ;
        elseif (self._drawTypeState == 1)then typeText = "Ellipse" ;
        elseif (self._drawTypeState == 2)then typeText = "Ellipse Box" ;
        elseif (self._drawTypeState == 3)then typeText = "Ellipse and Diamondo" ;
        elseif (self._drawTypeState == 4)then typeText = "Ellipse Box and Diamondo" ;
        end
        --============================================================
        if ( self._isExistTargetFx ==false)
        then
            typeText = "can\'t find Gonio Meter Ex jsfx.please insert Gonio Meter Ex jsfx."
        end
        --============================================================

        --============================================================
        gfx.x = 0 +gfx.texth/2;
        gfx.y = self.y + 5
        gfx.drawstr ( typeText );
        --============================================================

        --============================================================
        typeText = "Color Animation ";
        if (self._animationState ==true )
        then
            typeText = typeText .. "On : ";
        else
            typeText = typeText .. "Off : ";
        end
        --============================================================
        typeText = typeText .. math.floor(DEFINE_BACKGROUND_COLOR_HUE);
        gfx.x = self.x+10;
        gfx.y = gfx.h- gfx.texth-5
        gfx.drawstr (typeText);
        --============================================================
    end
    --================================================================

    --================================================================
    CustomComponent:_init()
    --================================================================
    return CustomComponent ;
    --================================================================
end
--====================================================================

--====================================================================
local function main()
    --================================================================
    local mainFrame = createApp("Gonio Meter EX",450,450); -- width ,height
    --================================================================
    local panel = createGonioMeter_EX("panel");
    panel._isDrawBackGridFill =true;
    mainFrame:addChildComponent(panel);
    --================================================================

    -- main loop
    --================================================================
    mainFrame:runLoop();
    --================================================================
end
--====================================================================

--====================================================================
if ( _INCLUDE_MODE_ ~= true)
then
    main()
end
--====================================================================
