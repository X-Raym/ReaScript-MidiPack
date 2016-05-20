--====================================================================== 
--[[ 
* ReaScript Name: kawa_MIDI_DetectBottomNote. 
* Version: 2016/06/15 
* Author: kawa_ 
* Author URI: http://forum.cockos.com/member.php?u=105939 
* Repository: GitHub 
* Repository URI: https://github.com/kawaCat/ReaScript-MidiPack 
--]] 
--====================================================================== 
_W_MODE_ON_=false;local u=300 local c=true local b=true if(_W_MODE_ON_==true)then u=500;c=true;end math.randomseed(reaper.time_precise()*os.time()/1e3);local e=40659 local r=40681 local y=40832 local g=40501 local e=40003 local k=40214 local t="kawa_MidiClip"local l="lastEditCursolTime"local w="lastAutoSelectionState"local f="lastAutoSelectionMinPitch"local v="lastAutoSelectionMaxPitch"local m="lastAutoSelectionExistPitch"local q="lastCropSelectionNotesTable"local p="lastsVelNotesTable"local d={"4,0","4,1","2,0","2,1","1,0","1,1","0.5,0","0.5,1","0.25,0","0.25,1"}function deepcopy(t)local a=type(t)local e if a=='table'then e={}for a,t in next,t,nil do e[deepcopy(a)]=deepcopy(t)end setmetatable(e,deepcopy(getmetatable(t)))else e=t end return e end function string:split(e)local t,e=e or":",{}local t=string.format("([^%s]+)",t)self:gsub(t,function(t)e[#e+1]=t end)return e end function table.toString(a)local function l(e)return string.format("%q",e)end local d="";local function e(e)d=d..e end;local r,t="   ","\n"local h,a={a},{[a]=1}e("return {"..t)for o,s in ipairs(h)do e("-- Table: {"..o.."}"..t)e("{"..t)local n={}for i,o in ipairs(s)do n[i]=true local i=type(o)if i=="table"then if not a[o]then table.insert(h,o)a[o]=#h end e(r.."{"..a[o].."},"..t)elseif i=="string"then e(r..l(o)..","..t)elseif i=="number"then e(r..tostring(o)..","..t)end end for i,o in pairs(s)do if(not n[i])then local n=""local s=type(i)if s=="table"then if not a[i]then table.insert(h,i)a[i]=#h end n=r.."[{"..a[i].."}]="elseif s=="string"then n=r.."["..l(i).."]="elseif s=="number"then n=r.."["..tostring(i).."]="end if(n~="")then s=type(o)end if s=="table"then if not a[o]then table.insert(h,o)a[o]=#h end e(n.."{"..a[o].."},"..t)elseif s=="string"then e(n..l(o)..","..t)elseif s=="number"then e(n..tostring(o)..","..t)elseif s=="boolean"then e(n..tostring(o)..","..t)end end end e("},"..t)end e("}")return d;end function table.fromString(e)local e=load(e);local e=e()if(type(e)~="table")then local e={}return e end for t=1,#e do local o={}for a,i in pairs(e[t])do if type(i)=="table"then e[t][a]=e[i[1]]end if type(a)=="table"and e[a[1]]then table.insert(o,{a,e[a[1]]})end end for o,a in ipairs(o)do e[t][a[2]],e[t][a[1]]=e[t][a[1]],nil end end return e[1]end function stringIter(t)local e=0;local a=string.len(t);return function()e=e+1;if(e>a)then return nil else return e,string.sub(t,e,e)end end end if(_DBG_==true)then _W_MODE_ON_=true u=500;c=true;dofile(reaper.GetResourcePath().."\\Scripts\\ReaScript_MIDI\\_kawa_DBG.lua")else function DBG()end;end function createMIDIClip()local e={}e.editorHwnd=nil;e.mediaTrack=nil;e.mediaItem=nil;e.take=nil;e.mediaItemInfo={};e.actionContextInfo={};e.loopRangeInfo={};e.editingNotes={}e.m_originalNotes={};e.m_isSelection=nil e.m_firstSelectionCheck=nil;e.m_processLimitNoteNum=u;e.m_processLimitNoteNum_min=0;function e:isMidiEditorActive()return(self.editorHwnd~=nil);end function e:isSelectionInEditingNotes(e)if(self.m_firstSelectionCheck==nil or e~=nil)then for t,e in ipairs(self.editingNotes)do if(e.selection==true)then self.m_isSelection=true;break;end self.m_isSelection=false;end self.m_firstSelectionCheck=true;end return self.m_isSelection;end function e:checkProcessLimitNum()if(self:isMidiEditorActive()~=true)then return false;end local e=self:_checkProcessLimitNum()if(e~=true and#self.editingNotes>1 and c==true)then local e=self.m_processLimitNoteNum;reaper.ShowMessageBox("over "..tostring(e).." notes.\nstop process.","stop",0)end return e;end function e:setProcessLimitNum(e)self.m_processLimitNoteNum=e end function e:setProcessLimitNum_Min(e)self.m_processLimitNoteNum_min=e end function e:callReaperCommand(e)if(self:isMidiEditorActive())then reaper.MIDIEditor_OnCommand(self.editorHwnd,e)end end function e:changeOctave(e)self:transpose(12*math.floor(e));end function e:transpose(e)local t=math.floor(e);local e=self:_detectTargetNotes()for a,e in ipairs(e)do e.pitch=e.pitch+t if(e.pitch<0)then e.pitch=e.pitch+127-7;end if(e.pitch>127)then e.pitch=e.pitch-127+7;end end end function e:changeLengh(e)local t=e or .8;local e=self:_detectTargetNotes()for a,e in ipairs(e)do local a=e.startpos+e.length*t;if(self.mediaItemInfo.endProjQN>=a)then e.length=e.length*t;e.endpos=e.startpos+e.length;end end end function e:changeStartPos(e)local t=e or .8;local e=self:_detectTargetNotes()for a,e in ipairs(e)do local t=e.length*(1-t)local a=e.startpos-t;if(self.mediaItemInfo.startProjQN<=a)then e.startpos=e.startpos-t;e.length=e.length+t;e.endpos=e.startpos+e.length;end end end function e:changeVelocity(e)local t=e or .8;local e=self:_detectTargetNotes()for a,e in ipairs(e)do if(t>1)then e.vel=math.floor(e.vel*t);elseif(t<=1)then e.vel=math.floor(e.vel*t);end if(e.vel>127)then e.vel=127;end if(e.vel<1)then e.vel=1;end end end function e:changeVelocityDistance(e)local o=e or .2;local a=self:_detectTargetNotes()local t=0;local e=200;for o,a in ipairs(a)do e=math.min(a.vel,e);t=math.max(a.vel,t);end local t=(t+e)/2 for a,e in ipairs(a)do local a=0;if(e.vel>=t)then a=(e.vel-t)*o;else a=-(t-e.vel)*o;end e.vel=math.floor(e.vel+a);if(e.vel>127)then e.vel=127;end if(e.vel<0)then e.vel=1;end end end function e:randomVelocity(e)local o=e or 60;local e=reaper.GetExtState(t,l);local i=reaper.GetCursorPosition();e=tonumber(e)or 0 local a=self:_detectTargetNotes();if(math.floor(e*1e3)/1e3~=math.floor(i*1e3)/1e3)then local e=self:_detectTargetNotes();local e=table.toString(e)reaper.SetExtState(t,p,e,false);else local e=reaper.GetExtState(t,p);a=table.fromString(e);if(#a<1)then local e=self:_detectTargetNotes();end end local e=self:_detectTargetNotes();if(#e~=#a)then a=deepcopy(e)end for t,e in ipairs(e)do e.vel=a[t].vel+(math.random()*o)-(o/2);e.vel=math.floor(e.vel);if(e.vel>127)then e.vel=127;end if(e.vel<0)then e.vel=1;end end reaper.SetExtState(t,l,tostring(i),false);end function e:fixVelocity()local t,e=reaper.GetUserInputs("fix Velocity",7,"velocity (1 ~127)","90,--,--,--,--,--,--")if(t~=true)then return;end local t=tonumber(e:split(",")[1])or 90;local e=self:_detectTargetNotes();for a,e in ipairs(e)do e.vel=math.floor(t);if(e.vel>127)then e.vel=127;end if(e.vel<0)then e.vel=1;end end end function e:velocityInterpolation(o,a)local t=self:_detectTargetNotes();table.sort(t,function(e,t)return(e.startpos<t.startpos)end);local n=o or 3 local h=a or 0 local function r(a,t,e,n)local o=0;if(e==1)then o=a*t elseif(e==2)then local e=a*t;o=e+math.sin(math.rad(360*t))*a/4;elseif(e==3)then local function i(e)e=e*2 if e<1 then return .5*e*e*e else e=e-2 return .5*(e*e*e+2)end end local e=i(t)o=a*e;end local e=0 if(t~=0 and t~=1)then e=n*math.random();end return o+e end local a=t[1].startpos;local e=t[#t].startpos;local o=t[1].vel;local s=t[#t].vel;local i=(e-a)or 1;local s=s-o;if(i<=0)then return end for t,e in ipairs(t)do local t=(e.startpos-a)/i local t=o+r(s,t,n,h)e.vel=t;if(e.vel>127)then e.vel=127-(e.vel-127);end if(e.vel<0)then e.vel=1-e.vel;end e.vel=math.floor(e.vel);end end function e:splitNote(t)local a=self:_detectTargetNotes()local e=t local i=self:_getSelectionNoteCount(a)local o={}for a,e in ipairs(a)do if(e.length>.001)then e.length=(e.length/t);e.endpos=e.startpos+e.length-1e-6;for a=1,t-1,1 do local t=deepcopy(e);t.startpos=t.startpos+(t.length)*a t.endpos=t.startpos+e.length t.selection=true;table.insert(o,t);end end end self:insertNotesFromC(o);if(i==0)then for t,e in ipairs(a)do e.selection=true end end end function e:copyToOctaveUp()local e=self:_detectTargetNotes()for t,e in ipairs(e)do local e=deepcopy(e)e.pitch=e.pitch+12;if(e.pitch<0)then e.pitch=e.pitch+127-7;end if(e.pitch>127)then e.pitch=e.pitch-127+7;end self:insertNoteFromC(e);end end function e:copyToOctaveDown()local e=self:_detectTargetNotes()for t,e in ipairs(e)do local e=deepcopy(e)e.pitch=e.pitch-12;if(e.pitch<0)then e.pitch=e.pitch+127-7;end if(e.pitch>127)then e.pitch=e.pitch-127+7;end self:insertNoteFromC(e);end end function e:resolveOverLap()local t=self:_detectTargetNotes()table.sort(t,function(t,e)return(t.startpos<e.startpos)end);for a,e in ipairs(t)do for a,t in ipairs(t)do if(e.idx<=t.idx and e.startpos~=t.startpos and e.endpos>t.startpos)then e.endpos=t.startpos;e.length=e.endpos-e.startpos;end end end end function e:deleteAllNote()self.editingNotes={};end function e:nudgeNote(e)local t=e or .8;local e=1/4 local a=1/32 local t=e*t;local e=self:_detectTargetNotes()for o,e in ipairs(e)do if(e.length>a)then e.startpos=e.startpos+t;e.endpos=e.endpos+t;e.length=e.endpos-e.startpos;end end end function e:strokeDown(a)local e=self:_detectTargetNotes()local t=self:_getExistStartPosTable(e);local a=a or .005 local o=1;for i,t in ipairs(t)do local e,t=self:_getSameStartPosNotes(t,e,o);for o,t in ipairs(e)do t.startpos=t.startpos+a*(#e-o)end end end function e:strokeUp(t)local e=self:_detectTargetNotes()local i=self:_getExistStartPosTable(e);local o=t or .015 local a=1;for i,t in ipairs(i)do local e,t=self:_getSameStartPosNotes(t,e,a);for t,e in ipairs(e)do e.startpos=e.startpos+o*(t-1)end end end function e:simpleDuplicate()local i=self.mediaItemInfo;local t=self:_detectTargetNotes();local e=self:_getFinalEndPos(t)local a=self:_getFirstStartPos(t)local o=e-a;local a={}for n,e in ipairs(t)do local e=deepcopy(e);e.startpos=e.startpos+o;e.endpos=e.endpos+o;if(i.endProjQN>=e.endpos)then e.selection=true;table.insert(a,e);else end t[n].selection=false;end self:insertNotesFromC(a);end function e:simpleDuplicateType3()local a=self:_detectTargetNotes();local t=self:_getFinalEndPos(a)local e=self:_getFirstStartPos(a)local e=t-e;local t=0;if(e<=.25)then t=.25-e elseif(e<=.5)then t=.5-e elseif(e<=1)then t=1-e elseif(e<=2)then t=2-e elseif(e<=4)then t=4-e else local a=math.floor(e/4+.6);local a=a*4;t=a-e;end e=e+t;e=math.floor((e)*100)/100;local i={}for t,o in ipairs(a)do local t=deepcopy(o);t.startpos=t.startpos+e;t.endpos=t.endpos+e;o.selection=false;if(self.mediaItemInfo.endProjQN>=t.endpos)then t.selection=true;table.insert(i,t);else end a.selection=false;end self:insertNotesFromC(i);end function e:growUp(e,a)local t=self:_detectTargetNotes();local n=a or .25 local s={}local h={}local o=e or 4;local function r(e)return n/(o/e)end for e,t in ipairs(t)do local a=-1;for i=o,1,-1 do local e=deepcopy(t);e.pitch=t.pitch-(o)+i;local o=r(i)e.startpos=t.startpos+(n*o);if(a~=-1)then e.endpos=a+.1 end table.insert(s,e);a=e.startpos end table.insert(h,t);end self:deleteNotes(h);self:insertNotesFromC(s);end function e:twoNoteNudge(e)local a=self:_getSelectionNotes();if(#a~=2)then return end;table.sort(a,function(e,t)return(e.startpos<t.startpos);end);local o=e or .9;local t=a[1];local e=a[2];if((t.length<.015 or e.length<.015)and t.startpos>=e.startpos)then return;end local o=t.length*o;local i=t.startpos+o;local n=i;local s=e.endpos-n;if(o>.01 and s>.01 and i<e.endpos)then t.length=o;t.endpos=i;e.startpos=n;e.length=s;end self:deleteNotes(a);self:insertNoteFromC(t);self:insertNoteFromC(e);end function e:selectAllNoteCurrentTake()reaper.PreventUIRefresh(1)reaper.MIDIEditor_OnCommand(self.editorHwnd,k)reaper.PreventUIRefresh(-1)reaper.MIDI_SelectAll(self.take,true);end function e:noteLengthToEnd()local e=self:_detectTargetNotes();local t=self:_getFinalEndPos(e)for a,e in ipairs(e)do e.endpos=t;end end function e:legatoType2()local t=self:_detectTargetNotes();local e=self:_getExistStartPosTable(t);local i=1;for a,o in ipairs(e)do local t,i=self:_getSameStartPosNotes(o,t,i);for i,t in pairs(t)do local t=t if(a+1<=#e and t.startpos>=o and t.endpos<e[a+1]and t.startpos<e[a+1])then t.endpos=e[a+1]end end end end function e:autoSelection(e)local s=e or 1 local i=reaper.GetExtState(t,l);local n=reaper.GetCursorPosition();i=tonumber(i)or 0 local o=0;local a=127;local e={}if(math.floor(i*1e3)/1e3~=math.floor(n*1e3)/1e3)then local i=self:_detectTargetNotes();o,a=self:_getMaxMinPitch(i);e=self:_getExistPitchNumber(i);local e=table.toString(e)reaper.SetExtState(t,m,e,false);reaper.SetExtState(t,f,tostring(o),false);reaper.SetExtState(t,v,tostring(a),false);else o=reaper.GetExtState(t,f);a=reaper.GetExtState(t,v);o=tonumber(o)or 0 a=tonumber(a)or 127 local t=reaper.GetExtState(t,m);e=table.fromString(t);if(#e<1)then local t=self:_detectTargetNotes();e=self:_getExistPitchNumber(t);end end self.editingNotes=self:_getNotes_(false)self.m_originalNotes=deepcopy(self.editingNotes);local a=reaper.GetExtState(t,w);if(a==nil or a=="")then a=d[1];end;local o=nil for e,t in ipairs(d)do if(t==a)then local e=e+s;if(e>#d)then e=1;end if(e<1)then e=#d;end o=d[e];break;end end local a=self.loopRangeInfo.startProjQN;local s=self.loopRangeInfo.endProjQN;local i=self.loopRangeInfo.lengthProjQN;local h=tonumber(o:split(",")[1]);local r=tonumber(o:split(",")[2]);for o,t in ipairs(self.editingNotes)do t.selection=false;local o=math.floor(t.startpos*100+.6)/100 for n,e in ipairs(e)do if((i<=0 or(t.startpos>=a and t.startpos<s))and e==t.pitch and(math.floor((o)/h))%2==r)then t.selection=true;end end end reaper.SetExtState(t,w,o,false);reaper.SetExtState(t,l,tostring(n),false);end function e:toggleSelectionCrop()local e=self.mediaItemInfo.ptrID;local e=q.."_"..e;local a=reaper.GetExtState(t,e);if(a~="")then local a=table.fromString(a)self:_selectionReset(a);self:insertNotesFromC(a)reaper.SetExtState(t,e,"",false);else if(self:_getSelectionNoteCount()<1)then reaper.SetExtState(t,e,"",false);return end local a=deepcopy(self.editingNotes);reaper.MIDIEditor_OnCommand(self.editorHwnd,g)self.editingNotes=self:_getNotes();self.m_originalNotes=deepcopy(self.editingNotes);local a=self:_detectTargetNotes();reaper.SetExtState(t,e,table.toString(a),false);self:deleteNotes(a);end end function e:detectTopNote()local e=self:_detectTargetNotes();local t=self:_getExistStartPosTable(e);local a={}local o=1;for i,t in ipairs(t)do local t,e=self:_getSameStartPosNotes(t,e,o);local e=-1 for a,t in ipairs(t)do if(e<t.pitch)then e=t.pitch end end if(#t>1)then for o,t in ipairs(t)do if(t.pitch<e)then table.insert(a,t)end end end end self:deleteNotes(a);end function e:detectBottomNote()local e=self:_detectTargetNotes();local t=self:_getExistStartPosTable(e);local a={}local o=1;for i,t in ipairs(t)do local e,t=self:_getSameStartPosNotes(t,e,o);local t=200 for a,e in ipairs(e)do if(t>e.pitch)then t=e.pitch end end if(#e>1)then for o,e in ipairs(e)do if(e.pitch>t)then table.insert(a,e)end end end end self:deleteNotes(a);end function e:deleteTopNote()local e=self:_detectTargetNotes();local t=self:_getExistStartPosTable(e);local a={}local o=1;for i,t in ipairs(t)do local e,t=self:_getSameStartPosNotes(t,e,o);local t=-1 for a,e in ipairs(e)do if(t<e.pitch)then t=e.pitch end end if(#e>1)then for o,e in ipairs(e)do if(e.pitch==t)then table.insert(a,e)end end end end self:deleteNotes(a);end function e:deleteBottomNote()local e=self:_detectTargetNotes();local t=self:_getExistStartPosTable(e);local a={}local o=1;for i,t in ipairs(t)do local t,e=self:_getSameStartPosNotes(t,e,o);local e=200 local o=0;for a,t in ipairs(t)do if(e>t.pitch)then e=t.pitch end end if(#t>1)then for o,t in ipairs(t)do if(t.pitch==e)then table.insert(a,t)end end end end self:deleteNotes(a);end function e:selectTopNote()local e=self:_detectTargetNotes();local t=self:_getExistStartPosTable(e);local a=1;for o,t in ipairs(t)do local e,t=self:_getSameStartPosNotes(t,e,a);local t=-1 for a,e in ipairs(e)do if(t<e.pitch)then t=e.pitch end end if(#e>=1)then for a,e in ipairs(e)do if(e.pitch==t)then e.selection=true;else e.selection=false;end end end end end function e:selectBottomNote()local e=self:_detectTargetNotes();local t=self:_getExistStartPosTable(e);local a=1;for o,t in ipairs(t)do local t,e=self:_getSameStartPosNotes(t,e,a);local e=200 for a,t in ipairs(t)do if(e>t.pitch)then e=t.pitch end end if(#t>=1)then for a,t in ipairs(t)do if(t.pitch==e)then t.selection=true;else t.selection=false;end end end end end function e:generateSelectionArp()local i={}local o=self:_getMidiGrid()local function a(e)local t=0;for a,e in ipairs(e)do if(t<e.length and(self:isSelectionInEditingNotes()==true and e.selection==true or self:isSelectionInEditingNotes()==false))then t=e.length end end return t;end local function e(t)local e={}for a,t in ipairs(t)do if(self:isSelectionInEditingNotes()==true and t.selection==true or self:isSelectionInEditingNotes()==false)then table.insert(e,t)end end return e;end local function s()local e=self:_detectTargetNotes();local n=self:_getExistStartPosTable(e);local t=1;for s,n in ipairs(n)do local e,t=self:_getSameStartPosNotes(n,e,t);if(#e>1)then local t=a(e)local s=math.floor(t/o);local h=#e;table.sort(e,function(t,e)return(t.pitch<e.pitch)end);local a=e[1].startpos;local o=o*.99999;local t=1;local function n()t=t+1;if(t>h)then t=1;end end for i=1,s,1 do local e=deepcopy(e[t]);e.length=o;e.startpos=a e.endpos=e.startpos+e.length;self:insertNoteFromC(e)a=a+o;n();end for t,e in ipairs(e)do table.insert(i,e)end end end end s();self:deleteNotes(i);end function e:flush(e,t)if(self:_checkProcessLimitNum()==0)then return end;if(e==nil)then self:_deleteMinimunLengthNote();end if(t==nil)then self:_safeOverLap();end self:_deleteAllOriginalNote();self:_editingNoteToMediaItem();reaper.MIDI_Sort(self.take);end function e:reset()self.editingNotes={}self.editingNotes=deepcopy(self.m_originalNotes);end function e:insertNoteFromC(e)e.idx=#self.editingNotes+1;table.insert(self.editingNotes,e);end function e:insertNotesFromC(e)for t,e in ipairs(e)do self:insertNoteFromC(e)end end function e:insertMidiNote(a,o,e,i,s,n,h)local t=e local e=i local r=o;local d=s or false;local s=h or false;local i=n or 1;local o=a;local a=#self.editingNotes+1;local e={selection=d,mute=s,startpos=t,endpos=e,chan=i,pitch=o,vel=r,take=self.take,idx=a,length=e-t}table.insert(self.editingNotes,e);end function e:deleteNote(e)for a,t in ipairs(self.editingNotes)do if(t.idx==e.idx)then table.remove(self.editingNotes,a)break;end end end function e:deleteNotes(e)if(e==self.editingNotes)then self.editingNotes={};return;end for t,e in ipairs(e)do self:deleteNote(e)end end function e:_init()self.editorHwnd=reaper.MIDIEditor_GetActive();self.take=reaper.MIDIEditor_GetTake(self.editorHwnd);if(self.take==nil)then return end self:_storeActionContextInfo();local e=reaper.GetToggleCommandStateEx(self.actionContextInfo.sectionID,y);if(e==0)then reaper.MIDIEditor_OnCommand(self.editorHwnd,y)end self.mediaItem=reaper.GetMediaItemTake_Item(self.take);self.mediaTrack=reaper.GetMediaItemTrack(self.mediaItem);self.mediaItemInfo=self:_storeMediaItemInfo();self.loopRangeInfo=self:_storeTimeSelectionInfo();self.editingNotes=self:_getNotes();self.m_originalNotes=deepcopy(self.editingNotes);end function e:_storeTimeSelectionInfo()local a,o=reaper.GetSet_LoopTimeRange2(0,false,b,0,0,false)local i=reaper.MIDI_GetPPQPosFromProjTime(self.take,a);local n=reaper.MIDI_GetPPQPosFromProjTime(self.take,o);local r=reaper.MIDI_GetProjQNFromPPQPos(self.take,i);local h=reaper.MIDI_GetProjQNFromPPQPos(self.take,n);local e=o-a;local t=reaper.MIDI_GetPPQPosFromProjTime(self.take,e);local s=reaper.MIDI_GetProjQNFromPPQPos(self.take,t);if(e<=0)then t=0 s=0 end local e={startTime=a,endTime=o,lengthTime=e,startPpq=i,endPpq=n,lengthPpq=t,startProjQN=r,endProjQN=h,lengthProjQN=s}return e;end function e:_getMidiGrid()local a,t,e=reaper.MIDI_GetGrid(self.take);return a,t,e end function e:_storeActionContextInfo()local e,t,a,i,o,n,s=reaper.get_action_context();self.actionContextInfo={is_new_value=e,filename=t,sectionID=a,cmdID=i,mode=o,resolution=n,val=s};return self.actionContextInfo;end function e:_storeMediaItemInfo()local t=reaper.GetMediaItemInfo_Value(self.mediaItem,"D_POSITION");local e=reaper.GetMediaItemInfo_Value(self.mediaItem,"D_LENGTH");local i=t+e;local o=reaper.MIDI_GetPPQPosFromProjTime(self.take,t);local a=reaper.MIDI_GetPPQPosFromProjTime(self.take,e)local n=reaper.MIDI_GetPPQPosFromProjTime(self.take,i)local h=reaper.MIDI_GetProjQNFromPPQPos(self.take,o);local s=reaper.MIDI_GetProjQNFromPPQPos(self.take,a);local r=reaper.MIDI_GetProjQNFromPPQPos(self.take,n);local d=reaper.GetMediaItemInfo_Value(self.mediaItem,"IP_ITEMNUMBER");local e={startTime=t,lengthTime=e,endTime=i,startPpq=o,lengthPpq=a,endPpq=n,startProjQN=h,lengthProjQN=s,endProjQN=r,mediaItem=midiMediaItem,take=takeMidi,IP_NUM_RO=d,ptrID=tostring(self.mediaItem);}return e;end function e:_getNotes()local e={}if(_W_MODE_ON_==true)then e=self:_getNotes_(false);else e=self:_getNotes_(true);if(#e<1)then e=self:_getNotes_(false)end end return e;end function e:_getNotes_(i)local m=reaper.GetToggleCommandStateEx(self.actionContextInfo.sectionID,r);if(m==0)then reaper.MIDIEditor_OnCommand(self.editorHwnd,r)end local n={};local c=self.take if(self.take==nil)then return n end reaper.MIDI_Sort(self.take)local u,o,s,t,e,l,d,h=reaper.MIDI_GetNote(self.take,0)local a=0 while u do t=reaper.MIDI_GetProjQNFromPPQPos(c,t)e=reaper.MIDI_GetProjQNFromPPQPos(c,e)local r={selection=o,mute=s,startpos=t,endpos=e,chan=l,pitch=d,vel=h,take=self.take,idx=a,length=e-t}if(i==true and o==i or i==false)then table.insert(n,r);end a=a+1 u,o,s,t,e,l,d,h=reaper.MIDI_GetNote(self.take,a)end if(m==0)then reaper.MIDIEditor_OnCommand(self.editorHwnd,r)end return n;end function e:_deleteAllOriginalNote(e)local e=e or self.m_originalNotes;while(#e>0)do local t=#e;reaper.MIDI_DeleteNote(e[t].take,e[t].idx)table.remove(e,#e);end end function e:_insertNoteToMediaItem(e)local t=self.take if t==nil then return end local i=e.selection or false;local o=e.mute;local s=reaper.MIDI_GetPPQPosFromProjQN(t,e.startpos)local h=reaper.MIDI_GetPPQPosFromProjQN(t,e.endpos)local n=e.chan;local a=e.pitch;local e=e.vel;reaper.MIDI_InsertNote(t,i,o,s,h,n,a,e,false)end function e:_editingNoteToMediaItem()local e=reaper.GetToggleCommandStateEx(self.actionContextInfo.sectionID,r);if(e==0)then reaper.MIDIEditor_OnCommand(self.editorHwnd,r)end for t,e in ipairs(self.editingNotes)do self:_insertNoteToMediaItem(e)end if(e==0)then reaper.MIDIEditor_OnCommand(self.editorHwnd,r)end end function e:_safeOverLap(e)local a=e or self.editingNotes local function o(t,a)local e={}for o,t in ipairs(t)do if(a.pitch==t.pitch)then table.insert(e,t);end end table.sort(e,function(t,e)return(t.startpos<e.startpos)end);return e;end table.sort(a,function(t,e)return(t.startpos<e.startpos)end);local a=deepcopy(a);local i={};local n={};while(#a>0)do local o=o(a,a[1]);while(#o>=2)do local e=o[1]local t=o[2]if(t~=nil and e.startpos<t.startpos and e.endpos>t.startpos)then table.insert(n,e);e.endpos=t.startpos-.001;e.length=e.endpos-e.startpos;t.startpos=e.endpos+.001;table.insert(i,e);end table.remove(o,1);end table.remove(a,1);end self:deleteNotes(n);self:insertNotesFromC(i);end function e:_deleteMinimunLengthNote()local t={}for a,e in ipairs(self.editingNotes)do if(e.endpos-e.startpos<.001)then table.insert(t,e);end end self:deleteNotes(t);end function e:_checkProcessLimitNum()local e=true;if(#self.editingNotes<self.m_processLimitNoteNum_min+1)then e=false end;if(#self.editingNotes>=self.m_processLimitNoteNum)then e=false;end;return e;end function e:_detectTargetNotes()local e=nil if(self:isSelectionInEditingNotes()==true)then e=self:_getSelectionNotes(self.editingNotes);else e=self.editingNotes end return e;end function e:_getSameStartPosNotes(i,a,t)local e={};local t=t or 1;local a=a or self.editingNotes;for o=t,#a do local a=a[o]if(a.startpos==i)then table.insert(e,a);t=o end end table.sort(e,function(t,e)return(t.pitch>e.pitch)end);return e,t;end function e:_getExistStartPosTable(e)local t={}local e=e or self.editingNotes;table.sort(e,function(e,t)return(e.startpos<t.startpos)end);local a=-100;for o,e in ipairs(e)do if(a~=e.startpos)then table.insert(t,e.startpos);a=e.startpos end end return t end function e:_getFinalEndPos(t)local e=0;local t=t or self.editingNotes;for a,t in ipairs(t)do if(e<t.endpos)then e=t.endpos;end end return e;end function e:_getFirstStartPos(e)local t=e or self.editingNotes;local e=self:_getFinalEndPos(t,isSelection);for a,t in ipairs(t)do if(e>t.startpos)then e=t.startpos;end end return e;end function e:_getRangeContainsNotes(e,t)local a=e.startpos;local o=e.endpos;local a=e.length;local a=t or self.editingNotes;local t={}for i,a in ipairs(a)do if(e.startpos<=a.startpos and a.startpos<=o)then table.insert(t,a)end end table.sort(t,function(t,e)return(t.pitch<e.pitch)end)return t;end function e:_selectionReset(e)local e=e or self.editingNotes;for t,e in ipairs(e)do e.selection=false;end if(e==self.editingNotes)then self.m_isSelection=false end end function e:_toSelectionAll(e)local e=e or self.editingNotes;for t,e in ipairs(e)do e.selection=true;end if(e==self.editingNotes)then self.m_isSelection=true end end function e:_toSelectionInverse(e)local t=e or self.editingNotes;for t,e in ipairs(t)do e.selection=(e.selection==false);end if(t==self.editingNotes)then self.m_firstSelectionCheck=nil end end function e:_getSelectionNoteCount(t)local e=0;local t=t or self.editingNotes;for a,t in ipairs(t)do if(t.selection==true)then e=e+1;end end return e;end function e:_getMaxMinPitch(e)local a=e or self.editingNotes;local e=200;local t=-1;for o,a in ipairs(a)do e=math.min(e,a.pitch)t=math.max(t,a.pitch)end return e,t end function e:_getExistPitchNumber(e)local t=e or self.editingNotes;local e={}for t,a in ipairs(t)do local t=false for o,e in ipairs(e)do if(e==a.pitch)then t=true;break;end end if(t==false)then table.insert(e,a.pitch)end end return e;end function e:_getSelectionNotes(a)local t={}local a=a or self.editingNotes;for a,e in ipairs(a)do if(e.selection==true)then table.insert(t,e);end end return t;end e:_init();return e;end local e=createMIDIClip();if(e:checkProcessLimitNum())then reaper.Undo_BeginBlock();e:detectBottomNote()e:flush();reaper.Undo_EndBlock("kawa Detect Bottom Note",-1);reaper.UpdateArrange();end