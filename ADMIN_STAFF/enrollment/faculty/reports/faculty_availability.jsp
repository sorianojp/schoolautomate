<%
if(request.getParameter("printPg") != null && request.getParameter("printPg").compareTo("1") ==0){%>
		<jsp:forward page="./faculty_availability_print.jsp" />
<%}%>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../css/reportlink.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../../Ajax/ajax.js"></script>
<script language="JavaScript" src="../../../../jscript/common.js"></script>
<script language="JavaScript">
function ViewFacultyLoadDtls(strStudID) {
	var pgLoc = "../teaching_load_slip.jsp?emp_id="+strStudID+"&sy_from="+
	document.form_.sy_from.value+"&sy_to="+document.form_.sy_to.value+
	"&semester="+document.form_.semester.value+"&get_hour_load=1";
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function OpenSearch() {
	var pgLoc = "../../../../search/srch_emp.jsp?opner_info=form_.emp_id";
	var win=window.open(pgLoc,"PrintWindow",'width=900,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function ReloadPage()
{
	document.form_.printPg.value = "";
	document.form_.submit();
}
function PrintPg()
{
	document.form_.printPg.value = "1";
	document.form_.range.value = document.form_.time_from_hr.value +":"+
									document.form_.time_from_min.value+" "+
									document.form_.time_from_AMPM[document.form_.time_from_AMPM.selectedIndex].text+
									" to "+
									document.form_.time_to_hr.value +":"+
									document.form_.time_to_min.value+" "+
									document.form_.time_to_AMPM[document.form_.time_to_AMPM.selectedIndex].text+
									" ("+document.form_.week_day.value +")"

	document.form_.submit();
}
function ShowResult() {
	document.form_.show_.value = "1";
	this.ReloadPage();
}
//all about ajax - to display student list with same name.
function AjaxMapName() {
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
		var strURL = "../../../../Ajax/AjaxInterface.jsp?methodRef=2&search_id=1&is_faculty=1&name_format=4&complete_name="+
			escape(strCompleteName);

		this.processRequest(strURL);
}
function UpdateID(strID, strUserIndex) {
	document.form_.emp_id.value = strID;
	document.getElementById("coa_info").innerHTML = "<font size='1' color=blue>...end of processing..</font>";
}
function UpdateName(strFName, strMName, strLName) {
	//do nothing.
}
function UpdateNameFormat(strName) {
	//do nothing.
}
-->
</script>
<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*,enrollment.FacMgmtSubstitution,java.util.Vector" %>
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
		
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
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ENROLLMENT-FACULTY-REPORTS"),"0"));
		}
	}
	if(iAccessLevel == -1) {//for fatal error.
		request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		request.getSession(false).setAttribute("errorMessage","You are already logged out. Please login again.");
		response.sendRedirect("../../../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0) {//NOT AUTHORIZED.
		response.sendRedirect("../../../../commfile/unauthorized_page.jsp");
		return;
	}

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Enrollment-Faculty-substitute-REPORTS","faculty_availability.jsp");
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
														"faculty_availability.jsp");
if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
	request.getSession(false).setAttribute("errorMessage",comUtil.getErrMsg());
	response.sendRedirect("../../../../commfile/fatal_error.jsp");
	return;
}
else if(iAccessLevel == 0)//NOT AUTHORIZED.
{
	dbOP.cleanUP();
	response.sendRedirect("../../../../commfile/unauthorized_page.jsp");
	return;
}
**/
//end of authenticaion code.

Vector vRetResult = new Vector();
FacMgmtSubstitution facSubs = new FacMgmtSubstitution(dbOP);
Vector vOccupied  = null;
Vector vAvailable = null;
if(WI.fillTextValue("sy_from").length() > 0 && WI.fillTextValue("sy_to").length() > 0 && WI.fillTextValue("semester").length() > 0
	&& WI.fillTextValue("show_").length() > 0)
{
	vRetResult = facSubs.getFacAvailabilityStat(dbOP,request);
	if(vRetResult == null)
		strErrMsg = facSubs.getErrMsg();
	else	
	{
		vOccupied  = (Vector)vRetResult.elementAt(0);
		vAvailable = (Vector)vRetResult.elementAt(1);
	}
}
%>
<form name="form_" action="./faculty_availability.jsp" method="post">

  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr bgcolor="#A49A6A" >
      <td height="25" colspan="5"><div align="center"><font color="#FFFFFF"><strong>:::: 
          FACULTY AVAILABILITY - SEARCH PAGE ::::</strong></font></strong></font></div></td>
    </tr>
  </table>

  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="27"></td>
      <td colspan="2"><font size="3"><%=WI.getStrValue(strErrMsg)%></font></td>
    </tr>
    <tr> 
      <td height="25"></td>
      <td colspan="2">SCHOOL YEAR 
        <%
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
	  readonly="yes"> &nbsp; <select name="semester">
          <option value="1">1st Sem</option>
          <%
