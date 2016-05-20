--====================================================================== 
--[[ 
* ReaScript Name: kawa_MAIN_TakeNameToTrackName. 
* Version: 2016/06/15 
* Author: kawa_ 
* Author URI: http://forum.cockos.com/member.php?u=105939 
* Repository: GitHub 
* Repository URI: https://github.com/kawaCat/ReaScript-MidiPack 
--]] 
--====================================================================== 
function deepcopy(t)local a=type(t)local e if a=='table'then e={}for a,t in next,t,nil do e[deepcopy(a)]=deepcopy(t)end setmetatable(e,deepcopy(getmetatable(t)))else e=t end return e end function string:split(e)local t,e=e or":",{}local t=string.format("([^%s]+)",t)self:gsub(t,function(t)e[#e+1]=t end)return e end function table.toString(a)local function l(e)return string.format("%q",e)end local d="";local function e(e)d=d..e end;local r,t="   ","\n"local h,a={a},{[a]=1}e("return {"..t)for o,n in ipairs(h)do e("-- Table: {"..o.."}"..t)e("{"..t)local d={}for i,o in ipairs(n)do d[i]=true local i=type(o)if i=="table"then if not a[o]then table.insert(h,o)a[o]=#h end e(r.."{"..a[o].."},"..t)elseif i=="string"then e(r..l(o)..","..t)elseif i=="number"then e(r..tostring(o)..","..t)end end for s,n in pairs(n)do if(not d[s])then local i=""local o=type(s)if o=="table"then if not a[s]then table.insert(h,s)a[s]=#h end i=r.."[{"..a[s].."}]="elseif o=="string"then i=r.."["..l(s).."]="elseif o=="number"then i=r.."["..tostring(s).."]="end if(i~="")then o=type(n)end if o=="table"then if not a[n]then table.insert(h,n)a[n]=#h end e(i.."{"..a[n].."},"..t)elseif o=="string"then e(i..l(n)..","..t)elseif o=="number"then e(i..tostring(n)..","..t)elseif o=="boolean"then e(i..tostring(n)..","..t)end end end e("},"..t)end e("}")return d;end function table.fromString(e)local e=load(e);local e=e()if(type(e)~="table")then local e={}return e end for a=1,#e do local i={}for t,o in pairs(e[a])do if type(o)=="table"then e[a][t]=e[o[1]]end if type(t)=="table"and e[t[1]]then table.insert(i,{t,e[t[1]]})end end for o,t in ipairs(i)do e[a][t[2]],e[a][t[1]]=e[a][t[1]],nil end end return e[1]end function stringIter(t)local e=0;local a=string.len(t);return function()e=e+1;if(e>a)then return nil else return e,string.sub(t,e,e)end end end math.randomseed(reaper.time_precise()*os.time()/1e3)local j=500;local x=false;local z=true local _=41383 local E=40058 local w=41613 local N=40635 local I=40297 local p=40914 local f=40289 local T=40757 local O=40290 local A=41720 local S=40205 local R=40204 local D=40289 local H=41588 local y=40454 local e=40455 local e=40456 local e=40457 local e=40458 local e=40459 local e=40460 local e=40461 local e=40462 local c=40463 local a="kawa_MainClip"local g="lastEditCursolTime"local b="lastToggleLength"local k="lastAutoSelection"local v="lastAutoSelectionExistTrack"local q="last_window_set"local m=0;local l={"4,0","4,1","2,0","2,1","1,0","1,1","0.5,0","0.5,1","0.25,0","0.25,1"}local u={"4","3","2","1","0.5","0.25","0.125"}if(_DBG_==true)then end _USE_TESTING_FUNC_=false function _toIntColor(e,a,o)local t=string.format("%x",e)local e=string.format("%x",a)local a=string.format("%x",o)if(#t<2)then t="0"..t end if(#e<2)then e="0"..e end if(#a<2)then a="0"..a end local e="01"..a..e..t;return tonumber(e,16)end function HSVToRGB(s,c,u)local i,a,n,r,l,e,t,h,o local d=s local s=c if(d>360)then d=d-360;elseif(d<0)then d=d+360;end if(s>1)then s=1;elseif(s<0)then s=0;end e=math.floor(255*u)if(e>255)then e=255;elseif(e<0)then e=0;end if(s==0)then i=e;a=e;n=e;else r=math.floor(d/60)l=d/60-r t=math.floor(e*(1-s))if(t<0)then t=0;elseif(t>255)then t=255;end h=math.floor(e*(1-l*s))if(h<0)then h=0;elseif(h>255)then h=255;end o=math.floor(e*(1-(1-l)*s))if(o<0)then o=0;elseif(o>255)then o=55;end if(r==0)then i=e;a=o;n=t;elseif(r==1)then i=h;a=e;n=t;elseif(r==2)then i=t;a=e;n=o;elseif(r==3)then i=t;a=h;n=e;elseif(r==4)then i=o;a=t;n=e;elseif(r==5)then i=e;a=t;n=h;else i=e;a=o;n=t;end end return i,a,n end function RGBToHSV(o,a,i)o,a,i=o/255,a/255,i/255;local t,s=math.max(o,a,i),math.min(o,a,i)local e,n,h=0,0,0 e=t-s;if(e>0)then if(t==o)then e=(a-i)/e;if(e<0)then e=e+6;end elseif(t==a)then e=2+(i-o)/e;else e=4+(o-a)/e;end end e=e/6;n=t-s;if(t~=0)then n=n/t;end h=t;return e,n,h;end function createMediaItemClip()local e={}e.editingItems={}e.m_originalItems={}e.loopRangeInfo={};e.m_isSelection=nil e.m_firstSelectionCheck=nil;e.m_processLimitNoteNum=j;e.m_processLimitNoteNum_min=0;function e:isExistSelectionItem(e)if(self.m_firstSelectionCheck~=true or e~=nil)then for t,e in ipairs(self.editingItems)do if(e.b_selection==true or e.b_selection==1)then self.m_isSelection=true break;end self.m_isSelection=false;end self.m_firstSelectionCheck=true;end return self.m_isSelection;end function e:checkProcessLimitNum()local e=self:_checkProcessLimitNum()if(e~=true and#self.editingItems~=0 and z==true)then local e=self.m_processLimitNoteNum;reaper.ShowMessageBox("over "..tostring(e).." clip num .\nstop process","stop",0)end return e;end function e:setProcessLimitNum(e)self.m_processLimitNoteNum=e end function e:setProcessLimitNum_Min(e)self.m_processLimitNoteNum_min=e end function e:selectedItemsStemRender()if(self:isExistSelectionItem()==false)then return;end;local e=self:_detectTargetItems();if(#e>20)then reaper.ShowMessageBox("over "..tostring(20).." clip num .\nstop process","stop.",0)return end for t,e in ipairs(e)do local t=e.trackInfo.track local e=e.mediaItem reaper.Main_OnCommand(f,0)reaper.SetMediaItemSelected(e,1)reaper.SetOnlyTrackSelected(t,1);reaper.Main_OnCommand(p,m)reaper.Main_OnCommand(O,m)reaper.Main_OnCommand(A,m)end end function e:duplicateMusical()if(self:isExistSelectionItem()==false)then return;end;local o=self:_detectTargetItems();local i=o[1].projQnInfo.Start;local e=o[#o].projQnInfo.End;local e=e-i-1e-6;local t,a=reaper.GetProjectTimeSignature()local t=0;if(e<=.25)then t=.25-e elseif(e<=.5)then t=.5-e elseif(e<1)then t=1-e elseif(e<2)then t=2-e elseif(e<a)then t=a-e else local o=math.floor(e/a)+1;local a=o*a;t=a-e;end e=e+t;local t=reaper.TimeMap2_QNToTime(0,i+e)local e=self.editingItems[1].trackInfo.track;reaper.PreventUIRefresh(7)reaper.Main_OnCommand(N,0)reaper.Main_OnCommand(_,0)reaper.Main_OnCommand(I,0)reaper.SetOnlyTrackSelected(e,true);reaper.Main_OnCommand(p,0)reaper.SetEditCurPos(t,true,false)reaper.Main_OnCommand(E,0)reaper.Main_OnCommand(w,0)reaper.PreventUIRefresh(-1)for t,e in ipairs(o)do e.b_selection=0 end end function e:changeLength(t)if(self:isExistSelectionItem()==false)then return;end;local e=self:_detectTargetItems();for a,e in ipairs(e)do e.d_length=e.d_length*t end end function e:toggleLength(t)if(self:isExistSelectionItem()==false)then return;end;local e=reaper.GetExtState(a,b);if(e=="")then e=u[1];end local o=t or 1 local t=1;for i,a in ipairs(u)do if(a==e)then local e=i+o;if(e>#u)then e=1;end if(e<1)then e=#u;end t=u[e];break;end end local e=self:_detectTargetItems();for e,a in ipairs(e)do local e=reaper.TimeMap2_QNToTime(0,tonumber(t));a.d_length=e-1e-5;end reaper.SetExtState(a,b,t,true);end function e:splitItem(e)if(self:isExistSelectionItem()==false)then return;end;local a=e or 3;local i={}local o=self:_detectTargetItems();for t,e in ipairs(o)do reaper.Main_OnCommand(f,0)local t=e.timeInfo.Length/a;if(t<.005)then return end;local o=e.timeInfo.Start reaper.SetMediaItemSelected(e.mediaItem,1)for a=1,a do local a=o+t*a reaper.PreventUIRefresh(3)reaper.SetEditCurPos(a,true,false)reaper.Main_OnCommand(T,0)reaper.Main_OnCommand(w,0)reaper.PreventUIRefresh(-1)local e=deepcopy(e)e.timeInfo.End=a;e.timeInfo.Start=a-t;e.timeInfo.Length=t;table.insert(i,e)end end self:_toSelectionInvert()self.m_isSelection=false self.editingItems=self:_getMediaItems_(false);self.originalItems=deepcopy(self.editingItems);o=self:_detectTargetItems();for t,e in ipairs(o)do for a,t in ipairs(i)do if(math.floor(e.timeInfo.Start*100)/100==math.floor(t.timeInfo.Start*100)/100 and math.floor(e.timeInfo.End*100)/100==math.floor(t.timeInfo.End*100)/100 and math.floor(e.timeInfo.Length*100)/100==math.floor(t.timeInfo.Length*100)/100)then e.b_selection=1;self.m_isSelection=true;self:_applyChangeMediaItem(e);break;end end end end function e:nudgeStartPos(e)if(self:isExistSelectionItem()==false)then return;end;local t=e or .99;local e=self:_detectTargetItems();for a,e in ipairs(e)do local t=(e.d_length*(1-t));e.d_position=e.d_position-t e.d_length=e.d_length+t end end function e:nudgeWaveOffset(e)if(self:isExistSelectionItem()==false)then return;end;local e=e or .99;local t=reaper.TimeMap2_QNToTime(0,.0125)local t=t*(e);local e=self:_detectTargetItems();for a,e in ipairs(e)do e.takeInfo.d_startOffset=e.takeInfo.d_startOffset+t end end function e:transposeItem(e)if(self:isExistSelectionItem()==false)then return;end;local t=0 if(e<0)then t=S;else t=R;end local t=math.abs(e)local t=self:_detectTargetItems();for a,t in ipairs(t)do t.takeInfo.d_pitch=t.takeInfo.d_pitch+e end end function e:selectedItemsGlue()if(self:isExistSelectionItem()==false)then return;end;local e=self:_detectTargetItems();for t,e in ipairs(e)do reaper.PreventUIRefresh(3)reaper.Main_OnCommand(D,0)reaper.SetMediaItemSelected(e.mediaItem,true)reaper.Main_OnCommand(H,0)reaper.PreventUIRefresh(-1)end self:_init();end function e:changeTuningPitch(e)if(self:isExistSelectionItem()==false)then return;end;local a=e or 440;local o=self:_detectTargetItems();local function t(e)return 1200*math.log(e/440)/math.log(2);end local function e(e)return math.exp(e/1200*math.log(2))*440;end for o,e in ipairs(o)do local e=e.takeInfo;local t=t(a);e.d_pitch=t*.01;end end function e:getSelectionItemTuningPitch(o)if(self:isExistSelectionItem()==false)then return;end;local t=self:_detectTargetItems();local function e(t,e)local t=e or 440;local e=offestCent or 440;return 1200*math.log(e/t)/math.log(2);end local function a(e,t)local t=t or 440;local e=e or 440;return math.exp(e/1200*math.log(2))*t;end local o=o or 440;local e=0;for i,t in ipairs(t)do local t=t.takeInfo;e=a(t.d_pitch*100,o);end return e;end function e:mediaItemNameToTrackName()if(self:isExistSelectionItem()==false)then return;end;local e=self:_detectTargetItems();for t,e in ipairs(e)do local t=e.trackInfo;local e=e.takeInfo;if(e~=nil)then local e=e.takeName;local a=e:match("^.+(%..+)$")or""e=e:gsub(a,"")reaper.GetSetMediaTrackInfo_String(t.track,"P_NAME",e,true)end end end function e:_check_SWS_Function(t)local e=false for t,a in pairs(reaper)do if(tostring(t)=="BR_EnvAlloc")then e=true end end if(e==false and t~=true)then reaper.ShowMessageBox("this scripts need sws extenstion. ","stop",0)end return e end function e:takeNameToTextClip()if(self:_check_SWS_Function()==false)then return;end if(self:isExistSelectionItem()==false)then return;end;local i=self:_detectTargetItems();local function o(t)local e="";if(t~=nil)then e=t.takeName;end local t=e:split(".");local e="";for a=1,#t-1 do e=e..t[a];end return e;end for t,e in ipairs(i)do local a=o(e.takeInfo);local t=e.trackInfo.track;local t=reaper.AddMediaItemToTrack(t)reaper.SetMediaItemInfo_Value(t,"C_BEATATTACHMODE",e.c_beatAttachMode)reaper.SetMediaItemInfo_Value(t,"C_LOCK",e.c_lock)reaper.SetMediaItemInfo_Value(t,"D_VOL",e.c_vol)reaper.SetMediaItemInfo_Value(t,"D_POSITION",e.d_position)reaper.SetMediaItemInfo_Value(t,"D_LENGTH",e.d_length)reaper.SetMediaItemInfo_Value(t,"D_SNAPOFFSET",e.d_snapOffset)reaper.SetMediaItemInfo_Value(t,"D_FADEINLEN",e.d_fadeInLength)reaper.SetMediaItemInfo_Value(t,"D_FADEOUTLEN",e.d_fadeOutLength)reaper.SetMediaItemInfo_Value(t,"D_FADEINLEN_AUTO",e.d_fadeInLenAuto)reaper.SetMediaItemInfo_Value(t,"D_FADEOUTLEN_AUTO",e.d_fadeOutLenAuto)reaper.SetMediaItemInfo_Value(t,"C_FADEINSHAPE",e.c_fadeInShape)reaper.SetMediaItemInfo_Value(t,"C_FADEOUTSHAPE",e.c_fadeOutShape)reaper.SetMediaItemInfo_Value(t,"I_GROUPID",e.i_groupId)reaper.SetMediaItemInfo_Value(t,"I_LASTY",e.i_lastY)reaper.SetMediaItemInfo_Value(t,"I_LASTH",e.i_lastH)reaper.SetMediaItemInfo_Value(t,"I_CUSTOMCOLOR",e.i_customColor)reaper.SetMediaItemInfo_Value(t,"F_FREEMODE_Y",e.f_freeModeY)reaper.SetMediaItemInfo_Value(t,"F_FREEMODE_H",e.f_freeModeH)reaper.ULT_SetMediaItemNote(t,a);end end function e:autoSelection(o)local t=reaper.GetExtState(a,g);local i=reaper.GetCursorPosition();t=tonumber(t)or 0 local e={};if(math.floor(t*1e3)/1e3~=math.floor(i*1e3)/1e3)then e=self:_getExistTrack();local e=table.toString(e);reaper.SetExtState(a,v,e,true);else local t=reaper.GetExtState(a,v);e=table.fromString(t);if(#e<1)then e=self:_getExistTrack();end end local t=reaper.GetExtState(a,k);local n=o or 1;if(t=="")then t=l[1];end local o=nil;for e,a in ipairs(l)do if(t==a)then local e=e+n;if(e>#l)then e=1;end if(e<1)then e=#l;end o=l[e];break;end end reaper.Main_OnCommand(f,0)self.editingItems=self:_getMediaItems_(false)self.m_originalItems=deepcopy(self.editingItems);local d=self.loopRangeInfo.startProjQN;local r=self.loopRangeInfo.endProjQN;local s=self.loopRangeInfo.lengthProjQN;local h=tonumber(o:split(",")[1]);local n=tonumber(o:split(",")[2]);for a,t in ipairs(self.editingItems)do t.b_selection=0;local a=math.floor(t.projQnInfo.Start*100+.6)/100 for o,e in ipairs(e)do if((s<=0 or(a>=d and a<r))and t.trackInfo.trackIdx==e and(math.floor((a)/h))%2==n)then t.b_selection=1;end end end reaper.SetExtState(a,k,o,true);reaper.SetExtState(a,g,tostring(i),true);end function e:flush()for t,e in ipairs(self.editingItems)do self:_applyChangeMediaItem(e)self:_applyChangeTakeInfo(e.takeInfo)end end function e:reset()self.editingItems={}self.editingItems=deepcopy(self.m_originalItems);end function e:_init()self.editingItems=self:_getMediaItems();self.originalItems=deepcopy(self.editingItems);self.loopRangeInfo=self:_storeTimeSelectionInfo();end function e:_storeTimeSelectionInfo()local a,t=reaper.GetSet_LoopTimeRange2(0,false,x,0,0,false)local i=reaper.TimeMap2_timeToQN(0,a);local n=reaper.TimeMap2_timeToQN(0,t);local e=t-a;local o=reaper.TimeMap2_timeToQN(0,e);if(e<=0)then o=0 end local e={startTime=a,endTime=t,lengthTime=e,startProjQN=i,endProjQN=n,lengthProjQN=o}return e;end function e:_getMediaItems()local e=self:_getMediaItems_(true)if(#e==0)then e=self:_getMediaItems_(false)end return e;end function e:_getMediaItems_(i)local s={}local a=0;local e=reaper.GetMediaItem(0,a)while(e~=nil)do local t={mediaItem=e,idx=a,b_mute=reaper.GetMediaItemInfo_Value(e,"B_MUTE"),b_loopsrc=reaper.GetMediaItemInfo_Value(e,"B_LOOPSRC"),b_allTakePlay=reaper.GetMediaItemInfo_Value(e,"B_ALLTAKESPLAY"),b_selection=reaper.GetMediaItemInfo_Value(e,"B_UISEL"),c_beatAttachMode=reaper.GetMediaItemInfo_Value(e,"C_BEATATTACHMODE"),c_lock=reaper.GetMediaItemInfo_Value(e,"D_LOCK"),c_vol=reaper.GetMediaItemInfo_Value(e,"D_VOL"),d_position=reaper.GetMediaItemInfo_Value(e,"D_POSITION"),d_length=reaper.GetMediaItemInfo_Value(e,"D_LENGTH"),d_snapOffset=reaper.GetMediaItemInfo_Value(e,"D_SNAPOFFSET"),d_fadeInLength=reaper.GetMediaItemInfo_Value(e,"D_FADEINLEN"),d_fadeOutLength=reaper.GetMediaItemInfo_Value(e,"D_FADEOUTLEN"),d_fadeInLenAuto=reaper.GetMediaItemInfo_Value(e,"D_FADEINLEN_AUTO"),d_fadeOutLenAuto=reaper.GetMediaItemInfo_Value(e,"D_FADEOUTLEN_AUTO"),c_fadeInShape=reaper.GetMediaItemInfo_Value(e,"C_FADEINSHAPE"),c_fadeOutShape=reaper.GetMediaItemInfo_Value(e,"C_FADEOUTSHAPE"),i_groupId=reaper.GetMediaItemInfo_Value(e,"I_GROUPID"),i_lastY=reaper.GetMediaItemInfo_Value(e,"I_LASTY"),i_lastH=reaper.GetMediaItemInfo_Value(e,"I_LASTH"),i_customColor=reaper.GetMediaItemInfo_Value(e,"I_CUSTOMCOLOR"),i_curTake=reaper.GetMediaItemInfo_Value(e,"I_CURTAKE"),ip_itemNumber=reaper.GetMediaItemInfo_Value(e,"IP_ITEMNUMBER"),f_freeModeY=reaper.GetMediaItemInfo_Value(e,"F_FREEMODE_Y"),f_freeModeH=reaper.GetMediaItemInfo_Value(e,"F_FREEMODE_H")}local n=reaper.GetMediaItemInfo_Value(e,"D_POSITION");local o=reaper.GetMediaItemInfo_Value(e,"D_LENGTH");local h=n+o;local d={Start=n,Length=o,End=h};local r=reaper.TimeMap2_timeToQN(0,n);local n=reaper.TimeMap2_timeToQN(0,o);local o=reaper.TimeMap2_timeToQN(0,h);local o={Start=r,Length=n,End=o};t.timeInfo=d;t.projQnInfo=o;t.trackInfo=self:_getTrackInfo(t);t.takeInfo=self:_getTakeInfo(t);if((i==false or i==nil)or(i==true and(t.b_selection==true or t.b_selection==1)))then table.insert(s,t);end a=a+1;e=reaper.GetMediaItem(0,a)end return s;end function e:_getTrackInfo(e)local e=reaper.GetMediaItemTrack(e.mediaItem)local t=reaper.GetMediaTrackInfo_Value(e,"IP_TRACKNUMBER")local e={track=e,trackIdx=t}return e;end function e:_getTakeInfo(e)local e=reaper.GetMediaItemTake(e.mediaItem,math.floor(e.i_curTake));if(e==nil)then return nil;end local s=reaper.GetMediaItemTakeInfo_Value(e,"D_STARTOFFS");local n=reaper.GetMediaItemTakeInfo_Value(e,"D_VOL");local a=reaper.GetMediaItemTakeInfo_Value(e,"D_PAN");local t=reaper.GetMediaItemTakeInfo_Value(e,"D_PANLAW");local o=reaper.GetMediaItemTakeInfo_Value(e,"D_PLAYRATE");local i=reaper.GetMediaItemTakeInfo_Value(e,"D_PITCH");local h=reaper.GetMediaItemTakeInfo_Value(e,"I_CHANMODE");local l=reaper.GetMediaItemTakeInfo_Value(e,"I_PITCHMODE");local d=reaper.GetMediaItemTakeInfo_Value(e,"I_CUSTOMCOLOR");local r=reaper.GetMediaItemTakeInfo_Value(e,"IP_TAKENUMBER");local c,u=reaper.GetSetMediaItemTakeInfo_String(e,"P_NAME","",false);local e={take=e,d_startOffset=s,d_vol=n,d_pan=a,d_panlaw=t,d_playrate=o,d_pitch=i,i_chanmode=h,i_pitchmode=l,i_customcolor=d,ip_takenumber=r,takeName=u}return e;end function e:_applyChangeMediaItem(e)local t=e.mediaItem;if(e.b_mute==true or e.b_mute==1)then reaper.SetMediaItemInfo_Value(t,"B_MUTE",1)else reaper.SetMediaItemInfo_Value(t,"B_MUTE",0)end if(e.b_loopsrc==true or e.b_loopsrc==1)then reaper.SetMediaItemInfo_Value(t,"B_LOOPSRC",1)else reaper.SetMediaItemInfo_Value(t,"B_LOOPSRC",0)end if(e.b_selection==true or e.b_selection==1)then reaper.SetMediaItemInfo_Value(t,"B_UISEL",1)else reaper.SetMediaItemInfo_Value(t,"B_UISEL",0)end reaper.SetMediaItemInfo_Value(t,"C_BEATATTACHMODE",e.c_beatAttachMode)reaper.SetMediaItemInfo_Value(t,"C_LOCK",e.c_lock)reaper.SetMediaItemInfo_Value(t,"D_VOL",e.c_vol)reaper.SetMediaItemInfo_Value(t,"D_POSITION",e.d_position)reaper.SetMediaItemInfo_Value(t,"D_LENGTH",e.d_length)reaper.SetMediaItemInfo_Value(t,"D_SNAPOFFSET",e.d_snapOffset)reaper.SetMediaItemInfo_Value(t,"D_FADEINLEN",e.d_fadeInLength)reaper.SetMediaItemInfo_Value(t,"D_FADEOUTLEN",e.d_fadeOutLength)reaper.SetMediaItemInfo_Value(t,"D_FADEINLEN_AUTO",e.d_fadeInLenAuto)reaper.SetMediaItemInfo_Value(t,"D_FADEOUTLEN_AUTO",e.d_fadeOutLenAuto)reaper.SetMediaItemInfo_Value(t,"C_FADEINSHAPE",e.c_fadeInShape)reaper.SetMediaItemInfo_Value(t,"C_FADEOUTSHAPE",e.c_fadeOutShape)reaper.SetMediaItemInfo_Value(t,"I_GROUPID",e.i_groupId)reaper.SetMediaItemInfo_Value(t,"I_LASTY",e.i_lastY)reaper.SetMediaItemInfo_Value(t,"I_LASTH",e.i_lastH)reaper.SetMediaItemInfo_Value(t,"I_CUSTOMCOLOR",e.i_customColor)reaper.SetMediaItemInfo_Value(t,"F_FREEMODE_Y",e.f_freeModeY)reaper.SetMediaItemInfo_Value(t,"F_FREEMODE_H",e.f_freeModeH)end function e:_applyChangeTakeInfo(e)if(e==nil)then return end;reaper.SetMediaItemTakeInfo_Value(e.take,"D_STARTOFFS",e.d_startOffset)reaper.SetMediaItemTakeInfo_Value(e.take,"D_VOL",e.d_vol)reaper.SetMediaItemTakeInfo_Value(e.take,"D_PAN",e.d_pan)reaper.SetMediaItemTakeInfo_Value(e.take,"D_PANLAW",e.d_panlaw)reaper.SetMediaItemTakeInfo_Value(e.take,"D_PLAYRATE",e.d_playrate)reaper.SetMediaItemTakeInfo_Value(e.take,"D_PITCH",e.d_pitch)reaper.SetMediaItemTakeInfo_Value(e.take,"I_CHANMODE",e.i_chanmode)reaper.SetMediaItemTakeInfo_Value(e.take,"I_PITCHMODE",e.i_pitchmode)reaper.SetMediaItemTakeInfo_Value(e.take,"I_CUSTOMCOLOR",e.i_customcolor)reaper.SetMediaItemTakeInfo_Value(e.take,"IP_TAKENUMBER",e.ip_takenumber)reaper.GetSetMediaItemTakeInfo_String(e.take,"P_NAME",e.takeName,true);end function e:_detectTargetItems()local e=nil if(self:isExistSelectionItem()==true)then e=self:_getSelectedItems(self.editingItems);else e=self.editingItems end return e;end function e:_checkProcessLimitNum()local e=true;if(#self.editingItems<self.m_processLimitNoteNum_min+1)then e=false end;if(#self.editingItems>=self.m_processLimitNoteNum)then e=false;end;return e;end function e:_getExistTrack(e)local e=e or self.editingItems;local a={}table.sort(e,function(t,e)return(t.trackInfo.trackIdx<e.trackInfo.trackIdx);end);local t=-1;for o,e in ipairs(e)do if(t<e.trackInfo.trackIdx)then table.insert(a,e.trackInfo.trackIdx)t=e.trackInfo.trackIdx end end return a;end function e:_getSelectedItems(e)local e=e or self.editingItems;local t={}for a,e in ipairs(e)do if(e.b_selection==1 or e.b_selection==true)then table.insert(t,e)end end return t;end function e:_toSelectionInvert(t)local t=t or self.editingItems;for t,e in ipairs(t)do e.b_selection=(e.b_selection==0 or e.b_selection==false)end end e:_init();if(_USE_TESTING_FUNC_==true)then local t=reaper.GetResourcePath().."\\Scripts\\ReaScript_MIDI\\TESTING\\_kawa_testing.lua"local t=io.open(t,"r")if(t~=nil)then _add_MAIN_TestingFunction(e);end end return e;end function StepWindowSet(t)local e=0 local e=reaper.GetExtState(a,q);if(e==""or e==nil)then e=c else e=tonumber(e)or c end local e=e+t;if(e>c)then e=y end if(e<y)then e=c end reaper.Main_OnCommand(e,0)reaper.SetExtState(a,q,tostring(e),true);end function ColorTrackHueGrad(o,i,a)local e=0 local t=reaper.CountSelectedTracks(e)local o=o or 60 local i=i or 1 local a=a or 1 if(t>0)then local n=math.floor(360*math.random());local o=o;reaper.Undo_BeginBlock();for t=0,t-1 do local s=reaper.GetSelectedTrack(e,t)local e=_toIntColor(HSVToRGB(n+o*t,i,a));reaper.SetTrackColor(s,e)end reaper.Undo_EndBlock("kawa MAIN Track Colorize Hue",-1);reaper.UpdateArrange();else local t=reaper.CountTracks(e);if(t<=0)then return end;local n=math.floor(360*math.random());local o=o;reaper.Undo_BeginBlock();for t=0,t-1 do local s=reaper.GetTrack(e,t);local e=_toIntColor(HSVToRGB(n+o*t,i,a));reaper.SetTrackColor(s,e)end reaper.Undo_EndBlock("kawa MAIN Track Colorize Hue",-1);reaper.UpdateArrange();end end function ColorMarkerHueGrad(h,r,o)local n={}local s={}local t=0 local i,a,e=reaper.CountProjectMarkers(t)local h=h or 60 local l=r or 1 local u=o or 1 if(i and(a~=0 or e~=0))then local c=math.floor(360*math.random());local m=h;for i=0,(a+e)-1 do local e,o,d,r,h,a,f=reaper.EnumProjectMarkers3(t,i)if(e~=nil)then local e={}e.posTime=d e.name=h e.regeonEnd=r e.idx=a e.intColor=_toIntColor(HSVToRGB(c+m*i,l,u));reaper.SetProjectMarker3(t,a,false,e.posTime,e.posTime,e.name,e.intColor)if(o==false)then reaper.SetProjectMarker3(t,a,o,e.posTime,e.posTime,e.name,e.intColor)table.insert(n,e)else reaper.SetProjectMarker3(t,a,o,e.posTime,e.regeonEnd,e.name,e.intColor)table.insert(s,e)end end end end end function CreateSampleOmatic5000()local e=0;local i="ReaSamplOmatic5000 (Cockos)"local o="ReaSamplOmatic"local n="ReaSamplOmatic"local a=reaper.GetSelectedTrack2(e,0,false)local t=0 if(a~=nil)then t=reaper.GetMediaTrackInfo_Value(a,"IP_TRACKNUMBER")end local t=t reaper.InsertTrackAtIndex(t,true)local e=reaper.GetTrack(e,t)if(e)then reaper.TrackFX_AddByName(e,i,false,-1)reaper.GetSetMediaTrackInfo_String(e,"P_NAME",n,true)local t=reaper.TrackFX_GetCount(e)local a=0 for t=0,t-1 do local i,e=reaper.TrackFX_GetFXName(e,t,"")if(string.find(e,o)~=nil)then a=t break;end end reaper.TrackFX_Show(e,a,1)end reaper.TrackList_UpdateAllExternalSurfaces()reaper.UpdateTimeline();reaper.UpdateArrange();end if(package.config:sub(1,1)=="\\")then else end local e=createMediaItemClip();if(e:checkProcessLimitNum())then reaper.Undo_BeginBlock();e:mediaItemNameToTrackName();e:flush();reaper.Undo_EndBlock("kawa MAIN Take Name To Track Name",-1);reaper.UpdateArrange();end
