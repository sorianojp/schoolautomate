<%@ page language="java" import="utility.*,java.util.Vector,chedReport.FNew"%>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);

	String strErrMsg = null;
	String strTemp = null;

//authenticate this user.
	int iAccessLevel = 0;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("REGISTRAR MANAGEMENT-REPORTS"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("REGISTRAR MANAGEMENT"),"0"));
		}
	}

	if(iAccessLevel == -1)//for fatal error.
	{
		request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		request.getSession(false).setAttribute("errorMessage","Please login to access this page.");
		response.sendRedirect("../../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0)//NOT AUTHORIZED.
	{
		response.sendRedirect("../../../commfile/unauthorized_page.jsp");
		return;
	}
//end of authenticaion code.

	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
							"Admin/staff-CHED REPORTS-CHED FORM F","ched_form_f_new.jsp");
	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		if(strErrMsg == null)
		strErrMsg = "Error in opening DB Connection.";
		%>

		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		  Error in opening connection </font></p>
		<%
		return;
	}
	
Vector vRetResult = null;
if(WI.fillTextValue("sy_from").length() > 0) {
	FNew fNew = new FNew();
	vRetResult = fNew.getFInfo(dbOP, request);
	if(vRetResult == null) 
		strErrMsg = fNew.getErrMsg();
}
	
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>CHED E-FORM B/C</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<style>
.body_font{
	font-size:11px;
}
</style>
</head>
<script language="JavaScript" src="../../../Ajax/ajax.js"></script>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript">
//all ajax operation here. 
function AjaxUpdateYesNo(strFieldName, objField, lblName) {
	var strNewVal = objField.selectedIndex;
	var objCOAInput = document.getElementById(lblName);
	this.InitXmlHttpObject(objCOAInput, 2);//I want to get innerHTML in this.retObj
	if(this.xmlHttp == null) {
		alert("Failed to init xmlHttp.");
		return;
	}
	var strURL = "../../../Ajax/AjaxInterface.jsp?methodRef=204&updateType=0&filed_val="+strNewVal+"&sy_from="+
		document.form_.sy_from.value+"&field="+strFieldName;
	//alert(strURL);
	this.processRequest(strURL);
}
var strPrevVal;
function InitVal(objField) {
	strPrevVal = objField.value;
}
function AjaxUpdateDigit(strFieldName, objField, lblName) {//integer or money update.. 
	var strNewVal = objField.value;
	//alert("Prev Val : "+strPrevVal+" New Val : "+strNewVal);
	
	if(strPrevVal == strNewVal)
		return;
		
	var objCOAInput = document.getElementById(lblName);
	this.InitXmlHttpObject(objCOAInput, 2);//I want to get innerHTML in this.retObj
	if(this.xmlHttp == null) {
		alert("Failed to init xmlHttp.");
		return;
	}
	var strURL = "../../../Ajax/AjaxInterface.jsp?methodRef=204&updateType=1&filed_val="+strNewVal+"&sy_from="+
		document.form_.sy_from.value+"&field="+strFieldName;
	this.processRequest(strURL);
}
function AjaxUpdateChkBox(strFieldName, objField, lblName) {
	var strNewVal = "0";
	if(objField.checked)
		strNewVal = "1";
		
	var objCOAInput = document.getElementById(lblName);
	this.InitXmlHttpObject(objCOAInput, 2);//I want to get innerHTML in this.retObj
	if(this.xmlHttp == null) {
		alert("Failed to init xmlHttp.");
		return;
	}
	var strURL = "../../../Ajax/AjaxInterface.jsp?methodRef=204&updateType=0&filed_val="+strNewVal+"&sy_from="+
		document.form_.sy_from.value+"&field="+strFieldName;
	this.processRequest(strURL);
}
function AjaxUpdateText(strFieldName, objField, lblName) {//integer or money update.. 
	var strNewVal = objField.value;
	if(strPrevVal == strNewVal)
		return;
		
	var objCOAInput = document.getElementById(lblName);
	this.InitXmlHttpObject(objCOAInput, 2);//I want to get innerHTML in this.retObj
	if(this.xmlHttp == null) {
		alert("Failed to init xmlHttp.");
		return;
	}
	var strURL = "../../../Ajax/AjaxInterface.jsp?methodRef=204&updateType=1&filed_val="+escape(strNewVal)+"&sy_from="+
		document.form_.sy_from.value+"&field="+strFieldName;
	this.processRequest(strURL);
}
</script>
<body>
<form name="form_" action="./ched_form_f_new.jsp" method="post" onSubmit="SubmitOnceButton(this);">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A"> 
      <td height="25" colspan="2"><div align="center"><font color="#FFFFFF" size="2" face="Arial, Helvetica, sans-serif"><strong>CHED FORM F DATA </strong> </font></div></td>
    </tr>
    <tr> 
      <td height="25" colspan="2">&nbsp; <%=WI.getStrValue(strErrMsg,"<font size=\"3\" color=\"#FF0000\">","</font>", "")%></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="2">
    <tr> 
      <td width="16%" height="25" class="body_font">&nbsp;Academic Year</td>
      <td width="84%"> 
<% 
strTemp = WI.fillTextValue("sy_from");
if (strTemp.length()  < 4){
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
}
%> 
<input name="sy_from" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        &nbsp;&nbsp; &nbsp;
		<input type="submit" name="_" value="Proceed >>>">	  </td>
    </tr>
    <tr>
      <td height="25" colspan="2" class="body_font" style="font-weight:bold; color:#0000FF">Note : If there is any change in the value, pls edit it before printing.. </td>
    </tr>
    <tr>
      <td height="25" colspan="2" class="body_font" align="right"><a href="./ched_form_f_new_print.jsp?sy_from=<%=WI.fillTextValue("sy_from")%>"><img src="../../../images/print.gif" border="0"></a> Print page</td>
    </tr>
  </table>
