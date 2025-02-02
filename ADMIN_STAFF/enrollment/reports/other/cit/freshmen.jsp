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

//print admission slip.
function printExamPermit() {
	var pgURL = "./exam_permit_print.jsp?stud_id="+document.form_.stud_id.value+
		"&sy_from="+document.form_.sy_from.value+
		"&sy_to="+document.form_.sy_to.value+
		"&semester="+document.form_.semester[document.form_.semester.selectedIndex].value+
		"&pmt_schedule="+document.form_.pmt_schedule[document.form_.pmt_schedule.selectedIndex].value;
	var win=window.open(pgURL,"myfile",'dependent=no,width=800,height=450,top=20,left=20,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function PrintPg() {
	document.getElementById('myADTable1').deleteRow(0);
	document.getElementById('myADTable1').deleteRow(0);

	document.getElementById('myADTable2').deleteRow(0);
	document.getElementById('myADTable2').deleteRow(0);
	document.getElementById('myADTable2').deleteRow(0);
	window.print();
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
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ENROLLMENT-REPORTS"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ENROLLMENT"),"0"));
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
Vector vRetResult = null; Vector vSubSchedule = new Vector();
if(WI.fillTextValue("show_result").equals("1")) {
	enrollment.ReportEnrollment RE = new enrollment.ReportEnrollment();
	vRetResult = RE.getFreshmenEnrollmentDetail(dbOP, request);
	if(vRetResult == null)
		strErrMsg = RE.getErrMsg();
}

%>
<body>
<form name="form_" action="./freshmen.jsp" method="post" onSubmit="SubmitOnceButton(this);">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" id="myADTable1">
    <tr bgcolor="#A49A6A"> 
      <td height="25" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF" ><strong>:::: FRESHMEN ENROLLMENT INFORMATION PAGE ::::</strong></font></div></td>
    </tr>
    <tr bgcolor="#FFFFFF"> 
      <td height="25" >&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<font style="font-size:16px; font-weight:bold; color:#FF0000"><b><%=WI.getStrValue(strErrMsg)%></b></font></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" id="myADTable2">
    
    <tr> 
      <td width="2%" height="25">&nbsp;</td>
      <td width="13%" height="25">SY/TERM</td>
      <td width="170%" height="25" colspan="2"> <%
strTemp = WI.fillTextValue("sy_from");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
%> <input name="sy_from" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp='DisplaySYTo("form_","sy_from","sy_to")'>
        to 
        <%
strTemp = WI.fillTextValue("sy_to");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_to");
%> <input name="sy_to" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  readonly="yes"> <select name="semester">
          <option value="0">Summer</option>
          <%
strTemp = WI.fillTextValue("semester");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sem");

		// force to 1 (regular for basic ) if not summer and if basic
		if (WI.fillTextValue("is_basic").equals("1") && !strTemp.equals("0"))  
			strTemp = "1";
	
		  if(strTemp.equals("1")){
		  %>
          <option value="1" selected>1st Sem</option>
          <%}else{%>
          <option value="1">1st Sem</option>
          <%}if(strTemp.equals("2")){%>
          <option value="2" selected>2nd Sem</option>
          <%}else{%>
          <option value="2">2nd Sem</option>
          <%}if(strTemp.equals("3")){%>
          <option value="3" selected>3rd Sem</option>
          <%}else{%>
          <option value="3">3rd Sem</option>
          <%}%>
        </select> &nbsp;&nbsp;&nbsp;&nbsp;</td>
    </tr>
    
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25" colspan="2"> 
	  <input type="submit" name="1" value="&nbsp;&nbsp;Show Result&nbsp;&nbsp;" 
	  	style="font-size:11px; height:28px;border: 1px solid #FF0000;" onClick="document.form_.show_result.value='1'"></td>
    </tr>
<%if(vRetResult != null && vRetResult.size() > 0) {%>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25" colspan="2" align="right" style="font-size:9px;"><a href="javascript:PrintPg();"><img src="../../../../../images/print.gif" border="0"></a>Print Page</td>
    </tr>
<%}%>
  </table>


<%if(vRetResult != null && vRetResult.size() > 0) {%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" id="myADTable4">
    <tr> 
      <td height="25" width="2%">Count</td>
      <td width="13%">Student ID </td>
      <td width="15%">Student Name </td>
      <td width="8%">Course-Year</td>
      <td width="12%">Subject Code </td>
      <td width="15%">Subject Name </td>
      <td width="5%">Section </td>
      <td width="10%">Lec Schedule </td>
      <td width="5%">Lec Room </td>
      <td width="10%">Lec Faculty </td>
      <td width="10%">Lab Schedule </td>
      <td width="5%">Lab Room</td>
      <td width="10%">Lab Faculty </td>
    </tr>
    <%
	int iCount = 0;
	for(int i = 0; i < vRetResult.size(); i +=7) {
		if(vSubSchedule.size() == 0)
			vSubSchedule = (Vector)vRetResult.elementAt(i +6); 
		if(vSubSchedule == null || vSubSchedule.size() == 0) { 
			System.out.println("Erorr in enrollment Information of student: "+vRetResult.elementAt(i + 1));
			continue;
		}
			%>
    <tr> 
      <td height="25" width="2%"><%=++iCount%></td>
      <td width="13%"><%=vRetResult.elementAt(i + 1)%></td>
      <td width="15%"><%=vRetResult.elementAt(i + 2)%></td>
      <td width="8%"><%=vRetResult.elementAt(i + 3)%> <%=WI.getStrValue((String)vRetResult.elementAt(i + 4), "", "", "")%> <%=WI.getStrValue((String)vRetResult.elementAt(i + 5), "-", "", "")%></td>
      <td width="12%"><%=WI.getStrValue(vSubSchedule.elementAt(0), "&nbsp;")%></td>
      <td width="15%"><%=WI.getStrValue(vSubSchedule.elementAt(1), "&nbsp;")%></td>
      <td width="5%"><%=WI.getStrValue(vSubSchedule.elementAt(2), "&nbsp;")%></td>
      <td width="10%"><%=WI.getStrValue(vSubSchedule.elementAt(3), "&nbsp;")%></td>
      <td width="5%"><%=WI.getStrValue(vSubSchedule.elementAt(4), "&nbsp;")%></td>
      <td width="10%"><%=WI.getStrValue(vSubSchedule.elementAt(8), "&nbsp;")%></td>
      <td width="10%"><%=WI.getStrValue(vSubSchedule.elementAt(5), "&nbsp;")%></td>
      <td width="5%"><%=WI.getStrValue(vSubSchedule.elementAt(6), "&nbsp;")%></td>
      <td width="10%"><%=WI.getStrValue(vSubSchedule.elementAt(10), "&nbsp;")%></td>
    </tr>
	<%vSubSchedule.remove(0);vSubSchedule.remove(0);vSubSchedule.remove(0);vSubSchedule.remove(0);vSubSchedule.remove(0);
	vSubSchedule.remove(0);vSubSchedule.remove(0);vSubSchedule.remove(0);vSubSchedule.remove(0);vSubSchedule.remove(0);vSubSchedule.remove(0);
	if(vSubSchedule.size() > 0)
		i = i - 7;
	}%> 
	<tr>
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
  </table>
<%}%>
  <input type="hidden" name="show_result">
</form>

</body>
</html>
<%
dbOP.cleanUP();
%>