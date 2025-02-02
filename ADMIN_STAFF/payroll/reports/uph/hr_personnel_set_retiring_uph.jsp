<%@ page language="java" import="utility.*,java.util.Vector,hr.HRInfoServiceRecord"%>
<%
///added code for HR/companies.
boolean bolIsSchool = false;
if( (new ReadPropertyFile().getImageFileExtn("IS_SCHOOL","1")).equals("1"))
	bolIsSchool = true;
%>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<style type="text/css">
 TD{
 	font-size: 11px;
 }
</style>
</head>
<script language="JavaScript" src="../../../Ajax/ajax.js"></script>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript">
function PageAction(strAction, strInfoIndex) {
	if(strAction == "0"){
		if(!confirm("Do you want to delete this information?"))
			return;
	}
	
	if(strInfoIndex.length > 0)
		document.form_.info_index.value = strInfoIndex;
				
	document.form_.page_action.value = strAction;
	document.form_.submit();
}
function ReloadPage() {
	document.form_.page_action.value = "";
	document.form_.submit();
}



function PrepareToEdit(index){
	document.form_.prepareToEdit.value = "1";
	document.form_.info_index.value = index;
	document.form_.page_action.value = "";
	document.form_.submit();
}
function FocusID() {
	if(document.form_.emp_id)
		document.form_.emp_id.focus();
}

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
		var strURL = "../../../Ajax/AjaxInterface.jsp?methodRef=2&search_id=1&is_faculty=1&name_format=4&complete_name="+
			escape(strCompleteName);

		this.processRequest(strURL);
}
function UpdateID(strID, strUserIndex) {
	document.form_.emp_id.value = strID;
	document.getElementById("coa_info").innerHTML = "<font size='1' color=blue>...end of processing..</font>";
	document.form_.submit();
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
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
	String strTemp2 = null;
	String strTemp3 = null;
	String strImgFileExt = null;
	String strPrepareToEdit = WI.getStrValue(WI.fillTextValue("prepareToEdit"),"0");
	
//add security hehol.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-PERSONNEL","hr_personnel_set_retiring_uph.jsp");
		ReadPropertyFile readPropFile = new ReadPropertyFile();
		strImgFileExt = readPropFile.getImageFileExtn("imgFileUploadExt");

		if(strImgFileExt == null || strImgFileExt.trim().length() ==0)
		{
			strErrMsg = "Image file extension is missing. Please contact school admin.";
			dbOP.cleanUP();
			throw new Exception();
		}
	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		if(strErrMsg == null)
		strErrMsg = "Error in opening DB Connection.";
		%>

		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		  Error in opening connection </font></p>
		<%
		return;
	}
//authenticate this user.
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"HR Management","PERSONNEL",request.getRemoteAddr(),
														"hr_personnel_set_retiring_uph.jsp");


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
Vector vEditInfo  = null;
Vector vEmpRec = null;Vector vTemp = null;

hr.HRRetirementMgmt retMgmt = new hr.HRRetirementMgmt();





String strEmpId = WI.fillTextValue("emp_id");
if(strEmpId.length() == 0)
	strEmpId = (String)request.getSession(false).getAttribute("encoding_in_progress_id");
else	
	request.getSession(false).setAttribute("encoding_in_progress_id",strEmpId);
strEmpId = WI.getStrValue(strEmpId);

if (WI.fillTextValue("emp_id").length() == 0 && strEmpId.length() > 0){
	request.setAttribute("emp_id",strEmpId);
}


strTemp = WI.fillTextValue("page_action");
if(strTemp.length() > 0){
	if(retMgmt.operateOnEmpRetirement(dbOP, request, Integer.parseInt(strTemp)) == null)
		strErrMsg = retMgmt.getErrMsg();
	else{
		if(strTemp.equals("0"))
			strErrMsg = "Information successfully removed.";
		if(strTemp.equals("1"))
			strErrMsg = "Information successfully saved.";
		if(strTemp.equals("2"))
			strErrMsg = "Information successfully updated.";		
	}
}

if (strEmpId.trim().length()> 0){
	enrollment.Authentication authentication = new enrollment.Authentication();
    vEmpRec = authentication.operateOnBasicInfo(dbOP,request,"0");
	if(vEmpRec == null || vEmpRec.size() == 0)
		strErrMsg = "Employee has no profile.";
}
int iElemCount = 0;
vRetResult = retMgmt.operateOnEmpRetirement(dbOP, request, 4);
if(vRetResult != null && vRetResult.size() > 0)
	iElemCount = retMgmt.getElemCount();

%>

