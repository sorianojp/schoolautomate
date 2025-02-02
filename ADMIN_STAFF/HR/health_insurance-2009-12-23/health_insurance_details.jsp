<%@ page language="java" import="utility.*,java.util.Vector,hr.HRInsuranceTracking" %>
<%
	WebInterface WI = new WebInterface(request);//to make sure , i call the dynamic opener form name to reload when close window is clicked.
	boolean bolIsSchool = false;
	if( (new CommonUtil().getIsSchool(null)).equals("1"))
		bolIsSchool = true;
	String[] strColorScheme = CommonUtil.getColorScheme(6);
	//strColorScheme is never null. it has value always.
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Health Insurance Details</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<style type="text/css">
.bgDynamic {
	background-color:<%=strColorScheme[1]%>
}
.footerDynamic {
	background-color:<%=strColorScheme[2]%>
}
</style>
</head>
<script language="JavaScript" src="../../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../../Ajax/ajax.js"></script>
<script language="JavaScript">
function UpdateInsuranceDetails(strInfoIndex){
	var pgLoc = "./health_insurance_dtls_update.jsp?insurance_index="+strInfoIndex+"&opner_form_name=form_";	
	var win=window.open(pgLoc,"UpdateInsuranceDetails",'width=700,height=350,top=110,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=yes,menubar=no');
	win.focus();
}

function ReloadPage(){
	document.form_.print_page.value="";
	document.form_.submit();
}

function SearchEmployee(){	
	if(document.form_.emp_id.value == '') {
		alert("Please enter employee ID.");
		return;
	} 
	document.form_.searchEmployee.value="1";
	document.form_.print_page.value="";
	document.form_.submit();
}

function PrintPg() {
	document.form_.print_page.value = "1";
	document.form_.submit();
}

