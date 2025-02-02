<%@ page language="java"  buffer="16kb"	import="utility.*,java.util.Vector,payroll.PRFaculty,payroll.PRConfidential" %>
<%
///added code for HR/companies.
boolean bolIsSchool = false;
if( (new CommonUtil().getIsSchool(null)).equals("1"))
	bolIsSchool = true;

String[] strColorScheme = CommonUtil.getColorScheme(6);

%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Salary Rate</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<%response.setHeader("Pragma","No-Cache");
response.setDateHeader("Expires",0);
response.setHeader("Cache-Control","no-Cache");
%>
<style type="text/css">
.bgDynamic {
	background-color:<%=strColorScheme[1]%>
}
.footerDynamic {
	background-color:<%=strColorScheme[2]%>
}
</style>
</head>

<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../Ajax/ajax.js"></script>
<script language="JavaScript">

function PageAction(strAction) {
	
	if(strAction == 1)
		document.form_.save.disabled = true;
	document.form_.page_action.value = strAction;
	this.SubmitOnce('form_');
}
function ReloadPage() {
	document.form_.page_action.value = "";
	this.SubmitOnce('form_');
}

function OpenSearch() {
	var pgLoc = "../../../search/srch_emp.jsp?opner_info=form_.emp_id";
	var win=window.open(pgLoc,"PrintWindow",'width=900,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}


function FocusID() {
	document.form_.emp_id.focus();
}

//all about ajax - to display student list with same name.
function AjaxMapName() {
	var strCompleteName = document.form_.emp_id.value;
	var objCOAInput = document.getElementById("coa_info");
	
	if(strCompleteName.length <=2) {
		objCOAInput.innerHTML = "";
		return ;
	}

	document.all.ajax_.style.visibility = "visible";
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
	document.all.ajax_.style.visibility = "hidden";
	document.form_.submit();
}
function UpdateName(strFName, strMName, strLName) {
	//do nothing.
}
function UpdateNameFormat(strName) {
	//do nothing.
}

function checkAllSaveItems() {
	var maxDisp = document.form_.emp_count.value;
	var bolIsSelAll = document.form_.selAllSaveItems.checked;
	for(var i =1; i <= maxDisp; ++i)
		eval('document.form_.save_'+i+'.checked='+bolIsSelAll);
}


</script>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
	String strTemp2 = null;
	String strTemp3 = null;
	String strImgFileExt = null;
	
	String strSchCode = (String)request.getSession(false).getAttribute("school_code");
	if(strSchCode == null)
	  strSchCode = "";		

	
//add security here.

	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");

	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("PAYROLL-SALARY RATE"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("PAYROLL"),"0"));
		}
	}

	if(iAccessLevel == -1)//for fatal error.
	{
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		request.getSession(false).setAttribute("errorMessage","You are logged out. Please login again.");
		response.sendRedirect("../../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0)//NOT AUTHORIZED.
	{
		response.sendRedirect("../../../commfile/unauthorized_page.jsp");
		return;
	}

	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Payroll-SALARY RATE-SALARY RATE","salary_rate_faculty_per_class.jsp");
		
		ReadPropertyFile readPropFile = new ReadPropertyFile();
		strImgFileExt = readPropFile.getImageFileExtn("imgFileUploadExt");
		
		if(strImgFileExt == null || strImgFileExt.trim().length() ==0)
		{
			strErrMsg = "Image file extension is missing. Please contact school admin.";
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
PRFaculty prFacRate = new PRFaculty();
PRConfidential prCon = new PRConfidential();

Vector vRetResult = null;
Vector vEmpRec    = null;

strTemp = WI.fillTextValue("page_action");
if(strTemp.length() > 0){
	if(prFacRate.operateOnFacultyLoadRate(dbOP, request, Integer.parseInt(strTemp)) == null)
		strErrMsg= prFacRate.getErrMsg();
	else{
		if(strTemp.equals("1"))
			strErrMsg = "Information successfully saved.";
	}
}


String strExtraErrMsg  = null;
String strFacTermType  = null;
boolean bolCheckAllowed = false;

String strSYFrom = WI.getStrValue(WI.fillTextValue("sy_from"), (String)request.getSession(false).getAttribute("cur_sch_yr_from"));
String strSemester = WI.getStrValue(WI.fillTextValue("semester"), (String)request.getSession(false).getAttribute("cur_sem"));				



if(WI.fillTextValue("emp_id").length() > 0) {
	bolCheckAllowed = (prCon.checkIfEmpIsProcessor(dbOP, request, WI.fillTextValue("emp_id"), true) == 1);
 	if(bolCheckAllowed){
		enrollment.Authentication authentication = new enrollment.Authentication();
		vEmpRec = authentication.operateOnBasicInfo(dbOP, request, "0");
 		if(vEmpRec == null)
			strErrMsg = "Employee has no profile.";
	}else
		strErrMsg = prCon.getErrMsg();
}

if(vEmpRec != null && vEmpRec.size() > 0) {	
	
	vRetResult = prFacRate.operateOnFacultyLoadRate(dbOP, request, 4);
	if(vRetResult == null && strErrMsg == null)
		strErrMsg = prFacRate.getErrMsg();
		
	strTemp = (String)vEmpRec.elementAt(0);
	strTemp = "select TERM_TYPE from PR_EMP_TERM_TYPE where USER_INDEX = "+strTemp;
	strFacTermType = dbOP.getResultOfAQuery(strTemp,0);
	if(strFacTermType == null)
		strExtraErrMsg = "Employee's Term is not set.";
	else{
		strTemp = "select SEM_DATE_INDEX from PR_SEM_DATES where IS_VALID =1 and SY_FROM_ = "+strSYFrom+
			" and TERM = "+strSemester+" and TERM_TYPE = "+strFacTermType;
		if(dbOP.getResultOfAQuery(strTemp,0) == null)
			strExtraErrMsg = "Term date range is not set.";
	}
}



int iIndexOf = 0;
int iCount = 0;

%>
<body bgcolor="#D2AE72" onLoad="FocusID();ShowHideHourlyOpt();" class="bgDynamic">
<form action="./salary_rate_faculty_per_class.jsp" method="post" name="form_">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="2" align="center" class="footerDynamic"><font color="#FFFFFF" ><strong>::::
      PAYROLL : SALARY INFORMATION PAGE ::::</strong></font></td>
    </tr>
  </table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">    
    <tr>
      <td height="23" colspan="4">&nbsp;&nbsp;&nbsp;<font size="3"><b><%=WI.getStrValue(strErrMsg)%></b></font></td>
    </tr>
    		<tr>
			<td height="25" width="3%">&nbsp;</td>
			<td width="16%">SY/Term:</td>			
		  	<td width="26%">
				
				<input name="sy_from" type="text" size="4" maxlength="4" class="textbox" value="<%=strSYFrom%>" 
					onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
					onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
					onKeyUp='DisplaySYTo("form_","sy_from","sy_to")'>
				-
				<%
					strTemp = WI.getStrValue(WI.fillTextValue("sy_to"), (String)request.getSession(false).getAttribute("cur_sch_yr_to"));
				%>
				<input name="sy_to" type="text" size="4" maxlength="4" class="textbox" value="<%=strTemp%>" 
					onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
					onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
					readonly="yes">
					
				<select name="semester">
				
              	<%
				if(strSemester.equals("1"))
					strErrMsg = "selected";
				else
					strErrMsg = "";					
				%><option value="1" <%=strErrMsg%>>1st Sem</option>
				<%			
				if(strSemester.equals("2"))
					strErrMsg = "selected";
				else
					strErrMsg = "";					
				%><option value="2" <%=strErrMsg%>>2nd Sem</option>
				<%			
				if(strSemester.equals("3"))
					strErrMsg = "selected";
				else
					strErrMsg = "";					
				%><option value="3" <%=strErrMsg%>>3rd Sem</option>
				<%			
				if(strSemester.equals("0"))
					strErrMsg = "selected";
				else
					strErrMsg = "";					
				%><option value="0" <%=strErrMsg%>>Summer</option>
              	
            	</select>	
				</td>
				<td align="right" style="font-size:15px; color:#FF0000; font-weight:bold"><%=WI.getStrValue(strExtraErrMsg)%></td>
		</tr>
    <tr>
      <td width="3%" height="25">&nbsp;</td>
      <td width="16%">Employee ID</td>
	  
      <td width="26%"><input name="emp_id" type="text" size="16" value="<%=WI.fillTextValue("emp_id")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" onKeyUp="AjaxMapName(1);"><br>
		<div id="ajax_" style="position:absolute; width:400px; overflow:auto">
		<label id="coa_info"></label>
		</div></td>
      <td width="55%"><a href="javascript:OpenSearch();"><img src="../../../images/search.gif" width="37" height="30" border="0" align="absmiddle"></a>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
        <input type="button" name="12" value=" Proceed " style="font-size:11px; height:28px;border: 1px solid #FF0000;" onClick="javascript:ReloadPage();">			</td>
    </tr>
  </table>
<%if(vEmpRec != null && vEmpRec.size() > 0) {%>
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <tr>
      <td width="25%" height="18">&nbsp; </td>
      <td>
        <%strTemp = "<img src=\"../../../upload_img/"+WI.fillTextValue("emp_id")+"."+strImgFileExt+"\" width=150 height=150 align=\"right\" border=1>";
		%>
		
        <%=WI.getStrValue(strTemp)%> <br> 
        <br>
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
      <td height="18" colspan="3"><hr size="1"></td>
    </tr>
  </table>

<%if(vRetResult != null && vRetResult.size() > 0){%>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
	<tr>
	  <td height="20"><font color="blue" style="font-weight:bold">Note: To Prevent System from computing faculty salary, set only one regular rates to -1.00 and all other regular rates to 0.00</font></td>
	</tr>
	<tr><td align="center" height="22"><strong>LIST OF FACULTY SCHEDULE</strong></td></tr>
</table>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
	<tr>
		<td width="15%" height="22" align="center" class="thinborder"><strong>Subject Code</strong></td>
		<td width="35%" align="center" class="thinborder"><strong>Subject Description</strong></td>
		<td width="5%" align="center" class="thinborder"><strong>Load Unit</strong></td>
		<td width="5%" align="center" class="thinborder"><strong>Load Hour</strong></td>
		<td width="15%" align="center" class="thinborder"><strong>Section</strong></td>
		
		<td width="10%" align="center" class="thinborder"><strong>Regular Rate</strong></td>
		<td width="10%" align="center" class="thinborder"><strong>Overload Rate</strong></td>
	    <td width="5%" align="center" class="thinborder"><strong>Select All<br />
	    </strong>
			<input type="checkbox" name="selAllSaveItems" value="0" onClick="checkAllSaveItems();"></td>
	</tr>
	
	<%
	String[] astrConvertUnitType = {" Unit", " Hour", " Weeks", " Months"};
	for(int i = 0; i < vRetResult.size(); i+=11){%>
	<tr>
		<input type="hidden" name="load_index_<%=++iCount%>" value="<%=vRetResult.elementAt(i)%>">
		<input type="hidden" name="sub_sec_index_<%=iCount%>" value="<%=vRetResult.elementAt(i+1)%>">
		<td class="thinborder" height="22"><%=vRetResult.elementAt(i+3)%></td>
		<td class="thinborder" height="22"><%=vRetResult.elementAt(i+4)%></td>
		<td height="22" class="thinborder" align="center"><%=WI.getStrValue(vRetResult.elementAt(i+8),"0")%>
			<%//=astrConvertUnitType[Integer.parseInt(WI.getStrValue(vRetResult.elementAt(i+9),"0"))]%></td>
		<td height="22" class="thinborder" align="center"><%=WI.getStrValue(vRetResult.elementAt(i+8),"0")%></td>
		<td class="thinborder" height="22"><%=vRetResult.elementAt(i+2)%></td>
		
		<%
		

		strTemp = ConversionTable.replaceString((String)vRetResult.elementAt(i+6), ",", "");
		if(Double.parseDouble(strTemp) != 0)
			strTemp = ConversionTable.replaceString(CommonUtil.formatFloat(strTemp, true),",","");
		else
			strTemp = "";
		%>
		<td class="thinborder" height="22" align="right">
			<input name="class_rate_<%=iCount%>" type="text" size="6" class="textbox"
				 style="text-align:right;" value="<%=strTemp%>"
			  onFocus="style.backgroundColor='#D3EBFF'" 
			  onBlur="AllowOnlyFloat('form_','class_rate_<%=iCount%>');style.backgroundColor='white'"
			  onKeyUp="AllowOnlyFloat('form_','class_rate_<%=iCount%>');">		</td>
		<%
		strTemp = ConversionTable.replaceString((String)vRetResult.elementAt(i+7), ",", "");
		if(Double.parseDouble(strTemp) != 0)
			strTemp = ConversionTable.replaceString(CommonUtil.formatFloat(strTemp, true),",","");
		else
			strTemp = "";
		%>
		<td class="thinborder" height="22" align="right">
			<input name="class_ovr_rate_<%=iCount%>" type="text" size="6" class="textbox"
				 style="text-align:right;" value="<%=strTemp%>"
			  onFocus="style.backgroundColor='#D3EBFF'" 
			  onBlur="AllowOnlyFloat('form_','class_ovr_rate_<%=iCount%>');style.backgroundColor='white'"
			  onKeyUp="AllowOnlyFloat('form_','class_ovr_rate_<%=iCount%>');">		</td>
	    <td class="thinborder" align="center">
			
				<input type="checkbox" name="save_<%=iCount%>" value="<%=(String)vRetResult.elementAt(i)%>" tabindex="-1" <%=strErrMsg%>>		</td>
	</tr>
	<%}%>
	<input type="hidden" name="emp_count" value="<%=iCount%>">
</table>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
	<tr><td align="center">
	<a href="javascript:PageAction('1');"><img id="save" name="save" src="../../../images/save.gif" border="0"></a>
	<font size="1">Click to save information</font>
	</td></tr>
</table>
<%}
}//only if(vEmpRec != null && vEmpRec.size() > 0) %>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="25" colspan="4">&nbsp;</td>
    </tr>
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="4" class="footerDynamic">&nbsp;</td>
    </tr>
  </table>

<input type="hidden" name="page_action">


</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
