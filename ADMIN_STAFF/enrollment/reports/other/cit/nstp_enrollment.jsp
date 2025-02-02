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
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("REGISTRAR MANAGEMENT-REPORTS"),"0"));
		}
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("REGISTRAR MANAGEMENT"),"0"));
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
Vector vRetResult = null;
if(WI.fillTextValue("show_result").equals("1")) {
	enrollment.ReportRegistrar RG = new enrollment.ReportRegistrar();
	vRetResult = RG.getNSTPEnrollList(dbOP, request);
	if(vRetResult == null)
		strErrMsg = RG.getErrMsg();
}
String[] astrConvertTerm = {"Summer","1st Term","2nd Term","3rd Term"};


boolean bolShowHeading = strSchCode.startsWith("EAC");
boolean bolHideLast3 = strSchCode.startsWith("EAC");
%>
<body>
<form name="form_" action="./nstp_enrollment.jsp" method="post">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" id="myADTable1">
    <tr bgcolor="#A49A6A"> 
      <td height="25" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF" ><strong>:::: NSTP ENROLLMENT INFORMATION PAGE ::::</strong></font></div></td>
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
if(strTemp == null)
	strTemp = "";
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
        </select> &nbsp;&nbsp;&nbsp;&nbsp;
<%if(strSchCode.startsWith("EAC")){%>
 <select name="nstp_val" style="font-weight:bold;">
 	<option value="">Include ALL</option>
 	<option value="-1">Not yet Defined</option>
	<%=dbOP.loadCombo("distinct NSTP_VAL","NSTP_VAL"," from NSTP_VALUES order by NSTP_VALUES.NSTP_VAL asc", WI.fillTextValue("nstp_val"), false)%>
</select>
<%}%>		
		</td>
    </tr>
    
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25" colspan="2"> 
	  <input type="submit" name="1" value="&nbsp;&nbsp;Show Result&nbsp;&nbsp;" 
	  	style="font-size:11px; height:28px;border: 1px solid #FF0000;" onClick="document.form_.show_result.value='1'">
<%if(bolShowHeading){%>		
		Rows per Page to Print : 
<%
int iDefVal = Integer.parseInt(WI.getStrValue(WI.fillTextValue("rows_per_pg"), "45"));
%>		
		<select name="rows_per_pg">
			<%for(int i =25; i < 75; ++i) {
				if(iDefVal == i)
					strTemp = "selected";
				else	
					strTemp = "";
			%>
			<option value="<%=i%>" <%=strTemp%>><%=i%></option>
			<%}%>
		</select>
<%}%>		
		
	  </td>
    </tr>
<%if(vRetResult != null && vRetResult.size() > 0) {%>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25" colspan="2" align="right" style="font-size:9px;"><a href="javascript:PrintPg();"><img src="../../../../../images/print.gif" border="0"></a>Print Page</td>
    </tr>
<%}%>
  </table>


