<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
</head>

<body bgcolor="#663300">

<form action="" method="post" name="staff_profile">
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="5" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF" ><strong>:::: 
          LEAVE APPLICATION PROCESSING PAGE ::::</strong></font></div></td>
    </tr>
</table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="5">
    <tr> 
      <td height="25" colspan="2"><a href="./personnel/hr_personnel_leave.jsp"><img src="../../../images/go_back.gif" border="0"></a> 
        Click to go back to main</td>
    </tr>
<% if (!bolMyHome){%>
    <tr>
      <td width="36%" height="25">&nbsp;Employee ID : 
        <input name="emp_id" type="text" class="textbox"   onFocus="style.backgroundColor='#D3EBFF'"
		onBlur="style.backgroundColor='white'" value="<%=strTemp%>" ></td>
      <td width="7%"> <a href="javascript:OpenSearch();"><img src="../../../images/search.gif" border="0"></a> 
			</td>
      <td width="57%"> <a href="javascript:viewInfo()"><img src="../../../images/form_proceed.gif" border="0"></a>
	   </td>
    </tr>
<%}else{%>
    <tr>
      <td colspan="3" height="25">&nbsp;Employee ID : <strong><font size="3" color="#FF0000"><%=strTemp%></font></strong>
        <input name="emp_id" type="hidden" value="<%=strTemp%>" ></td>
    </tr>
<%}%>
    <tr> 
      <td height="25" colspan="2"><hr size="1"> <table width="92%" border="0" align="center">
          <tr> 
            <td width="8%">&nbsp;</td>
            <td width="25%">Type of Leave</td>
            <td width="67%">$leave type.</td>
          </tr>
          <tr> 
            <td>&nbsp;</td>
            <td>Date of Application</td>
            <td>$date of application</td>
          </tr>
          <tr> 
            <td>&nbsp;</td>
            <td>&nbsp;</td>
            <td>&nbsp;</td>
          </tr>
          <tr> 
            <td colspan="3"><table width="100%" border="0" cellspacing="0" cellpadding="5">
                <tr> 
                  <td width="8%">&nbsp;</td>
                  <td width="24%" rowspan="3" bgcolor="#F4F3F5">Date(s) of Leave</td>
                  <td width="10%" bgcolor="#F4F3F5">(FROM) </td>
                  <td width="58%" bgcolor="#F4F3F5"><input name="a_address4" type= "text" disabled="true" class="textbox"  id="a_address44"  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="09/15/2004" size="15" readonly="true"> 
                    <img src="../../../images/calendar_new.gif"> 
                    Time 
                    <input name="a_address22" type= "text" class="textbox"  id="a_address2"  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="1" size="4">
                    : 
                    <input name="a_address222" type= "text" class="textbox"  id="a_address222"  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="00" size="4"> 
                    <select name="select3">
                      <option value="1">AM</option>
                      <option value="2" selected>PM</option>
                    </select></td>
                </tr>
                <tr> 
                  <td>&nbsp;</td>
                  <td bgcolor="#F4F3F5">&nbsp;</td>
                  <td bgcolor="#F4F3F5"><input name="checkbox" type="checkbox" value="checkbox" checked> 
                    <font size="1">Check if leave is only for a day or less</font></td>
                </tr>
                <tr> 
                  <td>&nbsp;</td>
                  <td bgcolor="#F4F3F5"> (TO) </td>
                  <td bgcolor="#F4F3F5"><input name="a_address42" type= "text" disabled="true" class="textbox"  id="a_address422"  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'" size="15" readonly="true"> 
                    <img src="../../../images/calendar_new.gif"> 
                    Time 
                    <input name="a_address23" type= "text" class="textbox"  id="a_address22"  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="4">
                    : 
                    <input name="a_address223" type= "text" class="textbox"  id="a_address223"  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="4"> 
                    <select name="select4">
                      <option value="1">AM</option>
                      <option value="2" selected>PM</option>
                    </select></td>
                </tr>
              </table></td>
          </tr>
          <tr> 
            <td>&nbsp;</td>
            <td>&nbsp;</td>
            <td>&nbsp;</td>
          </tr>
          <tr> 
            <td>&nbsp;</td>
            <td>Duration</td>
            <td><input name="a_address2" type= "text" class="textbox"  id="a_address23"  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="4" size="5"> 
              <select name="select">
                <option value="1" selected>hours</option>
                <option value="2">days</option>
              </select></td>
          </tr>
          <tr> 
            <td>&nbsp;</td>
            <td>&nbsp;</td>
            <td>&nbsp;</td>
          </tr>
          <tr> 
            <td>&nbsp;</td>
            <td>Supervisor's Approval</td>
            <td> &nbsp; 
              <select name="select7">
                <option value="">Not applicable</option>
                <option value="1">Approved</option>
                <option value="0">Disapproved</option>
                <option value="2">Pending</option>
              </select>
              </td>
          </tr>
          <tr> 
            <td>&nbsp;</td>
            <td colspan="2"> Remarks:<br> <textarea name="textarea" cols="64">Approved  -  09 - 14- 2004</textarea> 
            </td>
          </tr>
          <tr> 
            <td>&nbsp;</td>
            <td>HR Approval</td>
            <td><select name="select2">
                <option value="">Not applicable</option>
                <option value="1">Approved</option>
                <option value="0">Disapproved</option>
                <option value="2">Pending</option>
              </select> </td>
          </tr>
          <tr> 
            <td>&nbsp;</td>
            <td colspan="2">Remarks:<br> <textarea name="textarea2" cols="64"></textarea> 
            </td>
          </tr>
          <tr> 
            <td>&nbsp;</td>
            <td>President's Approval</td>
            <td> <select name="select5">
                <option value="">Not applicable</option>
                <option value="1">Approved</option>
                <option value="0">Disapproved</option>
                <option value="2">Pending</option>
              </select> </td>
          </tr>
          <tr> 
            <td>&nbsp;</td>
            <td colspan="2">Remarks:<br> <textarea name="textarea" cols="64"></textarea> 
            </td>
          </tr>
          <tr> 
            <td colspan="3"> <div align="center"> 
                <input name="image" type="image" onClick="AddRecord();" src="../../../images/save.gif" width="48" height="28">
                <font size="1">click to save entries</font> <img src="../../../images/edit.gif" border="0"><font size="1">click 
                to save changes</font> <img src="../../../images/cancel.gif" width="51" height="26" border="0"><font size="1">click 
                to cancel and clear entries</font> <font size="1">s</font> </div></td>
          </tr>
          <tr> 
            <td colspan="3" height="25">&nbsp;</td>
          </tr>
        </table></td>
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

