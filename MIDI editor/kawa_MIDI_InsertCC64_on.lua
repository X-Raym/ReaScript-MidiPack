--====================================================================== 
--[[ 
* ReaScript Name: kawa_MIDI_InsertCC64_on. 
* Version: 2016/06/15 
* Author: kawa_ 
* Author URI: http://forum.cockos.com/member.php?u=105939 
* Repository: GitHub 
* Repository URI: https://github.com/kawaCat/ReaScript-MidiPack 
--]] 
--====================================================================== 
local EditorHwnd=reaper.MIDIEditor_GetActive();
local Take=reaper.MIDIEditor_GetTake(EditorHwnd);
if(Take==nil)then return end
local selected=false
local muted=false
local editCursolTime=reaper.GetCursorPositionEx(0)
local insertPos=reaper.MIDI_GetPPQPosFromProjTime(Take,editCursolTime)
local insertChannnel=reaper.MIDIEditor_GetSetting_int(EditorHwnd,"default_note_chan");
local chanMsg=176;
local ccNum=64;
local ccValue=math.floor(127);
reaper.MIDI_InsertCC(Take
,selected
,muted
,insertPos
,chanMsg
,insertChannnel
,ccNum
,ccValue
,true)
reaper.MIDI_Sort(Take);
