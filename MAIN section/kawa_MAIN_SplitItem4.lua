--====================================================================== 
--[[ 
* ReaScript Name: kawa_MAIN_SplitItem4. 
* Version: 2016/06/15 
* Author: kawa_ 
* Author URI: http://forum.cockos.com/member.php?u=105939 
* Repository: GitHub 
* Repository URI: https://github.com/kawaCat/ReaScript-MidiPack 
--]] 
--====================================================================== 
function deepcopy(t)local a=type(t)local e if a=='table'then e={}for t,a in next,t,nil do e[deepcopy(t)]=deepcopy(a)end setmetatable(e,deepcopy(getmetatable(t)))else e=t end return e end function string:split(e)local t,e=e or":",{}local t=string.format("([^%s]+)",t)self:gsub(t,function(t)e[#e+1]=t end)return e end function table.toString(a)local function l(e)return string.format("%q",e)end local d="";local function e(e)d=d..e end;local r,t="   ","\n"local h,a={a},{[a]=1}e("return {"..t)for o,n in ipairs(h)do e("-- Table: {"..o.."}"..t)e("{"..t)local d={}for i,o in ipairs(n)do d[i]=true local i=type(o)if i=="table"then if not a[o]then table.insert(h,o)a[o]=#h end e(r.."{"..a[o].."},"..t)elseif i=="string"then e(r..l(o)..","..t)elseif i=="number"then e(r..tostring(o)..","..t)end end for n,s in pairs(n)do if(not d[n])then local i=""local o=type(n)if o=="table"then if not a[n]then table.insert(h,n)a[n]=#h end i=r.."[{"..a[n].."}]="elseif o=="string"then i=r.."["..l(n).."]="elseif o=="number"then i=r.."["..tostring(n).."]="end if(i~="")then o=type(s)end if o=="table"then if not a[s]then table.insert(h,s)a[s]=#h end e(i.."{"..a[s].."},"..t)elseif o=="string"then e(i..l(s)..","..t)elseif o=="number"then e(i..tostring(s)..","..t)elseif o=="boolean"then e(i..tostring(s)..","..t)end end end e("},"..t)end e("}")return d;end function table.fromString(e)local e=load(e);local e=e()if(type(e)~="table")then local e={}return e end for t=1,#e do local o={}for a,i in pairs(e[t])do if type(i)=="table"then e[t][a]=e[i[1]]end if type(a)=="table"and e[a[1]]then table.insert(o,{a,e[a[1]]})end end for o,a in ipairs(o)do e[t][a[2]],e[t][a[1]]=e[t][a[1]],nil end end return e[1]end function stringIter(t)local e=0;local a=string.len(t);return function()e=e+1;if(e>a)then return nil else return e,string.sub(t,e,e)end end end math.randomseed(reaper.time_precise()*os.time()/1e3)local x=500;local N=false;local H=true local D=41383 local R=40058 local k=41613 local I=40635 local S=40297 local g=40914 local m=40289 local O=40757 local _=40290 local z=41720 local E=40205 local A=40204 local T=40289 local j=41588 local y=40454 local e=40455 local e=40456 local e=40457 local e=40458 local e=40459 local e=40460 local e=40461 local e=40462 local c=40463 local a="kawa_MainClip"local v="lastEditCursolTime"local p="lastToggleLength"local w="lastAutoSelection"local q="lastAutoSelectionExistTrack"local b="last_window_set"local f=0;local l={"4,0","4,1","2,0","2,1","1,0","1,1","0.5,0","0.5,1","0.25,0","0.25,1"}local u={"4","3","2","1","0.5","0.25","0.125"}if(_DBG_==true)then end _USE_TESTING_FUNC_=false function _toIntColor(a,e,t)local a=string.format("%x",a)local e=string.format("%x",e)local t=string.format("%x",t)if(#a<2)then a="0"..a end if(#e<2)then e="0"..e end if(#t<2)then t="0"..t end local e="01"..t..e..a;return tonumber(e,16)end function HSVToRGB(s,h,u)local n,o,i,d,l,e,t,r,a local s=s local h=h if(s>360)then s=s-360;elseif(s<0)then s=s+360;end if(h>1)then h=1;elseif(h<0)then h=0;end e=math.floor(255*u)if(e>255)then e=255;elseif(e<0)then e=0;end if(h==0)then n=e;o=e;i=e;else d=math.floor(s/60)l=s/60-d t=math.floor(e*(1-h))if(t<0)then t=0;elseif(t>255)then t=255;end r=math.floor(e*(1-l*h))if(r<0)then r=0;elseif(r>255)then r=255;end a=math.floor(e*(1-(1-l)*h))if(a<0)then a=0;elseif(a>255)then a=55;end if(d==0)then n=e;o=a;i=t;elseif(d==1)then n=r;o=e;i=t;elseif(d==2)then n=t;o=e;i=a;elseif(d==3)then n=t;o=r;i=e;elseif(d==4)then n=a;o=t;i=e;elseif(d==5)then n=e;o=t;i=r;else n=e;o=a;i=t;end end return n,o,i end function RGBToHSV(a,t,i)a,t,i=a/255,t/255,i/255;local o,h=math.max(a,t,i),math.min(a,t,i)local e,n,s=0,0,0 e=o-h;if(e>0)then if(o==a)then e=(t-i)/e;if(e<0)then e=e+6;end elseif(o==t)then e=2+(i-a)/e;else e=4+(a-t)/e;end end e=e/6;n=o-h;if(o~=0)then n=n/o;end s=o;return e,n,s;end function createMediaItemClip()local e={}e.editingItems={}e.m_originalItems={}e.loopRangeInfo={};e.m_isSelection=nil e.m_firstSelectionCheck=nil;e.m_processLimitNoteNum=x;e.m_processLimitNoteNum_min=0;function e:isExistSelectionItem(e)if(self.m_firstSelectionCheck~=true or e~=nil)then for t,e in ipairs(self.editingItems)do if(e.b_selection==true or e.b_selection==1)then self.m_isSelection=true break;end self.m_isSelection=false;end self.m_firstSelectionCheck=true;end return self.m_isSelection;end function e:checkProcessLimitNum()local e=self:_checkProcessLimitNum()if(e~=true and#self.editingItems~=0 and H==true)then local e=self.m_processLimitNoteNum;reaper.ShowMessageBox("over "..tostring(e).." clip num .\nstop process","stop",0)end return e;end function e:setProcessLimitNum(e)self.m_processLimitNoteNum=e end function e:setProcessLimitNum_Min(e)self.m_processLimitNoteNum_min=e end function e:selectedItemsStemRender()if(self:isExistSelectionItem()==false)then return;end;local e=self:_detectTargetItems();if(#e>20)then reaper.ShowMessageBox("over "..tostring(20).." clip num .\nstop process","stop.",0)return end for t,e in ipairs(e)do local t=e.trackInfo.track local e=e.mediaItem reaper.Main_OnCommand(m,0)reaper.SetMediaItemSelected(e,1)reaper.SetOnlyTrackSelected(t,1);reaper.Main_OnCommand(g,f)reaper.Main_OnCommand(_,f)reaper.Main_OnCommand(z,f)end end function e:duplicateMusical()if(self:isExistSelectionItem()==false)then return;end;local a=self:_detectTargetItems();local i=a[1].projQnInfo.Start;local e=a[#a].projQnInfo.End;local e=e-i-1e-6;local t,o=reaper.GetProjectTimeSignature()local t=0;if(e<=.25)then t=.25-e elseif(e<=.5)then t=.5-e elseif(e<1)then t=1-e elseif(e<2)then t=2-e elseif(e<o)then t=o-e else local a=math.floor(e/o)+1;local a=a*o;t=a-e;end e=e+t;local t=reaper.TimeMap2_QNToTime(0,i+e)local e=self.editingItems[1].trackInfo.track;reaper.PreventUIRefresh(7)reaper.Main_OnCommand(I,0)reaper.Main_OnCommand(D,0)reaper.Main_OnCommand(S,0)reaper.SetOnlyTrackSelected(e,true);reaper.Main_OnCommand(g,0)reaper.SetEditCurPos(t,true,false)reaper.Main_OnCommand(R,0)reaper.Main_OnCommand(k,0)reaper.PreventUIRefresh(-1)for t,e in ipairs(a)do e.b_selection=0 end end function e:changeLength(t)if(self:isExistSelectionItem()==false)then return;end;local e=self:_detectTargetItems();for a,e in ipairs(e)do e.d_length=e.d_length*t end end function e:toggleLength(t)if(self:isExistSelectionItem()==false)then return;end;local e=reaper.GetExtState(a,p);if(e=="")then e=u[1];end local o=t or 1 local t=1;for a,i in ipairs(u)do if(i==e)then local e=a+o;if(e>#u)then e=1;end if(e<1)then e=#u;end t=u[e];break;end end local e=self:_detectTargetItems();for a,e in ipairs(e)do local t=reaper.TimeMap2_QNToTime(0,tonumber(t));e.d_length=t-1e-5;end reaper.SetExtState(a,p,t,true);end function e:splitItem(e)if(self:isExistSelectionItem()==false)then return;end;local a=e or 3;local i={}local o=self:_detectTargetItems();for t,e in ipairs(o)do reaper.Main_OnCommand(m,0)local t=e.timeInfo.Length/a;if(t<.005)then return end;local o=e.timeInfo.Start reaper.SetMediaItemSelected(e.mediaItem,1)for a=1,a do local a=o+t*a reaper.PreventUIRefresh(3)reaper.SetEditCurPos(a,true,false)reaper.Main_OnCommand(O,0)reaper.Main_OnCommand(k,0)reaper.PreventUIRefresh(-1)local e=deepcopy(e)e.timeInfo.End=a;e.timeInfo.Start=a-t;e.timeInfo.Length=t;table.insert(i,e)end end self:_toSelectionInvert()self.m_isSelection=false self.editingItems=self:_getMediaItems_(false);self.originalItems=deepcopy(self.editingItems);o=self:_detectTargetItems();for t,e in ipairs(o)do for a,t in ipairs(i)do if(math.floor(e.timeInfo.Start*100)/100==math.floor(t.timeInfo.Start*100)/100 and math.floor(e.timeInfo.End*100)/100==math.floor(t.timeInfo.End*100)/100 and math.floor(e.timeInfo.Length*100)/100==math.floor(t.timeInfo.Length*100)/100)then e.b_selection=1;self.m_isSelection=true;self:_applyChangeMediaItem(e);break;end end end end function e:nudgeStartPos(e)if(self:isExistSelectionItem()==false)then return;end;local t=e or .99;local e=self:_detectTargetItems();for a,e in ipairs(e)do local t=(e.d_length*(1-t));e.d_position=e.d_position-t e.d_length=e.d_length+t end end function e:nudgeWaveOffset(e)if(self:isExistSelectionItem()==false)then return;end;local e=e or .99;local t=reaper.TimeMap2_QNToTime(0,.0125)local t=t*(e);local e=self:_detectTargetItems();for a,e in ipairs(e)do e.takeInfo.d_startOffset=e.takeInfo.d_startOffset+t end end function e:transposeItem(e)if(self:isExistSelectionItem()==false)then return;end;local t=0 if(e<0)then t=E;else t=A;end local t=math.abs(e)local t=self:_detectTargetItems();for a,t in ipairs(t)do t.takeInfo.d_pitch=t.takeInfo.d_pitch+e end end function e:selectedItemsGlue()if(self:isExistSelectionItem()==false)then return;end;local e=self:_detectTargetItems();for t,e in ipairs(e)do reaper.PreventUIRefresh(3)reaper.Main_OnCommand(T,0)reaper.SetMediaItemSelected(e.mediaItem,true)reaper.Main_OnCommand(j,0)reaper.PreventUIRefresh(-1)end self:_init();end function e:changeTuningPitch(e)if(self:isExistSelectionItem()==false)then return;end;local a=e or 440;local o=self:_detectTargetItems();local function t(e)return 1200*math.log(e/440)/math.log(2);end local function e(e)return math.exp(e/1200*math.log(2))*440;end for o,e in ipairs(o)do local e=e.takeInfo;local t=t(a);e.d_pitch=t*.01;end end function e:getSelectionItemTuningPitch(t)if(self:isExistSelectionItem()==false)then return;end;local i=self:_detectTargetItems();local function e(t,e)local t=e or 440;local e=offestCent or 440;return 1200*math.log(e/t)/math.log(2);end local function a(t,e)local e=e or 440;local t=t or 440;return math.exp(t/1200*math.log(2))*e;end local o=t or 440;local e=0;for i,t in ipairs(i)do local t=t.takeInfo;e=a(t.d_pitch*100,o);end return e;end function e:mediaItemNameToTrackName()if(self:isExistSelectionItem()==false)then return;end;local e=self:_detectTargetItems();for t,e in ipairs(e)do local t=e.trackInfo;local e=e.takeInfo;if(e~=nil)then local e=e.takeName;local a=e:match("^.+(%..+)$")or""e=e:gsub(a,"")reaper.GetSetMediaTrackInfo_String(t.track,"P_NAME",e,true)end end end function e:_check_SWS_Function(t)local e=false for t,a in pairs(reaper)do if(tostring(t)=="BR_EnvAlloc")then e=true end end if(e==false and t~=true)then reaper.ShowMessageBox("this scripts need sws extenstion. ","stop",0)end return e end function e:takeNameToTextClip()if(self:_check_SWS_Function()==false)then return;end if(self:isExistSelectionItem()==false)then return;end;local o=self:_detectTargetItems();local function a(t)local e="";if(t~=nil)then e=t.takeName;end local t=e:split(".");local e="";for a=1,#t-1 do e=e..t[a];end return e;end for t,e in ipairs(o)do local a=a(e.takeInfo);local t=e.trackInfo.track;local t=reaper.AddMediaItemToTrack(t)reaper.SetMediaItemInfo_Value(t,"C_BEATATTACHMODE",e.c_beatAttachMode)reaper.SetMediaItemInfo_Value(t,"C_LOCK",e.c_lock)reaper.SetMediaItemInfo_Value(t,"D_VOL",e.c_vol)reaper.SetMediaItemInfo_Value(t,"D_POSITION",e.d_position)reaper.SetMediaItemInfo_Value(t,"D_LENGTH",e.d_length)reaper.SetMediaItemInfo_Value(t,"D_SNAPOFFSET",e.d_snapOffset)reaper.SetMediaItemInfo_Value(t,"D_FADEINLEN",e.d_fadeInLength)reaper.SetMediaItemInfo_Value(t,"D_FADEOUTLEN",e.d_fadeOutLength)reaper.SetMediaItemInfo_Value(t,"D_FADEINLEN_AUTO",e.d_fadeInLenAuto)reaper.SetMediaItemInfo_Value(t,"D_FADEOUTLEN_AUTO",e.d_fadeOutLenAuto)reaper.SetMediaItemInfo_Value(t,"C_FADEINSHAPE",e.c_fadeInShape)reaper.SetMediaItemInfo_Value(t,"C_FADEOUTSHAPE",e.c_fadeOutShape)reaper.SetMediaItemInfo_Value(t,"I_GROUPID",e.i_groupId)reaper.SetMediaItemInfo_Value(t,"I_LASTY",e.i_lastY)reaper.SetMediaItemInfo_Value(t,"I_LASTH",e.i_lastH)reaper.SetMediaItemInfo_Value(t,"I_CUSTOMCOLOR",e.i_customColor)reaper.SetMediaItemInfo_Value(t,"F_FREEMODE_Y",e.f_freeModeY)reaper.SetMediaItemInfo_Value(t,"F_FREEMODE_H",e.f_freeModeH)reaper.ULT_SetMediaItemNote(t,a);end end function e:autoSelection(n)local t=reaper.GetExtState(a,v);local i=reaper.GetCursorPosition();t=tonumber(t)or 0 local e={};if(math.floor(t*1e3)/1e3~=math.floor(i*1e3)/1e3)then e=self:_getExistTrack();local e=table.toString(e);reaper.SetExtState(a,q,e,true);else local t=reaper.GetExtState(a,q);e=table.fromString(t);if(#e<1)then e=self:_getExistTrack();end end local o=reaper.GetExtState(a,w);local n=n or 1;if(o=="")then o=l[1];end local t=nil;for a,e in ipairs(l)do if(o==e)then local e=a+n;if(e>#l)then e=1;end if(e<1)then e=#l;end t=l[e];break;end end reaper.Main_OnCommand(m,0)self.editingItems=self:_getMediaItems_(false)self.m_originalItems=deepcopy(self.editingItems);local s=self.loopRangeInfo.startProjQN;local r=self.loopRangeInfo.endProjQN;local h=self.loopRangeInfo.lengthProjQN;local n=tonumber(t:split(",")[1]);local o=tonumber(t:split(",")[2]);for a,t in ipairs(self.editingItems)do t.b_selection=0;local a=math.floor(t.projQnInfo.Start*100+.6)/100 for i,e in ipairs(e)do if((h<=0 or(a>=s and a<r))and t.trackInfo.trackIdx==e and(math.floor((a)/n))%2==o)then t.b_selection=1;end end end reaper.SetExtState(a,w,t,true);reaper.SetExtState(a,v,tostring(i),true);end function e:flush()for t,e in ipairs(self.editingItems)do self:_applyChangeMediaItem(e)self:_applyChangeTakeInfo(e.takeInfo)end end function e:reset()self.editingItems={}self.editingItems=deepcopy(self.m_originalItems);end function e:_init()self.editingItems=self:_getMediaItems();self.originalItems=deepcopy(self.editingItems);self.loopRangeInfo=self:_storeTimeSelectionInfo();end function e:_storeTimeSelectionInfo()local e,t=reaper.GetSet_LoopTimeRange2(0,false,N,0,0,false)local i=reaper.TimeMap2_timeToQN(0,e);local n=reaper.TimeMap2_timeToQN(0,t);local a=t-e;local o=reaper.TimeMap2_timeToQN(0,a);if(a<=0)then o=0 end local e={startTime=e,endTime=t,lengthTime=a,startProjQN=i,endProjQN=n,lengthProjQN=o}return e;end function e:_getMediaItems()local e=self:_getMediaItems_(true)if(#e==0)then e=self:_getMediaItems_(false)end return e;end function e:_getMediaItems_(n)local h={}local a=0;local e=reaper.GetMediaItem(0,a)while(e~=nil)do local t={mediaItem=e,idx=a,b_mute=reaper.GetMediaItemInfo_Value(e,"B_MUTE"),b_loopsrc=reaper.GetMediaItemInfo_Value(e,"B_LOOPSRC"),b_allTakePlay=reaper.GetMediaItemInfo_Value(e,"B_ALLTAKESPLAY"),b_selection=reaper.GetMediaItemInfo_Value(e,"B_UISEL"),c_beatAttachMode=reaper.GetMediaItemInfo_Value(e,"C_BEATATTACHMODE"),c_lock=reaper.GetMediaItemInfo_Value(e,"D_LOCK"),c_vol=reaper.GetMediaItemInfo_Value(e,"D_VOL"),d_position=reaper.GetMediaItemInfo_Value(e,"D_POSITION"),d_length=reaper.GetMediaItemInfo_Value(e,"D_LENGTH"),d_snapOffset=reaper.GetMediaItemInfo_Value(e,"D_SNAPOFFSET"),d_fadeInLength=reaper.GetMediaItemInfo_Value(e,"D_FADEINLEN"),d_fadeOutLength=reaper.GetMediaItemInfo_Value(e,"D_FADEOUTLEN"),d_fadeInLenAuto=reaper.GetMediaItemInfo_Value(e,"D_FADEINLEN_AUTO"),d_fadeOutLenAuto=reaper.GetMediaItemInfo_Value(e,"D_FADEOUTLEN_AUTO"),c_fadeInShape=reaper.GetMediaItemInfo_Value(e,"C_FADEINSHAPE"),c_fadeOutShape=reaper.GetMediaItemInfo_Value(e,"C_FADEOUTSHAPE"),i_groupId=reaper.GetMediaItemInfo_Value(e,"I_GROUPID"),i_lastY=reaper.GetMediaItemInfo_Value(e,"I_LASTY"),i_lastH=reaper.GetMediaItemInfo_Value(e,"I_LASTH"),i_customColor=reaper.GetMediaItemInfo_Value(e,"I_CUSTOMCOLOR"),i_curTake=reaper.GetMediaItemInfo_Value(e,"I_CURTAKE"),ip_itemNumber=reaper.GetMediaItemInfo_Value(e,"IP_ITEMNUMBER"),f_freeModeY=reaper.GetMediaItemInfo_Value(e,"F_FREEMODE_Y"),f_freeModeH=reaper.GetMediaItemInfo_Value(e,"F_FREEMODE_H")}local i=reaper.GetMediaItemInfo_Value(e,"D_POSITION");local o=reaper.GetMediaItemInfo_Value(e,"D_LENGTH");local s=i+o;local d={Start=i,Length=o,End=s};local r=reaper.TimeMap2_timeToQN(0,i);local o=reaper.TimeMap2_timeToQN(0,o);local i=reaper.TimeMap2_timeToQN(0,s);local o={Start=r,Length=o,End=i};t.timeInfo=d;t.projQnInfo=o;t.trackInfo=self:_getTrackInfo(t);t.takeInfo=self:_getTakeInfo(t);if((n==false or n==nil)or(n==true and(t.b_selection==true or t.b_selection==1)))then table.insert(h,t);end a=a+1;e=reaper.GetMediaItem(0,a)end return h;end function e:_getTrackInfo(e)local e=reaper.GetMediaItemTrack(e.mediaItem)local t=reaper.GetMediaTrackInfo_Value(e,"IP_TRACKNUMBER")local e={track=e,trackIdx=t}return e;end function e:_getTakeInfo(e)local e=reaper.GetMediaItemTake(e.mediaItem,math.floor(e.i_curTake));if(e==nil)then return nil;end local a=reaper.GetMediaItemTakeInfo_Value(e,"D_STARTOFFS");local n=reaper.GetMediaItemTakeInfo_Value(e,"D_VOL");local r=reaper.GetMediaItemTakeInfo_Value(e,"D_PAN");local l=reaper.GetMediaItemTakeInfo_Value(e,"D_PANLAW");local d=reaper.GetMediaItemTakeInfo_Value(e,"D_PLAYRATE");local s=reaper.GetMediaItemTakeInfo_Value(e,"D_PITCH");local h=reaper.GetMediaItemTakeInfo_Value(e,"I_CHANMODE");local t=reaper.GetMediaItemTakeInfo_Value(e,"I_PITCHMODE");local u=reaper.GetMediaItemTakeInfo_Value(e,"I_CUSTOMCOLOR");local o=reaper.GetMediaItemTakeInfo_Value(e,"IP_TAKENUMBER");local c,i=reaper.GetSetMediaItemTakeInfo_String(e,"P_NAME","",false);local e={take=e,d_startOffset=a,d_vol=n,d_pan=r,d_panlaw=l,d_playrate=d,d_pitch=s,i_chanmode=h,i_pitchmode=t,i_customcolor=u,ip_takenumber=o,takeName=i}return e;end function e:_applyChangeMediaItem(e)local t=e.mediaItem;if(e.b_mute==true or e.b_mute==1)then reaper.SetMediaItemInfo_Value(t,"B_MUTE",1)else reaper.SetMediaItemInfo_Value(t,"B_MUTE",0)end if(e.b_loopsrc==true or e.b_loopsrc==1)then reaper.SetMediaItemInfo_Value(t,"B_LOOPSRC",1)else reaper.SetMediaItemInfo_Value(t,"B_LOOPSRC",0)end if(e.b_selection==true or e.b_selection==1)then reaper.SetMediaItemInfo_Value(t,"B_UISEL",1)else reaper.SetMediaItemInfo_Value(t,"B_UISEL",0)end reaper.SetMediaItemInfo_Value(t,"C_BEATATTACHMODE",e.c_beatAttachMode)reaper.SetMediaItemInfo_Value(t,"C_LOCK",e.c_lock)reaper.SetMediaItemInfo_Value(t,"D_VOL",e.c_vol)reaper.SetMediaItemInfo_Value(t,"D_POSITION",e.d_position)reaper.SetMediaItemInfo_Value(t,"D_LENGTH",e.d_length)reaper.SetMediaItemInfo_Value(t,"D_SNAPOFFSET",e.d_snapOffset)reaper.SetMediaItemInfo_Value(t,"D_FADEINLEN",e.d_fadeInLength)reaper.SetMediaItemInfo_Value(t,"D_FADEOUTLEN",e.d_fadeOutLength)reaper.SetMediaItemInfo_Value(t,"D_FADEINLEN_AUTO",e.d_fadeInLenAuto)reaper.SetMediaItemInfo_Value(t,"D_FADEOUTLEN_AUTO",e.d_fadeOutLenAuto)reaper.SetMediaItemInfo_Value(t,"C_FADEINSHAPE",e.c_fadeInShape)reaper.SetMediaItemInfo_Value(t,"C_FADEOUTSHAPE",e.c_fadeOutShape)reaper.SetMediaItemInfo_Value(t,"I_GROUPID",e.i_groupId)reaper.SetMediaItemInfo_Value(t,"I_LASTY",e.i_lastY)reaper.SetMediaItemInfo_Value(t,"I_LASTH",e.i_lastH)reaper.SetMediaItemInfo_Value(t,"I_CUSTOMCOLOR",e.i_customColor)reaper.SetMediaItemInfo_Value(t,"F_FREEMODE_Y",e.f_freeModeY)reaper.SetMediaItemInfo_Value(t,"F_FREEMODE_H",e.f_freeModeH)end function e:_applyChangeTakeInfo(e)if(e==nil)then return end;reaper.SetMediaItemTakeInfo_Value(e.take,"D_STARTOFFS",e.d_startOffset)reaper.SetMediaItemTakeInfo_Value(e.take,"D_VOL",e.d_vol)reaper.SetMediaItemTakeInfo_Value(e.take,"D_PAN",e.d_pan)reaper.SetMediaItemTakeInfo_Value(e.take,"D_PANLAW",e.d_panlaw)reaper.SetMediaItemTakeInfo_Value(e.take,"D_PLAYRATE",e.d_playrate)reaper.SetMediaItemTakeInfo_Value(e.take,"D_PITCH",e.d_pitch)reaper.SetMediaItemTakeInfo_Value(e.take,"I_CHANMODE",e.i_chanmode)reaper.SetMediaItemTakeInfo_Value(e.take,"I_PITCHMODE",e.i_pitchmode)reaper.SetMediaItemTakeInfo_Value(e.take,"I_CUSTOMCOLOR",e.i_customcolor)reaper.SetMediaItemTakeInfo_Value(e.take,"IP_TAKENUMBER",e.ip_takenumber)reaper.GetSetMediaItemTakeInfo_String(e.take,"P_NAME",e.takeName,true);end function e:_detectTargetItems()local e=nil if(self:isExistSelectionItem()==true)then e=self:_getSelectedItems(self.editingItems);else e=self.editingItems end return e;end function e:_checkProcessLimitNum()local e=true;if(#self.editingItems<self.m_processLimitNoteNum_min+1)then e=false end;if(#self.editingItems>=self.m_processLimitNoteNum)then e=false;end;return e;end function e:_getExistTrack(e)local e=e or self.editingItems;local a={}table.sort(e,function(t,e)return(t.trackInfo.trackIdx<e.trackInfo.trackIdx);end);local t=-1;for o,e in ipairs(e)do if(t<e.trackInfo.trackIdx)then table.insert(a,e.trackInfo.trackIdx)t=e.trackInfo.trackIdx end end return a;end function e:_getSelectedItems(e)local e=e or self.editingItems;local t={}for a,e in ipairs(e)do if(e.b_selection==1 or e.b_selection==true)then table.insert(t,e)end end return t;end function e:_toSelectionInvert(t)local t=t or self.editingItems;for t,e in ipairs(t)do e.b_selection=(e.b_selection==0 or e.b_selection==false)end end e:_init();if(_USE_TESTING_FUNC_==true)then local t=reaper.GetResourcePath().."\\Scripts\\ReaScript_MIDI\\TESTING\\_kawa_testing.lua"local t=io.open(t,"r")if(t~=nil)then _add_MAIN_TestingFunction(e);end end return e;end function StepWindowSet(t)local e=0 local e=reaper.GetExtState(a,b);if(e==""or e==nil)then e=c else e=tonumber(e)or c end local e=e+t;if(e>c)then e=y end if(e<y)then e=c end reaper.Main_OnCommand(e,0)reaper.SetExtState(a,b,tostring(e),true);end function ColorTrackHueGrad(t,i,a)local e=0 local o=reaper.CountSelectedTracks(e)local t=t or 60 local i=i or 1 local a=a or 1 if(o>0)then local s=math.floor(360*math.random());local n=t;reaper.Undo_BeginBlock();for t=0,o-1 do local o=reaper.GetSelectedTrack(e,t)local e=_toIntColor(HSVToRGB(s+n*t,i,a));reaper.SetTrackColor(o,e)end reaper.Undo_EndBlock("kawa MAIN Track Colorize Hue",-1);reaper.UpdateArrange();else local o=reaper.CountTracks(e);if(o<=0)then return end;local n=math.floor(360*math.random());local s=t;reaper.Undo_BeginBlock();for t=0,o-1 do local e=reaper.GetTrack(e,t);local t=_toIntColor(HSVToRGB(n+s*t,i,a));reaper.SetTrackColor(e,t)end reaper.Undo_EndBlock("kawa MAIN Track Colorize Hue",-1);reaper.UpdateArrange();end end function ColorMarkerHueGrad(o,n,s)local h={}local u={}local t=0 local i,e,a=reaper.CountProjectMarkers(t)local o=o or 60 local c=n or 1 local s=s or 1 if(i and(e~=0 or a~=0))then local r=math.floor(360*math.random());local l=o;for i=0,(e+a)-1 do local e,o,n,m,d,a,f=reaper.EnumProjectMarkers3(t,i)if(e~=nil)then local e={}e.posTime=n e.name=d e.regeonEnd=m e.idx=a e.intColor=_toIntColor(HSVToRGB(r+l*i,c,s));reaper.SetProjectMarker3(t,a,false,e.posTime,e.posTime,e.name,e.intColor)if(o==false)then reaper.SetProjectMarker3(t,a,o,e.posTime,e.posTime,e.name,e.intColor)table.insert(h,e)else reaper.SetProjectMarker3(t,a,o,e.posTime,e.regeonEnd,e.name,e.intColor)table.insert(u,e)end end end end end function CreateSampleOmatic5000()local e=0;local o="ReaSamplOmatic5000 (Cockos)"local i="ReaSamplOmatic"local n="ReaSamplOmatic"local a=reaper.GetSelectedTrack2(e,0,false)local t=0 if(a~=nil)then t=reaper.GetMediaTrackInfo_Value(a,"IP_TRACKNUMBER")end local t=t reaper.InsertTrackAtIndex(t,true)local e=reaper.GetTrack(e,t)if(e)then reaper.TrackFX_AddByName(e,o,false,-1)reaper.GetSetMediaTrackInfo_String(e,"P_NAME",n,true)local a=reaper.TrackFX_GetCount(e)local t=0 for a=0,a-1 do local o,e=reaper.TrackFX_GetFXName(e,a,"")if(string.find(e,i)~=nil)then t=a break;end end reaper.TrackFX_Show(e,t,1)end reaper.TrackList_UpdateAllExternalSurfaces()reaper.UpdateTimeline();reaper.UpdateArrange();end if(package.config:sub(1,1)=="\\")then else end local e=createMediaItemClip();if(e:checkProcessLimitNum())then reaper.Undo_BeginBlock();local t=4 e:splitItem(t)e:flush();reaper.Undo_EndBlock("kawa MAIN Split 4",-1);reaper.UpdateArrange();end
