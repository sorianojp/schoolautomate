<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Certificate of Transfer Credential</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<style type="text/css">
.textbox {
	background-color: #FDFDFD;
	border-style: inset;
	border-width: 1px;
	border-color: #194685;
	font-family:Verdana, Arial, Helvetica, sans-serif;
}
.style1 {
	font-size: 11px;
	font-family: Verdana, Arial, Helvetica, sans-serif;
}

.style3 {font-size: 11px; font-family: Verdana, Arial, Helvetica, sans-serif; color: #FFFFFF; }
</style>
</head>
<script language="javascript" src ="../../../Ajax/ajax.js" ></script>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../jscript/td.js"></script>
<script language="JavaScript">
function OpenSearch() {
	var pgLoc = "../../../search/srch_stud.jsp?opner_info=form_.stud_id";
	var win=window.open(pgLoc,"PrintWindow",'width=900,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

function ReloadPage(){
	document.form_.submit();
}

function setLabelText(strLabelName, strLabel){
	var strOld = document.getElementById(strLabelName).innerHTML;
	var strNewValue = prompt(strLabel, strOld);

	if (strNewValue != null && strNewValue.length > 0){
		document.getElementById("pending").innerHTML = strNewValue;
		document.getElementById("pending1").innerHTML = strNewValue;
	}
}
function setLabel(strLabelName, strLabel){
	var strOld = document.getElementById(strLabelName).innerHTML;
	var strNewValue = prompt(strLabel, strOld);

	if (strNewValue != null && strNewValue.length > 0){	
		document.getElementById(strLabelName).innerHTML = strNewValue;		
	}
}


function PrintPage(){	

	document.bgColor = "#FFFFFF";

	document.getElementById("myADTable1").deleteRow(0);
	document.getElementById("myADTable1").deleteRow(0);
	document.getElementById("myADTable1").deleteRow(0);
	document.getElementById("myADTable1").deleteRow(0);

	document.getElementById("myADTable2").deleteRow(1);
	document.getElementById("myADTable2").deleteRow(1);

	document.getElementById("myADTable4").deleteRow(0);
	document.getElementById("myADTable4").deleteRow(0);


	window.print();

}
//all about ajax.
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
		var strURL = "../../../Ajax/AjaxInterface.jsp?methodRef=2&search_id=1&name_format=4&complete_name="+
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
<body bgcolor="#D2AE72" onLoad="document.form_.stud_id.focus();">
<%@ page language="java" import="utility.*,enrollment.RLEInformation,java.util.Vector " %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);

	String strErrMsg = null;
	String strTemp = null;

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Registrar Management-REPORTS-other",
								"certificate_transfer_cred.jsp");
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
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,
											(String)request.getSession(false).getAttribute("userId"),
											"Registrar Management","REPORTS",
											request.getRemoteAddr(),
											"certificate_transfer_cred.jsp");

if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
	request.getSession(false).setAttribute("errorMessage","You are logged out. Please login again.");
	response.sendRedirect("../../../commfile/fatal_error.jsp");
	return;
}
else if(iAccessLevel == 0)//NOT AUTHORIZED.
{
	dbOP.cleanUP();
	response.sendRedirect("../../../commfile/unauthorized_page.jsp");
	return;
}
Vector vRetResult = null;
Vector vStudInfo = null;
String strGender = "Mr. ";
String strHisHer = "His ";
String strHeShe="he";
enrollment.ReportRegistrar rr= new enrollment.ReportRegistrar();
enrollment.OfflineAdmission offlineAdm = new enrollment.OfflineAdmission();

String[] astrSemester= {"Summer", "First Semester",
						"Second Semester", "Third Semester"};

if (WI.fillTextValue("stud_id").length() > 0){
	vRetResult = rr.getTCRecordOfStudent(dbOP,WI.fillTextValue("stud_id"));
	vStudInfo = offlineAdm.getStudentBasicInfo(dbOP, WI.fillTextValue("stud_id"));
	 

	if (vRetResult == null)
		strErrMsg = rr.getErrMsg();

	if (vRetResult != null) {
		if (((String)vRetResult.elementAt(3)).toLowerCase().equals("f")) {
			strGender="Ms. ";
			strHisHer="Her ";
			strHeShe="she";
		}
	}
	if(vStudInfo == null || vStudInfo.size() ==0)
		strErrMsg = offlineAdm.getErrMsg();
	 
}

%>

