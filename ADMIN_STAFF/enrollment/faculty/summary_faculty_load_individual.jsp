<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<%response.setHeader("Pragma","No-Cache");
response.setDateHeader("Expires",0);
response.setHeader("Cache-Control","no-Cache");
%>
</head>
<script language="JavaScript" src="../../../Ajax/ajax.js"></script>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript">
function FocusID() {
	document.form_.emp_id.focus();
}
function OpenSearch() {
	var pgLoc = "../../../search/srch_emp.jsp?opner_info=form_.emp_id";
	var win=window.open(pgLoc,"PrintWindow",'width=900,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function ReloadPage(){
	document.form_.submit();
}
function PrintPg() {
	document.bgColor = "#FFFFFF";
	document.getElementById('myADTable0').deleteRow(0);
	
	document.getElementById('myADTable1').deleteRow(0);
	document.getElementById('myADTable1').deleteRow(0);
	document.getElementById('myADTable1').deleteRow(0);

	document.getElementById('myADTable2').deleteRow(2);

	document.getElementById('myADTable3').deleteRow(0);
	document.getElementById('myADTable3').deleteRow(0);

	alert("Click OK to print this page");
	window.print();
}
//all about ajax - to display student list with same name.
function AjaxMapName(e) {
		if(e.keyCode == 13) {
			ReloadPage();
			return;
		}
		var strCompleteName = document.form_.emp_id.value;
		var objCOAInput = document.getElementById("coa_info");
		
		if(strCompleteName.length <=2) {
			objCOAInput.innerHTML = "";
			return ;
		}

		this.InitXmlHttpObject(objCOAInput, 2);//I want to get innerHTML in this.retObj
  		if(this.xmlHttp == null) {
			alert("Failed to init xmlHttp.");
			return;
		}
		var strURL = "../../../Ajax/AjaxInterface.jsp?methodRef=2&search_id=1&is_faculty=1&name_format=4&complete_name="+
			escape(strCompleteName);

		this.processRequest(strURL);
}
function UpdateID(strID, strUserIndex) {
	document.form_.emp_id.value = strID;
	document.getElementById("coa_info").innerHTML = "<font size='1' color=blue>...end of processing..</font>";
	document.form_.submit();
}
function UpdateName(strFName, strMName, strLName) {
	//do nothing.
}
function UpdateNameFormat(strName) {
	//do nothing.
}
--></script>
<%@ page language="java" import="utility.*,java.util.Vector " %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
	String strTemp2 = null;
	String strTemp3 = null;
	String strImgFileExt = null;

	int iAccessLevel = 0;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ENROLLMENT-FACULTY"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ENROLLMENT"),"0"));
		}
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ENROLLMENT-FACULTY-SUMMARY LOAD"),"0"));
		}
	}
	if(iAccessLevel == -1) {//for fatal error.
		request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		request.getSession(false).setAttribute("errorMessage","You are already logged out. Please login again.");
		response.sendRedirect("../../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0) {//NOT AUTHORIZED.
		response.sendRedirect("../../../commfile/unauthorized_page.jsp");
		return;
	}

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Enrollment-Faculty-Summary Load","summary_faculty_load_individual.jsp");
		ReadPropertyFile readPropFile = new ReadPropertyFile();
		strImgFileExt = readPropFile.getImageFileExtn("imgFileUploadExt");

		if(strImgFileExt == null || strImgFileExt.trim().length() ==0)
		{
			strErrMsg = "Image file extension is missing. Please contact school admin.";
			dbOP.cleanUP();
			throw new Exception();
		}
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
/**
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"Enrollment","FACULTY",request.getRemoteAddr(),
														"summary_faculty_load_individual.jsp");
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
**/
Vector vRetResult = null;
Vector vEmpRec = null;

if(WI.fillTextValue("emp_id").length() > 0) {
	enrollment.Authentication authentication = new enrollment.Authentication();
    vEmpRec = authentication.operateOnBasicInfo(dbOP,request,"0");
	if(vEmpRec == null)
		strErrMsg = "Employee has no profile.";
	else {
		boolean bolIncSubName = false;
		if(WI.fillTextValue("inc_subname").length() > 0)
		  bolIncSubName = true;
	  
		enrollment.FacultyManagementExtn fmExtn = new enrollment.FacultyManagementExtn();
		vRetResult = fmExtn.viewSummaryFacultyLoad(dbOP, (String)vEmpRec.elementAt(0), bolIncSubName);
		if(vRetResult == null) 
			strErrMsg = fmExtn.getErrMsg();	
	}
}

String strSchCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchCode == null)
	strSchCode = "";