strTemp =WI.fillTextValue("semester");
if(strTemp.length() ==0) strTemp = (String)request.getSession(false).getAttribute("cur_sem");
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
          <%}%>
        </select></td>
    </tr>
    <tr> 
      <td height="25" colspan="3"><hr size="1"></td>
    </tr>
    <tr> 
      <td width="3%" height="25"></td>
      <td>FACULTY STATUS</td>
      <td> <select name="fac_stat">
          <option value="">All</option>
          <%
strTemp = WI.fillTextValue("fac_stat");
if(strTemp.compareTo("Occupied") ==0){%>
          <option selected value="Occupied">Occupied</option>
          <%}else{%>
          <option value="Occupied">Occupied</option>
          <%}if(strTemp.compareTo("Available") == 0){%>
          <option value="Available" selected>Available</option>
          <%}else{%>
          <option value="Available">Available</option>
          <%}%>
        </select> </td>
    </tr>
    <tr> 
      <td height="25"></td>
      <td>RANGE</td>
      <td><input type="text" name="week_day" size="20" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=WI.fillTextValue("week_day")%>"
	  onKeypress=" if(event.keyCode>47 && event.keyCode < 58) event.returnValue=false;" OnKeyUP="javascript:this.value=this.value.toUpperCase();">
        (M-T-W-TH-F-SAT-S)</td>
    </tr>
    <tr> 
      <td height="25"></td>
      <td>&nbsp;</td>
      <td><input type="text" name="time_from_hr" size="2" maxlength="2" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=WI.fillTextValue("time_from_hr")%>"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;">
        : 
        <input type="text" name="time_from_min" size="2" maxlength="2" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=WI.fillTextValue("time_from_min")%>"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;">
        : 
        <select name="time_from_AMPM">
          <option selected value="0">AM</option>
          <%
strTemp = WI.fillTextValue("time_from_AMPM");
if(strTemp.compareTo("1") ==0){%>
          <option value="1" selected>PM</option>
          <%}else{%>
          <option value="1">PM</option>
          <%}%>
        </select>
        to 
        <input type="text" name="time_to_hr" size="2" maxlength="2" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=WI.fillTextValue("time_to_hr")%>"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;">
        : 
        <input type="text" name="time_to_min"  size="2" maxlength="2" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=WI.fillTextValue("time_to_min")%>"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;">
        : 
        <select name="time_to_AMPM">
          <option selected value="0">AM</option>
          <%
strTemp = WI.fillTextValue("time_to_AMPM");
if(strTemp.compareTo("1") ==0){%>
          <option value="1" selected>PM</option>
          <%}else{%>
          <option value="1">PM</option>
          <%}%>
        </select> </td>
    </tr>
    <tr> 
      <td height="25"></td>
      <td>COLLEGE</td>
      <td><select name="c_index" onChange="ReloadPage();">
          <option value="">Select a college</option>
          <%
	strTemp = WI.fillTextValue("c_index");
%>
          <%=dbOP.loadCombo("c_index","C_NAME"," from COLLEGE where IS_DEL=0 order by c_name asc", strTemp, false)%> </select></td>
    </tr>
    <tr> 
      <td height="25"></td>
      <td width="14%">DEPARTMENT</td>
      <td width="83%"><select name="d_index">
          <option value="">Select a Department</option>
          <%
	strTemp = WI.fillTextValue("c_index");
	if(strTemp.length() == 0)
		strTemp = " and (c_index is null or c_index = 0)";
	else	
		strTemp = " and c_index = "+strTemp;
%>
          <%=dbOP.loadCombo("d_index","d_NAME"," from department where IS_DEL=0 "+strTemp+" order by d_name asc", 
		  WI.fillTextValue("d_index"), false)%> </select>      </td>
    </tr>
    <tr> 
      <td height="25"></td>
      <td>EMPLOYEE ID</td>
      <td><input name="emp_id" type="text" size="16" class="textbox" value="<%=WI.fillTextValue("emp_id")%>"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" onKeyUp="AjaxMapName();"> 
        <a href="javascript:OpenSearch();"><img src="../../../../images/search.gif" border="0" hspace="20" height="25"></a></td>
    </tr>
    <tr >
      <td></td>
      <td colspan="2"><label id="coa_info"></label></td>
    </tr>
    <tr>
      <td height="25"></td>
      <td>&nbsp;</td>
      <td><a href="javascript:ShowResult();"><img src="../../../../images/form_proceed.gif" border="0"></a></td>
    </tr>
  </table>

  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="25"><div align="center">
          <hr size="1">
        </div></td>
    </tr>
  </table>
