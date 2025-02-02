<%
String strAuthIndex = (String)request.getSession(false).getAttribute("authTypeIndex");
String strLoginID = (String)request.getSession(false).getAttribute("userId");
	String strSchCode = (String)request.getSession(false).getAttribute("school_code");
	if(strSchCode == null)
		strSchCode = "";

if(strAuthIndex == null || strAuthIndex.equals("4") || strLoginID == null || !strLoginID.toLowerCase().equals("sa-01") || !strSchCode.startsWith("UPH") ) {%>
	<p align="center" style="font-size:16px; font-weight:bold; color:#FF0000"> You are not allowed to access this page.
<%return;}%>



<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="./css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="./css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="./jscript/date-picker.js"></script>
<script language="JavaScript" src="./jscript/common.js"></script>
<script language="JavaScript">
function ReloadPage(strSYFrom, strSemester) {
	document.form_.page_action.value = '';
	document.form_.sy_from.value = strSYFrom;
	document.form_.semester.value = strSemester;

	document.form_.submit();
}
function UpdateEnrollment(strPageAction) {
	document.form_.page_action.value = strPageAction;
	document.form_.submit();
}
function SelAll() {
	var iCount = document.form_.max_disp.value;
	var bolIsChecked = false;
	var obj;
	eval('bolIsChecked=document.form_._0.checked');
	//alert(bolIsChecked);
	for(i = 0; i < iCount; ++i) {
		eval('obj=document.form_._'+i);
		obj.checked = bolIsChecked;
	} 
}
</script>

<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*,java.util.Vector" buffer="16kb"%>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);

	String strErrMsg = null;
	String strTemp = null;
	
	
