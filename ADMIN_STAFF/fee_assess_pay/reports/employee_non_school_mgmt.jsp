<%@ page language="java" import="utility.*,java.util.Vector" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
<title>Employee Discount Application</title>
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/reportlink.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>

<style type="text/css">
<!--
body {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 12px;
}
table{
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
}
td {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
 }

th {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
 }
-->
</style>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="javascript"  src ="../../../Ajax/ajax.js" ></script>
<script language="JavaScript">
var strType = "0";
function AjaxMapName(strSearchType) {

		strType = strSearchType;
		var strCompleteName = "";
		var objCOAInput = "";
		
		if(strSearchType == "1"){
			strCompleteName = document.form_.stud_id.value;
			objCOAInput = document.getElementById("stud_coa_info");
		}else{
			strCompleteName = document.form_.emp_id.value;
			objCOAInput = document.getElementById("coa_info");
		}
		
		
		if(strCompleteName.length <=2) {
			objCOAInput.innerHTML = "";
			return ;
		}

		this.InitXmlHttpObject(objCOAInput, 2);//I want to get innerHTML in this.retObj
  		if(this.xmlHttp == null) {
			alert("Failed to init xmlHttp.");
			return;
		}
		var strURL = "../../../Ajax/AjaxInterface.jsp?methodRef=2&search_id=1&name_format=4&complete_name="+escape(strCompleteName);
		if(strSearchType == "0")
			strURL += "&is_faculty=1";
		
		this.processRequest(strURL);
}
function UpdateID(strID, strUserIndex) {
	
	if(strType == "0"){
		document.form_.emp_id.value = strID;
		document.getElementById("coa_info").innerHTML = "";
		document.form_.submit();
	}else{
		document.form_.stud_id.value = strID;
		document.getElementById("stud_coa_info").innerHTML = "";
	}
	
}
function UpdateName(strFName, strMName, strLName) {
	//do nothing.
}
function UpdateNameFormat(strName) {
	//do nothing.
}




