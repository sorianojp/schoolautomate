<%@ page language="java" import="utility.*, java.util.Vector " buffer="16kb"%>
<%
boolean bolIsSchool = false;
if((new CommonUtil().getIsSchool(null)).equals("1"))
	bolIsSchool = true;
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="javascript"  src ="../../../jscript/common.js" ></script>
<script language="JavaScript">
var strErrMsg = "";//set err msg if any data to be validated before saving,, like date fields.. 
function ValidateDate(obj, strInfoIndex) {
	if(!obj) {
		strErrMsg = alert("Invalid Object.");
		return;
	}
	var strDate = obj.value;
	if(strDate.length != 10) {
		alert("Please enter in YYYY-DD-MM format. include 0 if mm or dd is less than 10");
		return;
	}
	if(strDate.charAt(4) != '-' || strDate.charAt(7) != '-' ) {
		alert("Please enter in YYYY-DD-MM format. include 0 if mm or dd is less than 10");
		return;
	}
	this.UpdateProp(strInfoIndex);
}

function UpdateProp(strInfoIndex){
	if(strErrMsg.length > 0) {
		alert(strErrMsg);
		return;
	}
	document.form_.update_info.value ="1";
	document.form_.info_index.value = strInfoIndex;
	this.SubmitOnce("form_");
}
function UpdateSpecific(objField, strTableName, strFieldName, strInitialVal) {
	if(document.form_.access_pwd.value.length == 0) {
		alert('Please enter access password.');
		document.form_.access_pwd.focus();
		return;
	}
	if(objField.value.length == 0) {
		alert("Value can't be empty.");
		objField.focus();
		return;
	}
	if(strInitialVal.length > 0) {
		if(eval(strInitialVal) >= eval(objField.value)) {
			alert("Field value can't be less than previous value.");
			objField.focus();
			return;
		}
	}
	
	document.form_.update_specific.value = objField.value;
	document.form_.update_sp_table.value = strTableName;
	document.form_.update_sp_field.value = strFieldName;
	
	document.form_.submit();	
}

function ValidatePreEnrolmentData(formFieldObj) {
	var vInput = formFieldObj.value;
	if(vInput.length != 6) {
		alert("Must have format YYYY-T. For example 2006-1 for 2006-07 first sem, 2006-2 for 2nd sem and 2006-0 for summer.");
		//document.form_.PRE_ENROLLMENT_SYTERM.focus();
		formFieldObj.value = '';
		return;
	}
	var vTerm = vInput.charAt(5);
	if(eval(vTerm) > 3) {
		alert("Invalid term. It should be 0 for summer, 1 for 1st sem, 2 for 2nd sem and 3 for 3rd sem");
		//document.form_.PRE_ENROLLMENT_SYTERM.focus();
		formFieldObj.value = '';
		return;
	}
}
//for help
function WhatIsPinCodeProtection()
{
	var win=window.open("../../../onlinehelp/whatis_handson.htm#pincode","HelpFile",
	'dependent=yes,width=300,height=300,screenX=200,screenY=300,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();

}
</script>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	Vector vRetResult = null;

	String strErrMsg = null;
	String strTemp = null;
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-System Administration-Set Parameters-System Setting","system_set.jsp");
	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		Error in opening connection</font></p>
		<%
		return;
	}
//authenticate this user.
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"System Administration","Set Parameters",request.getRemoteAddr(),
														"system_set.jsp");
if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
	request.getSession(false).setAttribute("errorMessage",comUtil.getErrMsg());
	response.sendRedirect("../../../commfile/fatal_error.jsp");
	return;
}
else if(iAccessLevel == 0)//NOT AUTHORIZED.
{
	dbOP.cleanUP();
	response.sendRedirect("../../../commfile/unauthorized_page.jsp");
	return;
}



//end of authenticaion code.
ReadPropertyFile rpf = new ReadPropertyFile();

if(WI.fillTextValue("update_info").compareTo("1") == 0){
	if (rpf.setSysProperty(dbOP, request,WI.fillTextValue("info_index")))
		strErrMsg = " Information updated successfully";
	else {
		strErrMsg = rpf.getErrMsg();
		if(strErrMsg == null)
			strErrMsg = " Infomation not updated. Please refresh and try again";
	}
}
if(WI.fillTextValue("update_specific").length() > 0 && WI.fillTextValue("update_sp_table").length() > 0) {
	if (rpf.setSysPropertySpecific(dbOP, request))
		strErrMsg = " Information updated successfully";
	else {
		strErrMsg = rpf.getErrMsg();
		if(strErrMsg == null)
			strErrMsg = " Infomation not updated. Please refresh and try again";
	}
}



vRetResult = rpf.getAllSysProperty(dbOP);
int iIndex = -1;

String strSchoolCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchoolCode == null)
	strSchoolCode = "";

%>


<body bgcolor="#D2AE72">
<form name="form_" action="./system_set.jsp" method="post" >
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A"> 
      <td height="25"><div align="center"><font color="#FFFFFF" ><strong>:::: 
          SYSTEM PARAMETER SETTINGS::::</strong></font></div></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;&nbsp;&nbsp;<font size="3"><strong><%=WI.getStrValue(strErrMsg)%></strong></font></td>
    </tr>
</table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" class="thinborderALL">
    <tr bgcolor="#F2E9D7"> 
      <td height="25" colspan="4" class="thinborderBOTTOM"><strong>&nbsp;Access Password</strong></td>
    </tr>
    <tr> 
    <tr> 
      <td width="34%" height="25" style="font-size:11px"><strong>&nbsp;Password to Access</strong></td>
      <td width="21%" style="font-size:11px"><strong>New Password</strong></td>
      <td width="27%" style="font-size:11px"><strong>Re-type New Password</strong></td>
      <td width="18%">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25">&nbsp;<input type="password" name="access_pwd" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" maxlength="24"></td>
      <td><input type="password" name="new_pwd" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
      <td><input type="password" name="rtype_pwd" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
      <td><a href='javascript:UpdateProp("access_password")'><img src="../../../images/update.gif" width="60" height="26" border="0"></a> 
      </td>
    </tr>
    <tr>
      <td height="18">&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
  </table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr>
  	<td>&nbsp;</td>
  </tr>
  </table>
