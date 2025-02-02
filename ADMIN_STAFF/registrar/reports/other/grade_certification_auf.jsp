<%@ page language="java" import="utility.*,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	WebInterface WI  = new WebInterface(request);

	String strTemp   = null;
	String strErrMsg = null;
	
//authenticate this user.
	int iAccessLevel = -1;
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

//end of authenticaion code.

//add security here.
	try	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Registrar Management-REPORTS-Others-Grade Certification","grade_certification_auf.jsp");
	}
	catch(Exception exp) {
		exp.printStackTrace();
		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		Error in opening connection</font></p>
		<%
		return;
	}
Vector vStudInfo  = null;
Vector vGradeInfo = null;
String strGender  = null;
Vector vSYTermList   = null;

boolean bolIsMedicine = false;

enrollment.OfflineAdmission offlineAdm = new enrollment.OfflineAdmission();
enrollment.ReportRegistrarExtn RR = new enrollment.ReportRegistrarExtn();
strTemp = WI.fillTextValue("sy_term");
if(strTemp.length() > 0 && WI.fillTextValue("stud_id").length() > 0) {
	vStudInfo = offlineAdm.getStudentBasicInfo(dbOP, WI.fillTextValue("stud_id"), WI.fillTextValue("sy_from"), WI.fillTextValue("sy_to"), WI.fillTextValue("semester"));
	if(vStudInfo == null)
		strErrMsg = offlineAdm.getErrMsg();
	else {
		strGender = ((String)vStudInfo.elementAt(16)).toLowerCase();
		vGradeInfo = RR.getCertificationOfGrade(dbOP, request, (String)vStudInfo.elementAt(12));
		if(vGradeInfo == null)
			strErrMsg = RR.getErrMsg();
		else {
			vSYTermList = (Vector)vGradeInfo.remove(0);
		}
		if(vStudInfo.elementAt(15).equals("2"))
			bolIsMedicine = true;
	}
}


