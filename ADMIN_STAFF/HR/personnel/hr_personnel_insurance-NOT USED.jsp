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
          INSURANCE RECORD ::::</strong></font></div></td>
    </tr>
</table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="5">
    <tr> 
      <td width="37%" height="25"><p>Employee ID : 
          <input name="textfield" type="text" value="ED-00142">
        </p></td>
      <td width="68%"><input name="image2" type="image" src="../../../images/form_proceed.gif" width="81" height="21" ></td>
    </tr>
    <tr> 
      <td colspan="2"><hr size="1">
        <img src="../../../images/sidebar.gif" width="11" height="270" align="right"> 
        <table width="400" border="0" align="center">
          <tr bgcolor="#FFFFFF"> 
            <td width="100%" valign="middle"> <img src="../../../images/sample_emp.jpg" width="100" height="150" align="right"><font size="2" face="Verdana, Arial, Helvetica, sans-serif"> 
              <strong><br>
              <br>
              <br>
              Virginia Magalong</strong><br>
              <font size="1">ED-00142, Instructor I<br>
              </font></font><font size="1" face="Verdana, Arial, Helvetica, sans-serif">College 
              of Education</font><font size="2" face="Verdana, Arial, Helvetica, sans-serif"><br>
              <br>
              <br>
              </font></td>
          </tr>
        </table>
        <br> <table width="92%" border="0" cellpadding="4" cellspacing="0">
          <tr> 
            <td width="10%" rowspan="7">&nbsp;</td>
            <td width="128">Name of Insurance</td>
            <td width="470"><input name="a_address242" type= "text" class="textbox"  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'"  id="a_address242" size="32">
              <img src="../../../images/update.gif" width="60" height="26"></td>
          </tr>
          <tr> 
            <td>Insurance Company</td>
            <td><input name="a_address24" type= "text" class="textbox"  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'"  id="a_address24" size="32"></td>
          </tr>
          <tr> 
            <td>Terms of payment</td>
            <td><input name="a_address2" type= "text" class="textbox"  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'"  id="a_address2" size="10">
              <font size="1"> (amount)</font> 
              <select name="select">
                <option value="1">Monthly</option>
                <option value="2">Quarterly</option>
                <option value="3">Annual</option>
              </select>
            </td>
          </tr>
          <tr> 
            <td>Date of Application</td>
            <td><input name="bdate22" type="text" disabled="true" id="bdate223" size="15" readonly="true">
              <a href="javascript:show_calendar('staff_profile.dob');" title="Click to select date" onmouseover="window.status='Select date';return true;" onmouseout="window.status='';return true;"><img src="../../../images/calendar_new.gif" width="18" height="20" border="0"></a></td>
          </tr>
          <tr> 
            <td>Date of Maturity</td>
            <td> <input name="bdate222" type="text" disabled="true" id="bdate2222" size="15" readonly="true">
              <a href="javascript:show_calendar('staff_profile.dob');" title="Click to select date" onmouseover="window.status='Select date';return true;" onmouseout="window.status='';return true;"><img src="../../../images/calendar_new.gif" width="18" height="20" border="0"></a></td>
          </tr>
          <tr> 
            <td colspan="2"><br>
              Notes:<br> <textarea name="textarea" cols="64" rows="5"></textarea> 
            </td>
          </tr>
          <tr> 
            <td colspan="2"><div align="center">
                <input name="image" type="image" onClick="AddRecord();" src="../../../images/save.gif" width="48" height="28">
                <font size="1">click to save entries</font> <img src="../../../images/edit.gif" border="0"><font size="1">click 
                to save changes</font> <img src="../../../images/cancel.gif" width="51" height="26" border="0"><font size="1">click 
                to cancel and clear entries</font> </div></td>
          </tr>
          <tr> </tr>
        </table> 
        <br>
        <table width="95%" border="0" align="center" cellpadding="5" cellspacing="0">
          <tr> 
            <td colspan="6" bgcolor="#000000"><div align="center"><strong><font color="#FFFFFF">EMPLOYEE'S 
                INSURANCE RECORD</font></strong></div></td>
          </tr>
          <tr align="center"> 
            <td width="38%"><strong>TRAINING / SEMINARS</strong></td>
            <td width="23%"><strong>Terms</strong></td>
            <td width="22%"><strong>DATE of APPLICATION</strong></td>
            <td width="7%">&nbsp;</td>
            <td width="10%">&nbsp;</td>
          </tr>
          <tr align="center"> 
            <td><strong><font color="#0000FF">Life Insurance</font></strong><br>
              Pet Plans International</td>
            <td>P 512.00 / month</td>
            <td>09-15-2000</td>
            <td><a href="#">Details</a></td>
            <td><a href="#">Delete</a></td>
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

