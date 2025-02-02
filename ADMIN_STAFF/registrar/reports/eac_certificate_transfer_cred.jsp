<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<link href="../../../css/common.css" rel="stylesheet" type="text/css">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
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

function PrintPage(){
	//var strOld = document.getElementById("pending").innerHTML;

	/**if (strOld.indexOf("(** click for") != -1){
		document.getElementById("pending").innerHTML = "";
		document.getElementById("pending1").innerHTML = "";
	}*/

	document.bgColor = "#FFFFFF";

	document.getElementById("myADTable1").deleteRow(0);
	document.getElementById("myADTable1").deleteRow(0);
	document.getElementById("myADTable1").deleteRow(0);
	document.getElementById("myADTable1").deleteRow(0);

	//document.getElementById("myADTable2").deleteRow(1);
	//document.getElementById("myADTable2").deleteRow(1);

	document.getElementById("myADTable4").deleteRow(0);
	document.getElementById("myADTable4").deleteRow(0);
	
	document.getElementById("myADTable5").deleteRow(0);
	document.getElementById("myADTable5").deleteRow(0);


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
								"eac_certificate_transfer_cred.jsp");
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
											"eac_certificate_transfer_cred.jsp");

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
String strCollegeName = null;
Vector vRetResult = null;
String strGender = "Mr. ";
String strHisHer = "His ";
enrollment.ReportRegistrar rr= new enrollment.ReportRegistrar();

String[] astrSemester= {"Sum", "1st", "2nd", "3rd"};

if (WI.fillTextValue("stud_id").length() > 0){
	vRetResult = rr.getTCRecordOfStudent(dbOP,WI.fillTextValue("stud_id"));	
	if (vRetResult == null)
		strErrMsg = rr.getErrMsg();
	else{
		if (((String)vRetResult.elementAt(3)).toLowerCase().equals("f")) {
			strGender="Ms. ";
			strHisHer="Her ";
		}
		
		strCollegeName = " select c_name from college join course_offered on (course_offered.c_index = college.c_index) "+
				" join stud_curriculum_hist on (stud_curriculum_hist.course_index = course_offered.course_index) "+
				" join user_table on (user_table.user_index = stud_curriculum_hist.user_index) "+
				" where stud_curriculum_hist.is_valid = 1 and sy_from = "+(String)vRetResult.elementAt(7)+" and semester = "+(String)vRetResult.elementAt(9)+
				" and id_number = "+WI.getInsertValueForDB(WI.fillTextValue("stud_id"),true, null);		
		strCollegeName = WI.getStrValue(dbOP.getResultOfAQuery(strCollegeName,0),"");		
	}
}

//System.out.println(vRetResult);

%>

<form name="form_" action="./eac_certificate_transfer_cred.jsp" method="post" >

  <table bgcolor="#FFFFFF"  width="100%" border="0" cellspacing="0" cellpadding="0" id="myADTable1">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="4" align="center" class="style3"><strong class="style3">::::
        CERTIFICATE OF TRANSFER CREDENTIAL  ::::</strong></td>
    </tr>
    <tr>
      <td height="25" colspan="4" >
	  <a href="./tc_main.jsp"><img src="../../../images/go_back.gif" border="0"></a>
	  &nbsp;&nbsp;
	  <strong style="font-size:14px; color:#FF0000"><%=WI.getStrValue(strErrMsg)%></strong></td>
    </tr>

    <tr>
      <td width="13%" height="25">&nbsp;&nbsp;Student ID</td>
      <td width="21%" >
	  <input type="text" name="stud_id" value="<%=WI.fillTextValue("stud_id")%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="20" maxlength="32"
	   onKeyUp="AjaxMapName('1');"></td>
      <td width="5%" ><a href="javascript:ReloadPage();"><img src="../../../images/form_proceed.gif" width="81" height="21" border="0"></a><a href="javascript:OpenSearch();"></a></td>
      <td width="61%" valign="top" ><label id="coa_info" style="font-size:11px; position:absolute; width:500px; font-weight:bold; color:#0000FF"></label></td>
    </tr>
     <tr bgcolor="#FFFFFF"><td height="25" colspan="4" valign="top">&nbsp;</td>
	</tr>
  </table>