<form name="form_" action="./certificate_transfer_cred_spc.jsp" method="post" >

  <table bgcolor="#FFFFFF"  width="100%" border="0" cellspacing="0" cellpadding="0" id="myADTable1">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="4" align="center" class="style3"><strong class="style3">::::
        CERTIFICATE OF TRANSFER CREDENTIAL  ::::</strong></td>
    </tr>
    <tr>
      <td height="25" colspan="4" >
	  <a href="javascript:history.back();"><img src="../../../images/go_back.gif" border="0"></a>
	  &nbsp;&nbsp;
	  <strong style="font-size:14px; color:#FF0000"><%=WI.getStrValue(strErrMsg)%></strong></td>
    </tr>
<!--
    <tr>
      <td height="25" style="font-size:11px;"><span class="style3">&nbsp;&nbsp;SY/Term</span></td>
      <td colspan="3" ><%
strTemp = WI.fillTextValue("sy_from");
if(strTemp.length() ==0) {
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
}
%>
        <input type="text" name="sy_from" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeyPress="AllowOnlyInteger('form_', 'sy_from');"
	  onKeyUp='DisplaySYTo("form_","sy_from","sy_to")'>
        <%
strTemp = WI.fillTextValue("sy_to");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_to");
%>
        <input type="text" name="sy_to" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" readonly>
-
<select name="semester">
  <%
strTemp     = WI.fillTextValue("semester");
if(strTemp.length() ==0) {
	strTemp = (String)request.getSession(false).getAttribute("cur_sem");
}
if(strTemp.compareTo("0") ==0){%>
  <option value="0" selected>Summer</option>
  <%}else{%>
  <option value="0">Summer</option>
  <%}if(strTemp.compareTo("1") ==0){%>
  <option value="1" selected>1st Sem</option>
  <%}else{%>
  <option value="1">1st Sem</option>
  <%}if(strTemp.compareTo("2") == 0){%>
  <option value="2" selected>2nd Sem</option>
  <%}else{%>
  <option value="2">2nd Sem</option>
  <%}if(strTemp.compareTo("3") == 0){%>
  <option value="3" selected>3rd Sem</option>
  <%}else{%>
  <option value="3">3rd Sem</option>
  <%}%>
</select>
&nbsp;&nbsp;&nbsp;&nbsp;</td>
    </tr>
-->
    <tr valign="top">
      <td width="13%" height="25" class="style1" style="font-size:11px;">&nbsp;&nbsp;Student ID</td>
      <td width="21%" >
	  <input type="text" name="stud_id" value="<%=WI.fillTextValue("stud_id")%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="20" maxlength="32"
	   onKeyUp="AjaxMapName('1');"></td>
      <td width="5%" ><a href="javascript:ReloadPage();"><img src="../../../images/form_proceed.gif" width="81" height="21" border="0"></a><a href="javascript:OpenSearch();"></a></td>
      <td width="61%" ><label id="coa_info" style="font-size:11px; font-weight:bold; color:#0000FF"></label></td>
    </tr>
     <tr bgcolor="#FFFFFF"><td height="25" colspan="4" valign="top">&nbsp;</td>
	</tr>
  </table>
