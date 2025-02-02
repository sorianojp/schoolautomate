<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<link href="../../../css/reportlink.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript">
function ReloadPage()
{
	document.form_.page_action.value = "";
	document.form_.reloadPage.value = 1;
	document.form_.submit();
}
function PageAction(strAction, strInfoIndex) {
	document.form_.page_action.value = strAction;
	if(strInfoIndex.length > 0)
		document.form_.info_index.value = strInfoIndex;
	if(strAction == 1) 
		document.form_.hide_save.src = "../../../images/blank.gif";
	document.form_.submit();
}
function PrepareToEdit(strInfoIndex) {
	document.form_.page_action.value = "";
	document.form_.prepareToEdit.value = "1";
	document.form_.info_index.value = strInfoIndex;
	document.form_.submit();
}
function Cancel() {
	document.form_.page_action.value = "";
	document.form_.prepareToEdit.value = "";
	document.form_.info_index.value = "";
	document.form_.submit();
}

</script>
<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*,enrollment.CurriculumMaintenance,java.util.Vector, java.util.Date" %>
<%
	DBOperation dbOP = null;
	String strErrMsg = "";
	String strTemp = null;
	WebInterface WI = new WebInterface(request);
	String strPrepareToEdit = WI.getStrValue(WI.fillTextValue("prepareToEdit"),"0");
	Vector vRetResult = new Vector();//this is added to store the subject descirption, category name and category index for Pre-requisite
	
	Vector vCurInfo = null;	
	boolean bolIsLocked = false;//check LOCK_CURRICULUM table.
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Registrar Management-CURRICULUM-curriculum remark","curriculum_remark.jsp");
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
														"Registrar Management","CURRICULUM",request.getRemoteAddr(),
														"curriculum_remark.jsp");
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
CurriculumMaintenance CM = new CurriculumMaintenance();
strTemp = WI.fillTextValue("info_index");
if(strTemp.length() == 0) {
	if(CM.operateOnCurriculumRemark(dbOP, request, Integer.parseInt(strTemp)) == null) 
		strErrMsg = CM.getErrMsg();
	else	
		strErrMsg = "Operation Successful";
}
if(strPreparedToEdit.equals("1")) {
		

}
%>

<form name="form_" method="post" action="./curriculum_remark.jsp">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="4"><div align="center"><font color="#FFFFFF"><strong>:::: CURRICULUM REMARK ::::</strong></font></div></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="2%">&nbsp;</td>
      <td height="25" colspan="2"><b><font size="3" color="#FF0000"><%=WI.getStrValue(strErrMsg,"Message: ","","")%></font></b> </td>
    </tr>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td width="6%">Course</td>
      <td width="92%"><select name="course_index" onChange="ReloadPage();">
        <option value=""></option>
        <%
//for all course listing strTemp = " from course_offered where IS_DEL=0 AND IS_VALID=1 order by course_name asc"
%>
        <%=dbOP.loadCombo("course_index","course_name"," from course_offered where IS_DEL=0 and is_valid=1 and degree_type="+
 						request.getParameter("degree_type")+"and cc_index="+request.getParameter("cc_index")+" order by course_name asc", request.getParameter("course_index"), false)%>
      </select></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td valign="top">Major&nbsp;&nbsp;</td>
      <td><select name="major_index" onChange="ReloadPage();">
        <option></option>
        <%
strTemp = request.getParameter("course_index");
if(strTemp != null)
{
strTemp = " from major where is_del=0 and course_index="+strTemp ;
%>
        <%=dbOP.loadCombo("major_index","major_name",strTemp, request.getParameter("major_index"), false)%>
<%}%>
      </select></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td  width="2%"height="25">&nbsp;</td>
      <td width="6%" height="25">Year</td>
      <td width="23%"> <select name="year">
          <option value="1">1st</option>
<%
if(vEditInfo != null && vEditInfo.size() > 0 && WI.fillTextValue("reloadPage").compareTo("0") == 0) 
	strTemp = (String)vEditInfo.elementAt(6);
else	
	strTemp = WI.fillTextValue("year");
if(strTemp.compareTo("2") ==0)
{%>
          <option value="2" selected>2nd</option>
          <%}else{%>
          <option value="2">2nd</option>
          <%}if(strTemp.compareTo("3") ==0)
{%>
          <option value="3" selected>3rd</option>
          <%}else{%>
          <option value="3">3rd</option>
          <%}if(strTemp.compareTo("4") ==0)
{%>
          <option value="4" selected>4th</option>
          <%}else{%>
          <option value="4">4th</option>
          <%}if(strTemp.compareTo("5") ==0)
{%>
          <option value="5" selected>5th</option>
          <%}else{%>
          <option value="5">5th</option>
          <%}if(strTemp.compareTo("6") ==0)
{%>
          <option value="6" selected>6th</option>
          <%}else{%>
          <option value="6">6th</option>
          <%}if(strTemp.compareTo("7") ==0)
{%>
          <option value="7" selected>7th</option>
          <%}else{%>
          <option value="7">7th</option>
          <%}if(strTemp.compareTo("8") ==0)
{%>
          <option value="8" selected>8th</option>
          <%}else{%>
          <option value="8">8th</option>
          <%}%>
        </select>      </td>
      <td width="9%" height="25">Term</td>
      <td width="60%" height="25"><select name="semester">
        <option value="1">1st Sem</option>
        <%