<body bgcolor="#FFFFFF" onLoad="focusID()">
<form action="./hr_personnel_set_retiring_uph.jsp" method="post" name="form_">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A"> 
      <td height="25" colspan="5" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF" ><strong>:::: 
          EMPLOYEE RETIREMENT MANAGEMENT PAGE ::::</strong></font></div></td>
    </tr>
    <tr> 
      <td height="30" colspan="5">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; <font size="3"><strong><%=WI.getStrValue(strErrMsg)%></strong></font> </td>
    </tr>    
    <tr>
        <td width="3%">&nbsp;</td> 
      <td width="17%" height="25">Employee ID :</td>      
      <td width="23%"> 
        <input name="emp_id" type="text" class="textbox"   onFocus="style.backgroundColor='#D3EBFF'"
		onBlur="style.backgroundColor='white'" value="<%=strEmpId%>" onKeyUp="AjaxMapName(1);">
        <a href="javascript:OpenSearch();"><img src="../../../images/search.gif" border="0" align="absmiddle"></a></td>
      <td width="57%"><label id="coa_info"></label>	  </td>
    </tr>
    <tr>
        <td>&nbsp;</td>
        <td height="25">Effective Date From</td>
        <td height="25"><input name="eff_date_fr" type="text" size="10" maxlength="10" readonly
			  onfocus="style.backgroundColor='#D3EBFF'" value="<%=WI.fillTextValue("eff_date_fr")%>" class="textbox"
			  onblur="style.backgroundColor='white';">
              <a href="javascript:show_calendar('form_.eff_date_fr');" title="Click to select date" 
			 	onMouseOver="window.status='Select date';return true;" 
			  	onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a></td>
        <td><a href="javascript:ReloadPage();"><img src="../../../images/refresh.gif" border="0"></a></td>
    </tr>
    <tr valign="top">
        <td height="25">&nbsp;</td>
        <td height="25">&nbsp;</td>
        <td height="25" colspan="2">
		<a href="javascript:PageAction('1','');"><img src="../../../images/save.gif" border="0"></a>
		<font size="1">Click to save information</font>
		<%
		strTemp = WI.fillTextValue("show_retired");
		if(strTemp.equals("1"))
			strTemp = "checked";
		else
			strTemp = "";
		%>
		<input type="checkbox" name="show_retired" value="1" <%=strTemp%> onClick="ReloadPage();">Click to show employees already retired.
		</td>
        </tr>    
  </table>
<%
if(vRetResult != null && vRetResult.size() > 0){
%>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
	<tr><td align="center" height="25"><strong>LIST OF EMPLOYEE FOR RETIREMENT</strong></td></tr>
</table>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
	<tr>
		<td width="14%" height="22" align="center" class="thinborder">EMPLOYEE ID</td>
		<td width="25%" align="center" class="thinborder">EMPLOYEE NAME</td>
		<td width="14%" align="center" class="thinborder">EFFECTIVE DATE FROM</td>
		<td width="25%" align="center" class="thinborder">CREATED BY</td>
		<td width="13%" align="center" class="thinborder">RETIRE DATE</td>
		<td width="9%" align="center" class="thinborder">DELETE</td>
	</tr>
<%for(int i = 0 ; i < vRetResult.size(); i+=iElemCount){%>
	<tr>
	    <td height="22" class="thinborder"><%=vRetResult.elementAt(i+1)%></td>
		<%
		strTemp  = WebInterface.formatName((String)vRetResult.elementAt(i+2),(String)vRetResult.elementAt(i+3),(String)vRetResult.elementAt(i+4),7);
		%>
	    <td class="thinborder"><%=strTemp%></td>
	    <td class="thinborder"><%=vRetResult.elementAt(i+5)%></td>
		<%
		strTemp  = WebInterface.formatName((String)vRetResult.elementAt(i+7),(String)vRetResult.elementAt(i+8),(String)vRetResult.elementAt(i+9),7);
		%>
	    <td class="thinborder"><%=strTemp%> (<%=vRetResult.elementAt(i+6)%>)</td>
	    <td class="thinborder"><%=WI.getStrValue(vRetResult.elementAt(i+11),"&nbsp;")%></td>
	    <td class="thinborder">
		<%if(WI.fillTextValue("show_retired").length() == 0){%>
		<a href="javascript:PageAction('0','<%=vRetResult.elementAt(i)%>')"><img src="../../../images/delete.gif" border="0"></a>
		<%}%>&nbsp;
		</td>
    </tr>
<%}%>
</table>
<%}%>
<input type="hidden" name="page_action">
<input type="hidden" name="prepareToEdit" value="<%=strPrepareToEdit%>">
<input type="hidden" name="info_index" value="<%=WI.fillTextValue("info_index")%>">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