%>
<body bgcolor="#D2AE72" onLoad="FocusID()">
<form action="./summary_faculty_load_individual.jsp" method="post" name="form_">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" id="myADTable0">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="2" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF" ><strong>:::: 
          FACULTY : SUMMARY OF FACULTY LOAD PAGE ::::</strong></font></div></td>
    </tr>
  </table>


  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" id="myADTable1">
    <tr > 
      <td height="25">&nbsp;</td>
      <td colspan="4"><font size="3"><b><%=WI.getStrValue(strErrMsg)%></b></font></td>
    </tr>
    <tr > 
      <td  width="2%" height="25">&nbsp;</td>
      <td width="14%">Employee ID</td>
      <td width="31%"> <input name="emp_id" type="text" size="16" value="<%=WI.fillTextValue("emp_id")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" onKeyUp="AjaxMapName(event);"></td>
      <td width="8%"><a href="javascript:OpenSearch();"><img src="../../../images/search.gif" width="37" height="30" border="0"></a></td>
      <td width="45%"><a href="javascript:ReloadPage();"><img src="../../../images/form_proceed.gif" border="0"></a>
	  &nbsp;&nbsp;&nbsp; 
<%
if(strSchCode.startsWith("EAC") && request.getParameter("emp_id") == null)
	strTemp = " checked";
else
	strTemp = WI.fillTextValue("inc_subname");
%>
	  <input type="checkbox" name="inc_subname" value="checked" <%=strTemp%>> Include Subject Description
	  
	  </td>
    </tr>
    <tr >
      <td></td>
      <td colspan="4"><label id="coa_info"></label></td>
    </tr>
    <tr > 
      <td height="19" colspan="5"><hr size="1"></td>
    </tr>
  </table>
<%
if(vEmpRec != null && vEmpRec.size() > 0) {%>
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF" id="myADTable2">
    <tr> 
      <td width="25%" height="18">&nbsp; </td>
      <td> 
        <%strTemp = "<img src=\"../../../upload_img/"+WI.fillTextValue("emp_id")+"."+strImgFileExt+"\" width=150 height=150 align=\"right\" border=1>";%>
        <%=WI.getStrValue(strTemp)%> <br> <br>
        <%
	strTemp  = WI.formatName((String)vEmpRec.elementAt(1),(String)vEmpRec.elementAt(2), (String)vEmpRec.elementAt(3),4);
	strTemp2 = (String)vEmpRec.elementAt(15);

	if((String)vEmpRec.elementAt(13) == null)
			strTemp3 = WI.getStrValue((String)vEmpRec.elementAt(14));
	else{
		strTemp3 =WI.getStrValue((String)vEmpRec.elementAt(13));
		if((String)vEmpRec.elementAt(14) != null)
		 strTemp3 += "/" + WI.getStrValue((String)vEmpRec.elementAt(14));
	}
%>
        <br> <strong><%=WI.getStrValue(strTemp)%></strong><br> <font size="1"><%=WI.getStrValue(strTemp2)%></font><br> 
        <font size="1"><%=WI.getStrValue(strTemp3)%></font><br> <br> <font size=1><%="Date Hired : "  + WI.formatDate((String)vEmpRec.elementAt(6),10)%><br>
        <%=new hr.HRUtil().getServicePeriodLength(dbOP,(String)vEmpRec.elementAt(0))%></font> 
        <br></td>
      <td width="25%">&nbsp;</td>
    </tr>
    <tr> 
      <td height="10">&nbsp;</td>
      <td height="10" valign="bottom">&nbsp;</td>
      <td height="10">&nbsp;</td>
    </tr>
    <tr> 
      <td height="18" colspan="3"><div align="right"><a href="javascript:PrintPg();"><img src="../../../images/print.gif" border="0" ></a> 
          <font size="1">click to print summary</font></div></td>
    </tr>
  </table>
<%
if(vRetResult != null && vRetResult.size() > 0) {%>
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF" class="thinborder">
    <tr bgcolor="#97ABC1"> 
      <td height="25" colspan="4" class="thinborder"><div align="center"><strong><font color="#FFFFFF" ><strong>SUMMARY 
          OF FACULTY LOAD</strong></font></strong></div></td>
    </tr>
    <tr> 
      <td width="15%" height="25" class="thinborder"><div align="center"><font size="1"><strong>SCHOOL YEAR</strong></font></div></td>
      <td width="15%" class="thinborder"><div align="center"><font size="1"><strong>TERM</strong></font></div></td>
      <td width="15%" class="thinborder"><div align="center"><font size="1"><strong>TOTAL LOAD UNITS</strong></font></div></td>
      <td width="55%" class="thinborder"><div align="center"><font size="1"><strong>SUBJECTS HANDLED</strong></font></div></td>
    </tr>
<%for(int i = 0; i < vRetResult.size(); i += 5) {%>
    <tr> 
      <td class="thinborder" height="25"><%=(String)vRetResult.elementAt(i) +" - "+(String)vRetResult.elementAt(i + 1)%></td>
      <td class="thinborder"><%=dbOP.getHETerm(Integer.parseInt((String)vRetResult.elementAt(i + 2)))%></td>
      <td class="thinborder"><%=(String)vRetResult.elementAt(i + 3)%></td>
      <td class="thinborder"><%=(String)vRetResult.elementAt(i + 4)%> </td>
    </tr>
<%}%>	
  </table>
<%}//only if vRetResult is not null;
}//show only if vEmpRec is not null;
%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" id="myADTable3">
    <tr> 
      <td height="25" colspan="4">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25" colspan="4" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>