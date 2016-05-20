--====================================================================== 
--[[ 
* ReaScript Name: kawa_MIDI_VelocityInterPolation_CubicRand. 
* Version: 2016/06/15 
* Author: kawa_ 
* Author URI: http://forum.cockos.com/member.php?u=105939 
* Repository: GitHub 
* Repository URI: https://github.com/kawaCat/ReaScript-MidiPack 
--]] 
--====================================================================== 
_W_MODE_ON_=false;local c=300 local m=true local j=true if(_W_MODE_ON_==true)then c=500;m=true;end math.randomseed(reaper.time_precise()*os.time()/1e3);local e=40659 local d=40681 local b=40832 local q=40501 local e=40003 local g=40214 local t="kawa_MidiClip"local u="lastEditCursolTime"local v="lastAutoSelectionState"local p="lastAutoSelectionMinPitch"local w="lastAutoSelectionMaxPitch"local y="lastAutoSelectionExistPitch"local k="lastCropSelectionNotesTable"local f="lastsVelNotesTable"local l={"4,0","4,1","2,0","2,1","1,0","1,1","0.5,0","0.5,1","0.25,0","0.25,1"}function deepcopy(t)local a=type(t)local e if a=='table'then e={}for a,t in next,t,nil do e[deepcopy(a)]=deepcopy(t)end setmetatable(e,deepcopy(getmetatable(t)))else e=t end return e end function string:split(e)local t,e=e or":",{}local t=string.format("([^%s]+)",t)self:gsub(t,function(t)e[#e+1]=t end)return e end function table.toString(a)local function l(e)return string.format("%q",e)end local d="";local function e(e)d=d..e end;local r,t="   ","\n"local h,a={a},{[a]=1}e("return {"..t)for o,n in ipairs(h)do e("-- Table: {"..o.."}"..t)e("{"..t)local s={}for i,o in ipairs(n)do s[i]=true local i=type(o)if i=="table"then if not a[o]then table.insert(h,o)a[o]=#h end e(r.."{"..a[o].."},"..t)elseif i=="string"then e(r..l(o)..","..t)elseif i=="number"then e(r..tostring(o)..","..t)end end for o,i in pairs(n)do if(not s[o])then local n=""local s=type(o)if s=="table"then if not a[o]then table.insert(h,o)a[o]=#h end n=r.."[{"..a[o].."}]="elseif s=="string"then n=r.."["..l(o).."]="elseif s=="number"then n=r.."["..tostring(o).."]="end if(n~="")then s=type(i)end if s=="table"then if not a[i]then table.insert(h,i)a[i]=#h end e(n.."{"..a[i].."},"..t)elseif s=="string"then e(n..l(i)..","..t)elseif s=="number"then e(n..tostring(i)..","..t)elseif s=="boolean"then e(n..tostring(i)..","..t)end end end e("},"..t)end e("}")return d;end function table.fromString(e)local e=load(e);local e=e()if(type(e)~="table")then local e={}return e end for t=1,#e do local o={}for a,i in pairs(e[t])do if type(i)=="table"then e[t][a]=e[i[1]]end if type(a)=="table"and e[a[1]]then table.insert(o,{a,e[a[1]]})end end for o,a in ipairs(o)do e[t][a[2]],e[t][a[1]]=e[t][a[1]],nil end end return e[1]end function stringIter(t)local e=0;local a=string.len(t);return function()e=e+1;if(e>a)then return nil else return e,string.sub(t,e,e)end end end if(_DBG_==true)then _W_MODE_ON_=true c=500;m=true;dofile(reaper.GetResourcePath().."\\Scripts\\ReaScript_MIDI\\_kawa_DBG.lua")else function DBG()end;end function createMIDIClip()local e={}e.editorHwnd=nil;e.mediaTrack=nil;e.mediaItem=nil;e.take=nil;e.mediaItemInfo={};e.actionContextInfo={};e.loopRangeInfo={};e.editingNotes={}e.m_originalNotes={};e.m_isSelection=nil e.m_firstSelectionCheck=nil;e.m_processLimitNoteNum=c;e.m_processLimitNoteNum_min=0;function e:isMidiEditorActive()return(self.editorHwnd~=nil);end function e:isSelectionInEditingNotes(e)if(self.m_firstSelectionCheck==nil or e~=nil)then for t,e in ipairs(self.editingNotes)do if(e.selection==true)then self.m_isSelection=true;break;end self.m_isSelection=false;end self.m_firstSelectionCheck=true;end return self.m_isSelection;end function e:checkProcessLimitNum()if(self:isMidiEditorActive()~=true)then return false;end local e=self:_checkProcessLimitNum()if(e~=true and#self.editingNotes>1 and m==true)then local e=self.m_processLimitNoteNum;reaper.ShowMessageBox("over "..tostring(e).." notes.\nstop process.","stop",0)end return e;end function e:setProcessLimitNum(e)self.m_processLimitNoteNum=e end function e:setProcessLimitNum_Min(e)self.m_processLimitNoteNum_min=e end function e:callReaperCommand(e)if(self:isMidiEditorActive())then reaper.MIDIEditor_OnCommand(self.editorHwnd,e)end end function e:changeOctave(e)self:transpose(12*math.floor(e));end function e:transpose(e)local t=math.floor(e);local e=self:_detectTargetNotes()for a,e in ipairs(e)do e.pitch=e.pitch+t if(e.pitch<0)then e.pitch=e.pitch+127-7;end if(e.pitch>127)then e.pitch=e.pitch-127+7;end end end function e:changeLengh(e)local t=e or .8;local e=self:_detectTargetNotes()for a,e in ipairs(e)do local a=e.startpos+e.length*t;if(self.mediaItemInfo.endProjQN>=a)then e.length=e.length*t;e.endpos=e.startpos+e.length;end end end function e:changeStartPos(e)local t=e or .8;local e=self:_detectTargetNotes()for a,e in ipairs(e)do local t=e.length*(1-t)local a=e.startpos-t;if(self.mediaItemInfo.startProjQN<=a)then e.startpos=e.startpos-t;e.length=e.length+t;e.endpos=e.startpos+e.length;end end end function e:changeVelocity(e)local t=e or .8;local e=self:_detectTargetNotes()for a,e in ipairs(e)do if(t>1)then e.vel=math.floor(e.vel*t);elseif(t<=1)then e.vel=math.floor(e.vel*t);end if(e.vel>127)then e.vel=127;end if(e.vel<1)then e.vel=1;end end end function e:changeVelocityDistance(e)local o=e or .2;local a=self:_detectTargetNotes()local t=0;local e=200;for o,a in ipairs(a)do e=math.min(a.vel,e);t=math.max(a.vel,t);end local t=(t+e)/2 for a,e in ipairs(a)do local a=0;if(e.vel>=t)then a=(e.vel-t)*o;else a=-(t-e.vel)*o;end e.vel=math.floor(e.vel+a);if(e.vel>127)then e.vel=127;end if(e.vel<0)then e.vel=1;end end end function e:randomVelocity(e)local o=e or 60;local e=reaper.GetExtState(t,u);local i=reaper.GetCursorPosition();e=tonumber(e)or 0 local a=self:_detectTargetNotes();if(math.floor(e*1e3)/1e3~=math.floor(i*1e3)/1e3)then local e=self:_detectTargetNotes();local e=table.toString(e)reaper.SetExtState(t,f,e,false);else local e=reaper.GetExtState(t,f);a=table.fromString(e);if(#a<1)then local e=self:_detectTargetNotes();end end local e=self:_detectTargetNotes();if(#e~=#a)then a=deepcopy(e)end for t,e in ipairs(e)do e.vel=a[t].vel+(math.random()*o)-(o/2);e.vel=math.floor(e.vel);if(e.vel>127)then e.vel=127;end if(e.vel<0)then e.vel=1;end end reaper.SetExtState(t,u,tostring(i),false);end function e:fixVelocity()local t,e=reaper.GetUserInputs("fix Velocity",7,"velocity (1 ~127)","90,--,--,--,--,--,--")if(t~=true)then return;end local t=tonumber(e:split(",")[1])or 90;local e=self:_detectTargetNotes();for a,e in ipairs(e)do e.vel=math.floor(t);if(e.vel>127)then e.vel=127;end if(e.vel<0)then e.vel=1;end end end function e:velocityInterpolation(a,o)local t=self:_detectTargetNotes();table.sort(t,function(t,e)return(t.startpos<e.startpos)end);local r=a or 3 local h=o or 0 local function s(o,t,e,n)local a=0;if(e==1)then a=o*t elseif(e==2)then local e=o*t;a=e+math.sin(math.rad(360*t))*o/4;elseif(e==3)then local function i(e)e=e*2 if e<1 then return .5*e*e*e else e=e-2 return .5*(e*e*e+2)end end local e=i(t)a=o*e;end local e=0 if(t~=0 and t~=1)then e=n*math.random();end return a+e end local i=t[1].startpos;local e=t[#t].startpos;local o=t[1].vel;local n=t[#t].vel;local a=(e-i)or 1;local n=n-o;if(a<=0)then return end for t,e in ipairs(t)do local t=(e.startpos-i)/a local t=o+s(n,t,r,h)e.vel=t;if(e.vel>127)then e.vel=127-(e.vel-127);end if(e.vel<0)then e.vel=1-e.vel;end e.vel=math.floor(e.vel);end end function e:splitNote(t)local a=self:_detectTargetNotes()local e=t local i=self:_getSelectionNoteCount(a)local o={}for a,e in ipairs(a)do if(e.length>.001)then e.length=(e.length/t);e.endpos=e.startpos+e.length-1e-6;for a=1,t-1,1 do local t=deepcopy(e);t.startpos=t.startpos+(t.length)*a t.endpos=t.startpos+e.length t.selection=true;table.insert(o,t);end end end self:insertNotesFromC(o);if(i==0)then for t,e in ipairs(a)do e.selection=true end end end function e:copyToOctaveUp()local e=self:_detectTargetNotes()for t,e in ipairs(e)do local e=deepcopy(e)e.pitch=e.pitch+12;if(e.pitch<0)then e.pitch=e.pitch+127-7;end if(e.pitch>127)then e.pitch=e.pitch-127+7;end self:insertNoteFromC(e);end end function e:copyToOctaveDown()local e=self:_detectTargetNotes()for t,e in ipairs(e)do local e=deepcopy(e)e.pitch=e.pitch-12;if(e.pitch<0)then e.pitch=e.pitch+127-7;end if(e.pitch>127)then e.pitch=e.pitch-127+7;end self:insertNoteFromC(e);end end function e:resolveOverLap()local t=self:_detectTargetNotes()table.sort(t,function(e,t)return(e.startpos<t.startpos)end);for a,e in ipairs(t)do for a,t in ipairs(t)do if(e.idx<=t.idx and e.startpos~=t.startpos and e.endpos>t.startpos)then e.endpos=t.startpos;e.length=e.endpos-e.startpos;end end end end function e:deleteAllNote()self.editingNotes={};end function e:nudgeNote(e)local t=e or .8;local e=1/4 local a=1/32 local t=e*t;local e=self:_detectTargetNotes()for o,e in ipairs(e)do if(e.length>a)then e.startpos=e.startpos+t;e.endpos=e.endpos+t;e.length=e.endpos-e.startpos;end end end function e:strokeDown(t)local e=self:_detectTargetNotes()local a=self:_getExistStartPosTable(e);local o=t or .005 local t=1;for i,a in ipairs(a)do local t,e=self:_getSameStartPosNotes(a,e,t);for a,e in ipairs(t)do e.startpos=e.startpos+o*(#t-a)end end end function e:strokeUp(a)local e=self:_detectTargetNotes()local t=self:_getExistStartPosTable(e);local o=a or .015 local a=1;for i,t in ipairs(t)do local e,t=self:_getSameStartPosNotes(t,e,a);for t,e in ipairs(e)do e.startpos=e.startpos+o*(t-1)end end end function e:simpleDuplicate()local n=self.mediaItemInfo;local t=self:_detectTargetNotes();local a=self:_getFinalEndPos(t)local e=self:_getFirstStartPos(t)local a=a-e;local o={}for i,e in ipairs(t)do local e=deepcopy(e);e.startpos=e.startpos+a;e.endpos=e.endpos+a;if(n.endProjQN>=e.endpos)then e.selection=true;table.insert(o,e);else end t[i].selection=false;end self:insertNotesFromC(o);end function e:simpleDuplicateType3()local a=self:_detectTargetNotes();local t=self:_getFinalEndPos(a)local e=self:_getFirstStartPos(a)local e=t-e;local t=0;if(e<=.25)then t=.25-e elseif(e<=.5)then t=.5-e elseif(e<=1)then t=1-e elseif(e<=2)then t=2-e elseif(e<=4)then t=4-e else local a=math.floor(e/4+.6);local a=a*4;t=a-e;end e=e+t;e=math.floor((e)*100)/100;local i={}for t,o in ipairs(a)do local t=deepcopy(o);t.startpos=t.startpos+e;t.endpos=t.endpos+e;o.selection=false;if(self.mediaItemInfo.endProjQN>=t.endpos)then t.selection=true;table.insert(i,t);else end a.selection=false;end self:insertNotesFromC(i);end function e:growUp(t,e)local o=self:_detectTargetNotes();local i=e or .25 local s={}local n={}local a=t or 4;local function h(e)return i/(a/e)end for e,t in ipairs(o)do local o=-1;for n=a,1,-1 do local e=deepcopy(t);e.pitch=t.pitch-(a)+n;local a=h(n)e.startpos=t.startpos+(i*a);if(o~=-1)then e.endpos=o+.1 end table.insert(s,e);o=e.startpos end table.insert(n,t);end self:deleteNotes(n);self:insertNotesFromC(s);end function e:twoNoteNudge(e)local a=self:_getSelectionNotes();if(#a~=2)then return end;table.sort(a,function(e,t)return(e.startpos<t.startpos);end);local o=e or .9;local t=a[1];local e=a[2];if((t.length<.015 or e.length<.015)and t.startpos>=e.startpos)then return;end local i=t.length*o;local o=t.startpos+i;local s=o;local n=e.endpos-s;if(i>.01 and n>.01 and o<e.endpos)then t.length=i;t.endpos=o;e.startpos=s;e.length=n;end self:deleteNotes(a);self:insertNoteFromC(t);self:insertNoteFromC(e);end function e:selectAllNoteCurrentTake()reaper.PreventUIRefresh(1)reaper.MIDIEditor_OnCommand(self.editorHwnd,g)reaper.PreventUIRefresh(-1)reaper.MIDI_SelectAll(self.take,true);end function e:noteLengthToEnd()local e=self:_detectTargetNotes();local t=self:_getFinalEndPos(e)for a,e in ipairs(e)do e.endpos=t;end end function e:legatoType2()local t=self:_detectTargetNotes();local e=self:_getExistStartPosTable(t);local i=1;for a,o in ipairs(e)do local t,i=self:_getSameStartPosNotes(o,t,i);for i,t in pairs(t)do local t=t if(a+1<=#e and t.startpos>=o and t.endpos<e[a+1]and t.startpos<e[a+1])then t.endpos=e[a+1]end end end end function e:autoSelection(e)local s=e or 1 local i=reaper.GetExtState(t,u);local n=reaper.GetCursorPosition();i=tonumber(i)or 0 local e=0;local o=127;local a={}if(math.floor(i*1e3)/1e3~=math.floor(n*1e3)/1e3)then local i=self:_detectTargetNotes();e,o=self:_getMaxMinPitch(i);a=self:_getExistPitchNumber(i);local a=table.toString(a)reaper.SetExtState(t,y,a,false);reaper.SetExtState(t,p,tostring(e),false);reaper.SetExtState(t,w,tostring(o),false);else e=reaper.GetExtState(t,p);o=reaper.GetExtState(t,w);e=tonumber(e)or 0 o=tonumber(o)or 127 local e=reaper.GetExtState(t,y);a=table.fromString(e);if(#a<1)then local e=self:_detectTargetNotes();a=self:_getExistPitchNumber(e);end end self.editingNotes=self:_getNotes_(false)self.m_originalNotes=deepcopy(self.editingNotes);local e=reaper.GetExtState(t,v);if(e==nil or e=="")then e=l[1];end;local o=nil for t,a in ipairs(l)do if(a==e)then local e=t+s;if(e>#l)then e=1;end if(e<1)then e=#l;end o=l[e];break;end end local i=self.loopRangeInfo.startProjQN;local s=self.loopRangeInfo.endProjQN;local h=self.loopRangeInfo.lengthProjQN;local d=tonumber(o:split(",")[1]);local r=tonumber(o:split(",")[2]);for t,e in ipairs(self.editingNotes)do e.selection=false;local o=math.floor(e.startpos*100+.6)/100 for a,t in ipairs(a)do if((h<=0 or(e.startpos>=i and e.startpos<s))and t==e.pitch and(math.floor((o)/d))%2==r)then e.selection=true;end end end reaper.SetExtState(t,v,o,false);reaper.SetExtState(t,u,tostring(n),false);end function e:toggleSelectionCrop()local e=self.mediaItemInfo.ptrID;local e=k.."_"..e;local a=reaper.GetExtState(t,e);if(a~="")then local a=table.fromString(a)self:_selectionReset(a);self:insertNotesFromC(a)reaper.SetExtState(t,e,"",false);else if(self:_getSelectionNoteCount()<1)then reaper.SetExtState(t,e,"",false);return end local a=deepcopy(self.editingNotes);reaper.MIDIEditor_OnCommand(self.editorHwnd,q)self.editingNotes=self:_getNotes();self.m_originalNotes=deepcopy(self.editingNotes);local a=self:_detectTargetNotes();reaper.SetExtState(t,e,table.toString(a),false);self:deleteNotes(a);end end function e:detectTopNote()local e=self:_detectTargetNotes();local o=self:_getExistStartPosTable(e);local a={}local t=1;for i,o in ipairs(o)do local t,e=self:_getSameStartPosNotes(o,e,t);local e=-1 for a,t in ipairs(t)do if(e<t.pitch)then e=t.pitch end end if(#t>1)then for o,t in ipairs(t)do if(t.pitch<e)then table.insert(a,t)end end end end self:deleteNotes(a);end function e:detectBottomNote()local e=self:_detectTargetNotes();local t=self:_getExistStartPosTable(e);local a={}local o=1;for i,t in ipairs(t)do local e,t=self:_getSameStartPosNotes(t,e,o);local t=200 for a,e in ipairs(e)do if(t>e.pitch)then t=e.pitch end end if(#e>1)then for o,e in ipairs(e)do if(e.pitch>t)then table.insert(a,e)end end end end self:deleteNotes(a);end function e:deleteTopNote()local e=self:_detectTargetNotes();local t=self:_getExistStartPosTable(e);local a={}local o=1;for i,t in ipairs(t)do local e,t=self:_getSameStartPosNotes(t,e,o);local t=-1 for a,e in ipairs(e)do if(t<e.pitch)then t=e.pitch end end if(#e>1)then for o,e in ipairs(e)do if(e.pitch==t)then table.insert(a,e)end end end end self:deleteNotes(a);end function e:deleteBottomNote()local e=self:_detectTargetNotes();local t=self:_getExistStartPosTable(e);local a={}local o=1;for i,t in ipairs(t)do local t,e=self:_getSameStartPosNotes(t,e,o);local e=200 local o=0;for a,t in ipairs(t)do if(e>t.pitch)then e=t.pitch end end if(#t>1)then for o,t in ipairs(t)do if(t.pitch==e)then table.insert(a,t)end end end end self:deleteNotes(a);end function e:selectTopNote()local e=self:_detectTargetNotes();local t=self:_getExistStartPosTable(e);local a=1;for o,t in ipairs(t)do local t,e=self:_getSameStartPosNotes(t,e,a);local e=-1 for a,t in ipairs(t)do if(e<t.pitch)then e=t.pitch end end if(#t>=1)then for a,t in ipairs(t)do if(t.pitch==e)then t.selection=true;else t.selection=false;end end end end end function e:selectBottomNote()local e=self:_detectTargetNotes();local t=self:_getExistStartPosTable(e);local a=1;for o,t in ipairs(t)do local e,t=self:_getSameStartPosNotes(t,e,a);local t=200 for a,e in ipairs(e)do if(t>e.pitch)then t=e.pitch end end if(#e>=1)then for a,e in ipairs(e)do if(e.pitch==t)then e.selection=true;else e.selection=false;end end end end end function e:generateSelectionArp()local i={}local o=self:_getMidiGrid()local function n(e)local t=0;for a,e in ipairs(e)do if(t<e.length and(self:isSelectionInEditingNotes()==true and e.selection==true or self:isSelectionInEditingNotes()==false))then t=e.length end end return t;end local function e(t)local e={}for a,t in ipairs(t)do if(self:isSelectionInEditingNotes()==true and t.selection==true or self:isSelectionInEditingNotes()==false)then table.insert(e,t)end end return e;end local function s()local e=self:_detectTargetNotes();local t=self:_getExistStartPosTable(e);local a=1;for s,t in ipairs(t)do local e,t=self:_getSameStartPosNotes(t,e,a);if(#e>1)then local t=n(e)local h=math.floor(t/o);local s=#e;table.sort(e,function(e,t)return(e.pitch<t.pitch)end);local a=e[1].startpos;local o=o*.99999;local t=1;local function n()t=t+1;if(t>s)then t=1;end end for i=1,h,1 do local e=deepcopy(e[t]);e.length=o;e.startpos=a e.endpos=e.startpos+e.length;self:insertNoteFromC(e)a=a+o;n();end for t,e in ipairs(e)do table.insert(i,e)end end end end s();self:deleteNotes(i);end function e:flush(t,e)if(self:_checkProcessLimitNum()==0)then return end;if(t==nil)then self:_deleteMinimunLengthNote();end if(e==nil)then self:_safeOverLap();end self:_deleteAllOriginalNote();self:_editingNoteToMediaItem();reaper.MIDI_Sort(self.take);end function e:reset()self.editingNotes={}self.editingNotes=deepcopy(self.m_originalNotes);end function e:insertNoteFromC(e)e.idx=#self.editingNotes+1;table.insert(self.editingNotes,e);end function e:insertNotesFromC(e)for t,e in ipairs(e)do self:insertNoteFromC(e)end end function e:insertMidiNote(s,a,t,e,o,h,r)local t=t local e=e local n=a;local i=o or false;local o=r or false;local a=h or 1;local s=s;local h=#self.editingNotes+1;local e={selection=i,mute=o,startpos=t,endpos=e,chan=a,pitch=s,vel=n,take=self.take,idx=h,length=e-t}table.insert(self.editingNotes,e);end function e:deleteNote(a)for t,e in ipairs(self.editingNotes)do if(e.idx==a.idx)then table.remove(self.editingNotes,t)break;end end end function e:deleteNotes(e)if(e==self.editingNotes)then self.editingNotes={};return;end for t,e in ipairs(e)do self:deleteNote(e)end end function e:_init()self.editorHwnd=reaper.MIDIEditor_GetActive();self.take=reaper.MIDIEditor_GetTake(self.editorHwnd);if(self.take==nil)then return end self:_storeActionContextInfo();local e=reaper.GetToggleCommandStateEx(self.actionContextInfo.sectionID,b);if(e==0)then reaper.MIDIEditor_OnCommand(self.editorHwnd,b)end self.mediaItem=reaper.GetMediaItemTake_Item(self.take);self.mediaTrack=reaper.GetMediaItemTrack(self.mediaItem);self.mediaItemInfo=self:_storeMediaItemInfo();self.loopRangeInfo=self:_storeTimeSelectionInfo();self.editingNotes=self:_getNotes();self.m_originalNotes=deepcopy(self.editingNotes);end function e:_storeTimeSelectionInfo()local o,a=reaper.GetSet_LoopTimeRange2(0,false,j,0,0,false)local i=reaper.MIDI_GetPPQPosFromProjTime(self.take,o);local s=reaper.MIDI_GetPPQPosFromProjTime(self.take,a);local h=reaper.MIDI_GetProjQNFromPPQPos(self.take,i);local r=reaper.MIDI_GetProjQNFromPPQPos(self.take,s);local t=a-o;local e=reaper.MIDI_GetPPQPosFromProjTime(self.take,t);local n=reaper.MIDI_GetProjQNFromPPQPos(self.take,e);if(t<=0)then e=0 n=0 end local e={startTime=o,endTime=a,lengthTime=t,startPpq=i,endPpq=s,lengthPpq=e,startProjQN=h,endProjQN=r,lengthProjQN=n}return e;end function e:_getMidiGrid()local a,t,e=reaper.MIDI_GetGrid(self.take);return a,t,e end function e:_storeActionContextInfo()local t,e,a,i,o,n,s=reaper.get_action_context();self.actionContextInfo={is_new_value=t,filename=e,sectionID=a,cmdID=i,mode=o,resolution=n,val=s};return self.actionContextInfo;end function e:_storeMediaItemInfo()local t=reaper.GetMediaItemInfo_Value(self.mediaItem,"D_POSITION");local e=reaper.GetMediaItemInfo_Value(self.mediaItem,"D_LENGTH");local n=t+e;local i=reaper.MIDI_GetPPQPosFromProjTime(self.take,t);local a=reaper.MIDI_GetPPQPosFromProjTime(self.take,e)local o=reaper.MIDI_GetPPQPosFromProjTime(self.take,n)local s=reaper.MIDI_GetProjQNFromPPQPos(self.take,i);local r=reaper.MIDI_GetProjQNFromPPQPos(self.take,a);local h=reaper.MIDI_GetProjQNFromPPQPos(self.take,o);local d=reaper.GetMediaItemInfo_Value(self.mediaItem,"IP_ITEMNUMBER");local e={startTime=t,lengthTime=e,endTime=n,startPpq=i,lengthPpq=a,endPpq=o,startProjQN=s,lengthProjQN=r,endProjQN=h,mediaItem=midiMediaItem,take=takeMidi,IP_NUM_RO=d,ptrID=tostring(self.mediaItem);}return e;end function e:_getNotes()local e={}if(_W_MODE_ON_==true)then e=self:_getNotes_(false);else e=self:_getNotes_(true);if(#e<1)then e=self:_getNotes_(false)end end return e;end function e:_getNotes_(i)local m=reaper.GetToggleCommandStateEx(self.actionContextInfo.sectionID,d);if(m==0)then reaper.MIDIEditor_OnCommand(self.editorHwnd,d)end local o={};local s=self.take if(self.take==nil)then return o end reaper.MIDI_Sort(self.take)local c,n,u,e,t,h,l,r=reaper.MIDI_GetNote(self.take,0)local a=0 while c do e=reaper.MIDI_GetProjQNFromPPQPos(s,e)t=reaper.MIDI_GetProjQNFromPPQPos(s,t)local s={selection=n,mute=u,startpos=e,endpos=t,chan=h,pitch=l,vel=r,take=self.take,idx=a,length=t-e}if(i==true and n==i or i==false)then table.insert(o,s);end a=a+1 c,n,u,e,t,h,l,r=reaper.MIDI_GetNote(self.take,a)end if(m==0)then reaper.MIDIEditor_OnCommand(self.editorHwnd,d)end return o;end function e:_deleteAllOriginalNote(e)local e=e or self.m_originalNotes;while(#e>0)do local t=#e;reaper.MIDI_DeleteNote(e[t].take,e[t].idx)table.remove(e,#e);end end function e:_insertNoteToMediaItem(e)local t=self.take if t==nil then return end local h=e.selection or false;local n=e.mute;local s=reaper.MIDI_GetPPQPosFromProjQN(t,e.startpos)local i=reaper.MIDI_GetPPQPosFromProjQN(t,e.endpos)local o=e.chan;local a=e.pitch;local e=e.vel;reaper.MIDI_InsertNote(t,h,n,s,i,o,a,e,false)end function e:_editingNoteToMediaItem()local e=reaper.GetToggleCommandStateEx(self.actionContextInfo.sectionID,d);if(e==0)then reaper.MIDIEditor_OnCommand(self.editorHwnd,d)end for t,e in ipairs(self.editingNotes)do self:_insertNoteToMediaItem(e)end if(e==0)then reaper.MIDIEditor_OnCommand(self.editorHwnd,d)end end function e:_safeOverLap(e)local a=e or self.editingNotes local function s(t,a)local e={}for o,t in ipairs(t)do if(a.pitch==t.pitch)then table.insert(e,t);end end table.sort(e,function(e,t)return(e.startpos<t.startpos)end);return e;end table.sort(a,function(t,e)return(t.startpos<e.startpos)end);local o=deepcopy(a);local i={};local n={};while(#o>0)do local a=s(o,o[1]);while(#a>=2)do local e=a[1]local t=a[2]if(t~=nil and e.startpos<t.startpos and e.endpos>t.startpos)then table.insert(n,e);e.endpos=t.startpos-.001;e.length=e.endpos-e.startpos;t.startpos=e.endpos+.001;table.insert(i,e);end table.remove(a,1);end table.remove(o,1);end self:deleteNotes(n);self:insertNotesFromC(i);end function e:_deleteMinimunLengthNote()local t={}for a,e in ipairs(self.editingNotes)do if(e.endpos-e.startpos<.001)then table.insert(t,e);end end self:deleteNotes(t);end function e:_checkProcessLimitNum()local e=true;if(#self.editingNotes<self.m_processLimitNoteNum_min+1)then e=false end;if(#self.editingNotes>=self.m_processLimitNoteNum)then e=false;end;return e;end function e:_detectTargetNotes()local e=nil if(self:isSelectionInEditingNotes()==true)then e=self:_getSelectionNotes(self.editingNotes);else e=self.editingNotes end return e;end function e:_getSameStartPosNotes(i,a,t)local e={};local t=t or 1;local a=a or self.editingNotes;for o=t,#a do local a=a[o]if(a.startpos==i)then table.insert(e,a);t=o end end table.sort(e,function(t,e)return(t.pitch>e.pitch)end);return e,t;end function e:_getExistStartPosTable(e)local a={}local e=e or self.editingNotes;table.sort(e,function(t,e)return(t.startpos<e.startpos)end);local t=-100;for o,e in ipairs(e)do if(t~=e.startpos)then table.insert(a,e.startpos);t=e.startpos end end return a end function e:_getFinalEndPos(t)local e=0;local t=t or self.editingNotes;for a,t in ipairs(t)do if(e<t.endpos)then e=t.endpos;end end return e;end function e:_getFirstStartPos(e)local t=e or self.editingNotes;local e=self:_getFinalEndPos(t,isSelection);for a,t in ipairs(t)do if(e>t.startpos)then e=t.startpos;end end return e;end function e:_getRangeContainsNotes(e,t)local a=e.startpos;local o=e.endpos;local a=e.length;local t=t or self.editingNotes;local a={}for i,t in ipairs(t)do if(e.startpos<=t.startpos and t.startpos<=o)then table.insert(a,t)end end table.sort(a,function(e,t)return(e.pitch<t.pitch)end)return a;end function e:_selectionReset(e)local e=e or self.editingNotes;for t,e in ipairs(e)do e.selection=false;end if(e==self.editingNotes)then self.m_isSelection=false end end function e:_toSelectionAll(e)local e=e or self.editingNotes;for t,e in ipairs(e)do e.selection=true;end if(e==self.editingNotes)then self.m_isSelection=true end end function e:_toSelectionInverse(e)local t=e or self.editingNotes;for t,e in ipairs(t)do e.selection=(e.selection==false);end if(t==self.editingNotes)then self.m_firstSelectionCheck=nil end end function e:_getSelectionNoteCount(t)local e=0;local t=t or self.editingNotes;for a,t in ipairs(t)do if(t.selection==true)then e=e+1;end end return e;end function e:_getMaxMinPitch(e)local a=e or self.editingNotes;local e=200;local t=-1;for o,a in ipairs(a)do e=math.min(e,a.pitch)t=math.max(t,a.pitch)end return e,t end function e:_getExistPitchNumber(e)local t=e or self.editingNotes;local e={}for t,a in ipairs(t)do local t=false for o,e in ipairs(e)do if(e==a.pitch)then t=true;break;end end if(t==false)then table.insert(e,a.pitch)end end return e;end function e:_getSelectionNotes(a)local t={}local a=a or self.editingNotes;for a,e in ipairs(a)do if(e.selection==true)then table.insert(t,e);end end return t;end e:_init();return e;end local e=createMIDIClip();if(e:checkProcessLimitNum())then reaper.Undo_BeginBlock();local a=3 local t=10 e:velocityInterpolation(a,t)e:flush();reaper.Undo_EndBlock("kawa MIDI Interpolation Velocity Cubic Rnd",-1);reaper.UpdateArrange();end