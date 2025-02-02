<%
///added code for HR/companies.
boolean bolIsSchool = false;
if( (new ReadPropertyFile().getImageFileExtn("IS_SCHOOL","1")).equals("1"))
	bolIsSchool = true;
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<SCRIPT LANGUAGE="JavaScript" SRC="../../../jscript/td.js"></script>
<script language="JavaScript">
function ViewInfo()
{
	document.staff_profile.page_action.value="0";
}
function AddRecord()
{
	document.staff_profile.page_action.value="1";
}
function EditRecord()
{
	document.staff_profile.page_action.value="2";
}
function DeleteRecord()
{
	document.staff_profile.page_action.value="3";
}
function ReloadPage()
{
	document.staff_profile.reloadPage.value = "1";
	document.staff_profile.submit();
}
function ShowHideOthers(strSelFieldName, strOthFieldName,strTextBoxID)
{
	if( eval('document.staff_profile.'+strSelFieldName+'.selectedIndex') == 0)
	{
		eval('document.staff_profile.'+strOthFieldName+'.disabled=false');
		showLayer(strTextBoxID);
	}
	else
	{
		hideLayer(strTextBoxID);
		eval('document.staff_profile.'+strOthFieldName+'.disabled=true');
	}
}
</script>
<body bgcolor="#663300">
<form action="" method="post" name="staff_profile">
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="5" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF" ><strong>:::: 
          TRAININGS/SEMINARS ::::</strong></font></div></td>
    </tr>
</table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="5">
    <tr> 
      <td width="105%"><hr size="1">
        <img src="../../../images/sidebar.gif" width="11" height="270" align="right">
<table width="92%" border="0" align="center" cellpadding="4" cellspacing="0">
          <tr> 
            <td width="55">&nbsp;</td>
            <td width="246">Name of Seminar/Training</td>
            <td width="555"><select name="emp_type">
              </select> &nbsp;<strong> 
              <input type="image" onClick="AddRecord();" src="../../../images/update.gif">
              </strong> -- check hr_personnel_trainings.jsp</td>
          </tr>
          <tr> 
            <td width="55">&nbsp;</td>
            <td>Venue</td>
            <td><input name="a_address24" type= "text" class="textbox"  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"  id="a_address24" size="32"></td>
          </tr>
          <tr> 
            <td width="55">&nbsp;</td>
            <td>Conducted by</td>
            <td><input name="a_address23" type= "text" class="textbox"  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"  id="a_address23" size="24"> 
            </td>
          </tr>
          <tr> 
            <td width="55">&nbsp;</td>
            <td>Inclusive Dates</td>
            <td>From : 
              <input name="bdate22" type="text" disabled="true" id="bdate22" size="15" readonly="true"> 
              <a href="javascript:show_calendar('staff_profile.dob');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" width="18" height="20" border="0"></a> 
              &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;To: 
              <input name="bdate222" type="text" disabled="true" id="bdate222" size="15" readonly="true"> 
              <a href="javascript:show_calendar('staff_profile.dob');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" width="18" height="20" border="0"></a> 
              &nbsp;</td>
          </tr>
          <tr> 
            <td>&nbsp;</td>
            <td>Length in Days/Hours</td>
            <td><input name="textfield2" type="text" size="4">
              Days 
              <input name="textfield3" type="text" size="4">
              Hours </td>
          </tr>
          <tr> 
            <td width="55">&nbsp;</td>
            <td>Open To</td>
            <td><select name="select">
                <option value="">ALL</option>
              </select>
              SHOW EMPLOYMENT TYPE FROM PROFILE PAGE. NO UPDATE BUTTON HERE</td>
          </tr>
          <tr> 
            <td>&nbsp;</td>
            <td>No of attendant(s) per <%if(bolIsSchool){%>College<%}else{%>Division<%}%></td>
            <td><input name="textfield" type="text" size="4">
            </td>
          </tr>
          <tr> 
            <td width="55">&nbsp;</td>
            <td>Mandatory Training</td>
            <td><input type="checkbox" name="checkbox" value="checkbox"> </td>
          </tr>
          <tr>
            <td>&nbsp;</td>
            <td>Only for New Employees</td>
            <td><input type="checkbox" name="checkbox2" value="checkbox"></td>
          </tr>
          <tr> 
            <td width="55">&nbsp;</td>
            <td colspan="2"><br>
              Notes:<br> <textarea name="textarea" cols="64" rows="5"></textarea> 
            </td>
          </tr>
          <tr> 
            <td colspan="3"><div align="center"> 
                <input name="image" type="image" onClick="AddRecord();" src="../../../images/save.gif" width="48" height="28">
                <font size="1">click to save entries</font> <img src="../../../images/edit.gif" width="51" height="26" border="0"><font size="1">click 
                to save changes</font><img src="../../../images/cancel.gif" width="51" height="26" border="0"><font size="1">click 
                to cancel and clear entries</font></div></td>
          </tr>
          <tr> </tr>
        </table> 
        <br>
        <table width="100%" border="0" align="center" cellpadding="5" cellspacing="0">
          <tr> 
            <td colspan="10" bgcolor="#000000"><div align="center"><strong><font color="#FFFFFF">FUTURE 
                TRAINING RECORDS</font></strong></div></td>
          </tr>
          <tr> 
            <td width="30%" align="center"><font size="1"><strong>TRAINING / SEMINARS</strong></font></td>
            <td width="30%" align="center"><font size="1"><strong>VENUE</strong></font></td>
            <td width="10%" align="center"><font size="1"><strong>OPEN TO</strong></font></td>
            <td width="10%" align="center"><font size="1"><strong>DATE</strong></font></td>
            <td width="6%" align="center"><font size="1"><strong>MANDATORY</strong></font></td>
            <td width="6%" align="center"><font size="1"><strong>FOR ONLY NEW 
              EMPLOYEES</strong></font></td>
            <td width="6%" align="center">&nbsp;</td>
            <td width="7%" align="center">&nbsp;</td>
            <td width="7%" align="center">&nbsp;</td>
          </tr>
          <tr> 
            <td>Work and Time Management </td>
            <td>VMUF Social Hall, Centrum Bldg.</td>
            <td>ALL</td>
            <td align="center">09/15/2004</td>
            <td align="center"><input name="image2" type="image" onClick="AddRecord();" src="../../../images/tick.gif"></td>
            <td align="center"><input name="image22" type="image" onClick="AddRecord();" src="../../../images/tick.gif"></td>
            <td align="center"><input type="image" onClick="AddRecord();" src="../../../images/view.gif"></td>
            <td align="center"><input  type="image" onClick="AddRecord();" src="../../../images/edit.gif"></td>
            <td align="center"><input type="image" onClick="AddRecord();" src="../../../images/delete.gif"></td>
          </tr>
        </table>
        <hr size="1"></td>
    </tr>
  </table>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="25"  colspan="3" bgcolor="#A49A6A">&nbsp;</td>
      </tr>
  </table>
</form>
</body>
</html>