<%
if(vRetResult != null && vRetResult.size() > 0) {
	int iDefVal = 45;
	if(WI.fillTextValue("rows_per_pg").length()> 0) 
		iDefVal = Integer.parseInt(WI.fillTextValue("rows_per_pg"));
		
	int iTotalCount = vRetResult.size()/14;
	int iTotalPage  = iTotalCount/iDefVal;
	if(iTotalCount % iDefVal > 0)
		++iTotalPage;
	int iPageNo = 1;
	int iRowPrinted = 0;
	iTotalCount = 0;	
	while(vRetResult.size() > 0) {
	
	if(iPageNo > 1 && bolShowHeading) {%>
		<DIV style="page-break-after:always" >&nbsp;</DIV>
	<%}if(bolShowHeading){%>
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr>
		  <td style="font-size:9px;">Date time Printed: <%=WI.getTodaysDateTime()%></td>
		  <td style="font-size:9px;" align="right">Page <%=iPageNo++%> of <%=iTotalPage%></td>
		</tr>
		<tr>
			<td align="center" colspan="2"><b><%=SchoolInformation.getSchoolName(dbOP,true,false)%></b><br>
			<font size="1"><%=WI.getStrValue(SchoolInformation.getAddressLine1(dbOP,false,false),"","<br>","")%></font>
			<font  style="font-size:9px;">
			<%=astrConvertTerm[Integer.parseInt(WI.fillTextValue("semester"))]%>, SY 
			<%=WI.fillTextValue("sy_from")%>-<%=WI.fillTextValue("sy_to")%></font>
			<br><br>
			<strong>STUDENT ENROLLED IN NSTP 
			<%if(bolShowHeading){
			strTemp = WI.fillTextValue("nstp_val");
			if(strTemp.length() == 0)
				strTemp = "Show ALL";
			else if(strTemp.equals("-1"))
				strTemp = " Component Net Yet Assigned";
			%>
				<%=WI.getStrValue(strTemp, " - ", "","")%>
			<%}%>
			</strong>
			<br>&nbsp;	  </td>
		</tr>
	  </table><%}%>
	  <table width="100%" border="0" cellpadding="0" cellspacing="0"<%if(bolShowHeading){%>class="thinborder"<%}else{%><%}%>>
		<tr> 
		  <td height="25" width="2%" class="<%if(!bolShowHeading){%>thinborderNONE<%}else{%>thinborder<%}%>">Count</td>
		  <td width="10%" class="<%if(!bolShowHeading){%>thinborderNONE<%}else{%>thinborder<%}%>">Student ID </td>
		  <td width="15%" class="<%if(!bolShowHeading){%>thinborderNONE<%}else{%>thinborder<%}%>">Student Name </td>
		  <td width="8%" class="<%if(!bolShowHeading){%>thinborderNONE<%}else{%>thinborder<%}%>">Course-Year</td>
		  <td width="4%" class="<%if(!bolShowHeading){%>thinborderNONE<%}else{%>thinborder<%}%>">Gender</td>
		  <td width="10%" class="<%if(!bolShowHeading){%>thinborderNONE<%}else{%>thinborder<%}%>">Subject Code </td>
		  <td width="5%" class="<%if(!bolShowHeading){%>thinborderNONE<%}else{%>thinborder<%}%>">Section </td>
<%if(!bolHideLast3){%>
		  <td width="10%" class="<%if(!bolShowHeading){%>thinborderNONE<%}else{%>thinborder<%}%>">Date of Birth</td>
		  <td width="20%" class="<%if(!bolShowHeading){%>thinborderNONE<%}else{%>thinborder<%}%>">Home Address</td>
		  <td width="10%" class="<%if(!bolShowHeading){%>thinborderNONE<%}else{%>thinborder<%}%>">Contact Number</td>
<%}%>
		</tr>
	<%while(vRetResult.size() > 0) {
		if(bolShowHeading) {
			if(++iRowPrinted > iDefVal) {
				iRowPrinted = 0;
				break;
			}
		}
		strTemp = (String)vRetResult.elementAt(12);
		if(strTemp == null)
			strTemp = (String)vRetResult.elementAt(13);
		%>    <tr>
		  <td height="25" class="<%if(!bolShowHeading){%>thinborderNONE<%}else{%>thinborder<%}%>"><%=++iTotalCount%></td>
		  <td class="<%if(!bolShowHeading){%>thinborderNONE<%}else{%>thinborder<%}%>"><%=vRetResult.elementAt(1)%></td>
		  <td class="<%if(!bolShowHeading){%>thinborderNONE<%}else{%>thinborder<%}%>"><%=vRetResult.elementAt(2)%></td>
		  <td class="<%if(!bolShowHeading){%>thinborderNONE<%}else{%>thinborder<%}%>"><%=vRetResult.elementAt(3)%><%=WI.getStrValue((String)vRetResult.elementAt(4), " - ", "","")%>
		  <%=WI.getStrValue((String)vRetResult.elementAt(5), " - ", "","")%></td>
		  <td class="<%if(!bolShowHeading){%>thinborderNONE<%}else{%>thinborder<%}%>"><%=WI.getStrValue((String)vRetResult.elementAt(9), "&nbsp;")%></td>
		  <td class="<%if(!bolShowHeading){%>thinborderNONE<%}else{%>thinborder<%}%>"><%=vRetResult.elementAt(6)%></td>
		  <td class="<%if(!bolShowHeading){%>thinborderNONE<%}else{%>thinborder<%}%>"><%=vRetResult.elementAt(8)%></td>
<%if(!bolHideLast3){%>
		  <td class="<%if(!bolShowHeading){%>thinborderNONE<%}else{%>thinborder<%}%>"><%=WI.getStrValue((String)vRetResult.elementAt(10),"&nbsp;")%></td>
		  <td class="<%if(!bolShowHeading){%>thinborderNONE<%}else{%>thinborder<%}%>"><%=WI.getStrValue((String)vRetResult.elementAt(11),"&nbsp;")%></td>
		  <td class="<%if(!bolShowHeading){%>thinborderNONE<%}else{%>thinborder<%}%>"><%=WI.getStrValue(strTemp, "&nbsp;")%></td>
<%}%>
		</tr>
		<%
			vRetResult.remove(0);vRetResult.remove(0);vRetResult.remove(0);vRetResult.remove(0);
			vRetResult.remove(0);vRetResult.remove(0);vRetResult.remove(0);vRetResult.remove(0);
			vRetResult.remove(0);vRetResult.remove(0);vRetResult.remove(0);vRetResult.remove(0);
			vRetResult.remove(0);vRetResult.remove(0);
		}%>
	  </table>
	<%}
}%>
  <input type="hidden" name="show_result">
</form>

</body>
</html>
<%
dbOP.cleanUP();
%>