<% if (vRetResult != null) {%>

<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
	<tr><td align="center"><font size="+1"><strong><%=SchoolInformation.getSchoolName(dbOP,true,false)%></strong></font><br>
		<%=SchoolInformation.getAddressLine1(dbOP,false,false)%><br><u><font color="#0033FF">registrar@eac.edu.ph</font></u>
		<br><br>
		<strong>CERTIFICATE OF TRANSFER CREDENTIAL</strong>
	</td></tr>
	<tr><td>&nbsp;</td></tr>
	<tr><td align="right"><%=WI.getTodaysDate(6)%></td></tr>
	
	<tr><td>TO WHOM IT MAY CONCERN:</td></tr>
	<tr><td>&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; This certifies that <%=strGender%> <u>&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; <strong>
				<%=(String)vRetResult.elementAt(0) +  " " +
			    (String)vRetResult.elementAt(1)  +  " " +
				(String)vRetResult.elementAt(2) %></strong>&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; </u> 
		a student in our <u>&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; <strong><%=strCollegeName.toUpperCase()%></strong>&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; </u> 
		&nbsp;with last attendance <u>&nbsp; &nbsp; &nbsp; 
		<strong><%=astrSemester[Integer.parseInt(WI.getStrValue((String)vRetResult.elementAt(6),"1"))]%></strong>&nbsp; &nbsp; &nbsp; </u> 
		Sem, <u>&nbsp; &nbsp; &nbsp; &nbsp; 
			<strong><%=(String)vRetResult.elementAt(4)%> - <%=(String)vRetResult.elementAt(5)%></strong>&nbsp; &nbsp; &nbsp; &nbsp; </u> 
		&nbsp;has been granted the TRANSFER CREDENTIAL from this College effective today.<br><br>
	
	&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; <%=strHisHer%> Transcript of Records will be sent upon receipt of return slip. _____________NSAT %ILE RANK ______________
	
	</td></tr>
	<tr><td height="25">&nbsp;</td></tr>
	<tr>
		<td>
			<table width="100%">
				<tr>
					<td width="50%" rowspan="2">&nbsp;</td>
					<td align="center"><u><strong><%=WI.getStrValue(CommonUtil.getNameForAMemberType(dbOP, "University Registrar",7)).toUpperCase()%></strong></u></td>
				</tr>
				<tr>
					<td align="center">REGISTRAR</td>
				</tr>
			</table>
		</td>
	</tr>
	<tr><td>&nbsp;</td></tr>
	<tr><td><strong>FILE COPY</strong></td></tr>
	<tr><td>&nbsp;<br><br><br><br>&nbsp;</td></tr>
</table>




<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
	<tr><td align="center"><font size="+1"><strong><%=SchoolInformation.getSchoolName(dbOP,true,false)%></strong></font><br>
		<%=SchoolInformation.getAddressLine1(dbOP,false,false)%><br><u><font color="#0033FF">registrar@eac.edu.ph</font></u>
		<br><br>
		<strong>CERTIFICATE OF TRANSFER CREDENTIAL</strong>
	</td></tr>
	<tr><td>&nbsp;</td></tr>
	<tr><td align="right"><%=WI.getTodaysDate(6)%></td></tr>
	
	<tr><td>TO WHOM IT MAY CONCERN:</td></tr>
	<tr><td>&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; This certifies that <%=strGender%> <u>&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; <strong>
				<%=(String)vRetResult.elementAt(0) +  " " +
			    (String)vRetResult.elementAt(1)  +  " " +
				(String)vRetResult.elementAt(2) %></strong>&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; </u> 
		a student in our <u>&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; <strong><%=strCollegeName.toUpperCase()%></strong>&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; </u> 
		&nbsp;with last attendance <u>&nbsp; &nbsp; &nbsp; 
		<strong><%=astrSemester[Integer.parseInt(WI.getStrValue((String)vRetResult.elementAt(6),"1"))]%></strong>&nbsp; &nbsp; &nbsp; </u> 
		Sem, <u>&nbsp; &nbsp; &nbsp; &nbsp; 
			<strong><%=(String)vRetResult.elementAt(4)%> - <%=(String)vRetResult.elementAt(5)%></strong>&nbsp; &nbsp; &nbsp; &nbsp; </u> 
		&nbsp;has been granted the TRANSFER CREDENTIAL from this College effective today.<br><br>
	
	&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; <%=strHisHer%> Transcript of Records will be sent upon receipt of return slip. _____________NSAT %ILE RANK ______________
	
	</td></tr>
	<tr><td height="25">&nbsp;</td></tr>
	<tr>
		<td>
			<table width="100%">
				<tr>
					<td width="50%" rowspan="2">&nbsp;</td>
					<td align="center"><u><strong><%=WI.getStrValue(CommonUtil.getNameForAMemberType(dbOP, "University Registrar",7)).toUpperCase()%></strong></u></td>
				</tr>
				<tr>
					<td align="center">REGISTRAR</td>
				</tr>
			</table>
		</td>
	</tr>
	<tr><td>&nbsp;</td></tr>
	<tr><td><strong>COPY FOR THE SCHOOL</strong></td></tr>
	<tr><td>&nbsp;<br><br><br><br>&nbsp;</td></tr>
</table>








<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
	<tr><td align="center"><strong><i>RETURN SLIP</i></strong><br><font size="+1"><strong><%=SchoolInformation.getSchoolName(dbOP,true,false)%></strong></font><br>
		<%=SchoolInformation.getAddressLine1(dbOP,false,false)%><br><u><font color="#0033FF">registrar@eac.edu.ph</font></u>
		<br><br>
		<strong>OFFICE OF THE REGISTRAR</strong>
	</td></tr>
	<tr><td>&nbsp;</td></tr>
	<tr>
		<td>
			<table width="100%">
				<tr>
					<td width="85%">&nbsp;</td>
					<td align="center" class="thinborderBOTTOM">&nbsp;</td>					
				</tr>
				<tr>
					<td>&nbsp;</td>
					<td align="center">Date</td>					
				</tr>
			</table>
		</td>
	</tr>
	<!--<tr><td>&nbsp;</td></tr>-->
	
	
	<tr>
	  <td>&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; Please furnish us with the Transcript of Record of ______________________________________, who 
			has been temporarily admitted to the College of ______________________________________ , pending 
			receipt of the document.</td>
	</tr>
	<tr><td>&nbsp;</td></tr>
	<tr>
		<td>
			<table width="100%">
				<tr>
					<td width="40%" class="thinborderBOTTOM">&nbsp;</td>
					<td align="">&nbsp;</td>
					<td align="center" width="40%" class="thinborderBOTTOM">&nbsp;</td>
				</tr>
				<tr>
					<td align="center">STUDENT</td>
					<td align="center">&nbsp;</td>
					<td align="center">REGISTRAR</td>
				</tr>
				<tr><td colspan="3">&nbsp;</td></tr>
				<tr>
					<td>Signature Over Printed Name</td>
					<td></td>
					<td>Signature Over Printed Name</td>
				</tr>
				<tr><td colspan="3">&nbsp;</td></tr>
				<Tr>
					<td width="40%" class="thinborderBOTTOM">&nbsp;</td>
					<td align="">&nbsp;</td>
					<td align="" width="40%" class="thinborderBOTTOM">&nbsp;</td>
				</tr>
				<tr>
					<td align="center">SCHOOL</td>
					<td align="center">&nbsp;</td>
					<td align="center">COURSE</td>
				</tr>
				
				<tr><td colspan="3">&nbsp;</td></tr>
				
				<tr><td colspan="3" class="thinborderBOTTOM">&nbsp;</td></tr>
				<tr><td colspan="3" align="center">ADDRESS</td></tr>
			</table>
		</td>
	</tr>
</table>

<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" id="myADTable5">
	<tr><td>&nbsp;</td></tr>
	<tr><td height="25" align="center" valign="top">
	  <a href="javascript:PrintPage()">
	  	<img src="../../../images/print.gif" width="58" height="26" border="0"></a>
	<font size="1" face="Verdana, Arial, Helvetica, sans-serif">print page </font></td>
	</tr>
</table>

<%}%>
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