%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="javascript" src="../../../../Ajax/ajax.js"></script>
<script language="javascript" src="../../../../jscript/common.js"></script>
<script>
//// - all about ajax.. 
function AjaxMapName() {
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
	var strURL = "../../../../Ajax/AjaxInterface.jsp?methodRef=2&search_id=1&name_format=4&complete_name="+
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
var objLbl = null;
function UpdateLbl() {
	if(objLbl == null)
		objLbl = document.getElementById("purpose_lbl");
	if(objLbl)	
		objLbl.innerHTML = document.form_.purpose.value;
}
function PrintPg() {
	document.getElementById('myADTable1').deleteRow(0);
	document.getElementById('myADTable1').deleteRow(0);
	document.getElementById('myADTable1').deleteRow(0);
	document.getElementById('myADTable1').deleteRow(0);
	document.getElementById('myADTable1').deleteRow(0);
	document.getElementById('myADTable1').deleteRow(0);
	document.getElementById('myADTable1').deleteRow(0);

	alert("Click OK to print this page");
	window.print();//called to remove rows, make bk white and call print.
}

</script>

<body onLoad="document.form_.stud_id.focus();">
<form action="./grade_certification_auf.jsp" name="form_" method="post">
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" id="myADTable1">
    <tr>
      <td height="25" colspan="5" align="center"><strong>:::: CERTIFICATION OF GRADE ::::</strong></td>
    </tr>
    <tr>
      <td height="25" colspan="5">&nbsp;&nbsp;&nbsp;<font size="3"><%=WI.getStrValue(strErrMsg)%></font></td>
    </tr>
    <tr valign="top">
      <td width="2%" height="25">&nbsp;</td>
      <td width="15%">Student ID </td>
      <td width="12%"><input name="stud_id" type="text" size="16" value="<%=WI.fillTextValue("stud_id")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" onKeyUp="AjaxMapName('1');">      </td>
      <td width="10%"><input name="image" type="image" src="../../../../images/form_proceed.gif"></td>
      <td width="61%"><label id="coa_info" style="font-size:11px; font-weight:bold; color:#0000FF"></label></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td valign="top"><br>SY/Term<br>
	  <font size="1">Format : <br>2008-1,2009-2,2009-0
	  <br>(0 is for summer)</font></td>
      <td colspan="3">
	  <textarea name="sy_term" class="textbox_bigfont" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" cols="55" rows="5"><%=WI.fillTextValue("sy_term")%></textarea>	  </td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>Purpose</td>
      <td colspan="3"><input name="purpose" type="text" size="46" value="<%=WI.fillTextValue("purpose")%>" class="textbox" onKeyUp="UpdateLbl();"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="UpdateLbl();style.backgroundColor='white'"></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td colspan="3" align="right"><a href="javascript:PrintPg();"><img src="../../../../images/print.gif" border="0"></a><font size="1">Print Page.</font></td>
    </tr>
    <tr>
      <td height="25" colspan="5"><hr size="1"></td>
    </tr>
  </table>
<%if(vStudInfo != null && vStudInfo.size() > 0 && vGradeInfo != null && vGradeInfo.size() > 0) {%>  
  <table cellpadding="0" cellspacing="0" width="100%" border="0">
  	<tr>
		<td width="62%" align="right">&nbsp;</td>
	    <td width="38%"><%=WI.getTodaysDate(6)%><br>&nbsp;</td>
  	</tr>
  	<tr>
  	  <td colspan="2" align="right">&nbsp;</td>
    </tr>
  	<tr>
  	  <td colspan="2" align="right">&nbsp;</td>
    </tr>
  	<tr>
  	  <td colspan="2" align="center" style="font-size:18px; font-weight:bold">C E R T I F I C A T I O N</td>
    </tr>
  	<tr>
  	  <td colspan="2" style="font-size:14px;">&nbsp;</td>
    </tr>
  	<tr>
  	  <td colspan="2" style="font-size:14px;">&nbsp;</td>
    </tr>
  	<tr>
  	  <td colspan="2" style="font-size:14px;">TO WHOM IT MAY CONCERN:</td>
    </tr>
  	<tr>
  	  <td colspan="2" style="font-size:14px;">&nbsp;</td>
    </tr>
  	<tr>
<%
strTemp = (String)vStudInfo.elementAt(7);
if(vStudInfo.elementAt(8) != null)
	strTemp = strTemp + "-"+(String)vStudInfo.elementAt(8) + " ("+(String)vStudInfo.elementAt(25)+")";
else	
	strTemp = strTemp +" ("+(String)vStudInfo.elementAt(24)+")";
%>
 	  <td colspan="2" style="font-size:12px;">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;THIS IS TO CERTIFY that based on the records on file with this Office, <strong><%if(strGender.equals("m")){%>Mr.<%}else{%>Ms.<%}%> 
	  <%=WebInterface.formatName((String)vStudInfo.elementAt(0),(String)vStudInfo.elementAt(1),(String)vStudInfo.elementAt(2),7)%></strong> took the following subjects 
	  in the <%=vStudInfo.elementAt(26)%> leading to the degree of <strong><%=strTemp%></strong>, in this University:</td>
    </tr>
  </table>
  <br>
  <table cellpadding="0" cellspacing="0" width="100%" border="0">
  	<tr style="font-weight:bold">
		<td width="2%" height="25" align="center">&nbsp;</td>
	    <td width="68%"><u>SUBJECTS</u></td>
	    <td width="10%"><u><%if(bolIsMedicine){%>HOURS<%}else{%>UNITS<%}%></u></td>
  	    <td width="20%" align="center"><u>FINAL GRADES</u></td>
  	</tr>
<%
boolean bolHideSY = false;
String[] astrConvertSem = {"Summer","1st Sem","2nd Sem","3rd Sem"};
String strGrade = null; Integer objInt = null;
String strCE    = null;

float fGWA = 0f;
String strSQLQuery = null; String strCourseIndex = null; String strMajorIndex = null;
java.sql.ResultSet rs = null;
student.GWA gwa = new student.GWA();

while(vSYTermList.size() > 0){
strTemp   = (String)vSYTermList.remove(0);//sy_from
strErrMsg = (String)vSYTermList.remove(0);//sem.

strSQLQuery = "select course_index, major_index from stud_curriculum_hist where user_index = "+(String)vStudInfo.elementAt(12)+
			" and is_valid = 1 and sy_from = "+ strTemp+" and semester = "+strErrMsg;
rs = dbOP.executeQuery(strSQLQuery);
if(rs.next()) {
	strCourseIndex = rs.getString(1);
	strMajorIndex  = rs.getString(2);
}
rs.close();
fGWA = (float)gwa.getGWAForAStud(dbOP, (String)vStudInfo.elementAt(12),strTemp,null,strErrMsg,strCourseIndex,strMajorIndex,null);

if(!bolHideSY){
	if(bolIsMedicine)
		bolHideSY = true;
	%>
  	<tr>
  	  <td height="25">&nbsp;</td>
  	  <td style="font-weight:bold"><u><%if(!bolIsMedicine){%><%=astrConvertSem[Integer.parseInt(strErrMsg)]%>,<%}%> AY <%=strTemp%>-<%=Integer.parseInt(strTemp) + 1%></u></td>
  	  <td>&nbsp;</td>
      <td>&nbsp;</td>
  	</tr>
	<%}while(true) {
	if(vGradeInfo.size() == 0 || !strTemp.equals(vGradeInfo.elementAt(5)) || !strErrMsg.equals(vGradeInfo.elementAt(6)))
		break;
		objInt = (Integer)vGradeInfo.remove(0);
	%>
		<tr>
		  <td>&nbsp;</td>
		  <td height="25"><%=vGradeInfo.remove(0)%> - <%=vGradeInfo.remove(0)%></td>
		  <td>
		  <%
		  strCE = WI.getStrValue(vGradeInfo.remove(0),"&nbsp;");
		  strGrade = (String)vGradeInfo.remove(0);
		  if(vGradeInfo.size() > 6 && vGradeInfo.elementAt(3).equals(objInt)) {//same subject.. 
		  	vGradeInfo.remove(0);vGradeInfo.remove(0);vGradeInfo.remove(0);//remove the rest of vGrade info element for this row.. 
			vGradeInfo.remove(0);vGradeInfo.remove(0);vGradeInfo.remove(0);//remove upto sub name.. 
			strGrade = strGrade + "/"+(String)vGradeInfo.remove(0);
		  }%>
		  
		  <%=strGrade%></td>
		  <td align="center"><%=strCE%></td>
		</tr>
	<%vGradeInfo.remove(0);vGradeInfo.remove(0);}//end of while(true)%>
		<tr align="center">
		  <td>&nbsp;</td>
		  <td>&nbsp;</td>
		  <td>&nbsp;</td>
    	  <td style="font-weight:bold">GWA: <%=CommonUtil.formatFloat(fGWA,true)%></td>
		</tr>

<%}//end of while(vSYTermList.size() > 0)%>
  </table>
  <br>
  <table cellpadding="0" cellspacing="0" width="100%" border="0">
  	<tr>
		<td colspan="2">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;This certification is being issued upon request of <%if(strGender.equals("m")){%>Mr.<%}else{%>Ms.<%}%> <%=vStudInfo.elementAt(2)%> for
		<label id="purpose_lbl"><%=WI.fillTextValue("purpose")%></label>.</td>
	</tr>
  	<tr>
  	  <td colspan="2">&nbsp;</td>
    </tr>
  	
  	<tr>
  	  <td colspan="2">&nbsp;</td>
    </tr>
  	
  	<tr>
  	  <td>&nbsp;</td>
      <td align="center"><br><br><%=WI.getStrValue(CommonUtil.getNameForAMemberType(dbOP,"University Registrar",1))%></td>
  	</tr>
  	<tr>
  	  <td width="42%">&nbsp;</td>
      <td width="58%" align="center">University Registrar </td>
  	</tr>
  	<tr>
  	  <td colspan="2">&nbsp;</td>
    </tr>
  </table>
<%}%>
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