//add security here.
	try
	{
		dbOP = new DBOperation();
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
	Vector vRetResult  = null;
	utility.AllProgramFix APF = new utility.AllProgramFix();
	
	String strSYFrom   = WI.fillTextValue("sy_from");
	String strSemester = WI.fillTextValue("semester");
	
	strTemp = WI.fillTextValue("page_action");
	if(strTemp.length() > 0) {
		if(APF.fixUPHCurriculumIssue(dbOP, request, Integer.parseInt(strTemp)) == null)
			strErrMsg = APF.getErrMsg();
		else	
			strErrMsg = "Fix Applied Successfully.";
	}
	
	if(strSYFrom.length() > 0) {
		vRetResult = APF.fixUPHCurriculumIssue(dbOP, request, 4);
		if(vRetResult == null && strErrMsg == null)
			strErrMsg = APF.getErrMsg();
	}
	
	Vector vSYInfo = APF.fixUPHCurriculumIssue(dbOP, request, 5);
	if(vSYInfo == null && strErrMsg == null)
		strErrMsg = APF.getErrMsg();
	

%>
<form name="form_" action="./cur_fix_uph.jsp" method="post">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF"><strong>::::
          CURRICULUM UPDATE PAGE ::::</strong></font></div></td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td height="25">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<%=WI.getStrValue(strErrMsg)%></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="4%" height="25">&nbsp;</td>
      <td height="25" colspan="2">SY-Term having Curriculum Issue: <font size="3">
	  <%for(int i = 0; i < vSYInfo.size(); i += 3) {%>
	  	&nbsp;&nbsp;&nbsp;&nbsp;
	  	<a href="javascript:ReloadPage('<%=vSYInfo.elementAt(i)%>','<%=vSYInfo.elementAt(i + 1)%>')"><%=vSYInfo.elementAt(i)%> - <%=vSYInfo.elementAt(i + 1)%> (<%=vSYInfo.elementAt(i + 2)%>)</a>
	  <%}%></font></td>
    </tr>
<input type="hidden" name="sy_from" value="<%=strSYFrom%>">
<input type="hidden" name="semester" value="<%=strSemester%>">
<%if(strSYFrom.length() > 0) {%>
    <tr>
      <td height="25">&nbsp;</td>
      <td width="12%" height="25">SY-Term</td>
      <td width="84%" height="25" style="font-weight:bold; font-size:16px;"><%=strSYFrom%> - <%=strSemester%></td>
    </tr>
    
  </table>
  <%if(vRetResult != null && vRetResult.size() > 0) {%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="50%" height="25" align="right"><input type="button" name="12" id="_update_date" value=" Fix EFCL >> " style="font-size:11px; height:28px;border: 1px solid #FF0000;" onClick="UpdateEnrollment('1');"></td>
      <td width="50%" align="right">
	  		<input type="button" name="12" id="_update_date" value=" Fix Curriculum >> " style="font-size:11px; height:28px;border: 1px solid #FF0000;" onClick="UpdateEnrollment('2');">
	  </td>
    </tr>
    <tr>
      <td height="25" colspan="2" align="center" bgcolor="#cccccc" style="font-weight:bold">List of Students Enrolled in Wrong Curriculum </td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr style="font-weight:bold" align="center">
      <td width="2%" class="thinborder">Count</td>
      <td height="22" width="10%" class="thinborder">Student ID </td>
      <td width="20%" class="thinborder">Student Name </td>
      <td width="7%" class="thinborder">Curriculum Yr </td>
      <td width="7%" class="thinborder">Course-Yr</td>
      <td width="10%" class="thinborder">Wrong Sub Code Enrolled </td>
      <td width="15%" class="thinborder">Wrong Sub Desc Enrolled </td>
      <td width="10%" class="thinborder">Correct Sub Code </td>
      <td width="15%" class="thinborder">Correct Sub Desc </td>
      <td width="15%" class="thinborder">Class Program Subject Code </td>
      <td width="6%" class="thinborder" onDblClick="SelAll();">Apply Fix </td>
    </tr>
<%
int iCount = 0;
String strCorrectSubCode = null;
String strWrongSubCode   = null;
String strBGColor = "";
for(int i = 0; i < vRetResult.size(); i += 13) {
strCorrectSubCode = (String)vRetResult.elementAt(i + 3)+"-3";
strWrongSubCode   = (String)vRetResult.elementAt(i + 1);
//System.out.println(strCorrectSubCode);
//System.out.println(strWrongSubCode);
if(strSYFrom.equals("2013")){
	if(!strCorrectSubCode.equals(strWrongSubCode))
		strBGColor = " bgcolor = '#cccccc'";
	else	
		strBGColor = "";
}
%>
    <tr<%=strBGColor%>>
      <td class="thinborder"><%=iCount + 1%></td>
      <td height="22" class="thinborder"><%=vRetResult.elementAt(i + 6)%></td>
      <td class="thinborder"><%=vRetResult.elementAt(i + 7)%></td>
      <td class="thinborder"><%=vRetResult.elementAt(i + 10)%> - <%=vRetResult.elementAt(i + 11)%></td>
      <td class="thinborder"><%=vRetResult.elementAt(i + 8)%><%=WI.getStrValue((String)vRetResult.elementAt(i + 9)," - ", "","")%></td>
      <td class="thinborder"><%=vRetResult.elementAt(i + 1)%></td>
      <td class="thinborder"><%=vRetResult.elementAt(i + 2)%></td>
      <td class="thinborder"><%=vRetResult.elementAt(i + 3)%></td>
      <td class="thinborder"><%=vRetResult.elementAt(i + 4)%></td>
      <td class="thinborder"><%=vRetResult.elementAt(i + 5)%><br><%=vRetResult.elementAt(i + 12)%></td>
      <td class="thinborder" align="center">&nbsp;<%if(true || strBGColor.length() == 0) {%><input type="checkbox" name="_<%=iCount++%>" value="<%=vRetResult.elementAt(i)%>"><%}%></td>
    </tr>
<%}%>
<input type="hidden" name="max_disp" value="<%=iCount%>">
  </table>
  <%}else{%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="25" align="center" style="font-weight:bold">No Student enrolled.. </td>
    </tr>
  </table>
  <%}%>
<%}%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="25">&nbsp;</td>
    </tr>
    <tr bgcolor="#B8CDD1">
      <td height="25" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
  <input type="hidden" name="page_action">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>