function OpenSearch() {
	var pgLoc = "../../../../search/srch_emp.jsp?opner_info=form_.emp_id";
	var win=window.open(pgLoc,"PrintWindow",'width=900,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
//all about ajax - to display student list with same name.
function AjaxMapName() {
	var strCompleteName = document.form_.emp_id.value;
	var objCOAInput = document.getElementById("coa_info");
		
	if(strCompleteName.length <= 2 ) {
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
	document.getElementById("coa_info").innerHTML = "";
}
function UpdateName(strFName, strMName, strLName) {
	//do nothing.
}
function UpdateNameFormat(strName) {
	//do nothing.
}
</script>

<%
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;
	
	//add security here.
	if (WI.fillTextValue("print_page").length() > 0){%>
		<jsp:forward page="./health_insurance_dtls_print.jsp" />
		<% 
	return;}

	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("HR MANAGEMENT-PERSONNEL"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("HR MANAGEMENT"),"0"));
		}
	}
	
	if(iAccessLevel == -1)//for fatal error.
	{
		if(bolIsSchool)
			request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		else
			request.getSession(false).setAttribute("go_home","../../../../index.jsp");
		
		request.getSession(false).setAttribute("errorMessage","You are logged out. Please login again.");
		response.sendRedirect("../../../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0)//NOT AUTHORIZED.
	{
		response.sendRedirect("../../../../commfile/unauthorized_page.jsp");
		return;
	}	
	
	String strAuthTypeIndex = (String)request.getSession(false).getAttribute("authTypeIndex");
	if(strAuthTypeIndex == null){
		request.getSession(false).setAttribute("go_home","../../../../index.jsp");
		request.getSession(false).setAttribute("errorMessage","You are not logged in. Please login to access this page.");
		response.sendRedirect("../../../../commfile/fatal_error.jsp");
		return;
	}
	
	try{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
			"Admin/staff-HR Management-Personnel-Health Insurance Copy","health_insurance_copy.jsp");
	}
	catch(Exception exp){
		exp.printStackTrace();
		if(strErrMsg == null)
			strErrMsg = "Error in opening DB Connection.";
	%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3"><%=strErrMsg%></font></p>
	<%
		return;
	}
		
	Vector vRetResult = null;
	Vector vUserInfo = null;
	HRInsuranceTracking hriTracker = new HRInsuranceTracking();
	int iSearchResult = 0;
	int i = 0;
	
	enrollment.Authentication auth = new enrollment.Authentication();
    request.setAttribute("emp_id", WI.fillTextValue("emp_id"));
    if(WI.fillTextValue("emp_id").length() > 0)
		vUserInfo = auth.operateOnBasicInfo(dbOP, request, "0");
	if(vUserInfo == null)
		strErrMsg = auth.getErrMsg();
	else{
		if(WI.fillTextValue("searchEmployee").length() > 0){
			vRetResult = hriTracker.viewHealthInsuranceDetails(dbOP,(String)vUserInfo.elementAt(0));
			if(vRetResult == null)
				strErrMsg = hriTracker.getErrMsg();
			else
				iSearchResult = hriTracker.getSearchCount();
		}	
	}
%>
<body bgcolor="#D2AE72" class="bgDynamic">
<form action="health_insurance_details.jsp" method="post" name="form_">

	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr bgcolor="#A49A6A"> 
			<td height="25" colspan="5" align="center" class="footerDynamic">
				<font color="#FFFFFF"><strong>:::: HEALTH INSURANCE CREDITS PAGE ::::</strong></font>			</td>
		</tr>
	</table>
	
	<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
		<tr> 
			<td colspan="2"><a href="health_insurance_tracking.jsp"><img src="../../../../images/go_back.gif" border="0" align="right"></a></td>
			<td>&nbsp;</td>
		</tr>
		<tr>
			<td width="3%">&nbsp;</td>
			<td width="90%"><font size="2" color="#FF0000"><strong><%=WI.getStrValue(strErrMsg)%></strong></font></td>
			<td width="7%">&nbsp;</td>
		</tr>
	</table>
	
	<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
		<tr>
		  <td height="25">&nbsp;</td>
		  <td colspan="4" style="font-weight:bold; font-size:13px;"><u>For Year : <%=WI.getTodaysDate(12)%></u></td>
	  </tr>
		<tr> 
			<td width="3%" height="10">&nbsp;</td>
			<td width="15%" height="10">Employee ID </td>
			<td height="10" colspan="2">
				<input name="emp_id" type="text" size="16" value="<%=WI.fillTextValue("emp_id")%>" class="textbox"
					onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" onKeyUp="AjaxMapName();">
				<strong>
				<a href="javascript:OpenSearch();"><img src="../../../../images/search.gif" width="37" height="30" border="0"></a></strong></td>
		    <td width="56%" height="10"><label id="coa_info"></label></td>
		</tr>
		<tr> 
			<td width="3%" height="10">&nbsp;</td>
			<td height="10" colspan="4">
			&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
			<input type="button" name="proceed_btn" value=" Proceed " style="font-size:11px; height:28px;border: 1px solid #FF0000;" 
				onClick="javascript:SearchEmployee();">
			<font size="1">click to display employee list to print.</font></td>
		</tr>
		<tr> 
			<td height="10" colspan="5">&nbsp;</td>
		</tr>
	</table>
	 
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr>   
	<% if (vRetResult != null && vRetResult.size() > 0 ){%>
			<td height="10">
				<div align="right"><font><a href="javascript:PrintPg()"> <img src="../../../../images/print.gif" border="0"></a> 
				<font size="1">click to print</font></font></div>
			</td>
			<%}%>
		</tr>
	</table>

	<% if (vRetResult != null &&  vRetResult.size() > 0) {%>
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr> 
			<td height="10" colspan="6"><hr size="1" color="#000000"></td>
		</tr>
		<tr> 
			<td height="10" colspan="2"><strong>EMPLOYEE INFORMATION: </strong></td>
		</tr>
		<tr> 
			<td height="10" colspan="2">&nbsp;</td>
		</tr>
		<tr> 
			<td width="15%" height="10">Name:</td>
		    <td width="85%"><%=WebInterface.formatName((String)vUserInfo.elementAt(1),(String)vUserInfo.elementAt(2),(String)vUserInfo.elementAt(3),7)%></td>
		</tr>
		<tr> 
			<td>Dept/Office:</td>
			<%
				if((String)vUserInfo.elementAt(13)== null || (String)vUserInfo.elementAt(14)== null)
					strTemp = " ";			
				else
					strTemp = " - ";
			%>
			<td>
			<%=WI.getStrValue((String)vUserInfo.elementAt(13),"")%>
			<%=strTemp%>
			<%=WI.getStrValue((String)vUserInfo.elementAt(14),"")%> 
			</td>
		</tr>
		<tr> 
			<td height="10" colspan="2">&nbsp;</td>
		</tr>
	</table>
  
	<table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF" class="thinborder">
		<tr> 
			<td height="20" colspan="6" bgcolor="#B9B292" class="thinborder">
				<div align="center"><strong> BENEFIT DETAILS </strong></div>
			</td>
		</tr>
		<tr>
			<td width="3%"  height="23"    class="thinborder">Count</td>
			<td width="34%" align="center" class="thinborder"><strong><font size="1">BENEFIT</font></strong></td>
			<td width="12%" align="center" class="thinborder"><strong><font size="1">AMOUNT</font></strong></td>
			<td width="9%"  align="center" class="thinborder"><strong><font size="1">BALANCE </font></strong></td>
			<td width="8%"  align="center" class="thinborder"><strong><font size="1">UDPATE </font></strong></td>
		</tr>
		<% 	int iCount = 1;
			for (i = 0; i < vRetResult.size(); i+=4,iCount++){
		%>
		<tr>
			<td class="thinborder">&nbsp;<%=iCount%></td>
			<td height="25" class="thinborder"><font size="1"><strong>&nbsp;&nbsp;
				<%=(String)vRetResult.elementAt(i+1)%></strong></font>
			</td>
			<td class="thinborder">&nbsp;<%=CommonUtil.formatFloat((String)vRetResult.elementAt(i + 2), true)%></td>		
			<td class="thinborder">&nbsp;<%=CommonUtil.formatFloat((String)vRetResult.elementAt(i + 3), true)%></td>
			<td align="center" class="thinborder">
				<%if(iAccessLevel > 1){%>
					<a href="javascript:UpdateInsuranceDetails('<%=vRetResult.elementAt(i)%>');">
					<img src="../../../../images/update.gif" border="0"></a>
				<%}%>
			</td>
		</tr>
		<%} //end for loop%>
	</table>
	<%} // end vRetResult != null && vRetResult.size() > 0 %>

	<table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
		<tr>
			<td height="25" colspan="3" bgcolor="#FFFFFF">&nbsp;</td>
		</tr>
		<tr>
			<td height="25"  colspan="3" bgcolor="#A49A6A" class="footerDynamic">&nbsp;</td>
		</tr>
	</table>
	
	<input type="hidden" name="print_page">
	<input type="hidden" name="searchEmployee" value="<%=WI.fillTextValue("searchEmployee")%>"> 
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>