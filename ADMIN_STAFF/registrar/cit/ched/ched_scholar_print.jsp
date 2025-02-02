<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Transferee Info Management</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../../Ajax/ajax.js"></script>
<script language="JavaScript">
function PareparedToEdit(strInfoIndex) {
	document.form_.preparedToEdit.value = '1';
	document.form_.info_index.value = strInfoIndex;
	document.form_.page_action.value = '';
	document.form_.submit();
}
function PageAction(strInfoIndex, strAction) {
	if(strAction == '0') {
		if(!confirm('Are you sure you want to delete this record'))
			return;
	}
	if(strAction == '5') {
		if(!confirm('Are you sure you want to Invalidate this record'))
			return;
	}
	document.form_.preparedToEdit.value = '';
	document.form_.info_index.value = strInfoIndex;
	document.form_.page_action.value = strAction;
	document.form_.submit();
}


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

</script>

<body bgcolor="#D2AE72" onLoad="document.form_.stud_id.focus();">
<%@ page language="java" import="utility.*,enrollment.CITChedBilling,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;

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
//authenticate this user.
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"Registrar Management","CHED SCHOLAR",request.getRemoteAddr(),
														"assign_student.jsp");
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

//end of authenticaion code.

CITChedBilling CCB = new CITChedBilling();
Vector vRetResult = null; Vector vStudInfo = new Vector();

Vector vPrevSYInfo = new Vector();

String strStudIndex  = null;
boolean bolIsFailed  = false;


if(WI.fillTextValue("stud_id").length() > 0 && WI.fillTextValue("sy_from").length() > 0) {
	enrollment.EnrlAddDropSubject EADS = new enrollment.EnrlAddDropSubject();
	vStudInfo = EADS.getEnrolledStudInfo(dbOP, null,WI.fillTextValue("stud_id"), WI.fillTextValue("sy_from"),
				String.valueOf(Integer.parseInt(WI.fillTextValue("sy_from")) + 1), WI.fillTextValue("semester")); 
	if(vStudInfo == null)
		strErrMsg = EADS.getErrMsg();
	else {
		strStudIndex = (String)vStudInfo.elementAt(0);
		vPrevSYInfo = CCB.prevEnrollmentInformation(dbOP, strStudIndex, WI.fillTextValue("sy_from"),WI.fillTextValue("semester")); 
	}
}




strTemp = WI.fillTextValue("page_action");
if(strTemp.length() > 0) {
	if(CCB.operateOnAssignAwardNo(dbOP, request, Integer.parseInt(strTemp), strStudIndex) == null) {
		strErrMsg = CCB.getErrMsg();
		bolIsFailed = true;
	}
	else {
		strErrMsg    = "Request processed successfully.";
	}
}
vRetResult = CCB.operateOnAssignAwardNo(dbOP, request, 3, strStudIndex);
if(vRetResult == null)
	strErrMsg = CCB.getErrMsg();


%>
<form action="./assign_student.jsp" method="post" name="form_">
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="4"><div align="center"><font color="#FFFFFF"><strong>::::
          MANAGE SCHOLARSHIP TYPE :::: </strong></font></div></td>
    </tr>
  </table>
	<table  bgcolor="#FFFFFF" width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr >
		<td width="2%" height="25" colspan="4">&nbsp;</td>
      <td width="98%"><strong><%=WI.getStrValue(strErrMsg)%></strong></td>
    </tr>
  </table>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr >
      <td height="25">&nbsp;</td>
      <td>Stduent ID </td>
      <td>
			<input name="stud_id" type="text" value="<%=WI.fillTextValue("stud_id")%>" class="textbox"
				onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" onKeyUp="AjaxMapName('1');">
		<label id="coa_info" style="font-size:11px; font-weight:bold; color:#0000FF"></label>
	  </td>
    </tr>
    <tr >
      <td height="25">&nbsp;</td>
      <td>SY-Term</td>
      <td>
<%
strTemp = WI.fillTextValue("sy_from");
if(strTemp.length() ==0)
	strTemp = WI.getStrValue((String)request.getSession(false).getAttribute("cur_sch_yr_from"));
%>
	<input name="sy_from" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
	  
	  - 
	  
	  <select name="semester">
          <option value="0">Summer</option>
<%
strTemp = WI.fillTextValue("semester");
if(strTemp.length() ==0)
	strTemp = WI.getStrValue((String)request.getSession(false).getAttribute("cur_sem"));
if(strTemp.equals("1"))
	strErrMsg = " selected";
else	
	strErrMsg = "";
%>
          <option value="1" <%=strErrMsg%>>1st Sem</option>
<%
if(strTemp.equals("2"))
	strErrMsg = " selected";
else	
	strErrMsg = "";
%>
          <option value="2" <%=strErrMsg%>>2nd Sem</option>
<%
if(strTemp.equals("3"))
	strErrMsg = " selected";
else	
	strErrMsg = "";