if(vEditInfo != null && vEditInfo.size() > 0 && WI.fillTextValue("reloadPage").compareTo("0") == 0) 
	strTemp = (String)vEditInfo.elementAt(14);
else	
	strTemp = WI.fillTextValue("semester");
if(strTemp.compareTo("2") ==0){%>
        <option value="2" selected>2nd Sem</option>
        <%}else{%>
        <option value="2">2nd Sem</option>
        <%}if(strTemp.compareTo("3") ==0){%>
        <option value="3" selected>3rd Sem</option>
        <%}else{%>
        <option value="3">3rd Sem</option>
        <%}if(strTemp.compareTo("4") ==0){%>
        <option value="4" selected>4th Sem</option>
        <%}else{%>
        <option value="4">4th Sem</option>
        <%}if(strTemp.compareTo("0") ==0){%>
        <option value="0" selected>Summer</option>
        <%}else{%>
        <option value="0">Summer</option>
        <%}if(strTemp.compareTo("6") ==0){%>
        <!--          <option value="6" selected>Internship/Clerkship</option>-->
        <%}else{%>
        <!--          <option value="6">Internship/Clerkship</option> -->
        <%}%>
      </select></td>
    </tr>
  </table>
<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="14%">&nbsp;</td>
      <td width="86%"><font size="1"> 
<%if(strPrepareToEdit.compareTo("1") != 0) {%>
        <a href='javascript:PageAction(1,"");'><img src="../../../images/save.gif" border="0" name="hide_save"></a> Click to save entries 
<%}else{%>
        <a href='javascript:PageAction(2, "");'><img src="../../../images/edit.gif" border="0"></a> Click to edit event 
<%}%>
        <a href="javascript:Cancel();"><img src="../../../images/cancel.gif" border="0"></a> Click to clear entries </font>
		</td>
    </tr>
  </table>
<%if(vCurInfo != null && vCurInfo.size() > 0) {%>
<table width="100%" border="0" cellspacing="0" cellpadding="0" class="thinborder">
    <tr bgcolor="#FFFFCC">
      <td height="25" colspan="6" class="thinborderLEFT"><div align="center"><strong>CURRICULUM REMARKS </strong></div></td>
    </tr>
</table>
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF" class="thinborder">
    <tr> 
      <td width="15%" height="25" class="thinborder">&nbsp;</td>
      <td width="41%" class="thinborder">&nbsp;</td>
      <td width="11%" class="thinborder">&nbsp;</td>
      <td width="8%" class="thinborder">&nbsp;</td>
      <td width="8%" class="thinborder">&nbsp;</td>
 <%if(!bolIsLocked){%><td width="17%" class="thinborder">&nbsp;</td><%}else{%>
      <td width="17%" class="thinborder">&nbsp;</td>
      <%}%>
    </tr>
<%
boolean bolIsElectiveAutoAdded = false;
Integer objInt = null; int iIndexOf = 0;

String strCreditUnitLec = null;
String strCreditUnitLab = null;

for(int i = 0; i < vCurInfo.size(); i += 16){
	objInt = new Integer((String)vCurInfo.elementAt(i + 1));
	iIndexOf = vNonCreditSubj.indexOf(objInt);
	
	if(iIndexOf > -1) {
		strCreditUnitLec = (String)vNonCreditSubj.elementAt(iIndexOf + 3);
		strCreditUnitLab = (String)vNonCreditSubj.elementAt(iIndexOf + 4);
		if(strCreditUnitLec != null && !strCreditUnitLec.equals("0"))
			strCreditUnitLec = "("+strCreditUnitLec+".0)";
		else	
			strCreditUnitLec = "0.0";
			
		if(strCreditUnitLab != null && !strCreditUnitLab.equals("0"))
			strCreditUnitLab = "("+strCreditUnitLab+".0)";		
		else	
			strCreditUnitLab = "0.0";
	}
	else {
		strCreditUnitLec = null;
		strCreditUnitLab = null;
	}
	
	if(vCurInfo.elementAt(i + 15) != null && ((String)vCurInfo.elementAt(i + 15)).compareTo("1") == 0)
		bolIsElectiveAutoAdded = true;
	else	
		bolIsElectiveAutoAdded = false;	%>
    <tr>
      <td height="25" class="thinborder">&nbsp;</td>
      <td class="thinborder">&nbsp;</td>
      <td class="thinborder">&nbsp;</td>
      <td class="thinborder">&nbsp;</td>
      <td class="thinborder">&nbsp;</td>
      <%if(!bolIsLocked){%><td class="thinborder">&nbsp;</td>
      <%}else{%>
       
      <td width="17%" class="thinborder" align="center">&nbsp;</td>
      <%}%>
   </tr>
<%}//end of for loop.%>
  </table>

<%}%>

  <table width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="25" bgcolor="#FFFFFF">&nbsp;</td>
    </tr>
    <tr>
      <td height="25" bgcolor="#A49A6A">&nbsp;</td>
    </tr> 
  </table>
<input type="hidden" name="page_action">
<input type="hidden" name="info_index" value="<%=WI.fillTextValue("info_index")%>">
<input type="hidden" name="prepareToEdit" value="<%=strPrepareToEdit%>">

</form>
	
</body>
</html>
<%
dbOP.cleanUP();
%>
