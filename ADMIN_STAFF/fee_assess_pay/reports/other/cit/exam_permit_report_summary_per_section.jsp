<%@ page language="java" import="utility.*,java.util.Vector" %>
<%
String strSchCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchCode == null)
	strSchCode = "";
WebInterface WI = new WebInterface(request);

%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../../../Ajax/ajax.js"></script>
<script language="JavaScript">
//// - all about ajax.. 
function AjaxMapName(strPos) {
		var strCompleteName;
		strCompleteName = document.form_.stud_id.value;
		if(strCompleteName.length < 2)
			return;
		
		var objCOAInput;
		objCOAInput = document.getElementById("coa_info");
			
		this.InitXmlHttpObject(objCOAInput, 2);//I want to get innerHTML in this.retObj
  		if(this.xmlHttp == null) {
			alert("Failed to init xmlHttp.");
			return;
		}
		var strURL = "../../../../../Ajax/AjaxInterface.jsp?methodRef=2&search_id=1&name_format=4&complete_name="+
			escape(strCompleteName);

		this.processRequest(strURL);
}
function UpdateID(strID, strUserIndex) {
	/** do not do anything **/
	document.form_.stud_id.value = strID;
	document.form_.submit();
}
function UpdateName(strFName, strMName, strLName) {
	//var strName = strLName.toUpperCase() +", "+strFName+" "+strMName.charAt(0);
	//document.form_.charge_to_name.value = strName;
}
function UpdateNameFormat(strName) {
	document.getElementById("coa_info").innerHTML = "";
}

</script>
<%
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;

//authenticate this user.
	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("FEE ASSESSMENT & PAYMENTS-EXAM PERMIT"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("FEE ASSESSMENT & PAYMENTS"),"0"));
		}
		//may be called from registrar.
	}
	if(iAccessLevel == -1)//for fatal error.
	{
		request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		request.getSession(false).setAttribute("errorMessage","You are already logged out. Please login again.");
		response.sendRedirect("../../../../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0)//NOT AUTHORIZED.
	{
		response.sendRedirect("../../../../../commfile/unauthorized_page.jsp");
		return;
	}




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

boolean bolIsBasic = false;
String strExamName = null;
String strExamPeriod = null;
String[] astrConvertSem = {"Summer","1st Semester","2nd Semester","3rd Semester"};

String strSYFrom   = WI.fillTextValue("sy_from");
String strSYTo     = WI.fillTextValue("sy_to");
String strSemester = WI.fillTextValue("semester");
strExamPeriod      = WI.fillTextValue("pmt_schedule");

Vector vRetResult  = null;//get subject schedule information.
	enrollment.ReportEnrollment RE = new enrollment.ReportEnrollment();
	vRetResult = RE.examPermitDetailPerSection(dbOP, request, WI.fillTextValue("section_ref"));
	if(vRetResult == null)
		strErrMsg = RE.getErrMsg();
%>
<body bgcolor="#D2AE72">
<form name="form_" action="./exam_permit_report_summary.jsp" method="post" onSubmit="SubmitOnceButton(this);">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" id="myADTable1">
    <tr bgcolor="#A49A6A"> 
      <td height="25" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF" ><strong>:::: 
          ADMISSION SLIP STATUS ::::</strong></font></div></td>
    </tr>
    <tr bgcolor="#FFFFFF"> 
      <td height="25" >&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<font style="font-size:16px; font-weight:bold; color:#FF0000"><b><%=WI.getStrValue(strErrMsg)%></b></font></td>
    </tr>
  </table>
  <%if(vRetResult != null && vRetResult.size() > 0) {%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="22" bgcolor="#CCCCCC" align="center" class="thinborderNONE" style="font-weight:bold">DETAIL OF ADMISSION SLIP PER SECTION </td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr align="center"> 
      <td width="5%" height="22" class="thinborder">Count</td>
      <td width="10%" class="thinborder">Student ID </td>
      <td width="15%" class="thinborder">Student Name </td>
      <td width="10%" class="thinborder">Date Printed </td>
      <td width="10%" class="thinborder">Time Printed </td>
      <td width="15%" class="thinborder">Reason</td>
      <td width="5%" class="thinborder">Allow Type </td>
    </tr>
<%int iCount = 0; 
String[] astrConvertAllowType = {"Reprint","Temp Permit","Temp Permit","&nbsp;","&nbsp;","&nbsp;","&nbsp;"};
String strBgColor = "";
for(int i = 0; i < vRetResult.size(); i += 8){
if(vRetResult.elementAt(i + 3) == null)
	strBgColor = " bgcolor='red'";
else	
	strBgColor = "";
%>
    <tr<%=strBgColor%>>
      <td height="22" class="thinborder"><%=++iCount%></td>
      <td class="thinborder"><%=vRetResult.elementAt(i)%></td>
      <td class="thinborder"><%=vRetResult.elementAt(i + 1)%></td>
      <td class="thinborder"><%=WI.getStrValue(vRetResult.elementAt(i + 3), "&nbsp;")%></td>
      <td class="thinborder"><%=WI.getStrValue(vRetResult.elementAt(i + 4), "&nbsp;")%></td>
      <td class="thinborder"><%=WI.getStrValue(vRetResult.elementAt(i + 6), "&nbsp;")%><%=WI.getStrValue((String)vRetResult.elementAt(i + 5), " valid until: ", "","")%></td>
      <td class="thinborder">
		<%=astrConvertAllowType[Integer.parseInt(WI.getStrValue(vRetResult.elementAt(i + 7), "5"))]%></td>
    </tr>
<%}%>
  </table>
<%}%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" id="myADTable4">
    <tr> 
      <td height="25">&nbsp;</td>
    </tr>
    <tr bgcolor="#A49A6A"> 
      <td height="25">&nbsp;</td>
    </tr>
  </table>
  <input type="hidden" name="sy_from" value="<%=WI.fillTextValue("sy_from")%>">
  <input type="hidden" name="semester" value="<%=WI.fillTextValue("semester")%>">
  <input type="hidden" name="section_ref" value="<%=WI.fillTextValue("section_ref")%>">
  <input type="hidden" name="pmt_schedule" value="<%=WI.fillTextValue("pmt_schedule")%>">
</form>

</body>
</html>
<%
dbOP.cleanUP();
%>