%>
          <option value="3" <%=strErrMsg%>>3rd Sem</option>
        </select>	
	  </td>
    </tr>
    <tr >
      <td width="2%" height="25">&nbsp;</td>
      <td width="13%">&nbsp;</td>
      <td width="85%">
		  <input type="submit" name="_show_result" value="Show Result" onClick="document.form_.page_action.value='';">
	  </td>
    </tr>
  </table>
<%if(vStudInfo != null && vStudInfo.size() > 0) {%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
	<tr>
      <td width="2%" height="25">&nbsp;</td>
      <td width="15%">Student Name </td>
      <td><%=vStudInfo.elementAt(1)%></td>
    </tr>
	<tr>
	  <td height="25">&nbsp;</td>
	  <td>Current Course-Yr </td>
	  <td><%=vStudInfo.elementAt(16)%> <%=WI.getStrValue((String)vStudInfo.elementAt(22), " - ", "","")%> <%=WI.getStrValue((String)vStudInfo.elementAt(4), " - ", "","")%></td>
    </tr>
<%
if(vPrevSYInfo != null && vPrevSYInfo.size() > 0)
	strTemp = (String)vPrevSYInfo.elementAt(3) + WI.getStrValue((String)vPrevSYInfo.elementAt(5), " - ", "","") + WI.getStrValue((String)vPrevSYInfo.elementAt(7), " - ", "","");
else
	strTemp = "";
%>
	<tr>
	  <td height="25">&nbsp;</td>
	  <td>Previous Course-Yr </td>
	  <td><%=strTemp%></td>
    </tr>
<%
if(vPrevSYInfo != null && vPrevSYInfo.size() > 0) {
	String[] astrConvertTerm = {"Summer","1st Sem","2nd Sem","3rd Sem"};
	strTemp = astrConvertTerm[Integer.parseInt((String)vPrevSYInfo.elementAt(2))] + ", "+(String)vPrevSYInfo.elementAt(0) + " - "+(String)vPrevSYInfo.elementAt(1);
}
else
	strTemp = "";
%>
	<tr>
	  <td height="25">&nbsp;</td>
	  <td>Previous SY/Term </td>
	  <td><%=strTemp%></td>
    </tr>
<%
if(bolIsFailed)
	strTemp = WI.fillTextValue("gwa");
else if(vPrevSYInfo != null && vPrevSYInfo.size() > 0)
	strTemp = (String)vPrevSYInfo.elementAt(8);
else
	strTemp = "0.00";
%>
	<tr>
	  <td height="25">&nbsp;</td>
	  <td>Previos GWA </td>
	  <td>
	  	<input name="gwa" type="text" value="<%=strTemp%>" size="5" maxlength="5" class="textbox"
			onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
	  </td>
    </tr>
<%
if(bolIsFailed)
	strTemp = WI.fillTextValue("award_no");
else if(vRetResult != null && vRetResult.size() > 0)
	strTemp = (String)vRetResult.elementAt(1);
else
	strTemp = "";
%>
	<tr>
	  <td height="25">&nbsp;</td>
	  <td>Award No </td>
	  <td><input name="award_no" type="text" value="<%=strTemp%>" class="textbox"
			onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
	  </td>
    </tr>
<%
if(bolIsFailed)
	strTemp = WI.fillTextValue("remarks");
else if(vRetResult != null && vRetResult.size() > 0)
	strTemp = (String)vRetResult.elementAt(2);
else
	strTemp = "";
%>
	<tr>
	  <td height="25">&nbsp;</td>
	  <td>Remarks</td>
	  <td>
<input name="remarks" type="text" value="<%=strTemp%>" size="75" class="textbox"
			onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
	  </td>
    </tr>
<%
if(bolIsFailed)
	strTemp = WI.fillTextValue("scholar_type");
else if(vRetResult != null && vRetResult.size() > 0)
	strTemp = (String)vRetResult.elementAt(0);
else
	strTemp = "";
%>
	<tr>
	  <td height="25">&nbsp;</td>
	  <td>Scholarship Type </td>
	  <td>
		<select name="scholar_type">
          <%=dbOP.loadCombo("SCHOLAR_TYPE_INDEX","SCHOLAR_CODE,SCHOLAR_NAME"," from CIT_CHED_SCHOLAR_TYPE where is_valid = 1 and IN_ACTIVE = 0 order by scholar_code", strTemp, false)%>
		</select>
	  </td>
    </tr>
	<tr>
	  <td height="25">&nbsp;</td>
	  <td>&nbsp;</td>
	  <td>
	  <input type="submit" name="_update_info" value="Update Information" onClick="document.form_.page_action.value='1';">
	  </td>
    </tr>
  </table>
<%}%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
	<tr>
      <td height="25">&nbsp;</td>
    </tr>
    <tr>
      <td height="25" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
  <!-- all hidden fields go here -->
  <input type="hidden" name="info_index">
  <input type="hidden" name="page_action">
  
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