<%if(bolIsSchool){%>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" class="thinborderALL">
    <tr bgcolor="#F2E9D7"> 
      <td height="25" colspan="3" class="thinborderBOTTOM"><strong>&nbsp;Fee assessment 
        &amp; payment (One time setting only)</strong></td>
    </tr>
<%
if(strSchoolCode.startsWith("CLDH") || strSchoolCode.startsWith("DBTC")){%>
    <tr> 
      <td width="23%" height="25" style="font-size:11px"><strong>&nbsp;Fixed Tuition 
        fee</strong></td>
      <td width="11%" style="font-size:11px"> 
<% 
	iIndex = -1;
	if (vRetResult != null) 
		iIndex= vRetResult.indexOf("IS_FIXED_TUITION");
   
 	
   //System.out.println(vRetResult);
   if (iIndex != -1) {
    strTemp = (String)vRetResult.elementAt(iIndex+1);
    vRetResult.removeElementAt(iIndex);
    vRetResult.removeElementAt(iIndex);
   }
   else 
   	strTemp = WI.fillTextValue("IS_FIXED_TUITION");
%> <select name="IS_FIXED_TUITION">
          <option value="0">No</option>
          <% if (strTemp.compareTo("1") == 0){%>
          <option value="1" selected>Yes</option>
          <%}else{%>
          <option value="1">Yes</option>
          <%}%>
        </select></td>
      <td width="66%" style="font-size:11px"><a href='javascript:UpdateProp("IS_FIXED_TUITION")'><img src="../../../images/update.gif" width="60" height="26" border="0"></a> 
        Change tuition fee type (Consult schoolbliz support before any change:: 
        if tuition fee is fixed, student's tuition fee will not change) </td>
    </tr>
<%}//show only if CLDH. -- or any school having fixed tuition type.%>
    <tr> 
      <td width="23%" height="25" style="font-size:11px"><strong>&nbsp;Grade encoding 
        and payment are linked</strong></td>
      <td width="11%" style="font-size:11px"> 
<% 
	iIndex = -1;
	if (vRetResult != null) 
		iIndex= vRetResult.indexOf("GS_PMT_LINKED");
   
 	
   //System.out.println(vRetResult);
   if (iIndex != -1) {
    strTemp = (String)vRetResult.elementAt(iIndex+1);
    vRetResult.removeElementAt(iIndex);
    vRetResult.removeElementAt(iIndex);
   }
   else 
   	strTemp = WI.fillTextValue("GS_PMT_LINKED");
%> <select name="GS_PMT_LINKED">
          <option value="0">No</option>
          <% if (strTemp.compareTo("1") == 0){%>
          <option value="1" selected>Yes</option>
          <%}else{%>
          <option value="1">Yes</option>
          <%}%>
        </select></td>
      <td width="66%" style="font-size:11px"><a href='javascript:UpdateProp("GS_PMT_LINKED")'><img src="../../../images/update.gif" width="60" height="26" border="0"></a><font size="1"> 
        if linked, grade will be allowed to be encoded only if student has paid 
        certain amount (pls refer to reqd. pmt parameter)</font></td>
    </tr>
<%if(new enrollment.FAPaymentUtil().isAutoGenORForAllTellerSet(dbOP)) {%>
    <tr>
      <td height="25" style="font-size:11px; font-weight:bold"> &nbsp;Last OR Used (in series) </td>
      <td style="font-size:11px">
<% 
	iIndex = -1;
	if (vRetResult != null) 
		iIndex= vRetResult.indexOf("LAST_OR_USED");
   
 	
   //System.out.println(vRetResult);
   if (iIndex != -1) {
    strTemp = (String)vRetResult.elementAt(iIndex+1);
    vRetResult.removeElementAt(iIndex);
    vRetResult.removeElementAt(iIndex);
   }
   else 
   	strTemp = WI.fillTextValue("LAST_OR_USED");
%>
	  <input type="text" name="LAST_OR_USED" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="12" value="<%=strTemp%>"> 
	  </td>
      <td style="font-size:11px">
	  <a href='javascript:UpdateProp("LAST_OR_USED")'><img src="../../../images/update.gif" width="60" height="26" border="0"></a></td>
    </tr>
<%}%>
    <tr> 
      <td height="18">&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
  </table>
<%}%>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="18" colspan="4"><div align="right">&nbsp;</div></td>
    </tr>
    <tr bgcolor="#F2E9D7"> 
      <td height="25" colspan="4" class="thinborderALL"><strong>&nbsp;System Preference</strong></td>
    </tr>
    <tr>
      <td height="25" class="thinborderLEFT">&nbsp;Allow Edit Personal Info in <%if(bolIsSchool){%>my Home.<%}else{%>ESS<%}%></td>
      <td>
<% if (vRetResult != null) iIndex= vRetResult.indexOf("ALLOW_HR_EDIT");
   else iIndex = -1;
   //System.out.println(vRetResult);
   if (iIndex != -1) {
    strTemp = (String)vRetResult.elementAt(iIndex+1);
    vRetResult.removeElementAt(iIndex);
    vRetResult.removeElementAt(iIndex);
   }
   else 
   	strTemp = WI.fillTextValue("ALLOW_HR_EDIT");
%>
        <select name="ALLOW_HR_EDIT">
          <option value="1">Yes</option>
<% if (strTemp.equals("0")){%>
          <option value="0" selected>No</option>
<%}else{%>
          <option value="0">No</option>
<%}%>
        </select> </td>
      <td height="25" colspan="2" class="thinborderRIGHT"><a href='javascript:UpdateProp("ALLOW_HR_EDIT")'><img src="../../../images/update.gif" width="60" height="26" border="0"></a> 
        Click to update <%if(bolIsSchool){%>my Home.<%}else{%>ESS<%}%> edit status setting.</td>
    </tr>
    <tr>
      <td height="25" class="thinborderLEFT">&nbsp;Current Employee ID Series in System </td>
      <td>
<%
strTemp = "select id_count from ID_TRACK_EMP";
strTemp = dbOP.getResultOfAQuery(strTemp, 0);
if(strTemp == null)
	strTemp = "";
%>
	  <input type="text" name="_emp_id_series" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="6" value="<%=strTemp%>"> 
	  
	  </td>
      <td height="25" colspan="2" class="thinborderRIGHT" style="font-size:9px;">&nbsp;
	  <a href='javascript:UpdateSpecific(document.form_._emp_id_series,"ID_TRACK_EMP","ID_COUNT","<%=strTemp%>")'><img src="../../../images/update.gif" border="0"></a> 
	  In case employee ID autogenerated, ID series will be taken from here. 
	  <br>	  
	  Emp ID format if auto generated YYxxx-XXXX (YY = year of employment, xxx = 3 digit security, XXXX = ID Series)</td>
    </tr>
    <tr> 
      <td height="25" class="thinborderLEFT">&nbsp;DTR Time Difference </td>
      <td> <% if (vRetResult != null) iIndex= vRetResult.indexOf("EDTR_TIME_DIFF");
   else iIndex = -1;
   
   if (iIndex != -1) {strTemp = (String)vRetResult.elementAt(iIndex+1);
    vRetResult.removeElementAt(iIndex);
    vRetResult.removeElementAt(iIndex);
   }else strTemp = WI.fillTextValue("EDTR_TIME_DIFF");
%> <input type="text" name="EDTR_TIME_DIFF" size="3" maxlength="3"  class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=strTemp%>">      </td>
      <td height="25" colspan="2" class="thinborderRIGHT"> <font size="1"><a href='javascript:UpdateProp("EDTR_TIME_DIFF")'><img src="../../../images/update.gif" width="60" height="26" border="0"></a>(Time 
        difference between successive login/logout (in minutes))</font></td>
    </tr>
<%if(bolIsSchool){%>
    <tr> 
      <td width="24%" height="25" class="thinborderLEFT">&nbsp;Auto Schedule Clinical 
        Test </td>
      <td width="10%"> <% if (vRetResult != null) iIndex= vRetResult.indexOf("ACTIVATE_CLINICAL_TEST");
   else iIndex = -1;//System.out.println(vRetResult);
   
   if (iIndex != -1) {strTemp = (String)vRetResult.elementAt(iIndex+1);
    vRetResult.removeElementAt(iIndex);
    vRetResult.removeElementAt(iIndex);
   }else strTemp = WI.getStrValue(WI.fillTextValue("ACTIVATE_CLINICAL_TEST"),"0");
%> <select name="ACTIVATE_CLINICAL_TEST">
          <option value="1">Yes</option>
          <% if (strTemp.equals("0")){%>
          <option value="0" selected>No</option>
          <%}else{%>
          <option value="0">No</option>
          <%}%>
      </select></td>
      <td width="66%" height="25" colspan="2" class="thinborderRIGHT"> <a href='javascript:UpdateProp("ACTIVATE_CLINICAL_TEST")'><img src="../../../images/update.gif" width="60" height="26" border="0"></a>      </td>
    </tr>
    <tr> 
      <td width="25%" height="25" class="thinborderLEFT">&nbsp;Show Heading in 
        Receipt</td>
      <td width="9%"> <% if (vRetResult != null) iIndex= vRetResult.indexOf("showHeadingOnPrintReceipt");
   else iIndex = -1;//System.out.println(vRetResult);
   
   if (iIndex != -1) {strTemp = (String)vRetResult.elementAt(iIndex+1);
    vRetResult.removeElementAt(iIndex);
    vRetResult.removeElementAt(iIndex);
   }else strTemp = WI.fillTextValue("showHeadingOnPrintReceipt");
%> <select name="showHeadingOnPrintReceipt">
          <option value="1">Yes</option>
          <% if (strTemp.equals("0")){%>
          <option value="0" selected>No</option>
          <%}else{%>
          <option value="0">No</option>
          <%}%>
      </select></td>
      <td width="66%" height="25" colspan="2" class="thinborderRIGHT"> <a href='javascript:UpdateProp("showHeadingOnPrintReceipt")'><img src="../../../images/update.gif" width="60" height="26" border="0"></a>      </td>
    </tr>
    <tr> 
      <td height="25" class="thinborderLEFT"> &nbsp;Storage Drive (CD ROM) </td>
      <td> <% if (vRetResult != null) iIndex= vRetResult.indexOf("storageDrive");
   else iIndex = -1;
   
   if (iIndex != -1) {strTemp = (String)vRetResult.elementAt(iIndex+1);
    vRetResult.removeElementAt(iIndex);
    vRetResult.removeElementAt(iIndex);
   }else strTemp = WI.fillTextValue("storageDrive");
%> <input name="storageDrive" type="text"  size="3" maxlength="3"  class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=strTemp%>"></td>
      <td height="25" colspan="2" class="thinborderRIGHT"> <font size="1"><a href='javascript:UpdateProp("storageDrive")'><img src="../../../images/update.gif" width="60" height="26" border="0"></a>(To 
        be used for data archiving)</font></td>
    </tr>
    <tr> 
      <td height="25" class="thinborderLEFT">&nbsp;Post Charge Payment Setting</td>
      <td height="25" colspan="3" class="thinborderRIGHT"> <p> 
          <% if (vRetResult != null) iIndex= vRetResult.indexOf("INSTAL_PMT_SETTING");
   else iIndex = -1;
   
   if (iIndex != -1) {strTemp = (String)vRetResult.elementAt(iIndex+1);
    vRetResult.removeElementAt(iIndex);
    vRetResult.removeElementAt(iIndex);
   }else strTemp = WI.fillTextValue("INSTAL_PMT_SETTING");
%>
          <select name="INSTAL_PMT_SETTING">
            <option value="0">Add Balance to next payment schedule <!--Divide in all installments--></option>
<%
if(strTemp.compareTo("1") == 0) {%>
            <option value="1" selected>Divide in remaining installments</option>
<%}else{%>
            <option value="1">Divide in remaining installments</option>
<%}if(strTemp.compareTo("2") == 0) {%>
            <option value="2" selected>Add all in final payments</option>
<%}else{%>
            <option value="2">Add all in final payments</option>
<%}%>          </select>
          <a href='javascript:UpdateProp("INSTAL_PMT_SETTING")'><img src="../../../images/update.gif" width="60" height="26" border="0"></a><br>
          <font size="1">( if charge is posted to ledger, select option for charged 
          value)</font></p></td>
    </tr>
    <tr> 
      <td height="25" class="thinborderLEFT">&nbsp;Gate Security For Employee </td>
      <td> <% if (vRetResult != null) iIndex= vRetResult.indexOf("EDTR_FACULTY");
   else iIndex = -1;//System.out.println(vRetResult);
   
   if (iIndex != -1) {strTemp = (String)vRetResult.elementAt(iIndex+1);
    vRetResult.removeElementAt(iIndex);
    vRetResult.removeElementAt(iIndex);
   }else strTemp = WI.fillTextValue("EDTR_FACULTY");
%> <select name="EDTR_FACULTY">
          <option value="0">No</option>
          <% if (strTemp.equals("1")){%>
          <option value="1" selected>Yes</option>
          <%}else{%>
          <option value="1">Yes</option>
          <%}%>
        </select>	  </td>
      <td height="25" colspan="2" class="thinborderRIGHT"> <font size="1"><a href='javascript:UpdateProp("EDTR_FACULTY")'><img src="../../../images/update.gif" width="60" height="26" border="0"></a>(Click Yes to record campus in and out time for employees)</font></td>
    </tr>
    <tr> 
      <td height="25" class="thinborderLEFT">&nbsp;Allow Summer Student during First Semester(Library and Gate Attendance) </td>
      <td> <% if (vRetResult != null) iIndex= vRetResult.indexOf("ALLOW_SUMMER_ATTENDANCE");
   else iIndex = -1;//System.out.println(vRetResult);
   
   if (iIndex != -1) {strTemp = (String)vRetResult.elementAt(iIndex+1);
    vRetResult.removeElementAt(iIndex);
    vRetResult.removeElementAt(iIndex);
   }else strTemp = WI.fillTextValue("ALLOW_SUMMER_ATTENDANCE");
%> <select name="ALLOW_SUMMER_ATTENDANCE">
          <option value="0">No</option>
          <% if (strTemp.equals("1")){%>
          <option value="1" selected>Yes</option>
          <%}else{%>
          <option value="1">Yes</option>
          <%}%>
        </select>	  </td>
      <td height="25" colspan="2" class="thinborderRIGHT"> <font size="1"><a href='javascript:UpdateProp("ALLOW_SUMMER_ATTENDANCE")'><img src="../../../images/update.gif" width="60" height="26" border="0"></a>(Click Yes to record campus in and out time for employees)</font></td>
    </tr>
<%}%>
<!--
    <tr> 
      <td height="25" class="thinborderBOTTOMLEFT">&nbsp;Image File Extension</td>
      <td class="thinborderBOTTOM"> <% if (vRetResult != null) iIndex= vRetResult.indexOf("imgFileUploadExt");
   else iIndex = -1;
   
   if (iIndex != -1) {strTemp = (String)vRetResult.elementAt(iIndex+1);
    vRetResult.removeElementAt(iIndex);
    vRetResult.removeElementAt(iIndex);
   }else strTemp = WI.fillTextValue("imgFileUploadExt");
%> <select name="imgFileUploadExt" >
          <option value="jpg">jpg</option>
          <% if (strTemp.startsWith("g")){%>
          <option value="gif" selected>gif</option>
          <%}else{%>
          <option value="gif">gif</option>
          <%}%>
        </select> </td>
      <td height="25" colspan="2" class="thinborderBOTTOMRIGHT"> <a href='javascript:UpdateProp("imgFileUploadExt")'><img src="../../../images/update.gif" width="60" height="26" border="0"></a></td>
    </tr>
-->
<%if(strSchoolCode.startsWith("SPC")){%>
    <tr> 
      <td height="25" class="thinborderLEFT">&nbsp;Allow Printing Permit on OR</td>
      <td> <% if (vRetResult != null) iIndex= vRetResult.indexOf("print_admslip_on_or");
   else iIndex = -1;
   
   if (iIndex != -1) {strTemp = (String)vRetResult.elementAt(iIndex+1);
    vRetResult.removeElementAt(iIndex);
    vRetResult.removeElementAt(iIndex);
   }
   else 
   	strTemp = WI.fillTextValue("print_admslip_on_or");
%> 			<select name="print_admslip_on_or" >
				<option value="0"></option>
          		<%=dbOP.loadCombo("pmt_sch_index","exam_name"," from FA_PMT_SCHEDULE  where is_valid=1 order by EXAM_PERIOD_ORDER asc",strTemp, false)%>
		  	</select>
	  </td>
      <td height="25" colspan="2" class="thinborderRIGHT"> <a href='javascript:UpdateProp("print_admslip_on_or")'><img src="../../../images/update.gif" width="60" height="26" border="0"></a></td>
    </tr>
<%}%>
    <tr> 
      <td height="25" class="thinborderLEFT">&nbsp;0 Balance required for TOR Printing</td>
      <td> <% if (vRetResult != null) iIndex= vRetResult.indexOf("TOR_PMT_REQUIRED");
   else iIndex = -1;
   
   if (iIndex != -1) {strTemp = (String)vRetResult.elementAt(iIndex+1);
    vRetResult.removeElementAt(iIndex);
    vRetResult.removeElementAt(iIndex);
   }
   else 
   	strTemp = WI.fillTextValue("TOR_PMT_REQUIRED");

if(strTemp.equals("1"))
	strTemp = " selected";
else	
	strTemp = "";
%> 			<select name="TOR_PMT_REQUIRED" >
				<option value="0"></option>
				<option value="1"<%=strTemp%>>Yes</option>
		  	</select>
	  </td>
      <td height="25" colspan="2" class="thinborderRIGHT"> <a href='javascript:UpdateProp("TOR_PMT_REQUIRED")'><img src="../../../images/update.gif" width="60" height="26" border="0"></a></td>
    </tr>

    <tr> 
      <td height="25" class="thinborderBOTTOMLEFT">&nbsp;Enforce Item Request for Supplies in MyHome</td>
      <td class="thinborderBOTTOM"> <% if (vRetResult != null) iIndex= vRetResult.indexOf("FORCE_SUPPLY_REQUISITION_MYHOME");
   else iIndex = -1;
   
   if (iIndex != -1) {strTemp = (String)vRetResult.elementAt(iIndex+1);
    vRetResult.removeElementAt(iIndex);
    vRetResult.removeElementAt(iIndex);
   }
   else 
   	strTemp = WI.fillTextValue("FORCE_SUPPLY_REQUISITION_MYHOME");

if(strTemp.equals("1"))
	strTemp = " selected";
else	
	strTemp = "";
%> 			<select name="FORCE_SUPPLY_REQUISITION_MYHOME" >
				<option value="0"></option>
				<option value="1"<%=strTemp%>>Yes</option>
		  	</select>
	  </td>
      <td height="25" colspan="2" class="thinborderBOTTOMRIGHT"> <a href='javascript:UpdateProp("FORCE_SUPPLY_REQUISITION_MYHOME")'><img src="../../../images/update.gif" width="60" height="26" border="0"></a></td>
    </tr>
    <tr> 
      <td height="18">&nbsp;</td>
      <td>&nbsp;</td>
      <td height="18" colspan="2">&nbsp;</td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#F2E9D7"> 
      <td height="25" colspan="3" class="thinborderALL"><strong>&nbsp;Security Options</strong></td>
    </tr>
    <tr> 
      <td width="24%" class="thinborderLEFT">&nbsp;Maximum Password Retries</td>
      <td width="73%" height="30" colspan="2" valign="middle" class="thinborderRIGHT"> 
<% if (vRetResult != null) iIndex= vRetResult.indexOf("passwordretry");
   else iIndex = -1;
   
   if (iIndex != -1) {strTemp = (String)vRetResult.elementAt(iIndex+1);
    vRetResult.removeElementAt(iIndex);
    vRetResult.removeElementAt(iIndex);
   }else strTemp = WI.fillTextValue("passwordretry");
%> 
        <input name="passwordretry" type="text" size="3" maxlength="3"  class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"value="<%=strTemp%>">
        <a href='javascript:UpdateProp("passwordretry")'><img src="../../../images/update.gif" width="60" height="26" border="0"></a></td>
    </tr>
    <tr>
      <td class="thinborderLEFT">&nbsp;Enforce Password Complexity</td>
      <td height="30" colspan="2" valign="middle" class="thinborderRIGHT">
<% if (vRetResult != null) iIndex= vRetResult.indexOf("FORCE_COMPLEX_PASSWORD");
   else iIndex = -1;
   
   if (iIndex != -1) {strTemp = (String)vRetResult.elementAt(iIndex+1);
    vRetResult.removeElementAt(iIndex);
    vRetResult.removeElementAt(iIndex);
   }else strTemp = WI.fillTextValue("FORCE_COMPLEX_PASSWORD");
%> 
<select name="FORCE_COMPLEX_PASSWORD">
          <option value="0"> Simple Password</option>
          <% if (strTemp.equals("1")) {%>
          <option value="1" selected>Force Complex Password</option>
          <%}else{%>
          <option value="1">Force Complex Password</option>
          <%}%>
        </select>
        <a href='javascript:UpdateProp("FORCE_COMPLEX_PASSWORD")'><img src="../../../images/update.gif" width="60" height="26" border="0"></a>( Complex Password is >=8 char, combination of digit, char and special chars)		</td>
    </tr>
<%if(bolIsSchool){%>
    <tr> 
      <td class="thinborderLEFT">&nbsp;Tempory User Password &nbsp;Retries</td>
      <td height="30" colspan="2" valign="middle" class="thinborderRIGHT"> <% if (vRetResult != null) iIndex= vRetResult.indexOf("tempuser_passwordretry");
   else iIndex = -1;
   
   if (iIndex != -1) {strTemp = (String)vRetResult.elementAt(iIndex+1);
    vRetResult.removeElementAt(iIndex);
    vRetResult.removeElementAt(iIndex);
   }else strTemp = WI.fillTextValue("tempuser_passwordretry");
%> 
        <input name="tempuser_passwordretry" type="text"  size="3" maxlength="3"  class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=strTemp%>">
        <a href='javascript:UpdateProp("tempuser_passwordretry")'><img src="../../../images/update.gif" width="60" height="26" border="0"></a></td>
    </tr>
    <tr> 
      <td height="25" class="thinborderLEFT">&nbsp;Auto Generate Password</td>
      <td colspan="2" class="thinborderRIGHT"> <% if (vRetResult != null) iIndex= vRetResult.indexOf("AUTOGEN_PWD");
   else iIndex = -1;
   
   if (iIndex != -1) {strTemp = (String)vRetResult.elementAt(iIndex+1);
    vRetResult.removeElementAt(iIndex);
    vRetResult.removeElementAt(iIndex);
   }else strTemp = WI.fillTextValue("AUTOGEN_PWD");
%> <select name="AUTOGEN_PWD">
          <option value="1">Generate</option>
          <% if (strTemp.equals("0")) {%>
          <option value="0" selected>Do Not Generate</option>
          <%}else{%>
          <option value="0"> Do Not Generate</option>
          <%}%>
        </select>
        <a href='javascript:UpdateProp("AUTOGEN_PWD")'><img src="../../../images/update.gif" width="60" height="26" border="0"></a>( for new 
        Student only )</td>
    </tr>
<%}%>
    <tr> 
      <td height="25" class="thinborderLEFT">&nbsp;Allow Password same as 
        Login ID/Emp ID</td>
      <td colspan="2" class="thinborderRIGHT"> 
	  <% if (vRetResult != null) 
	  		iIndex= vRetResult.indexOf("ALLOW_PWD_USERID_EQUAL");
   		else 
			iIndex = -1;
   
   if (iIndex != -1) {strTemp = (String)vRetResult.elementAt(iIndex+1);
    vRetResult.removeElementAt(iIndex);
    vRetResult.removeElementAt(iIndex);
   }else strTemp = WI.fillTextValue("ALLOW_PWD_USERID_EQUAL");
%>
        <select name="ALLOW_PWD_USERID_EQUAL">
          <option value="1">Yes</option>
          <% if (strTemp.equals("0")){%>
          <option value="0" selected>No</option>
          <%}else{%>
          <option value="0">No</option>
          <%}%>
        </select>
        <a href='javascript:UpdateProp("ALLOW_PWD_USERID_EQUAL")'><img src="../../../images/update.gif" width="60" height="26" border="0"></a> 
        <font size="1">(If not allowed, user can't set password same as login 
        ID/ emp-id <%if(bolIsSchool){%>(or stud id).<%}%></font></td>
    </tr>
    <tr> 
      <td height="25" class="thinborderLEFT">&nbsp;Force ID and Login ID 
        different </td>
      <td colspan="2" class="thinborderRIGHT"> 
	  <% if (vRetResult != null) 
	  		iIndex= vRetResult.indexOf("FORCE_ID_LOGIN_DIFF");
   		else 
			iIndex = -1;
   
   if (iIndex != -1) {strTemp = (String)vRetResult.elementAt(iIndex+1);
    vRetResult.removeElementAt(iIndex);
    vRetResult.removeElementAt(iIndex);
   }else strTemp = WI.fillTextValue("FORCE_ID_LOGIN_DIFF");
%>
        <select name="FORCE_ID_LOGIN_DIFF">
          <option value="0">No</option>
          <% if (strTemp.equals("1")){%>
          <option value="1" selected>Yes</option>
          <%}else{%>
          <option value="1">Yes</option>
          <%}%>
        </select>
        <a href='javascript:UpdateProp("FORCE_ID_LOGIN_DIFF")'><img src="../../../images/update.gif" width="60" height="26" border="0"></a> 
        <font size="1">(If not forced, user can't have same user id and login id. Must set login prefix). </font></td>
    </tr>
    <tr>
      <td height="25" class="thinborderLEFT">&nbsp;Force Pincode protection</td>
      <td colspan="2" class="thinborderRIGHT"><span class="thinborderRIGHT">
        <% if (vRetResult != null) 
	  		iIndex= vRetResult.indexOf("PINCODE_PROTECTION");
   		else 
			iIndex = -1;
   
   if (iIndex != -1) {strTemp = (String)vRetResult.elementAt(iIndex+1);
    vRetResult.removeElementAt(iIndex);
    vRetResult.removeElementAt(iIndex);
   }else strTemp = WI.fillTextValue("PINCODE_PROTECTION");
%>
        <select name="PINCODE_PROTECTION">
          <option value="0">No</option>
          <% if (strTemp.equals("1")){%>
          <option value="1" selected>Yes</option>
          <%}else{%>
          <option value="1">Yes</option>
          <%}%>
        </select>
        <a href='javascript:UpdateProp("PINCODE_PROTECTION")'><img src="../../../images/update.gif" width="60" height="26" border="0"></a></span>
		&nbsp;&nbsp;&nbsp;&nbsp;What is it? 
		<a href="javascript:WhatIsPinCodeProtection();">
			<img src="../../../images/online_help.gif" border="0"></a></td>
    </tr>
    <tr>
      <td height="25" class="thinborderLEFT">&nbsp;IDs allowed to Initialize AR </td>
      <td colspan="2" class="thinborderRIGHT">
	  <% 
if (vRetResult != null) 
	iIndex= vRetResult.indexOf("ID_ALLOWED_INITILIZE");
else 
	iIndex = -1;
   
if (iIndex != -1) {
	strTemp = (String)vRetResult.elementAt(iIndex+1);
	vRetResult.removeElementAt(iIndex);
	vRetResult.removeElementAt(iIndex);
}
else 
	strTemp = WI.fillTextValue("ID_ALLOWED_INITILIZE");
%> 
<input name="ID_ALLOWED_INITILIZE" type="text"   class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="32"  value="<%=strTemp%>"> 
        <a href='javascript:UpdateProp("ID_ALLOWED_INITILIZE")'><img src="../../../images/update.gif" width="60" height="26" border="0"></a>
		<font size="1">Note: if more than 1 IDs, place ids in csv.		</td>
    </tr>
    <tr>
      <td height="25" class="thinborderLEFT">&nbsp;IDs allowed to Enroll after End of Enrollment</td>
      <td colspan="2" class="thinborderRIGHT">
	  <% 
if (vRetResult != null) 
	iIndex= vRetResult.indexOf("ID_ALLOWED_ADMISSION");
else 
	iIndex = -1;
   
if (iIndex != -1) {
	strTemp = (String)vRetResult.elementAt(iIndex+1);
	vRetResult.removeElementAt(iIndex);
	vRetResult.removeElementAt(iIndex);
}
else 
	strTemp = WI.fillTextValue("ID_ALLOWED_ADMISSION");
%> 
<input name="ID_ALLOWED_ADMISSION" type="text"   class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="32"  value="<%=strTemp%>"> 
        <a href='javascript:UpdateProp("ID_ALLOWED_ADMISSION")'><img src="../../../images/update.gif" width="60" height="26" border="0"></a>
		<font size="1">Note: if more than 1 IDs, place ids in csv.		</td>
    </tr>
     <tr>
      <td height="25" class="thinborderBOTTOMLEFT">&nbsp;Record User visit Log</td>
      <td colspan="2" class="thinborderBOTTOMRIGHT"><span class="thinborderRIGHT">
        <% if (vRetResult != null) 
	  		iIndex= vRetResult.indexOf("RECORD_ACCESS_LOG");
   		else 
			iIndex = -1;
   
   if (iIndex != -1) {strTemp = (String)vRetResult.elementAt(iIndex+1);
    vRetResult.removeElementAt(iIndex);
    vRetResult.removeElementAt(iIndex);
   }else strTemp = WI.fillTextValue("RECORD_ACCESS_LOG");
%>
        <select name="RECORD_ACCESS_LOG">
          <option value="0">No</option>
          <% if (strTemp.equals("1")){%>
          <option value="1" selected>Yes</option>
          <%}else{%>
          <option value="1">Yes</option>
          <%}%>
        </select>
        <a href='javascript:UpdateProp("RECORD_ACCESS_LOG")'><img src="../../../images/update.gif" width="60" height="26" border="0"></a></span>
		&nbsp;&nbsp;&nbsp;&nbsp;System records page visit of every logged in user.</td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="18" colspan="3">&nbsp;</td>
    </tr>
    <tr bgcolor="#F2E9D7"> 
      <td height="25" colspan="3" class="thinborderALL"><strong> &nbsp;Mailing 
        Options:</strong></td>
    </tr>
    <tr> 
      <td width="25%" height="25" class="thinborderLEFT">&nbsp;Mailer Address 
        :</td>
      <td width="75%" colspan="2" class="thinborderRIGHT"> 
<% 
if (vRetResult != null) 
	iIndex= vRetResult.indexOf("mailerFROM");
else 
	iIndex = -1;
   
   if (iIndex != -1) {
   	strTemp = (String)vRetResult.elementAt(iIndex+1);
    vRetResult.removeElementAt(iIndex);
    vRetResult.removeElementAt(iIndex);
   }
   else 
   	strTemp = WI.fillTextValue("mailerFROM");
%> 
<input name="mailerFROM" type="text"   class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="64"  value="<%=strTemp%>"> 
      <a href='javascript:UpdateProp("mailerFROM")'><img src="../../../images/update.gif" width="60" height="26" border="0"></a></td>
    </tr>
    <tr> 
      <td height="25" class="thinborderLEFT">&nbsp;Mail Host Name :</td>
      <td colspan="2" class="thinborderRIGHT"> <% if (vRetResult != null) iIndex= vRetResult.indexOf("mailerHOST");
   else iIndex = -1;
   
   if (iIndex != -1) {strTemp = (String)vRetResult.elementAt(iIndex+1);
    vRetResult.removeElementAt(iIndex);
    vRetResult.removeElementAt(iIndex);
   }else strTemp = WI.fillTextValue("mailerHOST");
%> <input name="mailerHOST" type="text"   class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"size="64"  value="<%=strTemp%>"> 
        <a href='javascript:UpdateProp("mailerHOST")'><img src="../../../images/update.gif" width="60" height="26" border="0"></a></td>
    </tr>
    <tr> 
      <td height="25" class="thinborderLEFT">&nbsp;Mailer User Name:</td>
      <td colspan="2" class="thinborderRIGHT"> <% if (vRetResult != null) iIndex= vRetResult.indexOf("mailerUser");
   else iIndex = -1;
   
   if (iIndex != -1) {strTemp = (String)vRetResult.elementAt(iIndex+1);
    vRetResult.removeElementAt(iIndex);
    vRetResult.removeElementAt(iIndex);
   }else strTemp = WI.fillTextValue("mailerUser");
%> <input name="mailerUser" type="text" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="48"  value="<%=strTemp%>"> 
        <a href='javascript:UpdateProp("mailerUser")'><img src="../../../images/update.gif" width="60" height="26" border="0"></a></td>
    </tr>
    <tr> 
      <td height="25" class="thinborderLEFT">&nbsp;Mailer Password :</td>
      <td colspan="2" class="thinborderRIGHT"> <% if (vRetResult != null) iIndex= vRetResult.indexOf("mailerPwd");
   else iIndex = -1;
   
   if (iIndex != -1) {strTemp = (String)vRetResult.elementAt(iIndex+1);
       vRetResult.removeElementAt(iIndex);
    vRetResult.removeElementAt(iIndex);
   }else strTemp = WI.fillTextValue("mailerPwd");
%> <input name="mailerPwd" type="password"   class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"size="32"  value="<%=strTemp%>"> 
        <a href='javascript:UpdateProp("mailerPwd")'><img src="../../../images/update.gif" width="60" height="26" border="0"></a></td>
    </tr>
    <tr> 
      <td height="25" class="thinborderLEFT">&nbsp;Mail Subject :</td>
      <td colspan="2" class="thinborderRIGHT"> <% if (vRetResult != null) iIndex= vRetResult.indexOf("mailviolationSubject");
   else iIndex = -1;
   
   if (iIndex != -1) {strTemp = (String)vRetResult.elementAt(iIndex+1);
    vRetResult.removeElementAt(iIndex);
    vRetResult.removeElementAt(iIndex);
   }else strTemp = WI.fillTextValue("mailviolationSubject");
%> <input name="mailviolationSubject" type="text" size="48"  class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=strTemp%>"> 
        <a href='javascript:UpdateProp("mailviolationSubject")'><img src="../../../images/update.gif" width="60" height="26" border="0"></a></td>
    </tr>
    <tr> 
      <td height="25" class="thinborderLEFT" valign="top"><br>
        &nbsp;Mail Header :</td>
      <td colspan="2" class="thinborderRIGHT"> <% if (vRetResult != null) iIndex= vRetResult.indexOf("mailviolationStart");
   else iIndex = -1;
   
   if (iIndex != -1) {strTemp = (String)vRetResult.elementAt(iIndex+1);
    vRetResult.removeElementAt(iIndex);
    vRetResult.removeElementAt(iIndex);
   }else strTemp = WI.fillTextValue("mailviolationStart");
%> <textarea name="mailviolationStart"  class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"cols="48" rows="3"> <%=strTemp%></textarea> 
        <a href='javascript:UpdateProp("mailviolationStart")'><img src="../../../images/update.gif" width="60" height="26" border="0"></a></td>
    </tr>
    <tr> 
      <td height="24" class="thinborderBOTTOMLEFT" valign="top"><br>
        &nbsp;Main Footer :</td>
      <td colspan="2" class="thinborderBOTTOMRIGHT"> <% if (vRetResult != null) iIndex= vRetResult.indexOf("mailviolationEnd");
   else iIndex = -1;
   
   if (iIndex != -1) {strTemp = (String)vRetResult.elementAt(iIndex+1);
    vRetResult.removeElementAt(iIndex);
    vRetResult.removeElementAt(iIndex);
   }else strTemp = WI.fillTextValue("mailviolationEnd");
%> <textarea name="mailviolationEnd"  class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"cols="48" rows="3"><%=strTemp%></textarea> 
        <a href='javascript:UpdateProp("mailviolationEnd")'><img src="../../../images/update.gif" width="60" height="26" border="0"></a></td>
    </tr>
<%if(bolIsSchool){%>
    <tr> 
      <td height="18" colspan="3">&nbsp;</td>
    </tr>
    <tr bgcolor="#F2E9D7"> 
      <td height="24" colspan="3" class="thinborderALL"><strong>&nbsp;Advising 
        and Online Registration Options</strong></td>
    </tr>
    <tr>
      <td height="24" class="thinborderLEFT">&nbsp;Online Advising:</td>
      <td colspan="2" class="thinborderRIGHT">
<% 
   	if (vRetResult != null) 
		iIndex= vRetResult.indexOf("ONLINE_ADVISE_PARAM");
	else 
		iIndex = -1;
   
   	if (iIndex != -1) {
		strTemp = (String)vRetResult.elementAt(iIndex+1);
		vRetResult.removeElementAt(iIndex);
		vRetResult.removeElementAt(iIndex);
   	}
   	else 
		strTemp = WI.fillTextValue("ONLINE_ADVISE_PARAM");
%> <select name="ONLINE_ADVISE_PARAM" >
          <option value="0">Online advising is turned Off</option>
<%
if(strTemp.equals("1"))
	strErrMsg = " selected";
else	
	strErrMsg = "";
%>
          <option value="1"<%=strErrMsg%>>Open for all(no restriction)</option>
<%
if(strTemp.equals("2"))
	strErrMsg = " selected";
else
	strErrMsg = "";
%>
          <option value="2"<%=strErrMsg%>>Student/Section is preset by School</option>

        </select> 
<a href='javascript:UpdateProp("ONLINE_ADVISE_PARAM")'><img src="../../../images/update.gif" width="60" height="26" border="0"></a></td>
    </tr>
<!--this is added to limit the display of section depending on offered by college/dept.. -->
    <tr>
      <td height="24" class="thinborderLEFT">&nbsp;Section Offering Ownership Validity(Date):</td>
      <td colspan="2" class="thinborderRIGHT">
 <% if (vRetResult != null) iIndex= vRetResult.indexOf("ADVISING_SECTION_OWNERSHIP");
   else iIndex = -1;
   
   if (iIndex != -1) {strTemp = (String)vRetResult.elementAt(iIndex+1);
    vRetResult.removeElementAt(iIndex);
    vRetResult.removeElementAt(iIndex);
   }else strTemp = WI.fillTextValue("ADVISING_SECTION_OWNERSHIP");
%> 
<!--
<select name="ADVISING_SECTION_OWNERSHIP" >
          <option value="1">Yes</option>
          <% if (strTemp.equals("0")){%>
          <option value="0" selected>No</option>
          <%}else{%>
          <option value="0">No</option>
          <%}%>
        </select> 
-->		
		<input name="ADVISING_SECTION_OWNERSHIP" type="text" size="12"  class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=strTemp%>"> (Enter Date in YYYY-MM-DD format for example <%=WI.getTodaysDate()%>)
	  
	  
		<a href='javascript:ValidateDate(document.form_.ADVISING_SECTION_OWNERSHIP,"ADVISING_SECTION_OWNERSHIP")'><img src="../../../images/update.gif" width="60" height="26" border="0"></a>			  </td>
    </tr>
    <tr>
      <td height="24" class="thinborderLEFT">&nbsp;Implement Room Ownership</td>
      <td colspan="2" class="thinborderRIGHT">
 <% if (vRetResult != null) 
 		iIndex= vRetResult.indexOf("ROOM_OWNERSHIP");
   else 
   		iIndex = -1;
   
   if (iIndex != -1) {
   		strTemp = (String)vRetResult.elementAt(iIndex+1);
    	vRetResult.removeElementAt(iIndex);
    	vRetResult.removeElementAt(iIndex);
   }
   else 
   	strTemp = WI.fillTextValue("ROOM_OWNERSHIP");
%> <select name="ROOM_OWNERSHIP" >
          <option value="0">No</option>
          <% if (strTemp.equals("1")){%>
          <option value="1" selected>Yes</option>
          <%}else{%>
          <option value="1">Yes</option>
          <%}%>
        </select> <a href='javascript:UpdateProp("ROOM_OWNERSHIP")'><img src="../../../images/update.gif" width="60" height="26" border="0"></a>	  </td>
    </tr>
 <!--this is added to force implement blocksection... -->
    <tr>
      <td height="24" class="thinborderLEFT">&nbsp;Block Section Validity(Date):</td>
      <td colspan="2" class="thinborderRIGHT">
 <% if (vRetResult != null) iIndex= vRetResult.indexOf("FORCE_BLOCK_SECTION");
   else iIndex = -1;
   
   if (iIndex != -1) {strTemp = (String)vRetResult.elementAt(iIndex+1);
    vRetResult.removeElementAt(iIndex);
    vRetResult.removeElementAt(iIndex);
   }else strTemp = WI.fillTextValue("FORCE_BLOCK_SECTION");
%> 
		<input name="FORCE_BLOCK_SECTION" type="text" size="12"  class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=strTemp%>"> (Enter Date in YYYY-MM-DD format for example <%=WI.getTodaysDate()%>)
	  
	  
		<a href='javascript:ValidateDate(document.form_.FORCE_BLOCK_SECTION,"FORCE_BLOCK_SECTION")'><img src="../../../images/update.gif" width="60" height="26" border="0"></a>			  </td>
    </tr>
   <tr>
      <td height="24" class="thinborderLEFT">&nbsp;Allow Downpayment less than Required</td>
      <td colspan="2" class="thinborderRIGHT">
 <% if (vRetResult != null) 
 		iIndex= vRetResult.indexOf("ALLOW_DP_LESS");
   else 
   		iIndex = -1;
   
   if (iIndex != -1) {
   		strTemp = (String)vRetResult.elementAt(iIndex+1);
    	vRetResult.removeElementAt(iIndex);
    	vRetResult.removeElementAt(iIndex);
   }
   else 
   	strTemp = WI.fillTextValue("ALLOW_DP_LESS");
%> <select name="ALLOW_DP_LESS" >
          <option value="1">Yes</option>
          <% if (strTemp.equals("0")){%>
          <option value="0" selected>No</option>
          <%}else{%>
          <option value="0">No</option>
          <%}%>
        </select> <a href='javascript:UpdateProp("ALLOW_DP_LESS")'><img src="../../../images/update.gif" width="60" height="26" border="0"></a>	  </td>
    </tr>
<%if(strSchoolCode.startsWith("CIT")){%>
    <tr>
      <td height="24" class="thinborderLEFT">&nbsp;Claim Final Study Load After:</td>
      <td colspan="2" class="thinborderRIGHT">
        <% if (vRetResult != null) iIndex= vRetResult.indexOf("CIT_CLAIM_OFFICIAL_LOAD");
   else iIndex = -1;
   
   if (iIndex != -1){ strTemp = (String)vRetResult.elementAt(iIndex+1);
    vRetResult.removeElementAt(iIndex);
    vRetResult.removeElementAt(iIndex);
   }else strTemp = WI.fillTextValue("CIT_CLAIM_OFFICIAL_LOAD");
%>
        <input name="CIT_CLAIM_OFFICIAL_LOAD" type="text" size="2" maxlength="2"   class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"value="<%=strTemp%>">
        <a href='javascript:UpdateProp("CIT_CLAIM_OFFICIAL_LOAD")'><img src="../../../images/update.gif" width="60" height="26" border="0"></a> 
        <font size="1" color="#0000FF">Note: Enter number of days after student can claim Official Load</font></td>
    </tr>
<%}%>
    <tr>
      <td height="24" class="thinborderLEFT">&nbsp;Online Advising for specific Sy/Term:</td>
      <td colspan="2" class="thinborderRIGHT">
<% 
   	if (vRetResult != null) 
		iIndex= vRetResult.indexOf("ONLINE_ADVISE_SYTERM");
	else 
		iIndex = -1;
   
   	if (iIndex != -1) {
		strTemp = (String)vRetResult.elementAt(iIndex+1);
		vRetResult.removeElementAt(iIndex);
		vRetResult.removeElementAt(iIndex);
   	}
   	else 
		strTemp = WI.fillTextValue("ONLINE_ADVISE_SYTERM");
%> 
      <input name="ONLINE_ADVISE_SYTERM" type="text" size="7" maxlength="6"   class="textbox"
		  onfocus="style.backgroundColor='#D3EBFF'" 
		  onBlur="AllowOnlyIntegerExtn('form_','ONLINE_ADVISE_SYTERM','-');ValidatePreEnrolmentData(document.form_.ONLINE_ADVISE_SYTERM); style.backgroundColor='white'" value="<%=strTemp%>"
		  onKeyUP="AllowOnlyIntegerExtn('form_','ONLINE_ADVISE_SYTERM','-')">
		  <a href='javascript:UpdateProp("ONLINE_ADVISE_SYTERM")'><img src="../../../images/update.gif" width="60" height="26" border="0"></a> 
        <font size="1" color="#0000FF">
			(If Specific SY/Term doesn't have value, the functionality is disabled. SY-Term Format: 2006-1, 2006-2, 2006-0)	  </td>
    </tr>
    <tr>
      <td height="24" class="thinborderLEFT">&nbsp;Invalidate Advising:</td>
      <td colspan="2" class="thinborderRIGHT">
        <% if (vRetResult != null) iIndex= vRetResult.indexOf("REMOVE_ADVISING_SUB");
   else iIndex = -1;
   
   if (iIndex != -1){ strTemp = (String)vRetResult.elementAt(iIndex+1);
    vRetResult.removeElementAt(iIndex);
    vRetResult.removeElementAt(iIndex);
   }else strTemp = WI.fillTextValue("REMOVE_ADVISING_SUB");
%>
        <input name="REMOVE_ADVISING_SUB" type="text" size="5" maxlength="5"   class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"value="<%=strTemp%>">
        <a href='javascript:UpdateProp("REMOVE_ADVISING_SUB")'><img src="../../../images/update.gif" width="60" height="26" border="0"></a> 
        <font size="1" color="#0000FF">NOTE : Advising will be invalidated if 
        no downpayment paid within specified number of days - Holidays/saturday/sundays are included. </font></td>
    </tr>
    <tr>
      <td height="24" class="thinborderLEFT">&nbsp;Consider Hours in Invalidating  Advising:</td>
      <td colspan="2" class="thinborderRIGHT">
 <% if (vRetResult != null) iIndex= vRetResult.indexOf("REMOVE_ADV_SUB_CONSIDER_HR");
   else iIndex = -1;
   
   if (iIndex != -1) {strTemp = (String)vRetResult.elementAt(iIndex+1);
    vRetResult.removeElementAt(iIndex);
    vRetResult.removeElementAt(iIndex);
   }else strTemp = WI.fillTextValue("REMOVE_ADV_SUB_CONSIDER_HR");
%> <select name="REMOVE_ADV_SUB_CONSIDER_HR" >
          <option value="1">Yes</option>
          <% if (strTemp.equals("0")){%>
          <option value="0" selected>No</option>
          <%}else{%>
          <option value="0">No</option>
          <%}%>
        </select> <a href='javascript:UpdateProp("REMOVE_ADV_SUB_CONSIDER_HR")'><img src="../../../images/update.gif" width="60" height="26" border="0"></a>		</td>
    </tr>
    <tr> 
      <td height="24" class="thinborderLEFT">&nbsp;Send Email :</td>
      <td colspan="2" class="thinborderRIGHT"> <% if (vRetResult != null) iIndex= vRetResult.indexOf("sendmail");
   else iIndex = -1;
   
   if (iIndex != -1) {strTemp = (String)vRetResult.elementAt(iIndex+1);
    vRetResult.removeElementAt(iIndex);
    vRetResult.removeElementAt(iIndex);
   }else strTemp = WI.fillTextValue("sendmail");
%> <select name="sendmail" >
          <option value="1">Yes</option>
          <% if (strTemp.equals("0")){%>
          <option value="0" selected>No</option>
          <%}else{%>
          <option value="0">No</option>
          <%}%>
        </select> <a href='javascript:UpdateProp("sendmail")'><img src="../../../images/update.gif" width="60" height="26" border="0"></a></td>
    </tr>
    <tr> 
      <td height="25" class="thinborderLEFT" valign="top"><br>
        &nbsp;Content <br>
        (Email for online registration)</td>
      <td colspan="2" class="thinborderRIGHT"> <% if (vRetResult != null) iIndex= vRetResult.indexOf("content");
   else iIndex = -1;
   
   if (iIndex != -1) {strTemp = (String)vRetResult.elementAt(iIndex+1);
    vRetResult.removeElementAt(iIndex);
    vRetResult.removeElementAt(iIndex);
   }else strTemp = WI.fillTextValue("content");
%> <textarea name="content" cols="48"  class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"rows="3"><%=strTemp%></textarea> 
        <a href='javascript:UpdateProp("content")'><img src="../../../images/update.gif" width="60" height="26" border="0"></a><br>      </td>
    </tr>
    <tr>
      <td height="25" class="thinborderLEFT">Allow Summer Enrollee to Enroll in 1st Sem </td>
      <td colspan="2" class="thinborderRIGHT">
<% if (vRetResult != null) iIndex= vRetResult.indexOf("ALLOW_SUMMER_STUDENT_TO_ENROLL_1ST_SEM");
   else iIndex = -1;
   
   if (iIndex != -1){ strTemp = (String)vRetResult.elementAt(iIndex+1);
    vRetResult.removeElementAt(iIndex);
    vRetResult.removeElementAt(iIndex);
   }else strTemp = WI.fillTextValue("ALLOW_SUMMER_STUDENT_TO_ENROLL_1ST_SEM");
%>
        <input name="ALLOW_SUMMER_STUDENT_TO_ENROLL_1ST_SEM" type="text" size="7" maxlength="6"   class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" 
	  onBlur="AllowOnlyIntegerExtn('form_','ALLOW_SUMMER_STUDENT_TO_ENROLL_1ST_SEM','-'); style.backgroundColor='white'" value="<%=strTemp%>"
	  onKeyUP="AllowOnlyIntegerExtn('form_','ALLOW_SUMMER_STUDENT_TO_ENROLL_1ST_SEM', '-')">
        <a href='javascript:UpdateProp("ALLOW_SUMMER_STUDENT_TO_ENROLL_1ST_SEM")'><img src="../../../images/update.gif" width="60" height="26" border="0"></a> <font size="1" color="#0000FF">NOTE : Leave it blank or set to -1 if not implemented </font>	  </td>
    </tr>
    <tr>
      <td height="25" class="thinborderLEFT">Implement Prereq. for Specific Yr Level</td>
      <td colspan="2" class="thinborderRIGHT">
<% if (vRetResult != null) iIndex= vRetResult.indexOf("PREREQUISITE_ALLOWED");
   else iIndex = -1;
   
   if (iIndex != -1){ strTemp = (String)vRetResult.elementAt(iIndex+1);
    vRetResult.removeElementAt(iIndex);
    vRetResult.removeElementAt(iIndex);
   }else strTemp = WI.fillTextValue("PREREQUISITE_ALLOWED");
%>
        <input name="PREREQUISITE_ALLOWED" type="text" size="12" maxlength="16"   class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=strTemp%>">
        <a href='javascript:UpdateProp("PREREQUISITE_ALLOWED")'><img src="../../../images/update.gif" width="60" height="26" border="0"></a> <font size="1" color="#0000FF">NOTE : Leave it blank or set to -1 if not implemented.Use format 1,2,3 </font>	  </td>
    </tr>
    <tr>
      <td height="25" class="thinborderLEFT">Allow Student to View Class Program</td>
      <td colspan="2" class="thinborderRIGHT">
        <% if (vRetResult != null) iIndex= vRetResult.indexOf("STUDENT_VIEW_CLASSPROG");
   else iIndex = -1;
   
   if (iIndex != -1) {strTemp = (String)vRetResult.elementAt(iIndex+1);
    vRetResult.removeElementAt(iIndex);
    vRetResult.removeElementAt(iIndex);
   }else strTemp = WI.fillTextValue("STUDENT_VIEW_CLASSPROG");
%>
        <select name="STUDENT_VIEW_CLASSPROG" >
          <option value="0">No</option>
          <% if (strTemp.equals("1")){%>
          <option value="1" selected>Yes</option>
          <%}else{%>
          <option value="1">Yes</option>
          <%}%>
        </select> <a href='javascript:UpdateProp("STUDENT_VIEW_CLASSPROG")'><img src="../../../images/update.gif" width="60" height="26" border="0"></a>	  </td>
    </tr>
    <tr>
      <td height="25" class="thinborderBOTTOMLEFT" valign="top">PRE-Enrollment<br>
      (SY-Term)<a name="pre-enrol"></a></td>
      <td colspan="2" class="thinborderBOTTOMRIGHT">
<% if (vRetResult != null) iIndex= vRetResult.indexOf("PRE_ENROLLMENT_SYTERM");
   else iIndex = -1;
   
   if (iIndex != -1){ strTemp = (String)vRetResult.elementAt(iIndex+1);
    vRetResult.removeElementAt(iIndex);
    vRetResult.removeElementAt(iIndex);
   }else strTemp = WI.fillTextValue("PRE_ENROLLMENT_SYTERM");
%>
        <input name="PRE_ENROLLMENT_SYTERM" type="text" size="7" maxlength="6"   class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" 
	  onBlur="AllowOnlyIntegerExtn('form_','PRE_ENROLLMENT_SYTERM','-');ValidatePreEnrolmentData(document.form_.PRE_ENROLLMENT_SYTERM); style.backgroundColor='white'" value="<%=strTemp%>"
	  onKeyUP="AllowOnlyIntegerExtn('form_','PRE_ENROLLMENT_SYTERM','-')">
        <a href='javascript:UpdateProp("PRE_ENROLLMENT_SYTERM")'><img src="../../../images/update.gif" width="60" height="26" border="0"></a> <font size="1" color="#0000FF">NOTE : Active Pre-enrollment SY-Term  : 2006-1 , 2006-2, 2006-0 </font>	  </td>
    </tr>
    <tr> 
      <td height="18">&nbsp;</td>
      <td colspan="2">&nbsp;</td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#F2E9D7"> 
      <td height="25" colspan="3" class="thinborderALL"><strong>&nbsp;Internet 
        Cafe Options</strong></td>
    </tr>
    <tr>
      <td height="25" class="thinborderLEFT">&nbsp;I-Cafe login applicable to 
        staff</td>
      <td colspan="2" class="thinborderRIGHT">
        <% if (vRetResult != null) iIndex= vRetResult.indexOf("ICAFE_STAFF");
   else iIndex = -1;
   
   if (iIndex != -1) {strTemp = (String)vRetResult.elementAt(iIndex+1);
    vRetResult.removeElementAt(iIndex);
    vRetResult.removeElementAt(iIndex);
   }else strTemp = WI.fillTextValue("ICAFE_STAFF");
%>
        <select name="ICAFE_STAFF" >
          <option value="1">Yes</option>
          <% if (strTemp.equals("0")){%>
          <option value="0" selected>No</option>
          <%}else{%>
          <option value="0">No</option>
          <%}%>
        </select> <a href='javascript:UpdateProp("ICAFE_STAFF")'><img src="../../../images/update.gif" width="60" height="26" border="0"></a></td>
    </tr>
    <tr> 
      <td height="25" class="thinborderLEFT"> &nbsp;Default Internet Time</td>
      <td colspan="2" class="thinborderRIGHT"> <% if (vRetResult != null) iIndex= vRetResult.indexOf("default_Inet_time");
   else iIndex = -1;
   
   if (iIndex != -1){ strTemp = (String)vRetResult.elementAt(iIndex+1);
    vRetResult.removeElementAt(iIndex);
    vRetResult.removeElementAt(iIndex);
   }else strTemp = WI.fillTextValue("default_Inet_time");
%> <input name="default_Inet_time" type="text" size="5" maxlength="5"   class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"value="<%=strTemp%>"> 
        <a href='javascript:UpdateProp("default_Inet_time")'><img src="../../../images/update.gif" width="60" height="26" border="0"></a> 
      </td>
    </tr>
    <tr> 
      <td height="25" class="thinborderLEFT">&nbsp;Internet Card Time</td>
      <td colspan="2" class="thinborderRIGHT"> <% if (vRetResult != null) iIndex= vRetResult.indexOf("unit_Inet_time");
   else iIndex = -1;
   
   if (iIndex != -1) {strTemp = (String)vRetResult.elementAt(iIndex+1);
    vRetResult.removeElementAt(iIndex);
    vRetResult.removeElementAt(iIndex);
   }else strTemp = WI.fillTextValue("unit_Inet_time");
%> <input name="unit_Inet_time" type="text"  size="5" maxlength="5"   class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"value="<%=strTemp%>"> 
        <a href='javascript:UpdateProp("unit_Inet_time")'><img src="../../../images/update.gif" width="60" height="26" border="0"></a></td>
    </tr>
    <tr> 
      <td width="25%" height="25" class="thinborderBOTTOMLEFT">&nbsp;Internet 
        Fee Name </td>
      <td width="75%" colspan="2" class="thinborderBOTTOMRIGHT"> <% if (vRetResult != null) iIndex= vRetResult.indexOf("Inet_fee_name");
   else iIndex = -1;
   
   if (iIndex != -1) {strTemp = (String)vRetResult.elementAt(iIndex+1);
    vRetResult.removeElementAt(iIndex);
    vRetResult.removeElementAt(iIndex);
   }else strTemp = WI.fillTextValue("Inet_fee_name");
%> <input name="Inet_fee_name" type="text"  size="48"  value="<%=strTemp%>"  class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"> 
      <a href='javascript:UpdateProp("Inet_fee_name")'><img src="../../../images/update.gif" width="60" height="26" border="0"></a></td>
    </tr>
<%}%>
    <tr> 
      <td height="25" colspan="3">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25" colspan="3" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
<input type="hidden" name="info_index">
<input type="hidden" name="update_info" value="0">
<input type="hidden" name="update_specific">

<input type="hidden" name="update_sp_table">
<input type="hidden" name="update_sp_field">
<input type="hidden" name="update_con">

</form>
</body>
</html>