<%
if(vRetResult != null && vRetResult.size() > 0){%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr >
      <td height="25" width="3%">&nbsp;</td>
      <td >&nbsp;</td>
      <td><div align="right"><a href="javascript:PrintPg();"><img src="../../../../images/print.gif" width="58" height="26" border="0"></a><font size="1">click 
          to print statistics</font></div></td>
    </tr>
  </table>
<%
if(vOccupied != null && vOccupied.size() > 0){%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr bgcolor="#DBD8C8">
      <td height="20" width="3%">&nbsp;</td>
      <td ><font size="1">FACULTY STATUS :<strong> OCCUPIED ::: TOTAL: <%=vAvailable.size()/ 5%></strong></font></td>
      <td><div align="right"></div></td>
    </tr>
  </table>

  <table width="100%" border="1" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="15%" height="27" align="center"><font size="1"><strong>EMPLOYEE 
        ID</strong></font></td>
      <td width="29%" align="center"><font size="1"><strong>NAME</strong></font></td>
      <td width="24%" align="center"><font size="1"><strong>COLLEGE</strong></font></td>
      <td width="24%" align="center"><font size="1"><strong>DEPARTMENT</strong></font></td>
      <td width="8%" align="center"><font size="1"><strong>LOAD UNIT</strong></font></td>
    </tr>
    <%
for(int i = 0; i< vOccupied.size();i +=5){%>
    <tr> 
      <td height="25">
	  <a href='javascript:ViewFacultyLoadDtls("<%=(String)vOccupied.elementAt(i)%>");'>
	  <%=(String)vOccupied.elementAt(i)%></a></td>
      <td><%=(String)vOccupied.elementAt(i+1)%></td>
      <td><%=WI.getStrValue(vOccupied.elementAt(i+2),"N/A")%></td>
      <td><%=WI.getStrValue(vOccupied.elementAt(i+3),"N/A")%></td>
      <td><%=(String)vOccupied.elementAt(i+4)%></td>
    </tr>
<%}%>
  </table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td width="3%" height="25">&nbsp;</td>
      <td width="89%" align="right">&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
    <tr> 
  </table>
<%}//if occupied room is having some value. 
if(vAvailable != null && vAvailable.size() > 0){%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr bgcolor="#DBD8C8">
      <td height="20" width="3%">&nbsp;</td>
      <td ><font size="1">FACULTY STATUS :<strong> AVAILABLE ::: TOTAL: 
	  <%=vAvailable.size()/ 5%></strong></font></td>
      <td><div align="right"></div></td>
    </tr>
  </table>

  <table width="100%" border="1" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="15%" height="27" align="center"><font size="1"><strong>EMPLOYEE 
        ID</strong></font></td>
      <td width="29%" align="center"><font size="1"><strong>NAME</strong></font></td>
      <td width="24%" align="center"><font size="1"><strong>COLLEGE</strong></font></td>
      <td width="24%" align="center"><font size="1"><strong>DEPARTMENT.</strong></font></td>
      <td width="8%" align="center"><font size="1"><strong>LOAD UNIT</strong></font></td>
    </tr>
    <%
for(int i = 0; i< vAvailable.size();i +=5){%>
    
<tr> 
      <td height="25">
	  <a href='javascript:ViewFacultyLoadDtls("<%=(String)vAvailable.elementAt(i)%>");'><%=(String)vAvailable.elementAt(i)%></a>
	  </td>
      <td><%=(String)vAvailable.elementAt(i+1)%></td>
      <td><%=WI.getStrValue(vAvailable.elementAt(i+2),"N/A")%></td>
      <td><%=WI.getStrValue(vAvailable.elementAt(i+3),"N/A")%></td>
      <td><%=(String)vAvailable.elementAt(i+4)%></td>
    </tr>
<%}%>
  </table>

<%
	}//if vAvailable Room is not null. 	
}//only if vRetResult is not null
%>

  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25"><div align="center"></div></td>
      <td width="26%" height="25">&nbsp;</td>
    </tr>
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="3">&nbsp;</td>
    </tr>
  </table>
<input type="hidden" name="printPg">
<input type="hidden" name="range">
<input type="hidden" name="show_">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>