<% if (vRetResult != null) {%>
  <table  width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" id="myADTable2">
    <tr bgcolor="#FFFFFF">
      <td width="5%" height="25" valign="top">
          <p ALIGN="CENTER">&nbsp;</p>        </td>
      <td height="40" valign="top"><br><br><br><br><br><br><br><br><br><p  ALIGN="CENTER" style="font-size:17px"><strong> OFFICE OF THE REGISTRAR</strong></p>
        <p  ALIGN="CENTER"><br>CERTIFICATE OF TRANSFER CREDENTIAL</p>
        <p style="font-size:17px"><br>To  Whom It May Concern:</p>
        
        <p  style="text-align:justify; text-indent:50px; font-size:18px">This  certifies that
		&nbsp;<%=(String)vRetResult.elementAt(0) +  " " +
			    (String)vRetResult.elementAt(1)  +  " " +
				(String)vRetResult.elementAt(2) %>
		, &nbsp;a  <label id="_1" onClick="setLabel('_1','former student')">student/graduate</label> in our <%=WI.getStrValue((String)vStudInfo.elementAt(7)).toUpperCase()%> (<%=((String)vStudInfo.elementAt(24)).toUpperCase()%>) program (with last attendance <%if (vRetResult.elementAt(4)== null && vRetResult.elementAt(5)==null){%><%=astrSemester[Integer.parseInt(WI.getStrValue((String)vRetResult.elementAt(9),"1"))]%> <%=(String)vRetResult.elementAt(7)%> - <%=(String)vRetResult.elementAt(8)%><%} else {%>
		<%=astrSemester[Integer.parseInt(WI.getStrValue((String)vRetResult.elementAt(6),"1"))]%> <%=(String)vRetResult.elementAt(4)%> - <%=(String)vRetResult.elementAt(5)%><%}%>) has been granted permission to transfer from this college. <%=strHisHer%> transcript of record will be forwarded upon request from the College/University to which <%=strHeShe%> has transferred.
		</p>
        </font>
        <table width="100%" border="0"  cellpadding="0" cellspacing="0">
          <tr>
            <td width="65%"><font size="1"><br>NOT VALID WITHOUT<br>
            THE COLLEGE SEAL<br> <%=WI.getTodaysDate(6)%></font></td>
            <td width="35%"><div align="center"><label id="_7" onClick="setLabel('_7','')"><%=WI.getStrValue(CommonUtil.getNameForAMemberType(dbOP, "University Registrar",7)).toUpperCase()%></label><br>
                <label id="_8" onClick="setLabel('_8','College Registrar')">Registrar</label></div></td>
          </tr><br>
        </table>
		  <br>
		  <div style="border-bottom:dashed 1px #000000;"></div>
        <div align="center">RETURN SLIP</div>
        <table width="100%" border="0"  cellpadding="0" cellspacing="0">
          <tr>
              <td height="40">&nbsp;</td>
              <td>&nbsp;</td>
              <td>&nbsp;</td>
          </tr>
          <tr>
            <td width="60%" height="22">&nbsp;</td>
            <td width="15%">Student No</td>
            <td width="25%"><%=WI.fillTextValue("stud_id").toUpperCase()%></td>
          </tr>
		  <tr>
            <td width="60%" height="22">&nbsp;</td>
            <td width="15%">Course</td>
            <td width="25%"><%=((String)vStudInfo.elementAt(24)).toUpperCase()%></td>
		  </tr>
		  <tr>
            <td width="60%" height="22">&nbsp;</td>
            <td width="15%">Date</td>
            <td width="25%"><%=WI.getTodaysDate(6)%></td>
		  </tr>
        </table>
        <p style="font-size:17px">THE REGISTRAR<br><%=SchoolInformation.getSchoolName(dbOP,true,false)%>
       <br>
        <%=SchoolInformation.getAddressLine1(dbOP,false,false)%></p>
       
       
        <p  style="text-align:justify; text-indent:50px; font-size:17px"><%=strGender%> <%=(String)vRetResult.elementAt(0) +  " " +
			    (String)vRetResult.elementAt(1)  +  " " +
				(String)vRetResult.elementAt(2) %> has been enrolled in this College/University upon submisssion of a transfer credential certificate from your College. Kindly send us <%=strHisHer.toLowerCase()%> transcript as soon as possible.<br>
         


        <table width="100%" border="0"  cellpadding="0" cellspacing="0">
          <tr>
            <td width="54%" align="center" height="60">&nbsp;</td>
            <td width="46%" align="center" valign="bottom"><div style="border-bottom:solid 1px #000000; width:80%;"></div><font style="font-size:12px">REGISTRAR</font></td>
          </tr>
		  <tr>
            <td width="54%" align="center" valign="bottom" height="40">
				<div style="border-bottom:solid 1px #000000; width:50%;"></div><font style="font-size:12px">Student's Signature</font></td>
            <td width="46%" align="center" valign="bottom">
				<div style="border-bottom:solid 1px #000000; width:80%;"></div><font style="font-size:12px">College/University</font></td>
          </tr>
		  <tr>
            <td width="54%" align="center" height="40">&nbsp;</td>
            <td width="46%" align="center" valign="bottom">
				<div style="border-bottom:solid 1px #000000; width:80%;"></div><font style="font-size:12px">Address</font></td>
          </tr>
		  <tr>
            <td width="54%" align="center" height="40"></td>
            <td width="46%" align="center" valign="bottom">
				<div style="border-bottom:solid 1px #000000; width:80%;"></div><font style="font-size:12px">ZIP Code</font></td>
          </tr>
        </table>
       
            </td>
      <td width="5%" height="25" valign="top">&nbsp;</td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td height="25" valign="top">&nbsp;</td>
      <td height="25" valign="top">&nbsp;</td>
      <td height="25" valign="top">&nbsp;</td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td height="25" valign="top">&nbsp;</td>
      <td height="25" align="center" valign="top">
	  <a href="javascript:PrintPage()">
	  	<img src="../../../images/print.gif" width="58" height="26" border="0"></a>

	  <font size="1" face="Verdana, Arial, Helvetica, sans-serif">print page </font>	  </td>

      <td height="25" valign="top">&nbsp;</td>
    </tr>
  </table>
<% }%>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" id="myADTable4">
    <tr>
      <td colspan="8" height="25">&nbsp;</td>
    </tr>
    <tr>
      <td colspan="8" height="25" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>


</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
