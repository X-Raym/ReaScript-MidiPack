--====================================================================== 
--[[ 
* ReaScript Name: kawa_MIDI_VerticalZoom_Next. 
* Version: 2016/06/15 
* Author: kawa_ 
* Author URI: http://forum.cockos.com/member.php?u=105939 
* Repository: GitHub 
* Repository URI: https://github.com/kawaCat/ReaScript-MidiPack 
--]] 
--====================================================================== 
_W_MODE_ON_=false local u=300 local c=true local _=true if(_W_MODE_ON_==true)then u=500;c=true;end _USE_TESTING_FUNC_=false math.randomseed(reaper.time_precise()*os.time()/1e3);local e=40659 local r=40681 local g=40832 local T=40501 local e=40003 local E=40214 local x=1011 local j=1012 local q=40112 local k=40111 local e=40468 local e=40726 local e=40725 local z=40466;local t="kawa_MidiClip"local l="lastEditCursolTime"local y="lastAutoSelectionState"local w="lastAutoSelectionMinPitch"local f="lastAutoSelectionMaxPitch"local m="lastAutoSelectionExistPitch"local A="lastCropSelectionNotesTable"local v="lastsVelNotesTable"local b="lastsZoomOrderIdx"local p="lastsVerticalScrollState"local d={"4,0","4,1","2,0","2,1","1,0","1,1","0.5,0","0.5,1","0.25,0","0.25,1"}function deepcopy(t)local a=type(t)local e if a=='table'then e={}for a,t in next,t,nil do e[deepcopy(a)]=deepcopy(t)end setmetatable(e,deepcopy(getmetatable(t)))else e=t end return e end function string:split(e)local t,e=e or":",{}local t=string.format("([^%s]+)",t)self:gsub(t,function(t)e[#e+1]=t end)return e end function table.toString(a)local function l(e)return string.format("%q",e)end local d="";local function e(e)d=d..e end;local r,t="   ","\n"local h,a={a},{[a]=1}e("return {"..t)for o,n in ipairs(h)do e("-- Table: {"..o.."}"..t)e("{"..t)local d={}for i,o in ipairs(n)do d[i]=true local i=type(o)if i=="table"then if not a[o]then table.insert(h,o)a[o]=#h end e(r.."{"..a[o].."},"..t)elseif i=="string"then e(r..l(o)..","..t)elseif i=="number"then e(r..tostring(o)..","..t)end end for i,s in pairs(n)do if(not d[i])then local o=""local n=type(i)if n=="table"then if not a[i]then table.insert(h,i)a[i]=#h end o=r.."[{"..a[i].."}]="elseif n=="string"then o=r.."["..l(i).."]="elseif n=="number"then o=r.."["..tostring(i).."]="end if(o~="")then n=type(s)end if n=="table"then if not a[s]then table.insert(h,s)a[s]=#h end e(o.."{"..a[s].."},"..t)elseif n=="string"then e(o..l(s)..","..t)elseif n=="number"then e(o..tostring(s)..","..t)elseif n=="boolean"then e(o..tostring(s)..","..t)end end end e("},"..t)end e("}")return d;end function table.fromString(e)local e=load(e);local e=e()if(type(e)~="table")then local e={}return e end for t=1,#e do local i={}for a,o in pairs(e[t])do if type(o)=="table"then e[t][a]=e[o[1]]end if type(a)=="table"and e[a[1]]then table.insert(i,{a,e[a[1]]})end end for o,a in ipairs(i)do e[t][a[2]],e[t][a[1]]=e[t][a[1]],nil end end return e[1]end function stringIter(t)local e=0;local a=string.len(t);return function()e=e+1;if(e>a)then return nil else return e,string.sub(t,e,e)end end end if(_DBG_==true)then _W_MODE_ON_=true u=500;c=true;else function DBG()end;end function createMIDIClip()local e={}e.editorHwnd=nil;e.mediaTrack=nil;e.mediaItem=nil;e.take=nil;e.mediaItemInfo={};e.actionContextInfo={};e.loopRangeInfo={};e.editingNotes={}e.m_originalNotes={};e.m_isSelection=nil e.m_firstSelectionCheck=nil;e.m_processLimitNoteNum=u;e.m_processLimitNoteNum_min=0;function e:isMidiEditorActive()return(self.editorHwnd~=nil);end function e:isSelectionInEditingNotes(e)if(self.m_firstSelectionCheck==nil or e~=nil)then for t,e in ipairs(self.editingNotes)do if(e.selection==true)then self.m_isSelection=true;break;end self.m_isSelection=false;end self.m_firstSelectionCheck=true;end return self.m_isSelection;end function e:checkProcessLimitNum()if(self:isMidiEditorActive()~=true)then return false;end local e=self:_checkProcessLimitNum()if(e~=true and#self.editingNotes>1 and c==true)then local e=self.m_processLimitNoteNum;reaper.ShowMessageBox("over "..tostring(e).." notes.\nstop process.","stop",0)end return e;end function e:setProcessLimitNum(e)self.m_processLimitNoteNum=e end function e:setProcessLimitNum_Min(e)self.m_processLimitNoteNum_min=e end function e:callReaperCommand(e)if(self:isMidiEditorActive())then reaper.MIDIEditor_OnCommand(self.editorHwnd,e)end end function e:changeOctave(e)self:transpose(12*math.floor(e));end function e:transpose(e)local t=math.floor(e);local e=self:_detectTargetNotes()for a,e in ipairs(e)do e.pitch=e.pitch+t if(e.pitch<0)then e.pitch=e.pitch+127-7;end if(e.pitch>127)then e.pitch=e.pitch-127+7;end end end function e:changeLengh(e)local t=e or .8;local e=self:_detectTargetNotes()for a,e in ipairs(e)do local a=e.startpos+e.length*t;if(self.mediaItemInfo.endProjQN>=a)then e.length=e.length*t;e.endpos=e.startpos+e.length;end end end function e:changeStartPos(e)local t=e or .8;local e=self:_detectTargetNotes()for a,e in ipairs(e)do local t=e.length*(1-t)local a=e.startpos-t;if(self.mediaItemInfo.startProjQN<=a)then e.startpos=e.startpos-t;e.length=e.length+t;e.endpos=e.startpos+e.length;end end end function e:changeVelocity(e)local t=e or .8;local e=self:_detectTargetNotes()for a,e in ipairs(e)do if(t>1)then e.vel=math.floor(e.vel*t);elseif(t<=1)then e.vel=math.floor(e.vel*t);end if(e.vel>127)then e.vel=127;end if(e.vel<1)then e.vel=1;end end end function e:changeVelocityDistance(e)local o=e or .2;local i=self:_detectTargetNotes()local t=0;local e=200;for o,a in ipairs(i)do e=math.min(a.vel,e);t=math.max(a.vel,t);end local a=(t+e)/2 for t,e in ipairs(i)do local t=0;if(e.vel>=a)then t=(e.vel-a)*o;else t=-(a-e.vel)*o;end e.vel=math.floor(e.vel+t);if(e.vel>127)then e.vel=127;end if(e.vel<0)then e.vel=1;end end end function e:randomVelocity(e)local o=e or 60;local e=reaper.GetExtState(t,l);local i=reaper.GetCursorPosition();e=tonumber(e)or 0 local a=self:_detectTargetNotes();if(math.floor(e*1e3)/1e3~=math.floor(i*1e3)/1e3)then local e=self:_detectTargetNotes();local e=table.toString(e)reaper.SetExtState(t,v,e,false);else local e=reaper.GetExtState(t,v);a=table.fromString(e);if(#a<1)then local e=self:_detectTargetNotes();end end local e=self:_detectTargetNotes();if(#e~=#a)then a=deepcopy(e)end for t,e in ipairs(e)do e.vel=a[t].vel+(math.random()*o)-(o/2);e.vel=math.floor(e.vel);if(e.vel>127)then e.vel=127;end if(e.vel<0)then e.vel=1;end end reaper.SetExtState(t,l,tostring(i),false);end function e:fixVelocity()local e,t=reaper.GetUserInputs("fix Velocity",7,"velocity (1 ~127)","90,--,--,--,--,--,--")if(e~=true)then return;end local t=tonumber(t:split(",")[1])or 90;local e=self:_detectTargetNotes();for a,e in ipairs(e)do e.vel=math.floor(t);if(e.vel>127)then e.vel=127;end if(e.vel<0)then e.vel=1;end end end function e:velocityInterpolation(a,e)local t=self:_detectTargetNotes();table.sort(t,function(t,e)return(t.startpos<e.startpos)end);local n=a or 3 local r=e or 0 local function h(a,t,e,n)local o=0;if(e==1)then o=a*t elseif(e==2)then local e=a*t;o=e+math.sin(math.rad(360*t))*a/4;elseif(e==3)then local function i(e)e=e*2 if e<1 then return .5*e*e*e else e=e-2 return .5*(e*e*e+2)end end local e=i(t)o=a*e;end local e=0 if(t~=0 and t~=1)then e=n*math.random();end return o+e end local a=t[1].startpos;local e=t[#t].startpos;local o=t[1].vel;local s=t[#t].vel;local i=(e-a)or 1;local s=s-o;if(i<=0)then return end for t,e in ipairs(t)do local t=(e.startpos-a)/i local t=o+h(s,t,n,r)e.vel=t;if(e.vel>127)then e.vel=127-(e.vel-127);end if(e.vel<0)then e.vel=1-e.vel;end e.vel=math.floor(e.vel);end end function e:splitNote(t)local a=self:_detectTargetNotes()local e=t local i=self:_getSelectionNoteCount(a)local o={}for a,e in ipairs(a)do if(e.length>.001)then e.length=(e.length/t);e.endpos=e.startpos+e.length-1e-6;for a=1,t-1,1 do local t=deepcopy(e);t.startpos=t.startpos+(t.length)*a t.endpos=t.startpos+e.length t.selection=true;table.insert(o,t);end end end self:insertNotesFromC(o);if(i==0)then for t,e in ipairs(a)do e.selection=true end end end function e:copyToOctaveUp()local e=self:_detectTargetNotes()for t,e in ipairs(e)do local e=deepcopy(e)e.pitch=e.pitch+12;if(e.pitch<0)then e.pitch=e.pitch+127-7;end if(e.pitch>127)then e.pitch=e.pitch-127+7;end self:insertNoteFromC(e);end end function e:copyToOctaveDown()local e=self:_detectTargetNotes()for t,e in ipairs(e)do local e=deepcopy(e)e.pitch=e.pitch-12;if(e.pitch<0)then e.pitch=e.pitch+127-7;end if(e.pitch>127)then e.pitch=e.pitch-127+7;end self:insertNoteFromC(e);end end function e:resolveOverLap()local t=self:_detectTargetNotes()table.sort(t,function(t,e)return(t.startpos<e.startpos)end);for a,e in ipairs(t)do for a,t in ipairs(t)do if(e.idx<=t.idx and e.startpos~=t.startpos and e.endpos>t.startpos)then e.endpos=t.startpos;e.length=e.endpos-e.startpos;end end end end function e:deleteAllNote()self.editingNotes={};end function e:nudgeNote(e)local e=e or .8;local t=1/4 local a=1/32 local t=t*e;local e=self:_detectTargetNotes()for o,e in ipairs(e)do if(e.length>a)then e.startpos=e.startpos+t;e.endpos=e.endpos+t;e.length=e.endpos-e.startpos;end end end function e:strokeDown(t)local e=self:_detectTargetNotes()local i=self:_getExistStartPosTable(e);local o=t or .005 local a=1;for i,t in ipairs(i)do local t,e=self:_getSameStartPosNotes(t,e,a);for a,e in ipairs(t)do e.startpos=e.startpos+o*(#t-a)end end end function e:strokeUp(a)local e=self:_detectTargetNotes()local t=self:_getExistStartPosTable(e);local o=a or .015 local a=1;for i,t in ipairs(t)do local e,t=self:_getSameStartPosNotes(t,e,a);for t,e in ipairs(e)do e.startpos=e.startpos+o*(t-1)end end end function e:simpleDuplicate()local n=self.mediaItemInfo;local t=self:_detectTargetNotes();local e=self:_getFinalEndPos(t)local a=self:_getFirstStartPos(t)local o=e-a;local a={}for i,e in ipairs(t)do local e=deepcopy(e);e.startpos=e.startpos+o;e.endpos=e.endpos+o;if(n.endProjQN>=e.endpos)then e.selection=true;table.insert(a,e);else end t[i].selection=false;end self:insertNotesFromC(a);end function e:simpleDuplicateType3()local a=self:_detectTargetNotes();local t=self:_getFinalEndPos(a)local e=self:_getFirstStartPos(a)local e=t-e;local t=0;if(e<=.25)then t=.25-e elseif(e<=.5)then t=.5-e elseif(e<=1)then t=1-e elseif(e<=2)then t=2-e elseif(e<=4)then t=4-e else local a=math.floor(e/4+.6);local a=a*4;t=a-e;end e=e+t;e=math.floor((e)*100)/100;local o={}for t,i in ipairs(a)do local t=deepcopy(i);t.startpos=t.startpos+e;t.endpos=t.endpos+e;i.selection=false;if(self.mediaItemInfo.endProjQN>=t.endpos)then t.selection=true;table.insert(o,t);else end a.selection=false;end self:insertNotesFromC(o);end function e:growUp(t,e)local o=self:_detectTargetNotes();local s=e or .25 local h={}local n={}local a=t or 4;local function r(e)return s/(a/e)end for e,t in ipairs(o)do local o=-1;for i=a,1,-1 do local e=deepcopy(t);e.pitch=t.pitch-(a)+i;local a=r(i)e.startpos=t.startpos+(s*a);if(o~=-1)then e.endpos=o+.1 end table.insert(h,e);o=e.startpos end table.insert(n,t);end self:deleteNotes(n);self:insertNotesFromC(h);end function e:twoNoteNudge(o)local a=self:_getSelectionNotes();if(#a~=2)then return end;table.sort(a,function(t,e)return(t.startpos<e.startpos);end);local o=o or .9;local t=a[1];local e=a[2];if((t.length<.015 or e.length<.015)and t.startpos>=e.startpos)then return;end local o=t.length*o;local i=t.startpos+o;local n=i;local s=e.endpos-n;if(o>.01 and s>.01 and i<e.endpos)then t.length=o;t.endpos=i;e.startpos=n;e.length=s;end self:deleteNotes(a);self:insertNoteFromC(t);self:insertNoteFromC(e);end function e:selectAllNoteCurrentTake()reaper.PreventUIRefresh(1)reaper.MIDIEditor_OnCommand(self.editorHwnd,E)reaper.PreventUIRefresh(-1)reaper.MIDI_SelectAll(self.take,true);end function e:noteLengthToEnd()local e=self:_detectTargetNotes();local t=self:_getFinalEndPos(e)for a,e in ipairs(e)do e.endpos=t;end end function e:legatoType2()local a=self:_detectTargetNotes();local e=self:_getExistStartPosTable(a);local i=1;for t,o in ipairs(e)do local a,i=self:_getSameStartPosNotes(o,a,i);for i,a in pairs(a)do local a=a if(t+1<=#e and a.startpos>=o and a.endpos<e[t+1]and a.startpos<e[t+1])then a.endpos=e[t+1]end end end end function e:autoSelection(e)local s=e or 1 local i=reaper.GetExtState(t,l);local n=reaper.GetCursorPosition();i=tonumber(i)or 0 local o=0;local a=127;local e={}if(math.floor(i*1e3)/1e3~=math.floor(n*1e3)/1e3)then local i=self:_detectTargetNotes();o,a=self:_getMaxMinPitch(i);e=self:_getExistPitchNumber(i);local e=table.toString(e)reaper.SetExtState(t,m,e,false);reaper.SetExtState(t,w,tostring(o),false);reaper.SetExtState(t,f,tostring(a),false);else o=reaper.GetExtState(t,w);a=reaper.GetExtState(t,f);o=tonumber(o)or 0 a=tonumber(a)or 127 local t=reaper.GetExtState(t,m);e=table.fromString(t);if(#e<1)then local t=self:_detectTargetNotes();e=self:_getExistPitchNumber(t);end end self.editingNotes=self:_getNotes_(false)self.m_originalNotes=deepcopy(self.editingNotes);local a=reaper.GetExtState(t,y);if(a==nil or a=="")then a=d[1];end;local o=nil for e,t in ipairs(d)do if(t==a)then local e=e+s;if(e>#d)then e=1;end if(e<1)then e=#d;end o=d[e];break;end end local s=self.loopRangeInfo.startProjQN;local r=self.loopRangeInfo.endProjQN;local h=self.loopRangeInfo.lengthProjQN;local i=tonumber(o:split(",")[1]);local a=tonumber(o:split(",")[2]);for o,t in ipairs(self.editingNotes)do t.selection=false;local o=math.floor(t.startpos*100+.6)/100 for n,e in ipairs(e)do if((h<=0 or(t.startpos>=s and t.startpos<r))and e==t.pitch and(math.floor((o)/i))%2==a)then t.selection=true;end end end reaper.SetExtState(t,y,o,false);reaper.SetExtState(t,l,tostring(n),false);end function e:toggleSelectionCrop()local e=self.mediaItemInfo.ptrID;local e=A.."_"..e;local a=reaper.GetExtState(t,e);if(a~="")then local a=table.fromString(a)self:_selectionReset(a);self:insertNotesFromC(a)reaper.SetExtState(t,e,"",false);else if(self:_getSelectionNoteCount()<1)then reaper.SetExtState(t,e,"",false);return end local a=deepcopy(self.editingNotes);reaper.MIDIEditor_OnCommand(self.editorHwnd,T)self.editingNotes=self:_getNotes();self.m_originalNotes=deepcopy(self.editingNotes);local a=self:_detectTargetNotes();reaper.SetExtState(t,e,table.toString(a),false);self:deleteNotes(a);end end function e:_chengePitchCursol(t,e)local i=e or false;local e=reaper.MIDIEditor_GetSetting_int(self.editorHwnd,"active_note_row");local t=math.floor(math.min(math.max(0,t),127));if(e==t)then return;end local o=40049;local a=40050;local o=o;if(e>t)then o=a;end local a=0;while(a<200)do e=reaper.MIDIEditor_GetSetting_int(self.editorHwnd,"active_note_row");e=math.floor(math.min(math.max(0,e),127));if(e==t)then break;end;if(i)then reaper.PreventUIRefresh(10);reaper.MIDIEditor_OnCommand(self.editorHwnd,o);reaper.PreventUIRefresh(-1);else reaper.MIDIEditor_OnCommand(self.editorHwnd,o);end a=a+1;end end function e:_ScrollToPitchRow(e)self:_chengePitchCursol(e,false);end function e:VerticalScrollToTopNotePosition()self.editingNotes=self:_getNotes_(false);self.m_originalNotes=deepcopy(self.editingNotes);local t=self.editingNotes;local e=-1;for a,t in ipairs(t)do e=math.max(e,t.pitch);end self:_ScrollToPitchRow(e);end function e:VerticalScrollToBottomNotePosition()self.editingNotes=self:_getNotes_(false);self.m_originalNotes=deepcopy(self.editingNotes);local t=self.editingNotes;local e=200;for a,t in ipairs(t)do e=math.min(e,t.pitch);end self:_ScrollToPitchRow(e);end function e:VerticalScrollToCenterPosition()self.editingNotes=self:_getNotes_(false);self.m_originalNotes=deepcopy(self.editingNotes);local a=self.editingNotes;local e=200;local t=0;for o,a in ipairs(a)do e=math.min(e,a.pitch);t=math.max(t,a.pitch);end local e=math.floor(e+(t-e)/2);self:_ScrollToPitchRow(e);end function e:VerticalScrollToStep()local e=reaper.GetExtState(t,p);if(e==""or tonumber(e)==nil)then e=1;else e=tonumber(e);end local a=1;if(e==1)then self:VerticalScrollToBottomNotePosition();a=2;elseif(e==2)then self:VerticalScrollToCenterPosition();a=3;elseif(e==3)then self:VerticalScrollToTopNotePosition();a=1;end reaper.SetExtState(t,p,tostring(a),true);end function e:zoomInHorizontal(t)local e=j;for t=1,t do reaper.MIDIEditor_OnCommand(self.editorHwnd,e);end end function e:zoomOutHorizontal(e)local t=x;for e=1,e do reaper.MIDIEditor_OnCommand(self.editorHwnd,t);end end function e:zoomInVertical(e)local t=k;for e=1,e do reaper.MIDIEditor_OnCommand(self.editorHwnd,t);end end function e:zoomOutVertical(e)local t=q;for e=1,e do reaper.MIDIEditor_OnCommand(self.editorHwnd,t);end end function e:_zoomReset(t,a)local e=100;if(t==true)then self:zoomInVertical(e);end if(a==true)then self:zoomInHorizontal(e);end end function e:changeZoom(e,t)self:_zoomReset((e~=0),(t~=0));if(e>0)then self:zoomOutVertical(e);end if(t>0)then self:zoomOutHorizontal(t);end end function e:stepChangeZoom(a,i,o)local e=reaper.GetExtState(t,b..o);if(e==""or tonumber(e)==nil)then e=1;else e=tonumber(e);end local e=e+i;if(e>#a)then e=1;end if(e<1)then e=#a;end self:changeZoom(a[e][1],a[e][2]);if(type(a[e][3])=="function")then a[e][3](self);end reaper.SetExtState(t,b..o,tostring(e),true);end function e:horizontalZoomToContent()reaper.MIDIEditor_OnCommand(self.editorHwnd,z);end function e:detectTopNote()local e=self:_detectTargetNotes();local t=self:_getExistStartPosTable(e);local a={}local o=1;for i,t in ipairs(t)do local t,e=self:_getSameStartPosNotes(t,e,o);local e=-1 for a,t in ipairs(t)do if(e<t.pitch)then e=t.pitch end end if(#t>1)then for o,t in ipairs(t)do if(t.pitch<e)then table.insert(a,t)end end end end self:deleteNotes(a);end function e:detectBottomNote()local e=self:_detectTargetNotes();local t=self:_getExistStartPosTable(e);local a={}local o=1;for i,t in ipairs(t)do local t,e=self:_getSameStartPosNotes(t,e,o);local e=200 for a,t in ipairs(t)do if(e>t.pitch)then e=t.pitch end end if(#t>1)then for o,t in ipairs(t)do if(t.pitch>e)then table.insert(a,t)end end end end self:deleteNotes(a);end function e:deleteTopNote()local e=self:_detectTargetNotes();local o=self:_getExistStartPosTable(e);local a={}local t=1;for i,o in ipairs(o)do local e,t=self:_getSameStartPosNotes(o,e,t);local t=-1 for a,e in ipairs(e)do if(t<e.pitch)then t=e.pitch end end if(#e>1)then for o,e in ipairs(e)do if(e.pitch==t)then table.insert(a,e)end end end end self:deleteNotes(a);end function e:deleteBottomNote()local e=self:_detectTargetNotes();local t=self:_getExistStartPosTable(e);local a={}local o=1;for i,t in ipairs(t)do local t,e=self:_getSameStartPosNotes(t,e,o);local e=200 local o=0;for a,t in ipairs(t)do if(e>t.pitch)then e=t.pitch end end if(#t>1)then for o,t in ipairs(t)do if(t.pitch==e)then table.insert(a,t)end end end end self:deleteNotes(a);end function e:selectTopNote()local e=self:_detectTargetNotes();local t=self:_getExistStartPosTable(e);local a=1;for o,t in ipairs(t)do local e,t=self:_getSameStartPosNotes(t,e,a);local t=-1 for a,e in ipairs(e)do if(t<e.pitch)then t=e.pitch end end if(#e>=1)then for a,e in ipairs(e)do if(e.pitch==t)then e.selection=true;else e.selection=false;end end end end end function e:selectBottomNote()local e=self:_detectTargetNotes();local a=self:_getExistStartPosTable(e);local t=1;for o,a in ipairs(a)do local t,e=self:_getSameStartPosNotes(a,e,t);local e=200 for a,t in ipairs(t)do if(e>t.pitch)then e=t.pitch end end if(#t>=1)then for a,t in ipairs(t)do if(t.pitch==e)then t.selection=true;else t.selection=false;end end end end end function e:selectMiddleNotes()local e=self:_detectTargetNotes();local t=self:_getExistStartPosTable(e);local a=1;for o,t in ipairs(t)do local e,t=self:_getSameStartPosNotes(t,e,a);local a=200 local t=0 for o,e in ipairs(e)do a=math.min(a,e.pitch);t=math.max(t,e.pitch);end if(#e>=1)then for o,e in ipairs(e)do if(e.pitch>a and e.pitch<t)then e.selection=true;else e.selection=false;end end end end end function e:generateSelectionArp()local i={}local o=self:_getMidiGrid()local function a(t)local e=0;for a,t in ipairs(t)do if(e<t.length and(self:isSelectionInEditingNotes()==true and t.selection==true or self:isSelectionInEditingNotes()==false))then e=t.length end end return e;end local function e(e)local t={}for a,e in ipairs(e)do if(self:isSelectionInEditingNotes()==true and e.selection==true or self:isSelectionInEditingNotes()==false)then table.insert(t,e)end end return t;end local function r()local e=self:_detectTargetNotes();local t=self:_getExistStartPosTable(e);local n=1;for s,t in ipairs(t)do local e,t=self:_getSameStartPosNotes(t,e,n);if(#e>=1)then local t=a(e)local s=math.floor(t/o);local n=#e;table.sort(e,function(e,t)return(e.pitch<t.pitch)end);local a=e[1].startpos;local o=o*.99999;local t=1;local function h()t=t+1;if(t>n)then t=1;end end for i=1,s,1 do local e=deepcopy(e[t]);e.length=o;e.startpos=a e.endpos=e.startpos+e.length;self:insertNoteFromC(e)a=a+o;h();end for t,e in ipairs(e)do table.insert(i,e)end end end end r();self:deleteNotes(i);end function e:selectSimilerChord(t)local e=self:_getSelectionNotes(self.editingNotes);local n=self:_getExistPitchNumber(e);self.editingNotes=self:_getNotes_(false)self.m_originalNotes=deepcopy(self.editingNotes);self:_selectionReset(self.editingNotes);local e=t or 0;local s=self:_getChordTones_Near(e);local function h(t,a)local e=false;for o,t in ipairs(t)do if(t.pitch==a)then e=true break;end end return e;end local function i(e,a)local o=false;local t=0;for i,o in ipairs(e)do if(h(a,o)==true and#e==#a)then t=t+1;end end if(t>=#e)then o=true;end return o;end for t,e in ipairs(s)do if(i(n,e)==true)then for t,e in ipairs(e)do e.selection=true;end end end end function e:selectTopNote_Near(t)local e=self:_detectTargetNotes();table.sort(e,function(e,t)return(e.startpos<t.startpos)end);local o=1;local a=t or 1/4;for i,t in ipairs(e)do if(t._checkedAsChordNote_~=true)then local e,t=self:_detectChordNotesNear(t.startpos,e,o,a);local t=-1 for a,e in ipairs(e)do t=math.max(t,e.pitch);end for a,e in ipairs(e)do if(e._isChordChecked_~=true)then if(e.pitch==t)then e.selection=true;else e.selection=false;end else e._isChordChecked_=true;end end end end end function e:detectTopNote_Near(a)local e=self:_detectTargetNotes();table.sort(e,function(t,e)return(t.startpos<e.startpos)end);local i=1;local o=a or 1/4;local t={};for n,a in ipairs(e)do if(a._checkedAsChordNote_~=true)then local a,e=self:_detectChordNotesNear(a.startpos,e,i,o);local e=-1 for a,t in ipairs(a)do e=math.max(e,t.pitch);end for o,a in ipairs(a)do if(a.pitch<e)then table.insert(t,a)end end end end self:deleteNotes(t);end function e:deleteTopNote_Near(t)local e=self:_detectTargetNotes();table.sort(e,function(t,e)return(t.startpos<e.startpos)end);local o=1;local i=t or 1/4;local a={}for n,t in ipairs(e)do if(t._checkedAsChordNote_~=true)then local e,t=self:_detectChordNotesNear(t.startpos,e,o,i);local t=-1 for a,e in ipairs(e)do t=math.max(t,e.pitch);end for o,e in ipairs(e)do if(e._isChordChecked_~=true)then if(e.pitch==t)then table.insert(a,e)end else e._isChordChecked_=true;end end end end self:deleteNotes(a);end function e:selectBottomNote_Near(o)local e=self:_detectTargetNotes();table.sort(e,function(t,e)return(t.startpos<e.startpos)end);local a=1;local o=o or 1/4;for i,t in ipairs(e)do if(t._checkedAsChordNote_~=true)then local e,t=self:_detectChordNotesNear(t.startpos,e,a,o);local t=200 for a,e in ipairs(e)do t=math.min(t,e.pitch);end for a,e in ipairs(e)do if(e._isChordChecked_~=true)then if(e.pitch==t)then e.selection=true;else e.selection=false;end else e._isChordChecked_=true;end end end end end function e:detectBottomNote_Near(a)local e=self:_detectTargetNotes();table.sort(e,function(t,e)return(t.startpos<e.startpos)end);local i=1;local o=a or 1/4;local a={};for n,t in ipairs(e)do if(t._checkedAsChordNote_~=true)then local e,t=self:_detectChordNotesNear(t.startpos,e,i,o);local t=200 for a,e in ipairs(e)do t=math.min(t,e.pitch);end for o,e in ipairs(e)do if(e._isChordChecked_~=true)then if(e.pitch>t)then table.insert(a,e)end else e._isChordChecked_=true;end end end end self:deleteNotes(a);end function e:deleteBottomNote_Near(t)local e=self:_detectTargetNotes();table.sort(e,function(e,t)return(e.startpos<t.startpos)end);local o=1;local i=t or 1/4;local a={};for n,t in ipairs(e)do if(t._checkedAsChordNote_~=true)then local e,t=self:_detectChordNotesNear(t.startpos,e,o,i);local t=200 for a,e in ipairs(e)do t=math.min(t,e.pitch);end for o,e in ipairs(e)do if(e._isChordChecked_~=true)then if(e.pitch==t)then table.insert(a,e)end else e._isChordChecked_=true;end end end end self:deleteNotes(a);end function e:selectMiddleNotes_Near(a)local e=self:_detectTargetNotes();table.sort(e,function(t,e)return(t.startpos<e.startpos)end);local o=1;local a=a or 1/4;for i,t in ipairs(e)do if(t._checkedAsChordNote_~=true)then local o,e=self:_detectChordNotesNear(t.startpos,e,o,a);local a=200 local t=0 for o,e in ipairs(o)do a=math.min(a,e.pitch);t=math.max(t,e.pitch);end for o,e in ipairs(o)do if(e.pitch>a and e.pitch<t)then e.selection=true;else e.selection=false;end end end end end function e:_patternSelect(t,a)local e=1;table.sort(t,function(t,e)return(t.pitch<e.pitch);end);for o,t in ipairs(t)do t.selection=a[e]or false;e=e+1;if(e>#a)then e=1;end end end function e:_getChordTones_Near(t)local e=self:_detectTargetNotes();table.sort(e,function(e,t)return(e.startpos<t.startpos)end);local i=1;local o=t or 1/4;local t={};for n,a in ipairs(e)do if(a._checkedAsChordNote_~=true)then local a,e=self:_detectChordNotesNear(a.startpos,e,i,o);local e={}for a,t in ipairs(a)do table.insert(e,t)end table.insert(t,e);end end return t;end function e:incrementNoteChannel()local e=self:_detectTargetNotes()for t,e in ipairs(e)do e.chan=e.chan+1;if(e.chan>15)then e.chan=0;end;if(e.chan<0)then e.chan=15;end;end end function e:decrementNoteChannel()local e=self:_detectTargetNotes()for t,e in ipairs(e)do e.chan=e.chan-1;if(e.chan>15)then e.chan=0;end;if(e.chan<0)then e.chan=15;end;end end function e:assignChordToneToChannel_B()local e=self:_detectTargetNotes();local t=self:_getExistStartPosTable(e);local a=1;for o,t in ipairs(t)do local t,e=self:_getSameStartPosNotes(t,e,a);table.sort(t,function(e,t)return(e.pitch<t.pitch);end);local e=0;for a,t in ipairs(t)do if(a==1)then e=t.chan;else t.chan=e;end e=e+1;if(e>15)then e=0;end;if(e<0)then e=15;end;end end end function e:assignChordToneToChannel_B_Near(o)local e=self:_detectTargetNotes();table.sort(e,function(t,e)return(t.startpos<e.startpos)end);local a=1;local o=o or 1/4;for i,t in ipairs(e)do if(t._checkedAsChordNote_~=true)then local t,e=self:_detectChordNotesNear(t.startpos,e,a,o);table.sort(t,function(e,t)return(e.pitch<t.pitch);end);local e=0;for a,t in ipairs(t)do if(a==1)then e=t.chan;else t.chan=e;end e=e+1;if(e>15)then e=0;end;if(e<0)then e=15;end;end end end end function e:flush(t,e)if(self:_checkProcessLimitNum()==0)then return end;if(t==nil)then self:_deleteMinimunLengthNote();end if(e==nil)then self:_safeOverLap();end self:_deleteAllOriginalNote();self:_editingNoteToMediaItem();reaper.MIDI_Sort(self.take);end function e:reset()self.editingNotes={}self.editingNotes=deepcopy(self.m_originalNotes);end function e:insertNoteFromC(e)e.idx=#self.editingNotes+1;table.insert(self.editingNotes,e);end function e:insertNotesFromC(e)for t,e in ipairs(e)do self:insertNoteFromC(e)end end function e:insertMidiNote(i,o,e,s,r,n,a)local t=e local e=s local h=o;local s=r or false;local a=a or false;local o=n or 1;local n=i;local i=#self.editingNotes+1;local e={selection=s,mute=a,startpos=t,endpos=e,chan=o,pitch=n,vel=h,take=self.take,idx=i,length=e-t}table.insert(self.editingNotes,e);end function e:deleteNote(e)for t,a in ipairs(self.editingNotes)do if(a.idx==e.idx)then table.remove(self.editingNotes,t)break;end end end function e:deleteNotes(e)if(e==self.editingNotes)then self.editingNotes={};return;end for t,e in ipairs(e)do self:deleteNote(e)end end function e:_init()self.editorHwnd=reaper.MIDIEditor_GetActive();self.take=reaper.MIDIEditor_GetTake(self.editorHwnd);if(self.take==nil)then return end self:_storeActionContextInfo();local e=reaper.GetToggleCommandStateEx(self.actionContextInfo.sectionID,g);if(e==0)then reaper.MIDIEditor_OnCommand(self.editorHwnd,g)end self.mediaItem=reaper.GetMediaItemTake_Item(self.take);self.mediaTrack=reaper.GetMediaItemTrack(self.mediaItem);self.mediaItemInfo=self:_storeMediaItemInfo();self.loopRangeInfo=self:_storeTimeSelectionInfo();self.editingNotes=self:_getNotes();self.m_originalNotes=deepcopy(self.editingNotes);end function e:_storeTimeSelectionInfo()local e,t=reaper.GetSet_LoopTimeRange2(0,false,_,0,0,false)local n=reaper.MIDI_GetPPQPosFromProjTime(self.take,e);local i=reaper.MIDI_GetPPQPosFromProjTime(self.take,t);local h=reaper.MIDI_GetProjQNFromPPQPos(self.take,n);local r=reaper.MIDI_GetProjQNFromPPQPos(self.take,i);local o=t-e;local a=reaper.MIDI_GetPPQPosFromProjTime(self.take,o);local s=reaper.MIDI_GetProjQNFromPPQPos(self.take,a);if(o<=0)then a=0 s=0 end local e={startTime=e,endTime=t,lengthTime=o,startPpq=n,endPpq=i,lengthPpq=a,startProjQN=h,endProjQN=r,lengthProjQN=s}return e;end function e:_getMidiGrid()local t,a,e=reaper.MIDI_GetGrid(self.take);return t,a,e end function e:_storeActionContextInfo()local t,i,a,s,n,o,e=reaper.get_action_context();self.actionContextInfo={is_new_value=t,filename=i,sectionID=a,cmdID=s,mode=n,resolution=o,val=e};return self.actionContextInfo;end function e:_storeMediaItemInfo()local t=reaper.GetMediaItemInfo_Value(self.mediaItem,"D_POSITION");local e=reaper.GetMediaItemInfo_Value(self.mediaItem,"D_LENGTH");local a=t+e;local i=reaper.MIDI_GetPPQPosFromProjTime(self.take,t);local o=reaper.MIDI_GetPPQPosFromProjTime(self.take,e)local n=reaper.MIDI_GetPPQPosFromProjTime(self.take,a)local r=reaper.MIDI_GetProjQNFromPPQPos(self.take,i);local d=reaper.MIDI_GetProjQNFromPPQPos(self.take,o);local h=reaper.MIDI_GetProjQNFromPPQPos(self.take,n);local s=reaper.GetMediaItemInfo_Value(self.mediaItem,"IP_ITEMNUMBER");local e={startTime=t,lengthTime=e,endTime=a,startPpq=i,lengthPpq=o,endPpq=n,startProjQN=r,lengthProjQN=d,endProjQN=h,mediaItem=midiMediaItem,take=takeMidi,IP_NUM_RO=s,ptrID=tostring(self.mediaItem);}return e;end function e:_getNotes()local e={}if(_W_MODE_ON_==true)then e=self:_getNotes_(false);else e=self:_getNotes_(true);if(#e<1)then e=self:_getNotes_(false)end end return e;end function e:_getNotes_(n)local c=reaper.GetToggleCommandStateEx(self.actionContextInfo.sectionID,r);if(c==0)then reaper.MIDIEditor_OnCommand(self.editorHwnd,r)end local i={};local m=self.take if(self.take==nil)then return i end reaper.MIDI_Sort(self.take)local l,o,u,e,t,h,s,d=reaper.MIDI_GetNote(self.take,0)local a=0 while l do e=reaper.MIDI_GetProjQNFromPPQPos(m,e)t=reaper.MIDI_GetProjQNFromPPQPos(m,t)local r={selection=o,mute=u,startpos=e,endpos=t,chan=h,pitch=s,vel=d,take=self.take,idx=a,length=t-e}if(n==true and o==n or n==false)then table.insert(i,r);end a=a+1 l,o,u,e,t,h,s,d=reaper.MIDI_GetNote(self.take,a)end if(c==0)then reaper.MIDIEditor_OnCommand(self.editorHwnd,r)end return i;end function e:_deleteAllOriginalNote(e)local e=e or self.m_originalNotes;while(#e>0)do local t=#e;reaper.MIDI_DeleteNote(e[t].take,e[t].idx)table.remove(e,#e);end end function e:_insertNoteToMediaItem(e)local t=self.take if t==nil then return end local h=e.selection or false;local s=e.mute;local i=reaper.MIDI_GetPPQPosFromProjQN(t,e.startpos)local n=reaper.MIDI_GetPPQPosFromProjQN(t,e.endpos)local o=e.chan;local a=e.pitch;local e=e.vel;reaper.MIDI_InsertNote(t,h,s,i,n,o,a,e,false)end function e:_editingNoteToMediaItem()local e=reaper.GetToggleCommandStateEx(self.actionContextInfo.sectionID,r);if(e==0)then reaper.MIDIEditor_OnCommand(self.editorHwnd,r)end for t,e in ipairs(self.editingNotes)do self:_insertNoteToMediaItem(e)end if(e==0)then reaper.MIDIEditor_OnCommand(self.editorHwnd,r)end end function e:_safeOverLap(e)local t=e or self.editingNotes local function a(t,a)local e={}for o,t in ipairs(t)do if(a.pitch==t.pitch)then table.insert(e,t);end end table.sort(e,function(t,e)return(t.startpos<e.startpos)end);return e;end table.sort(t,function(e,t)return(e.startpos<t.startpos)end);local o=deepcopy(t);local n={};local i={};while(#o>0)do local a=a(o,o[1]);while(#a>=2)do local e=a[1]local t=a[2]if(t~=nil and e.startpos<t.startpos and e.endpos>t.startpos)then table.insert(i,e);e.endpos=t.startpos-.001;e.length=e.endpos-e.startpos;t.startpos=e.endpos+.001;table.insert(n,e);end table.remove(a,1);end table.remove(o,1);end self:deleteNotes(i);self:insertNotesFromC(n);end function e:_deleteMinimunLengthNote()local t={}for a,e in ipairs(self.editingNotes)do if(e.endpos-e.startpos<.001)then table.insert(t,e);end end self:deleteNotes(t);end function e:_checkProcessLimitNum()local e=true;if(#self.editingNotes<self.m_processLimitNoteNum_min+1)then e=false end;if(#self.editingNotes>=self.m_processLimitNoteNum)then e=false;end;return e;end function e:_detectTargetNotes()local e=nil if(self:isSelectionInEditingNotes()==true)then e=self:_getSelectionNotes(self.editingNotes);else e=self.editingNotes end return e;end function e:_getSameStartPosNotes(i,a,t)local e={};local t=t or 1;local o=a or self.editingNotes;for a=t,#o do local o=o[a]if(o.startpos==i)then table.insert(e,o);t=a end end table.sort(e,function(e,t)return(e.pitch>t.pitch)end);return e,t;end function e:_getNearStartPosNotes(n,a,e,o)local t={};local e=e or 1;local a=a or self.editingNotes;local i=o or 1/16;for o=e,#a do local a=a[o]if(a.startpos>n-i and a.startpos<n+i)then table.insert(t,a);e=o;end end table.sort(t,function(t,e)return(t.pitch>e.pitch)end);return t,e;end function e:_detectChordNotesNear(o,n,e,i)local t={};local a=e or 1;local e=n or self.editingNotes;local i=i or 1/16;for n=a,#e do local e=e[n]if(e.startpos>=o-i and e.startpos<=o+i and e._checkedAsChordNote_~=true)then e._checkedAsChordNote_=true;table.insert(t,e);a=n;end end table.sort(t,function(e,t)return(e.pitch>t.pitch)end);return t,a;end function e:_getExistStartPosTable(e)local t={}local e=e or self.editingNotes;table.sort(e,function(t,e)return(t.startpos<e.startpos)end);local a=-100;for o,e in ipairs(e)do if(a~=e.startpos)then table.insert(t,e.startpos);a=e.startpos end end return t end function e:_getFinalEndPos(t)local e=0;local t=t or self.editingNotes;for a,t in ipairs(t)do if(e<t.endpos)then e=t.endpos;end end return e;end function e:_getFirstStartPos(e)local t=e or self.editingNotes;local e=self:_getFinalEndPos(t,isSelection);for a,t in ipairs(t)do if(e>t.startpos)then e=t.startpos;end end return e;end function e:_getRangeContainsNotes(e,t)local a=e.startpos;local o=e.endpos;local a=e.length;local t=t or self.editingNotes;local a={}for i,t in ipairs(t)do if(e.startpos<=t.startpos and t.startpos<=o)then table.insert(a,t)end end table.sort(a,function(t,e)return(t.pitch<e.pitch)end)return a;end function e:_selectionReset(e)local e=e or self.editingNotes;for t,e in ipairs(e)do e.selection=false;end if(e==self.editingNotes)then self.m_isSelection=false end end function e:_toSelectionAll(e)local e=e or self.editingNotes;for t,e in ipairs(e)do e.selection=true;end if(e==self.editingNotes)then self.m_isSelection=true end end function e:_toSelectionInverse(e)local t=e or self.editingNotes;for t,e in ipairs(t)do e.selection=(e.selection==false);end if(t==self.editingNotes)then self.m_firstSelectionCheck=nil end end function e:_getSelectionNoteCount(t)local e=0;local t=t or self.editingNotes;for a,t in ipairs(t)do if(t.selection==true)then e=e+1;end end return e;end function e:_getMaxMinPitch(e)local a=e or self.editingNotes;local t=200;local e=-1;for o,a in ipairs(a)do t=math.min(t,a.pitch)e=math.max(e,a.pitch)end return t,e end function e:_getExistPitchNumber(e)local t=e or self.editingNotes;local e={}for a,t in ipairs(t)do local a=false for o,e in ipairs(e)do if(e==t.pitch)then a=true;break;end end if(a==false)then table.insert(e,t.pitch)end end return e;end function e:_getSelectionNotes(a)local t={}local a=a or self.editingNotes;for a,e in ipairs(a)do if(e.selection==true)then table.insert(t,e);end end return t;end e:_init();if(_USE_TESTING_FUNC_==true)then local t=reaper.GetResourcePath().."\\Scripts\\ReaScript_MIDI\\TESTING\\_kawa_testing.lua"local t=io.open(t,"r")if(t~=nil)then _add_MIDI_TestingFunction(e);end end return e;end if(package.config:sub(1,1)=="\\")then else end local e=createMIDIClip();e:setProcessLimitNum_Min(-1);local t={}table.insert(t,{55,0});table.insert(t,{80,0});table.insert(t,{98,0});if(e:checkProcessLimitNum())then local a=1;e:stepChangeZoom(t,a,"vertType1");e:flush();reaper.UpdateArrange();end