function OpenSearch() {
	var pgLoc = "../../../search/srch_emp.jsp?opner_info=form_.emp_id";
	var win=window.open(pgLoc,"OpenSearch",'width=600,height=400,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function ShowData(){
	document.form_.reload_page.value = "1";	
	document.form_.page_action_eval.value = "";
	document.form_.page_action.value = "";
	document.form_.submit();	
}

function ManageNonSchoolEmployee(){
	var strID = document.form_.emp_id.value;
	if(strID.length == 0){
		alert("Please provide employee id number.");
		return;
	}
	var pgLoc = "./employee_non_school_mgmt.jsp?is_forwarded=1&emp_id="+strID;
	var win=window.open(pgLoc,"OpenSearch",'width=600,height=400,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

function PrintForm(strStudID){
	if(strStudID.length == 0){
		alert("Student id number not found.");
		return;
	}
	
	var pgLoc = "./employee_discount_application_print.jsp?application_print=1&stud_id="+strStudID+
		"&emp_id="+document.form_.emp_id.value+
		"&sy_to="+document.form_.sy_to.value+
		"&semester="+document.form_.semester.value+
		"&sy_from="+document.form_.sy_from.value;
	var win=window.open(pgLoc,"PrintWindow",'width=900,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

function PageActionEval(strAction){
	document.form_.page_action_eval.value = strAction;
	document.form_.page_action.value = "";
	document.form_.submit();
}

function PageAction(strAction, strInfoIndex){
	if(strAction == "0"){		
		if(!confirm("Do you want to delete this employee information?"))
			return;
	}	
	
	if(strAction == "3"){		
		if(!confirm("Do you want to validate this employee information?"))
			return;
	}	
	
	document.form_.page_action.value = strAction;
	document.form_.page_action_eval.value = "";
	document.form_.submit();
}

</script>
<body bgcolor="#D2AE72" onload="document.form_.emp_id.focus();">
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp   = null;
	String strTemp2   = null;
	String strTemp3   = null;
	String strImgFileExt = null;
    try{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Fee Assessment & Payments - Admission slip","employee_discount_application.jsp");
		
		ReadPropertyFile readPropFile = new ReadPropertyFile();
		strImgFileExt = readPropFile.getImageFileExtn("imgFileUploadExt");
		
		if(strImgFileExt == null || strImgFileExt.trim().length() ==0){
			strErrMsg = "Image file extension is missing. Please contact school admin.";
			dbOP.cleanUP();
			throw new Exception();
		}
	}catch(Exception exp){
		exp.printStackTrace();%>
        <p align="center"><font face="Verdana, Arial, Helvetica, sans-serif" size="3">Error in opening connection</font></p>
		<%return;
	}
	
	CommonUtil comUtil = new CommonUtil();
	int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
															"Fee Assessment & Payments","Reports",request.getRemoteAddr(),
															"employee_discount_application.jsp");														
	
	if(iAccessLevel == 0)
		iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"HR Management","PERSONNEL",request.getRemoteAddr(),
														"hr_personnel_personal_data.jsp");
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

	Vector vRetResult = null;
	Vector vEmpRec = null;	
	Vector vDelEmpRec = null;
	Vector vEmpEval  = null;
	
	String strEmployeeID=WI.fillTextValue("emp_id");;
	
	enrollment.FAEmpDiscountApplication FAEmpDisc = new enrollment.FAEmpDiscountApplication();


	strTemp = WI.fillTextValue("page_action_eval");	
	if(strTemp.length() > 0){
		if(FAEmpDisc.operateOnEmpDiscEvaluation(dbOP, request, Integer.parseInt(strTemp), strEmployeeID) == null)
			strErrMsg = FAEmpDisc.getErrMsg();
		else{			
			strErrMsg = "Employee evaluation successfully updated.";
		}
	}

	strTemp = WI.fillTextValue("page_action");
	if(strTemp.length() > 0){
		/**
		used in iAction 0 and 5
		*/
		int iValid = Integer.parseInt(strTemp);
		if(iValid == 5)
			iValid = 0;//to find invalid data to validate
		else if(iValid == 0)
			iValid = 1;//to find valid data to invalidate
		
		if(FAEmpDisc.operateOnEmpNonSchoolMgmt(dbOP, request, Integer.parseInt(strTemp), iValid) == null)
			strErrMsg = FAEmpDisc.getErrMsg();
		else{
			if(strTemp.equals("0"))
				strErrMsg = "Employee information successfully deleted.";
			if(strTemp.equals("1"))
				strErrMsg = "Employee information successfully updated.";
			if(strTemp.equals("5"))
				strErrMsg = "Employee information successfully validated.";
		}
	}	

	boolean bolNonSchool = true;	
	
	if(strEmployeeID.length() > 0){
		vEmpRec = FAEmpDisc.operateOnEmpNonSchoolMgmt(dbOP,request,4, 1);
		if(vEmpRec == null){  
			enrollment.Authentication authentication = new enrollment.Authentication();
			vEmpRec = authentication.operateOnBasicInfo(dbOP,request,"0"); 			
			if(vEmpRec != null && vEmpRec.size() > 0)			
				bolNonSchool = false;
		}
				
		
		
		vDelEmpRec = FAEmpDisc.operateOnEmpNonSchoolMgmt(dbOP,request,4, 0);
		
		vEmpEval   = FAEmpDisc.operateOnEmpDiscEvaluation(dbOP,request,4, strEmployeeID);
	}
	
%>
<form name="form_" action="employee_non_school_mgmt.jsp" method="post">
<%

String strClass = "";

if(WI.fillTextValue("encode_type").equals("1")){
%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF" id="header">
    <tr bgcolor="#A49A6A" >
      <td height="25" colspan="5" align="center" style="font-weight:bold; color:#FFFFFF"> :::: EMPLOYEE DISCOUNT APPLICATION PAGE ::::</td>
    </tr>
  
    <tr>
      <td height="25" colspan="3">&nbsp;&nbsp;&nbsp; <font size="3"><strong><%=WI.getStrValue(strErrMsg)%></strong></font> </td>
    </tr>	
			
	<tr>
     <td width="3%" height="25">&nbsp;</td>
      <td width="21%">Employee ID </td>
      <td width="76%"><%if(bolNonSchool){%>
	  <input name="emp_id" type="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
	  onBlur="style.backgroundColor='white'" value="<%=strEmployeeID%>" size="16">
	  <input type="image" src="../../../images/refresh.gif" border="0" />
	  <%}else{%><input type="hidden" name="emp_id" value="<%=strEmployeeID%>" /><strong><%=strEmployeeID%></strong><%}%></td>
	  </tr>
	  <tr>
	    <td height="25">&nbsp;</td>
	    <td>First Name</td>
		<%
		strTemp = "";
		if(vEmpRec != null && vEmpRec.size() > 0){
			if(bolNonSchool)
				strTemp = (String)vEmpRec.elementAt(2);
			else
				strTemp = (String)vEmpRec.elementAt(1);
		}
		%>
	    <td><%if(bolNonSchool){%><input name="fname" type="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
	  onBlur="style.backgroundColor='white'" value="<%=strTemp%>" size="20"><%}else{%>
	  <input type="hidden" name="fname" value="<%=strTemp%>" /><strong><%=WI.getStrValue(strTemp).toUpperCase()%></strong><%}%>
	  </td>
	    </tr>
	<tr>
	    <td height="25">&nbsp;</td>
	    <td>Middle Name</td>
		<%
		strTemp = "";
		if(vEmpRec != null && vEmpRec.size() > 0){
			if(bolNonSchool)
				strTemp = (String)vEmpRec.elementAt(3);
			else
				strTemp = (String)vEmpRec.elementAt(2);
		}
		%>
	    <td><%if(bolNonSchool){%><input name="mname" type="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
	  onBlur="style.backgroundColor='white'" value="<%=WI.getStrValue(strTemp)%>" size="20">
	  <%}else{%><input type="hidden" name="mname" value="<%=WI.getStrValue(strTemp)%>" /><strong><%=WI.getStrValue(strTemp).toUpperCase()%></strong><%}%>
	  </td>
	    </tr>
	<tr>
	    <td height="25">&nbsp;</td>
	    <td>Last Name</td>
		<%
		strTemp = "";
		if(vEmpRec != null && vEmpRec.size() > 0){
			if(bolNonSchool)
				strTemp = (String)vEmpRec.elementAt(4);
			else
				strTemp = (String)vEmpRec.elementAt(3);
		}
		%>
	    <td><%if(bolNonSchool){%><input name="lname" type="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
	  onBlur="style.backgroundColor='white'" value="<%=strTemp%>" size="20">
	  <%}else{%><input type="hidden" name="lname" value="<%=WI.getStrValue(strTemp)%>" /><strong><%=WI.getStrValue(strTemp).toUpperCase()%></strong><%}%></td>
	    </tr>
	
	<tr>
	    <td height="25">&nbsp;</td>
	    <td>Position/Title</td>
		<%
		strTemp = "";
		if(vEmpRec != null && vEmpRec.size() > 0){			
			if(bolNonSchool)
				strTemp = (String)vEmpRec.elementAt(5);
			else
				strTemp = (String)vEmpRec.elementAt(15);
		}
		%>
	    <td><%if(bolNonSchool){%><input name="position_title" type="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
	  onBlur="style.backgroundColor='white'" value="<%=strTemp%>" size="30">
	  <%}else{%><input type="hidden" name="position_title" value="<%=WI.getStrValue(strTemp)%>" /><strong><%=WI.getStrValue(strTemp).toUpperCase()%></strong><%}%>
	  </td>
	    </tr>
	<tr>
	    <td height="25">&nbsp;</td>
	    <td>Date of Employment</td>
		<%
		strTemp = "";
		if(vEmpRec != null && vEmpRec.size() > 0)
			strTemp = (String)vEmpRec.elementAt(6);
		%>
	    <td>
		<%if(bolNonSchool){%><input name="date_hired" type="text" size="12" maxlength="12" readonly="yes" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        <a href="javascript:show_calendar('form_.date_hired');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a>
        </font>		
		<%}else{%><input type="hidden" name="date_hired" value="<%=WI.getStrValue(strTemp)%>" /><strong><%=WI.getStrValue(strTemp).toUpperCase()%></strong><%}%>
		</td>
	    </tr>
          <tr> 
            <td height="25">&nbsp;</td>
            <td height="25">Employment Tenure </td>
			<%
			strTemp = WI.fillTextValue("employment_status");
			if(vEmpRec != null && vEmpRec.size() > 0){
				if(bolNonSchool)
					strTemp = (String)vEmpRec.elementAt(8);
				else
					strTemp = (String)vEmpRec.elementAt(10);
			}
			%>
            <td height="25"> 
              <%if(bolNonSchool){%><select name="employment_status">
                <%=dbOP.loadCombo("status_index","status"," from user_status where IS_FOR_STUDENT=0 order by status asc",strTemp, false)%> </select> 
				<%}else{
				if(vEmpRec != null && vEmpRec.size() > 0){					
						strTemp = (String)vEmpRec.elementAt(16);
				}
				%><input type="hidden" name="date_hired" value="<%=WI.getStrValue(strTemp)%>" /><strong><%=WI.getStrValue(strTemp).toUpperCase()%></strong><%}%>
			</td>
          </tr>
	<tr>
	    <td height="25">&nbsp;</td>
	    <td>Business / Service Unit</td>
		<%
		strTemp = "";
		if(vEmpRec != null && vEmpRec.size() > 0)
			strTemp = (String)vEmpRec.elementAt(7);
		%>
	    <td>
			<%if(bolNonSchool){%><select name="business_service_type">
				<option value="">Select Any</option>
				<%=dbOP.loadCombo("distinct FA_EMP_DISCOUNT_NON_SCHOOL.BUSINESS_SERVICE_UNIT","FA_EMP_DISCOUNT_NON_SCHOOL.BUSINESS_SERVICE_UNIT", 
					" from FA_EMP_DISCOUNT_NON_SCHOOL where is_valid =1 order by FA_EMP_DISCOUNT_NON_SCHOOL.BUSINESS_SERVICE_UNIT",
					WI.fillTextValue("business_service_type"), false)%>
			</select>			
			<input name="business_service_unit" type="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
			  onBlur="style.backgroundColor='white'" value="<%=strTemp%>" size="30">
			  <%}else{
			  strTemp = "SCHOOL";
			  %><input type="hidden" name="business_service_unit" value="<%=WI.getStrValue(strTemp)%>" /><strong><%=WI.getStrValue(strTemp)%></strong><%}%>
		    </td>
	    </tr>
<%if(bolNonSchool){%>	
	<tr>
	    <td height="25">&nbsp;</td>
	    <td>&nbsp;</td>
	    <td>
		<a href="javascript:PageAction('1');"><img src="../../../images/update.gif" border="0" /></a>
		<font size="1">Click to save/update employee information.</font>
		<%
		if(vEmpRec != null && vEmpRec.size() > 0){
		%>
		<br>
		<a href="javascript:PageAction('0');"><img src="../../../images/delete.gif" border="0" /></a>
		<font size="1">Click to delete employee information.</font><%}%>		</td>
	    </tr> 
<%}%>   
  </table>
<%
if(vDelEmpRec != null && vDelEmpRec.size() > 0){
%>
<table width="100%" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
	<tr><td>&nbsp;</td></tr>
</table>
<table width="100%" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
	<tr><td align="center" class="thinborder" height="25" colspan="7"><strong>DELETED EMPLOYEE INFORMATION</strong></td></tr>
	<tr>
		<td width="10%" height="22" class="thinborder"><strong>EMPLOYEE ID</strong></td>
		<td width="20%" class="thinborder"><strong>EMPLOYEE NAME</strong></td>
		<td width="15%" class="thinborder"><strong>POSITION/TITLE</strong></td>
		<td width="13%" class="thinborder"><strong>DATE OF EMPLOYMENT</strong></td>
		<td width="16%" class="thinborder"><strong>EMPLOYMENT STATUS</strong></td>
		<td width="17%" class="thinborder"><strong>BUSINESS/SERVICE UNIT</strong></td>
	    <td width="9%" class="thinborder" align="center"><strong>OPTION</strong></td>
	</tr>
	<tr>
		<td class="thinborder" height="20">&nbsp;<%=(String)vDelEmpRec.elementAt(1)%></td>
		<%
		strTemp = WebInterface.formatName((String)vDelEmpRec.elementAt(2),(String)vDelEmpRec.elementAt(3),(String)vDelEmpRec.elementAt(4),5);
		%>
		<td class="thinborder" height="20">&nbsp;<%=strTemp%></td>
		<td class="thinborder" height="20">&nbsp;<%=WI.getStrValue(vDelEmpRec.elementAt(5),"N/A")%></td>
		<td class="thinborder" height="20">&nbsp;<%=WI.getStrValue(vDelEmpRec.elementAt(6),"N/A")%></td>
		<td class="thinborder">&nbsp;<%=WI.getStrValue(vDelEmpRec.elementAt(9),"N/A")%></td>
		<td class="thinborder" height="20">&nbsp;<%=WI.getStrValue(vDelEmpRec.elementAt(7),"N/A")%></td>
		<td class="thinborder" height="20" align="center">
		<a href="javascript:PageAction('5');"><img src="../../../images/update.gif" border="0" /></a>		</td>
	</tr>
</table>
<%}

}else{
if(vEmpRec != null && vEmpRec.size() > 0){
%>

<table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF" id="header">
    <tr bgcolor="#A49A6A" >
      <td height="25" colspan="5" align="center" style="font-weight:bold; color:#FFFFFF"> :::: EMPLOYEE PERFORMANCE EVALUATION ::::</td>
    </tr>
  
    <tr>
      <td height="25" colspan="3">&nbsp;&nbsp;&nbsp; <font size="3"><strong><%=WI.getStrValue(strErrMsg)%></strong></font> </td>
    </tr>	
</table>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
 	<tr>
 	    <td height="25">&nbsp;</td>
 	    <td>EMPLOYEE ID </td>
 	    <td  colspan="2"><input type="hidden" name="emp_id" value="<%=strEmployeeID%>" /><strong style="font-size:14px;"><%=strEmployeeID%></strong>
		&nbsp; &nbsp;
		 <input type="image" src="../../../images/refresh.gif" border="0" align="absmiddle" />
		</td>
 	    </tr>
 	<tr>
	<td height="25">&nbsp;</td>
	<td width="17%">SY-TERM:</td>
      <td  colspan="2">
<%	strTemp = WI.fillTextValue("sy_from");
	if(strTemp.length() ==0)
		strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
%>    <input name="sy_from" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp='DisplaySYTo("form_","sy_from","sy_to")'>
        to 
<%	strTemp = WI.fillTextValue("sy_to");
	if(strTemp.length() ==0)
			strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_to");
%>    <input name="sy_to" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  readonly="yes">
       <select name="semester" >
          <option value="1">1st Sem</option>
<%	 strTemp =WI.fillTextValue("semester");
	 if(strTemp.length() ==0) 
			strTemp = (String)request.getSession(false).getAttribute("cur_sem");
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
        </select>      </td>
    </tr>
	<%if(!bolNonSchool){%>
	
	<tr>
		<td colspan="3" valign="bottom">
			<table width="400" border="0" align="center">
    <tr bgcolor="#FFFFFF">
      <td width="100%" valign="middle"><%strTemp = "<img src=\"../../../upload_img/"+strEmployeeID.toUpperCase()+"."+strImgFileExt+"\" width=150 height=150 align=\"right\" border=\"1\">";%>
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
          <br>
          <strong><%=WI.getStrValue(strTemp)%></strong><br>
          <font size="1"><%=WI.getStrValue(strTemp2)%></font><br>
          <font size="1"><%=WI.getStrValue(strTemp3)%></font><br>
          <br>
          <font size=1><%="Date Hired : "  + WI.formatDate((String)vEmpRec.elementAt(6),10)%><br>		  
          <%="Length of Service : <br>" + new hr.HRUtil().getServicePeriodLength(dbOP,(String)vEmpRec.elementAt(0))%></font> </td>
    </tr>
  </table>		</td>
	</tr>
	<%}else{%>
	<tr>
		<td width="3%" height="25">&nbsp;</td>
		<td width="17%">Employee Name</td>
		<%
		strTemp = WebInterface.formatName((String)vEmpRec.elementAt(2),(String)vEmpRec.elementAt(3),(String)vEmpRec.elementAt(4),5);
		%>
		<td><%=strTemp%></td>
	</tr>
	<tr>
	    <td height="25">&nbsp;</td>
	    <td>Position</td>
	    <td><%=(String)vEmpRec.elementAt(5)%></td>
	    </tr>
	<tr>
	    <td height="25">&nbsp;</td>
	    <td>Date of Employment</td>
	    <td><%=(String)vEmpRec.elementAt(6)%></td>
	    </tr>
	<tr>
	    <td height="25">&nbsp;</td>
	    <td>Business / Service Unit</td>
	    <td><%=(String)vEmpRec.elementAt(7)%></td>
	    </tr>
	
	<%}%>
	<tr>
	    <td height="25">&nbsp;</td>
	    <td colspan="2">With Disciplinary Action / Sanction for the past 12 months:
		<%
		strTemp = "";
		if(vEmpEval != null && vEmpEval.size() > 0)
			strTemp = (String)vEmpEval.elementAt(1);
		if(strTemp.equals("1"))
			strErrMsg = "checked";
		else
			strErrMsg = "";
		%>
		<input type="radio" name="disciplinary_action" value="1" <%=strErrMsg%> />YES&nbsp; &nbsp;
		<%
		if(strTemp.equals("0"))
			strErrMsg = "checked";
		else
			strErrMsg = "";
		%>
		<input type="radio" name="disciplinary_action" value="0" <%=strErrMsg%> />NO		</td>
	    </tr>
	<tr>
	    <td height="25">&nbsp;</td>
		<%
		strTemp = "";
		if(vEmpEval != null && vEmpEval.size() > 0)
			strTemp = (String)vEmpEval.elementAt(2);
		%>
	    <td colspan="2">Latest Performance Appraisal Result :
		<textarea name="perfomance_appraisal" cols="50" rows="2"><%=strTemp%></textarea>		</td>
	    </tr>
	<tr>
	    <td height="25">&nbsp;</td>
	    <td>&nbsp;</td>
	    <td><a href="javascript:PageActionEval('1');"><img src="../../../images/update.gif" border="0" /></a>
		<font size="1">Click to save/update employee evaluation.</font></td>
	    </tr>
 </table>

<%}}%>

<table width="100%" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" id="myADTable5">
<tr bgcolor="#FFFFFF"><td height="25"></td></tr>
<tr bgcolor="#A49A6A"><td height="25">&nbsp;</td></tr>
</table>
<input type="hidden" name="page_action" />
<input type="hidden" name="page_action_eval" />

<input type="hidden" name="reload_page">
<input type="hidden" name="encode_type" value="<%=WI.fillTextValue("encode_type")%>">
<%
strTemp = "";
if(vEmpEval != null && vEmpEval.size() > 0)
	strTemp = (String)vEmpEval.elementAt(0);

%>
<input type="hidden" name="info_index" value="<%=strTemp%>" />
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