<br>
<br>
<%if(vRetResult != null && vRetResult.size() > 0) {
int iSYFrom = Integer.parseInt(WI.getStrValue(WI.fillTextValue("sy_from"), "0"));%>
	<table width="100%" border="0" cellpadding="0" cellspacing="0">
		<tr>
		  <td width="100%" height="25" class="body_font" style="font-weight:bold">A. STUDENT's SELECTIVITY</td>
		</tr>
		<tr>
		  <td height="25" class="body_font">1. Do you have Qualifying Examination in choosing your freshmen students?
			<select name="QUALIFYING_EXAM_NEW" onChange="AjaxUpdateYesNo('QUALIFYING_EXAM_NEW',document.form_.QUALIFYING_EXAM_NEW,'lbl_1')">
			<option value="0">No</option>
<%
strTemp = (String)vRetResult.elementAt(0);
if(strTemp != null && strTemp.equals("1"))
	strTemp = " selected";
else	
	strTemp = "";
%>	  			<option value="1"<%=strTemp%>>Yes</option>
		    </select>		  
			 <label id="lbl_1"></label>
		  </td>
	  </tr>
		<tr>
		  <td height="25" class="body_font">
		  	<table width="100%" cellpadding="0" cellspacing="0" class="thinborder">
				 <tr bgcolor="#99CCCC">
				 	<td width="2%" class="thinborder">&nbsp;</td>
					<td width="49%" class="thinborder">Student's Selectivity</td>
					<td width="8%" align="center" class="thinborder">Pre-bacc <br>(a)</td>
					<td width="12%" align="center" class="thinborder">Undergraduate <br>(b)</td>
					<td width="8%" align="center" class="thinborder">Post-bacc <br>(c)</td>
					<td width="7%" align="center" class="thinborder">Master's <br>(d)</td>
					<td width="8%" align="center" class="thinborder">Doctorate <br>(e)</td>
				 </tr>
				 <tr>
				   <td class="thinborder">2.</td>
				   <td class="thinborder">How many students applied for first year undergraduate, master's,
			       doctorate in your institutions for AY <%=iSYFrom%>-<%=iSYFrom + 1%>?</td>
				   <td align="center" class="thinborder">
<%
strTemp = WI.getStrValue(vRetResult.elementAt(1), "0");
%>				   <input type="text" name="APPLIED_EXAM_PREBAC" class="textbox" onFocus="InitVal(document.form_.APPLIED_EXAM_PREBAC);style.backgroundColor='#D3EBFF'" value="<%=strTemp%>" size="4"
				   onBlur="AllowOnlyInteger('form_','APPLIED_EXAM_PREBAC');AjaxUpdateDigit('APPLIED_EXAM_PREBAC',document.form_.APPLIED_EXAM_PREBAC,'lbl_2');style.backgroundColor='white'" onKeyUp="AllowOnlyInteger('form_','APPLIED_EXAM_PREBAC')">
				   <label id="lbl_2"></label>				   </td>
				   <td align="center" class="thinborder">
<%
strTemp = WI.getStrValue(vRetResult.elementAt(2), "0");
%>				   <input type="text" name="APPLIED_EXAM_UG" class="textbox" onFocus="InitVal(document.form_.APPLIED_EXAM_UG);style.backgroundColor='#D3EBFF'" value="<%=strTemp%>" size="4"
				   onBlur="AllowOnlyInteger('form_','APPLIED_EXAM_UG');AjaxUpdateDigit('APPLIED_EXAM_UG',document.form_.APPLIED_EXAM_UG,'lbl_3');style.backgroundColor='white'" onKeyUp="AllowOnlyInteger('form_','APPLIED_EXAM_UG')">
				   <label id="lbl_3"></label>				   </td>
				   <td align="center" class="thinborder">
<%
strTemp = WI.getStrValue(vRetResult.elementAt(3), "0");
%>				   <input type="text" name="APPLIED_EXAM_POSTBAC" class="textbox" onFocus="InitVal(document.form_.APPLIED_EXAM_POSTBAC);style.backgroundColor='#D3EBFF'" value="<%=strTemp%>" size="4"
				   onBlur="AllowOnlyInteger('form_','APPLIED_EXAM_POSTBAC');AjaxUpdateDigit('APPLIED_EXAM_POSTBAC',document.form_.APPLIED_EXAM_POSTBAC,'lbl_4');style.backgroundColor='white'" onKeyUp="AllowOnlyInteger('form_','APPLIED_EXAM_POSTBAC')">
				   <label id="lbl_4"></label>				   </td>
				   <td align="center" class="thinborder">
<%
strTemp = WI.getStrValue(vRetResult.elementAt(4), "0");
%>				   <input type="text" name="APPLIED_EXAM_MASTER" class="textbox" onFocus="InitVal(document.form_.APPLIED_EXAM_MASTER);style.backgroundColor='#D3EBFF'" value="<%=strTemp%>" size="4"
				   onBlur="AllowOnlyInteger('form_','APPLIED_EXAM_MASTER');AjaxUpdateDigit('APPLIED_EXAM_MASTER',document.form_.APPLIED_EXAM_MASTER,'lbl_5');style.backgroundColor='white'" onKeyUp="AllowOnlyInteger('form_','APPLIED_EXAM_MASTER')">
				   <label id="lbl_5"></label>				   </td>
				   <td align="center" class="thinborder">
<%
strTemp = WI.getStrValue(vRetResult.elementAt(5), "0");
%>				   <input type="text" name="APPLIED_EXAM_DOCTOR" class="textbox" onFocus="InitVal(document.form_.APPLIED_EXAM_DOCTOR);style.backgroundColor='#D3EBFF'" value="<%=strTemp%>" size="4"
				   onBlur="AllowOnlyInteger('form_','APPLIED_EXAM_DOCTOR');AjaxUpdateDigit('APPLIED_EXAM_DOCTOR',document.form_.APPLIED_EXAM_DOCTOR,'lbl_6');style.backgroundColor='white'" onKeyUp="AllowOnlyInteger('form_','APPLIED_EXAM_DOCTOR')">
				   <label id="lbl_6"></label>				   </td>
		      </tr>
				 <tr>
				   <td class="thinborder">3.</td>
				   <td class="thinborder">How many qualified in the examination?</td>
				   <td align="center" class="thinborder">
<%
strTemp = WI.getStrValue(vRetResult.elementAt(6), "0");
%>				   <input type="text" name="QUALIFIED_EXAM_PREBAC" class="textbox" onFocus="InitVal(document.form_.QUALIFIED_EXAM_PREBAC);style.backgroundColor='#D3EBFF'" value="<%=strTemp%>" size="4"
				   onBlur="AllowOnlyInteger('form_','QUALIFIED_EXAM_PREBAC');AjaxUpdateDigit('QUALIFIED_EXAM_PREBAC',document.form_.QUALIFIED_EXAM_PREBAC,'lbl_7');style.backgroundColor='white'" onKeyUp="AllowOnlyInteger('form_','QUALIFIED_EXAM_PREBAC')">
				   <label id="lbl_7"></label>				   </td>
				   <td align="center" class="thinborder">
<%
strTemp = WI.getStrValue(vRetResult.elementAt(7), "0");
%>				   <input type="text" name="QUALIFIED_EXAM_UG" class="textbox" onFocus="InitVal(document.form_.QUALIFIED_EXAM_UG);style.backgroundColor='#D3EBFF'" value="<%=strTemp%>" size="4"
				   onBlur="AllowOnlyInteger('form_','QUALIFIED_EXAM_UG');AjaxUpdateDigit('QUALIFIED_EXAM_UG',document.form_.QUALIFIED_EXAM_UG,'lbl_8');style.backgroundColor='white'" onKeyUp="AllowOnlyInteger('form_','QUALIFIED_EXAM_UG')">
				   <label id="lbl_8"></label>				   </td>
				   <td align="center" class="thinborder">
<%
strTemp = WI.getStrValue(vRetResult.elementAt(8), "0");
%>				   <input type="text" name="QUALIFIED_EXAM_POSTBAC" class="textbox" onFocus="InitVal(document.form_.QUALIFIED_EXAM_POSTBAC);style.backgroundColor='#D3EBFF'" value="<%=strTemp%>" size="4"
				   onBlur="AllowOnlyInteger('form_','QUALIFIED_EXAM_POSTBAC');AjaxUpdateDigit('QUALIFIED_EXAM_POSTBAC',document.form_.QUALIFIED_EXAM_POSTBAC,'lbl_9');style.backgroundColor='white'" onKeyUp="AllowOnlyInteger('form_','QUALIFIED_EXAM_POSTBAC')">
				   <label id="lbl_9"></label>				   </td>
				   <td align="center" class="thinborder">
<%
strTemp = WI.getStrValue(vRetResult.elementAt(9), "0");
%>				   <input type="text" name="QUALIFIED_EXAM_MASTER" class="textbox" onFocus="InitVal(document.form_.QUALIFIED_EXAM_MASTER);style.backgroundColor='#D3EBFF'" value="<%=strTemp%>" size="4"
				   onBlur="AllowOnlyInteger('form_','APPLIED_EXAM_MASTER');AjaxUpdateDigit('QUALIFIED_EXAM_MASTER',document.form_.QUALIFIED_EXAM_MASTER,'lbl_10');style.backgroundColor='white'" onKeyUp="AllowOnlyInteger('form_','QUALIFIED_EXAM_MASTER')">
				   <label id="lbl_10"></label>				   </td>
				   <td align="center" class="thinborder">
<%
strTemp = WI.getStrValue(vRetResult.elementAt(10), "0");
%>				   <input type="text" name="QUALIFIED_EXAM_DOCTOR" class="textbox" onFocus="InitVal(document.form_.QUALIFIED_EXAM_DOCTOR);style.backgroundColor='#D3EBFF'" value="<%=strTemp%>" size="4"
				   onBlur="AllowOnlyInteger('form_','QUALIFIED_EXAM_DOCTOR');AjaxUpdateDigit('QUALIFIED_EXAM_DOCTOR',document.form_.QUALIFIED_EXAM_DOCTOR,'lbl_11');style.backgroundColor='white'" onKeyUp="AllowOnlyInteger('form_','QUALIFIED_EXAM_DOCTOR')">
				   <label id="lbl_11"></label>				   </td>
		      </tr>
				 <tr>
				   <td class="thinborder">4.</td>
				   <td class="thinborder">How many of those who qualified actually enrolled for the first semester
			       for AY <%=iSYFrom%>-<%=iSYFrom + 1%>?</td>
				   <td align="center" class="thinborder">
<%
strTemp = WI.getStrValue(vRetResult.elementAt(11), "0");
%>				   <input type="text" name="ENROLLED_EXAM_PREBAC" class="textbox" onFocus="InitVal(document.form_.ENROLLED_EXAM_PREBAC);style.backgroundColor='#D3EBFF'" value="<%=strTemp%>" size="4"
				   onBlur="AllowOnlyInteger('form_','ENROLLED_EXAM_PREBAC');AjaxUpdateDigit('ENROLLED_EXAM_PREBAC',document.form_.ENROLLED_EXAM_PREBAC,'lbl_12');style.backgroundColor='white'" onKeyUp="AllowOnlyInteger('form_','ENROLLED_EXAM_PREBAC')">
				   <label id="lbl_12"></label>				   </td>
				   <td align="center" class="thinborder">
<%
strTemp = WI.getStrValue(vRetResult.elementAt(12), "0");
%>				   <input type="text" name="ENROLLED_EXAM_UG" class="textbox" onFocus="InitVal(document.form_.ENROLLED_EXAM_UG);style.backgroundColor='#D3EBFF'" value="<%=strTemp%>" size="4"
				   onBlur="AllowOnlyInteger('form_','ENROLLED_EXAM_UG');AjaxUpdateDigit('ENROLLED_EXAM_UG',document.form_.ENROLLED_EXAM_UG,'lbl_13');style.backgroundColor='white'" onKeyUp="AllowOnlyInteger('form_','ENROLLED_EXAM_UG')">
				   <label id="lbl_13"></label>				   </td>
				   <td align="center" class="thinborder">
<%
strTemp = WI.getStrValue(vRetResult.elementAt(13), "0");
%>				   <input type="text" name="ENROLLED_EXAM_POSTBAC" class="textbox" onFocus="InitVal(document.form_.ENROLLED_EXAM_POSTBAC);style.backgroundColor='#D3EBFF'" value="<%=strTemp%>" size="4"
				   onBlur="AllowOnlyInteger('form_','ENROLLED_EXAM_POSTBAC');AjaxUpdateDigit('ENROLLED_EXAM_POSTBAC',document.form_.ENROLLED_EXAM_POSTBAC,'lbl_14');style.backgroundColor='white'" onKeyUp="AllowOnlyInteger('form_','ENROLLED_EXAM_POSTBAC')">
				   <label id="lbl_14"></label>				   </td>
				   <td align="center" class="thinborder">
<%
strTemp = WI.getStrValue(vRetResult.elementAt(14), "0");
%>				   <input type="text" name="ENROLLED_EXAM_MASTER" class="textbox" onFocus="InitVal(document.form_.ENROLLED_EXAM_MASTER);style.backgroundColor='#D3EBFF'" value="<%=strTemp%>" size="4"
				   onBlur="AllowOnlyInteger('form_','ENROLLED_EXAM_MASTER');AjaxUpdateDigit('ENROLLED_EXAM_MASTER',document.form_.ENROLLED_EXAM_MASTER,'lbl_15');style.backgroundColor='white'" onKeyUp="AllowOnlyInteger('form_','ENROLLED_EXAM_MASTER')">
				   <label id="lbl_15"></label>				   </td>
				   <td align="center" class="thinborder">
<%
strTemp = WI.getStrValue(vRetResult.elementAt(15), "0");
%>				   <input type="text" name="ENROLLED_EXAM_DOCTOR" class="textbox" onFocus="InitVal(document.form_.ENROLLED_EXAM_DOCTOR);style.backgroundColor='#D3EBFF'" value="<%=strTemp%>" size="4"
				   onBlur="AllowOnlyInteger('form_','ENROLLED_EXAM_DOCTOR');AjaxUpdateDigit('ENROLLED_EXAM_DOCTOR',document.form_.ENROLLED_EXAM_DOCTOR,'lbl_16');style.backgroundColor='white'" onKeyUp="AllowOnlyInteger('form_','ENROLLED_EXAM_DOCTOR')">
				   <label id="lbl_16"></label>				   </td>
		      </tr>
			</table>		  </td>
	  </tr>
		<tr>
		  <td height="25" class="body_font">5. Do you have Qualifying Examination for transferee?
			<select name="QUALIFYING_EXAM_TRANSFEREE" onChange="AjaxUpdateYesNo('QUALIFYING_EXAM_TRANSFEREE',document.form_.QUALIFYING_EXAM_TRANSFEREE,'lbl_17')">
			<option value="0">No</option>
<%
strTemp = (String)vRetResult.elementAt(16);
if(strTemp != null && strTemp.equals("1"))
	strTemp = " selected";
else	
	strTemp = "";
%>	  			<option value="1"<%=strTemp%>>Yes</option>
		    </select> <label id="lbl_17"></label>
		</td>
	  </tr>
		<tr>
		  <td height="25" class="body_font">6. If NO, but still accepting transferees kindly state the other criteria in accepting transferees:</td>
	  </tr>
		<tr>
		  <td height="25" class="body_font">
		  <table width="100%" cellpadding="0" cellspacing="0">
            <tr>
              <td width="2%">&nbsp;</td>
              <td width="48%">
<%
strTemp = (String)vRetResult.elementAt(17);
if(strTemp != null && strTemp.equals("1"))
	strTemp = " checked";
else	
	strTemp = "";
%>			  <input type="checkbox" name="TRANSFEREE_REQ_TOR" value="1"<%=strTemp%> onClick="AjaxUpdateChkBox('TRANSFEREE_REQ_TOR',document.form_.TRANSFEREE_REQ_TOR,'lbl_18')"><label id="lbl_18"></label> Transcript of Records w/ qualitfied grades</td>
              <td width="50%">
<%
strTemp = (String)vRetResult.elementAt(19);
if(strTemp != null && strTemp.equals("1"))
	strTemp = " checked";
else	
	strTemp = "";
%>			  <input type="checkbox" name="TRANSFEREE_REQ_GMC" value="1"<%=strTemp%> onClick="AjaxUpdateChkBox('TRANSFEREE_REQ_GMC',document.form_.TRANSFEREE_REQ_GMC,'lbl_19')"><label id="lbl_19"></label> Good Moral Character</td>
            </tr>
            <tr>
              <td>&nbsp;</td>
              <td>
<%
strTemp = (String)vRetResult.elementAt(18);
if(strTemp != null && strTemp.equals("1"))
	strTemp = " checked";
else	
	strTemp = "";
%>			  <input type="checkbox" name="TRANSFEREE_REQ_HD" value="1"<%=strTemp%> onClick="AjaxUpdateChkBox('TRANSFEREE_REQ_HD',document.form_.TRANSFEREE_REQ_HD,'lbl_20')"><label id="lbl_20"></label> Honorable Dismissal</td>
              <td>Others
<%
strTemp = WI.getStrValue((String)vRetResult.elementAt(20));
%>			  
			<textarea name="TRANSFEREE_REQ_OTHERS" rows="2" cols="60" style="font-size:11px;" class="textbox" onFocus="InitVal(document.form_.TRANSFEREE_REQ_OTHERS);style.backgroundColor='#D3EBFF'"
				onBlur="AjaxUpdateText('TRANSFEREE_REQ_OTHERS',document.form_.TRANSFEREE_REQ_OTHERS,'lbl_21');style.backgroundColor='white'"><%=strTemp%></textarea>
			<label id="lbl_21"></label>	</td>
            </tr>
          </table></td>
	  </tr>
		<tr>
		  <td height="25" class="body_font">7. How many transferees for AY <%=WI.fillTextValue("sy_from")%> - <%=Integer.parseInt(WI.fillTextValue("sy_from")) + 1%>? (Kindly fill-up the table below.)</td>
	  </tr>
		<tr>
		  <td height="25" class="body_font" align="center">
		  	<table width="40%" cellpadding="0" cellspacing="0" class="thinborder">
            <tr bgcolor="#99CCCC">
              <td width="49%" rowspan="2" class="thinborder">Program Level </td>
              <td colspan="2" align="center" class="thinborder">Coming From </td>
              </tr>
            <tr bgcolor="#99CCCC">
              <td width="8%" align="center" class="thinborder">Private</td>
              <td width="12%" align="center" class="thinborder">Public</td>
              </tr>
            <tr>
              <td class="thinborder">Pre-baccalaureate</td>
              <td align="center" class="thinborder">
<%
strTemp = WI.getStrValue(vRetResult.elementAt(21), "0");
%>				   <input type="text" name="TRANSFEREE_PRIVATE_PREBAC" class="textbox" onFocus="InitVal(document.form_.TRANSFEREE_PRIVATE_PREBAC);style.backgroundColor='#D3EBFF'" value="<%=strTemp%>" size="4"
				   onBlur="AllowOnlyInteger('form_','TRANSFEREE_PRIVATE_PREBAC');AjaxUpdateDigit('TRANSFEREE_PRIVATE_PREBAC',document.form_.TRANSFEREE_PRIVATE_PREBAC,'lbl_22');style.backgroundColor='white'" onKeyUp="AllowOnlyInteger('form_','TRANSFEREE_PRIVATE_PREBAC')">
				   <label id="lbl_22"></label>				   </td>
              <td align="center" class="thinborder">
<%
strTemp = WI.getStrValue(vRetResult.elementAt(26), "0");
%>				   <input type="text" name="TRANSFEREE_PUBLIC_PREBAC" class="textbox" onFocus="InitVal(document.form_.TRANSFEREE_PUBLIC_PREBAC);style.backgroundColor='#D3EBFF'" value="<%=strTemp%>" size="4"
				   onBlur="AllowOnlyInteger('form_','TRANSFEREE_PUBLIC_PREBAC');AjaxUpdateDigit('TRANSFEREE_PUBLIC_PREBAC',document.form_.TRANSFEREE_PUBLIC_PREBAC,'lbl_23');style.backgroundColor='white'" onKeyUp="AllowOnlyInteger('form_','TRANSFEREE_PUBLIC_PREBAC')">
				   <label id="lbl_23"></label>				   </td>
              </tr>
            <tr>
              <td class="thinborder">Baccalaureate</td>
              <td align="center" class="thinborder">
<%
strTemp = WI.getStrValue(vRetResult.elementAt(22), "0");
%>				   <input type="text" name="TRANSFEREE_PRIVATE_BAC" class="textbox" onFocus="InitVal(document.form_.TRANSFEREE_PRIVATE_BAC);style.backgroundColor='#D3EBFF'" value="<%=strTemp%>" size="4"
				   onBlur="AllowOnlyInteger('form_','TRANSFEREE_PRIVATE_BAC');AjaxUpdateDigit('TRANSFEREE_PRIVATE_BAC',document.form_.TRANSFEREE_PRIVATE_BAC,'lbl_24');style.backgroundColor='white'" onKeyUp="AllowOnlyInteger('form_','TRANSFEREE_PRIVATE_BAC')">
				   <label id="lbl_24"></label>				   </td>
              <td align="center" class="thinborder">
<%
strTemp = WI.getStrValue(vRetResult.elementAt(27), "0");
%>				   <input type="text" name="TRANSFEREE_PUBLIC_BAC" class="textbox" onFocus="InitVal(document.form_.TRANSFEREE_PUBLIC_BAC);style.backgroundColor='#D3EBFF'" value="<%=strTemp%>" size="4"
				   onBlur="AllowOnlyInteger('form_','TRANSFEREE_PUBLIC_BAC');AjaxUpdateDigit('TRANSFEREE_PUBLIC_BAC',document.form_.TRANSFEREE_PUBLIC_BAC,'lbl_25');style.backgroundColor='white'" onKeyUp="AllowOnlyInteger('form_','TRANSFEREE_PUBLIC_BAC')">
				   <label id="lbl_25"></label>				   </td>
              </tr>
            <tr>
              <td class="thinborder">Post-baccalaureate</td>
              <td align="center" class="thinborder">
<%
strTemp = WI.getStrValue(vRetResult.elementAt(23), "0");
%>				   <input type="text" name="TRANSFEREE_PRIVATE_POSTBAC" class="textbox" onFocus="InitVal(document.form_.TRANSFEREE_PRIVATE_POSTBAC);style.backgroundColor='#D3EBFF'" value="<%=strTemp%>" size="4"
				   onBlur="AllowOnlyInteger('form_','TRANSFEREE_PRIVATE_POSTBAC');AjaxUpdateDigit('TRANSFEREE_PRIVATE_POSTBAC',document.form_.TRANSFEREE_PRIVATE_POSTBAC,'lbl_26');style.backgroundColor='white'" onKeyUp="AllowOnlyInteger('form_','TRANSFEREE_PRIVATE_POSTBAC')">
				   <label id="lbl_26"></label>				   </td>
              <td align="center" class="thinborder">
<%
strTemp = WI.getStrValue(vRetResult.elementAt(28), "0");
%>				   <input type="text" name="TRANSFEREE_PUBLIC_POSTBAC" class="textbox" onFocus="InitVal(document.form_.TRANSFEREE_PUBLIC_POSTBAC);style.backgroundColor='#D3EBFF'" value="<%=strTemp%>" size="4"
				   onBlur="AllowOnlyInteger('form_','TRANSFEREE_PUBLIC_POSTBAC');AjaxUpdateDigit('TRANSFEREE_PUBLIC_POSTBAC',document.form_.TRANSFEREE_PUBLIC_POSTBAC,'lbl_27');style.backgroundColor='white'" onKeyUp="AllowOnlyInteger('form_','TRANSFEREE_PUBLIC_POSTBAC')">
				   <label id="lbl_27"></label>				   </td>
              </tr>
            <tr>
              <td class="thinborder">Master's</td>
              <td align="center" class="thinborder">
<%
strTemp = WI.getStrValue(vRetResult.elementAt(24), "0");
%>				   <input type="text" name="TRANSFEREE_PRIVATE_MASTER" class="textbox" onFocus="InitVal(document.form_.TRANSFEREE_PRIVATE_MASTER);style.backgroundColor='#D3EBFF'" value="<%=strTemp%>" size="4"
				   onBlur="AllowOnlyInteger('form_','TRANSFEREE_PRIVATE_MASTER');AjaxUpdateDigit('TRANSFEREE_PRIVATE_MASTER',document.form_.TRANSFEREE_PRIVATE_MASTER,'lbl_28');style.backgroundColor='white'" onKeyUp="AllowOnlyInteger('form_','TRANSFEREE_PRIVATE_MASTER')">
				   <label id="lbl_28"></label>				   </td>
              <td align="center" class="thinborder">
<%
strTemp = WI.getStrValue(vRetResult.elementAt(29), "0");
%>				   <input type="text" name="TRANSFEREE_PUBLIC_MASTER" class="textbox" onFocus="InitVal(document.form_.TRANSFEREE_PUBLIC_MASTER);style.backgroundColor='#D3EBFF'" value="<%=strTemp%>" size="4"
				   onBlur="AllowOnlyInteger('form_','TRANSFEREE_PUBLIC_MASTER');AjaxUpdateDigit('TRANSFEREE_PUBLIC_MASTER',document.form_.TRANSFEREE_PUBLIC_MASTER,'lbl_29');style.backgroundColor='white'" onKeyUp="AllowOnlyInteger('form_','TRANSFEREE_PUBLIC_MASTER')">
				   <label id="lbl_29"></label>				   </td>
            </tr>
            <tr>
              <td class="thinborder">Doctorate</td>
              <td align="center" class="thinborder">
<%
strTemp = WI.getStrValue(vRetResult.elementAt(25), "0");
%>				   <input type="text" name="TRANSFEREE_PRIVATE_DOCTOR" class="textbox" onFocus="InitVal(document.form_.TRANSFEREE_PRIVATE_DOCTOR);style.backgroundColor='#D3EBFF'" value="<%=strTemp%>" size="4"
				   onBlur="AllowOnlyInteger('form_','TRANSFEREE_PRIVATE_DOCTOR');AjaxUpdateDigit('TRANSFEREE_PRIVATE_DOCTOR',document.form_.TRANSFEREE_PRIVATE_DOCTOR,'lbl_30');style.backgroundColor='white'" onKeyUp="AllowOnlyInteger('form_','TRANSFEREE_PRIVATE_DOCTOR')">
				   <label id="lbl_30"></label>				   </td>
              <td align="center" class="thinborder">
<%
strTemp = WI.getStrValue(vRetResult.elementAt(30), "0");
%>				   <input type="text" name="TRANSFEREE_PUBLIC_DOCTOR" class="textbox" onFocus="InitVal(document.form_.TRANSFEREE_PUBLIC_DOCTOR);style.backgroundColor='#D3EBFF'" value="<%=strTemp%>" size="4"
				   onBlur="AllowOnlyInteger('form_','TRANSFEREE_PUBLIC_DOCTOR');AjaxUpdateDigit('TRANSFEREE_PUBLIC_DOCTOR',document.form_.TRANSFEREE_PUBLIC_DOCTOR,'lbl_31');style.backgroundColor='white'" onKeyUp="AllowOnlyInteger('form_','TRANSFEREE_PUBLIC_DOCTOR')">
				   <label id="lbl_31"></label>				   </td>
            </tr>
          </table></td>
	  </tr>
		<tr>
		  <td height="25" class="body_font">8. Do you accept foreign students to study in your institution?
			<select name="ACCEPT_FOREIGN_STUD" onChange="AjaxUpdateYesNo('ACCEPT_FOREIGN_STUD',document.form_.ACCEPT_FOREIGN_STUD,'lbl_32')">
			<option value="0">No</option>
<%
strTemp = (String)vRetResult.elementAt(31);
if(strTemp != null && strTemp.equals("1"))
	strTemp = " selected";
else	
	strTemp = "";
%>	  			<option value="1"<%=strTemp%>>Yes</option>
		    </select>	<label id="lbl_32"></label>	  </td>
	  </tr>
		<tr>
		  <td height="25" class="body_font">9. If YES, how many foreign students enrolled for AY <%=iSYFrom%>-<%=iSYFrom + 1%>? 
<%
strTemp = WI.getStrValue(vRetResult.elementAt(32), "0");
%>				   <input type="text" name="FOREIGN_STUD_ENROLLED" class="textbox" onFocus="InitVal(document.form_.FOREIGN_STUD_ENROLLED);style.backgroundColor='#D3EBFF'" value="<%=strTemp%>" size="4"
				   onBlur="AllowOnlyInteger('form_','FOREIGN_STUD_ENROLLED');AjaxUpdateDigit('FOREIGN_STUD_ENROLLED',document.form_.FOREIGN_STUD_ENROLLED,'lbl_33');style.backgroundColor='white'" onKeyUp="AllowOnlyInteger('form_','FOREIGN_STUD_ENROLLED')">
				   <label id="lbl_33"></label>				   </td>
	  </tr>
		<tr>
		  <td height="25" class="body_font" style="font-weight:bold">B. DISTRIBUTION OF STUDENTS by AGE, PROGRAM LEVEL AND GENDER</td>
	  </tr>
		<tr>
		  <td height="25" class="body_font"><table width="100%" cellpadding="0" cellspacing="0" class="thinborder">
            <tr bgcolor="#99CCCC" align="center">
              <td width="7%" rowspan="2" class="thinborder">Age</td>
              <td colspan="2" class="thinborder">Pre-baccalaureate</td>
              <td colspan="2" class="thinborder">Baccalaureate</td>
              <td colspan="2" class="thinborder">Post-baccalaureate</td>
              <td colspan="2" class="thinborder">Master's</td>
              <td colspan="2" class="thinborder">Doctorate</td>
            </tr>
            <tr bgcolor="#99CCCC" align="center">
              <td width="7%" class="thinborder">Male</td>
              <td width="7%" class="thinborder">Female</td>
              <td width="7%" class="thinborder">Male</td>
              <td width="7%" class="thinborder">Female</td>
              <td width="7%" class="thinborder">Male</td>
              <td width="7%" class="thinborder">Female</td>
              <td width="7%" class="thinborder">Male</td>
              <td width="7%" class="thinborder">Female</td>
              <td width="7%" class="thinborder">Male</td>
              <td width="7%" class="thinborder">Female</td>
            </tr>
            <tr align="center">
              <td class="thinborder">down - 16</td>
              <td class="thinborder">
<%
strTemp = WI.getStrValue(vRetResult.elementAt(41), "0");
%>				   <input type="text" name="_16_DOWN_MALE_PREBAC" class="textbox" onFocus="InitVal(document.form_._16_DOWN_MALE_PREBAC);style.backgroundColor='#D3EBFF'" value="<%=strTemp%>" size="4"
				   onBlur="AllowOnlyInteger('form_','_16_DOWN_MALE_PREBAC');AjaxUpdateDigit('_16_DOWN_MALE_PREBAC',document.form_._16_DOWN_MALE_PREBAC,'lbl_34');style.backgroundColor='white'" onKeyUp="AllowOnlyInteger('form_','_16_DOWN_MALE_PREBAC')">
				   <label id="lbl_34"></label>				   </td>
              <td class="thinborder">
<%
strTemp = WI.getStrValue(vRetResult.elementAt(42), "0");
%>				   <input type="text" name="_16_DOWN_FEMALE_PREBAC" class="textbox" onFocus="InitVal(document.form_._16_DOWN_FEMALE_PREBAC);style.backgroundColor='#D3EBFF'" value="<%=strTemp%>" size="4"
				   onBlur="AllowOnlyInteger('form_','_16_DOWN_FEMALE_PREBAC');AjaxUpdateDigit('_16_DOWN_FEMALE_PREBAC',document.form_._16_DOWN_FEMALE_PREBAC,'lbl_35');style.backgroundColor='white'" onKeyUp="AllowOnlyInteger('form_','_16_DOWN_FEMALE_PREBAC')">
				   <label id="lbl_35"></label>				   </td>
              <td class="thinborder">
<%
strTemp = WI.getStrValue(vRetResult.elementAt(43), "0");
%>				   <input type="text" name="_16_DOWN_MALE_BAC" class="textbox" onFocus="InitVal(document.form_._16_DOWN_MALE_BAC);style.backgroundColor='#D3EBFF'" value="<%=strTemp%>" size="4"
				   onBlur="AllowOnlyInteger('form_','_16_DOWN_MALE_BAC');AjaxUpdateDigit('_16_DOWN_MALE_BAC',document.form_._16_DOWN_MALE_BAC,'lbl_36');style.backgroundColor='white'" onKeyUp="AllowOnlyInteger('form_','_16_DOWN_MALE_BAC')">
				   <label id="lbl_36"></label>				   </td>
              <td class="thinborder">
<%
strTemp = WI.getStrValue(vRetResult.elementAt(44), "0");
%>				   <input type="text" name="_16_DOWN_FEMALE_BAC" class="textbox" onFocus="InitVal(document.form_._16_DOWN_FEMALE_BAC);style.backgroundColor='#D3EBFF'" value="<%=strTemp%>" size="4"
				   onBlur="AllowOnlyInteger('form_','_16_DOWN_FEMALE_BAC');AjaxUpdateDigit('_16_DOWN_FEMALE_BAC',document.form_._16_DOWN_FEMALE_BAC,'lbl_37');style.backgroundColor='white'" onKeyUp="AllowOnlyInteger('form_','_16_DOWN_FEMALE_BAC')">
				   <label id="lbl_37"></label>				   </td>
			  
              <td class="thinborder">
<%
strTemp = WI.getStrValue(vRetResult.elementAt(45), "0");
%>				   <input type="text" name="_16_DOWN_MALE_POSTBAC" class="textbox" onFocus="InitVal(document.form_._16_DOWN_MALE_POSTBAC);style.backgroundColor='#D3EBFF'" value="<%=strTemp%>" size="4"
				   onBlur="AllowOnlyInteger('form_','_16_DOWN_MALE_POSTBAC');AjaxUpdateDigit('_16_DOWN_MALE_POSTBAC',document.form_._16_DOWN_MALE_POSTBAC,'lbl_38');style.backgroundColor='white'" onKeyUp="AllowOnlyInteger('form_','_16_DOWN_MALE_POSTBAC')">
				   <label id="lbl_38"></label>				   </td>
              <td class="thinborder">
<%
strTemp = WI.getStrValue(vRetResult.elementAt(46), "0");
%>				   <input type="text" name="_16_DOWN_FEMALE_POSTBAC" class="textbox" onFocus="InitVal(document.form_._16_DOWN_FEMALE_POSTBAC);style.backgroundColor='#D3EBFF'" value="<%=strTemp%>" size="4"
				   onBlur="AllowOnlyInteger('form_','_16_DOWN_FEMALE_POSTBAC');AjaxUpdateDigit('_16_DOWN_FEMALE_POSTBAC',document.form_._16_DOWN_FEMALE_POSTBAC,'lbl_39');style.backgroundColor='white'" onKeyUp="AllowOnlyInteger('form_','_16_DOWN_FEMALE_POSTBAC')">
				   <label id="lbl_39"></label>				   </td>
              <td class="thinborder">
<%
strTemp = WI.getStrValue(vRetResult.elementAt(47), "0");
%>				   <input type="text" name="_16_DOWN_MALE_MASTER" class="textbox" onFocus="InitVal(document.form_._16_DOWN_MALE_MASTER);style.backgroundColor='#D3EBFF'" value="<%=strTemp%>" size="4"
				   onBlur="AllowOnlyInteger('form_','_16_DOWN_MALE_MASTER');AjaxUpdateDigit('_16_DOWN_MALE_MASTER',document.form_._16_DOWN_MALE_MASTER,'lbl_40');style.backgroundColor='white'" onKeyUp="AllowOnlyInteger('form_','_16_DOWN_MALE_MASTER')">
				   <label id="lbl_40"></label>				   </td>
              <td class="thinborder">
<%
strTemp = WI.getStrValue(vRetResult.elementAt(48), "0");
%>				   <input type="text" name="_16_DOWN_FEMALE_MASTER" class="textbox" onFocus="InitVal(document.form_._16_DOWN_FEMALE_MASTER);style.backgroundColor='#D3EBFF'" value="<%=strTemp%>" size="4"
				   onBlur="AllowOnlyInteger('form_','_16_DOWN_FEMALE_MASTER');AjaxUpdateDigit('_16_DOWN_FEMALE_MASTER',document.form_._16_DOWN_FEMALE_MASTER,'lbl_41');style.backgroundColor='white'" onKeyUp="AllowOnlyInteger('form_','_16_DOWN_FEMALE_MASTER')">
				   <label id="lbl_41"></label>				   </td>
              <td class="thinborder">
<%
strTemp = WI.getStrValue(vRetResult.elementAt(49), "0");
%>				   <input type="text" name="_16_DOWN_MALE_DOCTOR" class="textbox" onFocus="InitVal(document.form_._16_DOWN_MALE_DOCTOR);style.backgroundColor='#D3EBFF'" value="<%=strTemp%>" size="4"
				   onBlur="AllowOnlyInteger('form_','_16_DOWN_MALE_DOCTOR');AjaxUpdateDigit('_16_DOWN_MALE_DOCTOR',document.form_._16_DOWN_MALE_DOCTOR,'lbl_42');style.backgroundColor='white'" onKeyUp="AllowOnlyInteger('form_','_16_DOWN_MALE_DOCTOR')">
				   <label id="lbl_42"></label>				   </td>
              <td class="thinborder">
<%
strTemp = WI.getStrValue(vRetResult.elementAt(50), "0");
%>				   <input type="text" name="_16_DOWN_FEMALE_DOCTOR" class="textbox" onFocus="InitVal(document.form_._16_DOWN_FEMALE_DOCTOR);style.backgroundColor='#D3EBFF'" value="<%=strTemp%>" size="4"
				   onBlur="AllowOnlyInteger('form_','_16_DOWN_FEMALE_DOCTOR');AjaxUpdateDigit('_16_DOWN_FEMALE_DOCTOR',document.form_._16_DOWN_FEMALE_DOCTOR,'lbl_43');style.backgroundColor='white'" onKeyUp="AllowOnlyInteger('form_','_16_DOWN_FEMALE_DOCTOR')">
				   <label id="lbl_43"></label>				   </td>
            </tr>
            <tr align="center">
              <td class="thinborder">17 - 20</td>
              <td class="thinborder">
<%
strTemp = WI.getStrValue(vRetResult.elementAt(51), "0");
%>				   <input type="text" name="_1720_MALE_PREBAC" class="textbox" onFocus="InitVal(document.form_._1720_MALE_PREBAC);style.backgroundColor='#D3EBFF'" value="<%=strTemp%>" size="4"
				   onBlur="AllowOnlyInteger('form_','_1720_MALE_PREBAC');AjaxUpdateDigit('_1720_MALE_PREBAC',document.form_._1720_MALE_PREBAC,'lbl_44');style.backgroundColor='white'" onKeyUp="AllowOnlyInteger('form_','_1720_MALE_PREBAC')">
				   <label id="lbl_44"></label>				   </td>
              <td class="thinborder">
<%
strTemp = WI.getStrValue(vRetResult.elementAt(52), "0");
%>				   <input type="text" name="_1720_FEMALE_PREBAC" class="textbox" onFocus="InitVal(document.form_._1720_FEMALE_PREBAC);style.backgroundColor='#D3EBFF'" value="<%=strTemp%>" size="4"
				   onBlur="AllowOnlyInteger('form_','_1720_FEMALE_PREBAC');AjaxUpdateDigit('_1720_FEMALE_PREBAC',document.form_._1720_FEMALE_PREBAC,'lbl_45');style.backgroundColor='white'" onKeyUp="AllowOnlyInteger('form_','_1720_FEMALE_PREBAC')">
				   <label id="lbl_45"></label>				   </td>
              <td class="thinborder">
<%
strTemp = WI.getStrValue(vRetResult.elementAt(53), "0");
%>				   <input type="text" name="_1720_MALE_BAC" class="textbox" onFocus="InitVal(document.form_._1720_MALE_BAC);style.backgroundColor='#D3EBFF'" value="<%=strTemp%>" size="4"
				   onBlur="AllowOnlyInteger('form_','_1720_MALE_BAC');AjaxUpdateDigit('_1720_MALE_BAC',document.form_._1720_MALE_BAC,'lbl_46');style.backgroundColor='white'" onKeyUp="AllowOnlyInteger('form_','_1720_MALE_BAC')">
				   <label id="lbl_46"></label>				   </td>
              <td class="thinborder">
<%
strTemp = WI.getStrValue(vRetResult.elementAt(54), "0");
%>				   <input type="text" name="_1720_FEMALE_BAC" class="textbox" onFocus="InitVal(document.form_._1720_FEMALE_BAC);style.backgroundColor='#D3EBFF'" value="<%=strTemp%>" size="4"
				   onBlur="AllowOnlyInteger('form_','_1720_FEMALE_BAC');AjaxUpdateDigit('_1720_FEMALE_BAC',document.form_._1720_FEMALE_BAC,'lbl_47');style.backgroundColor='white'" onKeyUp="AllowOnlyInteger('form_','_1720_FEMALE_BAC')">
				   <label id="lbl_47"></label>				   </td>
			  
              <td class="thinborder">
<%
strTemp = WI.getStrValue(vRetResult.elementAt(55), "0");
%>				   <input type="text" name="_1720_MALE_POSTBAC" class="textbox" onFocus="InitVal(document.form_._1720_MALE_POSTBAC);style.backgroundColor='#D3EBFF'" value="<%=strTemp%>" size="4"
				   onBlur="AllowOnlyInteger('form_','_1720_MALE_POSTBAC');AjaxUpdateDigit('_1720_MALE_POSTBAC',document.form_._1720_MALE_POSTBAC,'lbl_48');style.backgroundColor='white'" onKeyUp="AllowOnlyInteger('form_','_1720_MALE_POSTBAC')">
				   <label id="lbl_48"></label>				   </td>
              <td class="thinborder">
<%
strTemp = WI.getStrValue(vRetResult.elementAt(56), "0");
%>				   <input type="text" name="_1720_FEMALE_POSTBAC" class="textbox" onFocus="InitVal(document.form_._1720_FEMALE_POSTBAC);style.backgroundColor='#D3EBFF'" value="<%=strTemp%>" size="4"
				   onBlur="AllowOnlyInteger('form_','_1720_FEMALE_POSTBAC');AjaxUpdateDigit('_1720_FEMALE_POSTBAC',document.form_._1720_FEMALE_POSTBAC,'lbl_49');style.backgroundColor='white'" onKeyUp="AllowOnlyInteger('form_','_1720_FEMALE_POSTBAC')">
				   <label id="lbl_49"></label>				   </td>
              <td class="thinborder">
<%
strTemp = WI.getStrValue(vRetResult.elementAt(57), "0");
%>				   <input type="text" name="_1720_MALE_MASTER" class="textbox" onFocus="InitVal(document.form_._1720_MALE_MASTER);style.backgroundColor='#D3EBFF'" value="<%=strTemp%>" size="4"
				   onBlur="AllowOnlyInteger('form_','_1720_MALE_MASTER');AjaxUpdateDigit('_1720_MALE_MASTER',document.form_._1720_MALE_MASTER,'lbl_50');style.backgroundColor='white'" onKeyUp="AllowOnlyInteger('form_','_1720_MALE_MASTER')">
				   <label id="lbl_50"></label>				   </td>
              <td class="thinborder">
<%
strTemp = WI.getStrValue(vRetResult.elementAt(58), "0");
%>				   <input type="text" name="_1720_FEMALE_MASTER" class="textbox" onFocus="InitVal(document.form_._1720_FEMALE_MASTER);style.backgroundColor='#D3EBFF'" value="<%=strTemp%>" size="4"
				   onBlur="AllowOnlyInteger('form_','_1720_FEMALE_MASTER');AjaxUpdateDigit('_1720_FEMALE_MASTER',document.form_._1720_FEMALE_MASTER,'lbl_51');style.backgroundColor='white'" onKeyUp="AllowOnlyInteger('form_','_1720_FEMALE_MASTER')">
				   <label id="lbl_51"></label>				   </td>
              <td class="thinborder">
<%
strTemp = WI.getStrValue(vRetResult.elementAt(59), "0");
%>				   <input type="text" name="_1720_MALE_DOCTOR" class="textbox" onFocus="InitVal(document.form_._1720_MALE_DOCTOR);style.backgroundColor='#D3EBFF'" value="<%=strTemp%>" size="4"
				   onBlur="AllowOnlyInteger('form_','_1720_MALE_DOCTOR');AjaxUpdateDigit('_1720_MALE_DOCTOR',document.form_._1720_MALE_DOCTOR,'lbl_52');style.backgroundColor='white'" onKeyUp="AllowOnlyInteger('form_','_1720_MALE_DOCTOR')">
				   <label id="lbl_52"></label>				   </td>
              <td class="thinborder">
<%
strTemp = WI.getStrValue(vRetResult.elementAt(60), "0");
%>				   <input type="text" name="_1720_FEMALE_DOCTOR" class="textbox" onFocus="InitVal(document.form_._1720_FEMALE_DOCTOR);style.backgroundColor='#D3EBFF'" value="<%=strTemp%>" size="4"
				   onBlur="AllowOnlyInteger('form_','_1720_FEMALE_DOCTOR');AjaxUpdateDigit('_1720_FEMALE_DOCTOR',document.form_._1720_FEMALE_DOCTOR,'lbl_53');style.backgroundColor='white'" onKeyUp="AllowOnlyInteger('form_','_1720_FEMALE_DOCTOR')">
				   <label id="lbl_53"></label>				   </td>
            </tr>
			<tr align="center">
              <td class="thinborder">21 - 24</td>
              <td class="thinborder">
<%
strTemp = WI.getStrValue(vRetResult.elementAt(61), "0");
%>				   <input type="text" name="_2124_MALE_PREBAC" class="textbox" onFocus="InitVal(document.form_._2124_MALE_PREBAC);style.backgroundColor='#D3EBFF'" value="<%=strTemp%>" size="4"
				   onBlur="AllowOnlyInteger('form_','_2124_MALE_PREBAC');AjaxUpdateDigit('_2124_MALE_PREBAC',document.form_._2124_MALE_PREBAC,'lbl_54');style.backgroundColor='white'" onKeyUp="AllowOnlyInteger('form_','_2124_MALE_PREBAC')">
				   <label id="lbl_54"></label>				   </td>
              <td class="thinborder">
<%
strTemp = WI.getStrValue(vRetResult.elementAt(62), "0");
%>				   <input type="text" name="_2124_FEMALE_PREBAC" class="textbox" onFocus="InitVal(document.form_._2124_FEMALE_PREBAC);style.backgroundColor='#D3EBFF'" value="<%=strTemp%>" size="4"
				   onBlur="AllowOnlyInteger('form_','_2124_FEMALE_PREBAC');AjaxUpdateDigit('_2124_FEMALE_PREBAC',document.form_._2124_FEMALE_PREBAC,'lbl_55');style.backgroundColor='white'" onKeyUp="AllowOnlyInteger('form_','_2124_FEMALE_PREBAC')">
				   <label id="lbl_55"></label>				   </td>
              <td class="thinborder">
<%
strTemp = WI.getStrValue(vRetResult.elementAt(63), "0");
%>				   <input type="text" name="_2124_MALE_BAC" class="textbox" onFocus="InitVal(document.form_._2124_MALE_BAC);style.backgroundColor='#D3EBFF'" value="<%=strTemp%>" size="4"
				   onBlur="AllowOnlyInteger('form_','_2124_MALE_BAC');AjaxUpdateDigit('_2124_MALE_BAC',document.form_._2124_MALE_BAC,'lbl_56');style.backgroundColor='white'" onKeyUp="AllowOnlyInteger('form_','_2124_MALE_BAC')">
				   <label id="lbl_56"></label>				   </td>
              <td class="thinborder">
<%
strTemp = WI.getStrValue(vRetResult.elementAt(64), "0");
%>				   <input type="text" name="_2124_FEMALE_BAC" class="textbox" onFocus="InitVal(document.form_._2124_FEMALE_BAC);style.backgroundColor='#D3EBFF'" value="<%=strTemp%>" size="4"
				   onBlur="AllowOnlyInteger('form_','_2124_FEMALE_BAC');AjaxUpdateDigit('_2124_FEMALE_BAC',document.form_._2124_FEMALE_BAC,'lbl_57');style.backgroundColor='white'" onKeyUp="AllowOnlyInteger('form_','_2124_FEMALE_BAC')">
				   <label id="lbl_57"></label>				   </td>
			  
              <td class="thinborder">
<%
strTemp = WI.getStrValue(vRetResult.elementAt(65), "0");
%>				   <input type="text" name="_2124_MALE_POSTBAC" class="textbox" onFocus="InitVal(document.form_._2124_MALE_POSTBAC);style.backgroundColor='#D3EBFF'" value="<%=strTemp%>" size="4"
				   onBlur="AllowOnlyInteger('form_','_2124_MALE_POSTBAC');AjaxUpdateDigit('_2124_MALE_POSTBAC',document.form_._2124_MALE_POSTBAC,'lbl_58');style.backgroundColor='white'" onKeyUp="AllowOnlyInteger('form_','_2124_MALE_POSTBAC')">
				   <label id="lbl_58"></label>				   </td>
              <td class="thinborder">
<%
strTemp = WI.getStrValue(vRetResult.elementAt(66), "0");
%>				   <input type="text" name="_2124_FEMALE_POSTBAC" class="textbox" onFocus="InitVal(document.form_._2124_FEMALE_POSTBAC);style.backgroundColor='#D3EBFF'" value="<%=strTemp%>" size="4"
				   onBlur="AllowOnlyInteger('form_','_2124_FEMALE_POSTBAC');AjaxUpdateDigit('_2124_FEMALE_POSTBAC',document.form_._2124_FEMALE_POSTBAC,'lbl_59');style.backgroundColor='white'" onKeyUp="AllowOnlyInteger('form_','_2124_FEMALE_POSTBAC')">
				   <label id="lbl_59"></label>				   </td>
              <td class="thinborder">
<%
strTemp = WI.getStrValue(vRetResult.elementAt(67), "0");
%>				   <input type="text" name="_2124_MALE_MASTER" class="textbox" onFocus="InitVal(document.form_._2124_MALE_MASTER);style.backgroundColor='#D3EBFF'" value="<%=strTemp%>" size="4"
				   onBlur="AllowOnlyInteger('form_','_2124_MALE_MASTER');AjaxUpdateDigit('_2124_MALE_MASTER',document.form_._2124_MALE_MASTER,'lbl_50');style.backgroundColor='white'" onKeyUp="AllowOnlyInteger('form_','_2124_MALE_MASTER')">
				   <label id="lbl_60"></label>				   </td>
              <td class="thinborder">
<%
strTemp = WI.getStrValue(vRetResult.elementAt(68), "0");
%>				   <input type="text" name="_2124_FEMALE_MASTER" class="textbox" onFocus="InitVal(document.form_._2124_FEMALE_MASTER);style.backgroundColor='#D3EBFF'" value="<%=strTemp%>" size="4"
				   onBlur="AllowOnlyInteger('form_','_2124_FEMALE_MASTER');AjaxUpdateDigit('_2124_FEMALE_MASTER',document.form_._2124_FEMALE_MASTER,'lbl_61');style.backgroundColor='white'" onKeyUp="AllowOnlyInteger('form_','_2124_FEMALE_MASTER')">
				   <label id="lbl_61"></label>				   </td>
              <td class="thinborder">
<%
strTemp = WI.getStrValue(vRetResult.elementAt(69), "0");
%>				   <input type="text" name="_2124_MALE_DOCTOR" class="textbox" onFocus="InitVal(document.form_._2124_MALE_DOCTOR);style.backgroundColor='#D3EBFF'" value="<%=strTemp%>" size="4"
				   onBlur="AllowOnlyInteger('form_','_2124_MALE_DOCTOR');AjaxUpdateDigit('_2124_MALE_DOCTOR',document.form_._2124_MALE_DOCTOR,'lbl_62');style.backgroundColor='white'" onKeyUp="AllowOnlyInteger('form_','_2124_MALE_DOCTOR')">
				   <label id="lbl_62"></label>				   </td>
              <td class="thinborder">
<%
strTemp = WI.getStrValue(vRetResult.elementAt(70), "0");
%>				   <input type="text" name="_2124_FEMALE_DOCTOR" class="textbox" onFocus="InitVal(document.form_._2124_FEMALE_DOCTOR);style.backgroundColor='#D3EBFF'" value="<%=strTemp%>" size="4"
				   onBlur="AllowOnlyInteger('form_','_2124_FEMALE_DOCTOR');AjaxUpdateDigit('_2124_FEMALE_DOCTOR',document.form_._2124_FEMALE_DOCTOR,'lbl_63');style.backgroundColor='white'" onKeyUp="AllowOnlyInteger('form_','_2124_FEMALE_DOCTOR')">
				   <label id="lbl_63"></label>				   </td>
            </tr>
            <tr align="center">
              <td class="thinborder">25 - 29</td>
              <td class="thinborder">
<%
strTemp = WI.getStrValue(vRetResult.elementAt(71), "0");
%>				   <input type="text" name="_2529_MALE_PREBAC" class="textbox" onFocus="InitVal(document.form_._2529_MALE_PREBAC);style.backgroundColor='#D3EBFF'" value="<%=strTemp%>" size="4"
				   onBlur="AllowOnlyInteger('form_','_2529_MALE_PREBAC');AjaxUpdateDigit('_2529_MALE_PREBAC',document.form_._2529_MALE_PREBAC,'lbl_64');style.backgroundColor='white'" onKeyUp="AllowOnlyInteger('form_','_2529_MALE_PREBAC')">
				   <label id="lbl_64"></label>				   </td>
              <td class="thinborder">
<%
strTemp = WI.getStrValue(vRetResult.elementAt(72), "0");
%>				   <input type="text" name="_2529_FEMALE_PREBAC" class="textbox" onFocus="InitVal(document.form_._2529_FEMALE_PREBAC);style.backgroundColor='#D3EBFF'" value="<%=strTemp%>" size="4"
				   onBlur="AllowOnlyInteger('form_','_2529_FEMALE_PREBAC');AjaxUpdateDigit('_2529_FEMALE_PREBAC',document.form_._2529_FEMALE_PREBAC,'lbl_65');style.backgroundColor='white'" onKeyUp="AllowOnlyInteger('form_','_2529_FEMALE_PREBAC')">
				   <label id="lbl_65"></label>				   </td>
              <td class="thinborder">
<%
strTemp = WI.getStrValue(vRetResult.elementAt(73), "0");
%>				   <input type="text" name="_2529_MALE_BAC" class="textbox" onFocus="InitVal(document.form_._2529_MALE_BAC);style.backgroundColor='#D3EBFF'" value="<%=strTemp%>" size="4"
				   onBlur="AllowOnlyInteger('form_','_2529_MALE_BAC');AjaxUpdateDigit('_2529_MALE_BAC',document.form_._2529_MALE_BAC,'lbl_66');style.backgroundColor='white'" onKeyUp="AllowOnlyInteger('form_','_2529_MALE_BAC')">
				   <label id="lbl_66"></label>				   </td>
              <td class="thinborder">
<%
strTemp = WI.getStrValue(vRetResult.elementAt(74), "0");
%>				   <input type="text" name="_2529_FEMALE_BAC" class="textbox" onFocus="InitVal(document.form_._2529_FEMALE_BAC);style.backgroundColor='#D3EBFF'" value="<%=strTemp%>" size="4"
				   onBlur="AllowOnlyInteger('form_','_2529_FEMALE_BAC');AjaxUpdateDigit('_2529_FEMALE_BAC',document.form_._2529_FEMALE_BAC,'lbl_67');style.backgroundColor='white'" onKeyUp="AllowOnlyInteger('form_','_2529_FEMALE_BAC')">
				   <label id="lbl_67"></label>				   </td>
			  
              <td class="thinborder">
<%
strTemp = WI.getStrValue(vRetResult.elementAt(75), "0");
%>				   <input type="text" name="_2529_MALE_POSTBAC" class="textbox" onFocus="InitVal(document.form_._2529_MALE_POSTBAC);style.backgroundColor='#D3EBFF'" value="<%=strTemp%>" size="4"
				   onBlur="AllowOnlyInteger('form_','_2529_MALE_POSTBAC');AjaxUpdateDigit('_2529_MALE_POSTBAC',document.form_._2529_MALE_POSTBAC,'lbl_68');style.backgroundColor='white'" onKeyUp="AllowOnlyInteger('form_','_2529_MALE_POSTBAC')">
				   <label id="lbl_68"></label>				   </td>
              <td class="thinborder">
<%
strTemp = WI.getStrValue(vRetResult.elementAt(76), "0");
%>				   <input type="text" name="_2529_FEMALE_POSTBAC" class="textbox" onFocus="InitVal(document.form_._2529_FEMALE_POSTBAC);style.backgroundColor='#D3EBFF'" value="<%=strTemp%>" size="4"
				   onBlur="AllowOnlyInteger('form_','_2529_FEMALE_POSTBAC');AjaxUpdateDigit('_2529_FEMALE_POSTBAC',document.form_._2529_FEMALE_POSTBAC,'lbl_69');style.backgroundColor='white'" onKeyUp="AllowOnlyInteger('form_','_2529_FEMALE_POSTBAC')">
				   <label id="lbl_69"></label>				   </td>
              <td class="thinborder">
<%
strTemp = WI.getStrValue(vRetResult.elementAt(77), "0");
%>				   <input type="text" name="_2529_MALE_MASTER" class="textbox" onFocus="InitVal(document.form_._2529_MALE_MASTER);style.backgroundColor='#D3EBFF'" value="<%=strTemp%>" size="4"
				   onBlur="AllowOnlyInteger('form_','_2529_MALE_MASTER');AjaxUpdateDigit('_2529_MALE_MASTER',document.form_._2529_MALE_MASTER,'lbl_70');style.backgroundColor='white'" onKeyUp="AllowOnlyInteger('form_','_2529_MALE_MASTER')">
				   <label id="lbl_70"></label>				   </td>
              <td class="thinborder">
<%
strTemp = WI.getStrValue(vRetResult.elementAt(78), "0");
%>				   <input type="text" name="_2529_FEMALE_MASTER" class="textbox" onFocus="InitVal(document.form_._2529_FEMALE_MASTER);style.backgroundColor='#D3EBFF'" value="<%=strTemp%>" size="4"
				   onBlur="AllowOnlyInteger('form_','_2529_FEMALE_MASTER');AjaxUpdateDigit('_2529_FEMALE_MASTER',document.form_._2529_FEMALE_MASTER,'lbl_71');style.backgroundColor='white'" onKeyUp="AllowOnlyInteger('form_','_2529_FEMALE_MASTER')">
				   <label id="lbl_71"></label>				   </td>
              <td class="thinborder">
<%
strTemp = WI.getStrValue(vRetResult.elementAt(79), "0");
%>				   <input type="text" name="_2529_MALE_DOCTOR" class="textbox" onFocus="InitVal(document.form_._2529_MALE_DOCTOR);style.backgroundColor='#D3EBFF'" value="<%=strTemp%>" size="4"
				   onBlur="AllowOnlyInteger('form_','_2529_MALE_DOCTOR');AjaxUpdateDigit('_2529_MALE_DOCTOR',document.form_._2529_MALE_DOCTOR,'lbl_72');style.backgroundColor='white'" onKeyUp="AllowOnlyInteger('form_','_2529_MALE_DOCTOR')">
				   <label id="lbl_72"></label>				   </td>
              <td class="thinborder">
<%
strTemp = WI.getStrValue(vRetResult.elementAt(80), "0");
%>				   <input type="text" name="_2529_FEMALE_DOCTOR" class="textbox" onFocus="InitVal(document.form_._2529_FEMALE_DOCTOR);style.backgroundColor='#D3EBFF'" value="<%=strTemp%>" size="4"
				   onBlur="AllowOnlyInteger('form_','_2529_FEMALE_DOCTOR');AjaxUpdateDigit('_2529_FEMALE_DOCTOR',document.form_._2529_FEMALE_DOCTOR,'lbl_73');style.backgroundColor='white'" onKeyUp="AllowOnlyInteger('form_','_2529_FEMALE_DOCTOR')">
				   <label id="lbl_73"></label>				   </td>
            </tr>
            <tr align="center">
              <td class="thinborder">30 - up</td>
              <td class="thinborder">
<%
strTemp = WI.getStrValue(vRetResult.elementAt(81), "0");
%>				   <input type="text" name="_30_UP_MALE_PREBAC" class="textbox" onFocus="InitVal(document.form_._30_UP_MALE_PREBAC);style.backgroundColor='#D3EBFF'" value="<%=strTemp%>" size="4"
				   onBlur="AllowOnlyInteger('form_','_30_UP_MALE_PREBAC');AjaxUpdateDigit('_30_UP_MALE_PREBAC',document.form_._30_UP_MALE_PREBAC,'lbl_74');style.backgroundColor='white'" onKeyUp="AllowOnlyInteger('form_','_30_UP_MALE_PREBAC')">
				   <label id="lbl_74"></label>				   </td>
              <td class="thinborder">
<%
strTemp = WI.getStrValue(vRetResult.elementAt(82), "0");
%>				   <input type="text" name="_30_UP_FEMALE_PREBAC" class="textbox" onFocus="InitVal(document.form_._30_UP_FEMALE_PREBAC);style.backgroundColor='#D3EBFF'" value="<%=strTemp%>" size="4"
				   onBlur="AllowOnlyInteger('form_','_30_UP_FEMALE_PREBAC');AjaxUpdateDigit('_30_UP_FEMALE_PREBAC',document.form_._30_UP_FEMALE_PREBAC,'lbl_75');style.backgroundColor='white'" onKeyUp="AllowOnlyInteger('form_','_30_UP_FEMALE_PREBAC')">
				   <label id="lbl_75"></label>				   </td>
              <td class="thinborder">
<%
strTemp = WI.getStrValue(vRetResult.elementAt(83), "0");
%>				   <input type="text" name="_30_UP_MALE_BAC" class="textbox" onFocus="InitVal(document.form_._30_UP_MALE_BAC);style.backgroundColor='#D3EBFF'" value="<%=strTemp%>" size="4"
				   onBlur="AllowOnlyInteger('form_','_30_UP_MALE_BAC');AjaxUpdateDigit('_30_UP_MALE_BAC',document.form_._30_UP_MALE_BAC,'lbl_76');style.backgroundColor='white'" onKeyUp="AllowOnlyInteger('form_','_30_UP_MALE_BAC')">
				   <label id="lbl_76"></label>				   </td>
              <td class="thinborder">
<%
strTemp = WI.getStrValue(vRetResult.elementAt(84), "0");
%>				   <input type="text" name="_30_UP_FEMALE_BAC" class="textbox" onFocus="InitVal(document.form_._30_UP_FEMALE_BAC);style.backgroundColor='#D3EBFF'" value="<%=strTemp%>" size="4"
				   onBlur="AllowOnlyInteger('form_','_30_UP_FEMALE_BAC');AjaxUpdateDigit('_30_UP_FEMALE_BAC',document.form_._30_UP_FEMALE_BAC,'lbl_77');style.backgroundColor='white'" onKeyUp="AllowOnlyInteger('form_','_30_UP_FEMALE_BAC')">
				   <label id="lbl_77"></label>				   </td>
			  
              <td class="thinborder">
<%
strTemp = WI.getStrValue(vRetResult.elementAt(85), "0");
%>				   <input type="text" name="_30_UP_MALE_POSTBAC" class="textbox" onFocus="InitVal(document.form_._30_UP_MALE_POSTBAC);style.backgroundColor='#D3EBFF'" value="<%=strTemp%>" size="4"
				   onBlur="AllowOnlyInteger('form_','_30_UP_MALE_POSTBAC');AjaxUpdateDigit('_30_UP_MALE_POSTBAC',document.form_._30_UP_MALE_POSTBAC,'lbl_78');style.backgroundColor='white'" onKeyUp="AllowOnlyInteger('form_','_30_UP_MALE_POSTBAC')">
				   <label id="lbl_78"></label>				   </td>
              <td class="thinborder">
<%
strTemp = WI.getStrValue(vRetResult.elementAt(86), "0");
%>				   <input type="text" name="_30_UP_FEMALE_POSTBAC" class="textbox" onFocus="InitVal(document.form_._30_UP_FEMALE_POSTBAC);style.backgroundColor='#D3EBFF'" value="<%=strTemp%>" size="4"
				   onBlur="AllowOnlyInteger('form_','_30_UP_FEMALE_POSTBAC');AjaxUpdateDigit('_30_UP_FEMALE_POSTBAC',document.form_._30_UP_FEMALE_POSTBAC,'lbl_79');style.backgroundColor='white'" onKeyUp="AllowOnlyInteger('form_','_30_UP_FEMALE_POSTBAC')">
				   <label id="lbl_79"></label>				   </td>
              <td class="thinborder">
<%
strTemp = WI.getStrValue(vRetResult.elementAt(87), "0");
%>				   <input type="text" name="_30_UP_MALE_MASTER" class="textbox" onFocus="InitVal(document.form_._30_UP_MALE_MASTER);style.backgroundColor='#D3EBFF'" value="<%=strTemp%>" size="4"
				   onBlur="AllowOnlyInteger('form_','_30_UP_MALE_MASTER');AjaxUpdateDigit('_30_UP_MALE_MASTER',document.form_._30_UP_MALE_MASTER,'lbl_80');style.backgroundColor='white'" onKeyUp="AllowOnlyInteger('form_','_30_UP_MALE_MASTER')">
				   <label id="lbl_80"></label>				   </td>
              <td class="thinborder">
<%
strTemp = WI.getStrValue(vRetResult.elementAt(88), "0");
%>				   <input type="text" name="_30_UP_FEMALE_MASTER" class="textbox" onFocus="InitVal(document.form_._30_UP_FEMALE_MASTER);style.backgroundColor='#D3EBFF'" value="<%=strTemp%>" size="4"
				   onBlur="AllowOnlyInteger('form_','_30_UP_FEMALE_MASTER');AjaxUpdateDigit('_30_UP_FEMALE_MASTER',document.form_._30_UP_FEMALE_MASTER,'lbl_81');style.backgroundColor='white'" onKeyUp="AllowOnlyInteger('form_','_30_UP_FEMALE_MASTER')">
				   <label id="lbl_81"></label>				   </td>
              <td class="thinborder">
<%
strTemp = WI.getStrValue(vRetResult.elementAt(89), "0");
%>				   <input type="text" name="_30_UP_MALE_DOCTOR" class="textbox" onFocus="InitVal(document.form_._30_UP_MALE_DOCTOR);style.backgroundColor='#D3EBFF'" value="<%=strTemp%>" size="4"
				   onBlur="AllowOnlyInteger('form_','_30_UP_MALE_DOCTOR');AjaxUpdateDigit('_30_UP_MALE_DOCTOR',document.form_._30_UP_MALE_DOCTOR,'lbl_82');style.backgroundColor='white'" onKeyUp="AllowOnlyInteger('form_','_30_UP_MALE_DOCTOR')">
				   <label id="lbl_82"></label>				   </td>
              <td class="thinborder">
<%
strTemp = WI.getStrValue(vRetResult.elementAt(90), "0");
%>				   <input type="text" name="_30_UP_FEMALE_DOCTOR" class="textbox" onFocus="InitVal(document.form_._30_UP_FEMALE_DOCTOR);style.backgroundColor='#D3EBFF'" value="<%=strTemp%>" size="4"
				   onBlur="AllowOnlyInteger('form_','_30_UP_FEMALE_DOCTOR');AjaxUpdateDigit('_30_UP_FEMALE_DOCTOR',document.form_._30_UP_FEMALE_DOCTOR,'lbl_83');style.backgroundColor='white'" onKeyUp="AllowOnlyInteger('form_','_30_UP_FEMALE_DOCTOR')">
				   <label id="lbl_83"></label>				   </td>
            </tr>
            

          </table></td>
	  </tr>
		<tr>
		  <td height="25" class="body_font" style="font-weight:bold">C. LINKAGES</td>
	  </tr>
		<tr>
		  <td height="25" class="body_font">10. Do you have an International Institution Linkages? 
		  			<select name="INTERNATIONAL_LINKAGE" onChange="AjaxUpdateYesNo('INTERNATIONAL_LINKAGE',document.form_.INTERNATIONAL_LINKAGE,'lbl_84')">
			<option value="0">No</option>
<%
strTemp = (String)vRetResult.elementAt(33);
if(strTemp != null && strTemp.equals("1"))
	strTemp = " selected";
else	
	strTemp = "";
%>	  			<option value="1"<%=strTemp%>>Yes</option>
			 </select>	<label id="lbl_84"></label>
		  </td>
	  </tr>
		<tr>
		  <td height="25" class="body_font">11. If YES, please write the institutional name and country: (insert row if needed)</td>
	  </tr>
		<tr>
		  <td height="25" class="body_font">
		  	<table cellpadding="0" cellspacing="0" class="thinborder">
			 <tr align="center" bgcolor="#0066CC">
				<td class="thinborder" height="25">Institutional Name and Country </td>
			  </tr>
			 <tr>
			      <td class="thinborder">
<%
strTemp = WI.getStrValue((String)vRetResult.elementAt(34));
%>			  
			<textarea name="INST_NAME_COUNTRY" rows="6" cols="100" style="font-size:11px;" class="textbox" onFocus="InitVal(document.form_.INST_NAME_COUNTRY);style.backgroundColor='#D3EBFF'"
				onBlur="AjaxUpdateText('INST_NAME_COUNTRY',document.form_.INST_NAME_COUNTRY,'lbl_85');style.backgroundColor='white'"><%=strTemp%></textarea>
			<label id="lbl_85"></label>	</td>
		      </tr>
			 <tr>
			   <td class="thinborder">Note : Format Institution Name#Country#Institution Name#Country ... </td>
		      </tr>
	        </table>
		  </td>
	  </tr>
		<tr>
		  <td height="25" class="body_font">12. Do you have an Industrial Linkages?
		  <select name="INDUSTRY_LINKAGE" onChange="AjaxUpdateYesNo('INDUSTRY_LINKAGE',document.form_.INDUSTRY_LINKAGE,'lbl_86')">
			<option value="0">No</option>
<%
strTemp = (String)vRetResult.elementAt(35);
if(strTemp != null && strTemp.equals("1"))
	strTemp = " selected";
else	
	strTemp = "";
%>	  			<option value="1"<%=strTemp%>>Yes</option>
		    </select>	<label id="lbl_86"></label>
		  </td>
	  </tr>
		<tr>
		  <td height="25" class="body_font">13. If YES, please write the company name and country: (insert row if needed)</td>
	  </tr>
		<tr>
		  <td height="25" class="body_font">
			<table cellpadding="0" cellspacing="0" class="thinborder">
			 <tr align="center" bgcolor="#0066CC">
				<td class="thinborder" height="25">Industry Name and Country </td>
			  </tr>
			 <tr>
			      <td class="thinborder">
<%
strTemp = WI.getStrValue((String)vRetResult.elementAt(36));
%>			  
			<textarea name="INDUSTRY_NAME_COUNTRY" rows="6" cols="100" style="font-size:11px;" class="textbox" onFocus="InitVal(document.form_.INDUSTRY_NAME_COUNTRY);style.backgroundColor='#D3EBFF'"
				onBlur="AjaxUpdateText('INDUSTRY_NAME_COUNTRY',document.form_.INDUSTRY_NAME_COUNTRY,'lbl_87');style.backgroundColor='white'"><%=strTemp%></textarea>
			<label id="lbl_87"></label>	</td>
		      </tr>
			 <tr>
			   <td class="thinborder">Note : Format Industry Name#Country#Industry Name#Country ... </td>
		      </tr>
	        </table>		  
		  </td>
	  </tr>
		<tr>
		  <td height="25" class="body_font" style="font-weight:bold">D. STUDENT COST</td>
	  </tr>
		<tr>
		  <td height="25" class="body_font">14. How much is per student cost for AY <%=WI.fillTextValue("sy_from")%> - <%=Integer.parseInt(WI.fillTextValue("sy_from")) + 1%> </td>
	  </tr>
		<tr>
		  <td height="25" class="body_font">Formula is:
		  <table width="75%" cellpadding="0" cellspacing="0">
		  	<tr>
				<td width="8%"></td>
				<td>Per student cost = </td>
				<td class="body_font"><u>Maintenance and Other Operating Expenses + Personal Services</u></td>
				<td>
<%
strTemp = WI.getStrValue(vRetResult.elementAt(38), "0");
strTemp = CommonUtil.formatFloat(strTemp, true);
strTemp = ConversionTable.replaceString(strTemp, ",", "");
%>				   <input type="text" name="FORMULA_UPPER" class="textbox" onFocus="InitVal(document.form_.FORMULA_UPPER);style.backgroundColor='#D3EBFF'" value="<%=strTemp%>" size="24"
				   onBlur="AllowOnlyIntegerExtn('form_','FORMULA_UPPER','.');AjaxUpdateDigit('FORMULA_UPPER',document.form_.FORMULA_UPPER,'lbl_88');style.backgroundColor='white'" onKeyUp="AllowOnlyIntegerExtn('form_','FORMULA_UPPER','.')">
				   <label id="lbl_88"></label>				   </td>
			</tr>
		  	<tr>
		  	  <td></td>
		  	  <td>&nbsp;</td>
		  	  <td class="body_font" align="center">Number of Students</td>
		  	  <td>
<%
strTemp = WI.getStrValue(vRetResult.elementAt(39), "0");
%>				   <input type="text" name="FORMULA_LOWER" class="textbox" onFocus="InitVal(document.form_.FORMULA_LOWER);style.backgroundColor='#D3EBFF'" value="<%=strTemp%>" size="14"
				   onBlur="AllowOnlyInteger('form_','FORMULA_LOWER');AjaxUpdateDigit('FORMULA_LOWER',document.form_.FORMULA_LOWER,'lbl_89');style.backgroundColor='white'" onKeyUp="AllowOnlyInteger('form_','FORMULA_LOWER')">
				   <label id="lbl_89"></label>				   </td>
	  	    </tr>
		  </table>
		  
		  </td>
	  </tr>
		<tr>
		  <td height="25" class="body_font">15. How much is per unit cost for AY 2008-2009
		  &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
		  
<%
strTemp = WI.getStrValue(vRetResult.elementAt(37), "0");
%>				   <input type="text" name="PER_STUD_COST" class="textbox" onFocus="InitVal(document.form_.PER_STUD_COST);style.backgroundColor='#D3EBFF'" value="<%=strTemp%>" size="14"
				   onBlur="AllowOnlyIntegerExtn('form_','PER_STUD_COST','.');AjaxUpdateDigit('PER_STUD_COST',document.form_.PER_STUD_COST,'lbl_90');style.backgroundColor='white'" onKeyUp="AllowOnlyIntegerExtn('form_','PER_STUD_COST','.')">
				   <label id="lbl_90"></label>				   </td>
	  </tr>
		<tr>
		  <td height="25" class="body_font">&nbsp;</td>
	  </tr>
		<tr>
		  <td height="25" class="body_font">&nbsp;</td>
	  </tr>
		<tr>
		  <td height="25" class="body_font">&nbsp;</td>
	  </tr>
	</table>
<%}//show only vRetResult is not null %>

  
</form>
</body>
</html>
<%
	dbOP.cleanUP();
%>
