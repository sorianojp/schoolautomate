<%@ page language="java" import="utility.*,java.util.Vector " %>
<%
///added code for HR/companies.
boolean bolIsSchool = false;
if( (new CommonUtil().getIsSchool(null)).equals("1"))
	bolIsSchool = true;
String[] strColorScheme = CommonUtil.getColorScheme(8);
//strColorScheme is never null. it has value always.
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<style type="text/css">
.bgDynamic {
	background-color:<%=strColorScheme[1]%>
}
.footerDynamic {
	background-color:<%=strColorScheme[2]%>
}
.style1 {color: #FF0000}
</style>
</head>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript">
function FocusID() {
	document.form_.status_code.focus();
}
function ReloadPage() {
	document.form_.reload_page.value = "1";
	document.form_.page_action.value = "";
	document.form_.submit();
}
function PageAction(strAction, strInfoIndex){
	if(strAction == '0') {
		if(!confirm("Are you sure you want to remove this information."))
			return;
	}
	document.form_.page_action.value = strAction;
	document.form_.info_index.value  = strInfoIndex;
	document.form_.submit();
}

</script>
<body bgcolor="#8C9AAA" onLoad="FocusID();" class="bgDynamic">
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;String strTemp2 = null;

	boolean bolNoRecord = true; //it is false if there is error in edit info.

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Health Monitoring-DENTAL STATUS SET UP","dental_status_setup.jsp");
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
														"Health Monitoring","DENTAL STATUS",request.getRemoteAddr(),
														"dental_status_setup.jsp");
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

//end of authenticaion code.
String strPreparedToEdit = WI.getStrValue(WI.fillTextValue("preparedToEdit"), "0");

health.Dental dental = new health.Dental();
strTemp = WI.fillTextValue("page_action");
if(strTemp.length() > 0){
	if(dental.operateOnDentalStatus(dbOP, request, Integer.parseInt(strTemp)) != null) {
		strErrMsg = "Dental status information updated successfully.";
		strPreparedToEdit = "0";
	}
	else
		strErrMsg = dental.getErrMsg();
}
//get dental record for this day.. 
Vector vRetResult = dental.operateOnDentalStatus(dbOP, request, 4);
Vector vEditInfo  = null;

if(strPreparedToEdit.equals("1"))
	vEditInfo = dental.operateOnDentalStatus(dbOP, request, 3);

%>
<form action="./dental_status_setup.jsp" method="post" name="form_" onSubmit="SubmitOnceButton(this);">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr >
      <td height="28" colspan="3" bgcolor="#697A8F" class="footerDynamic" align="center"><font color="#FFFFFF" ><strong>::::
        DENTAL STATUS MAINTENANCE PAGE ::::</strong></font></td>
    </tr>
    <tr >
      <td height="25" colspan="3">&nbsp;&nbsp;&nbsp;&nbsp;<font size="3">&nbsp;<strong><%=WI.getStrValue(strErrMsg)%></strong></font></td>
    </tr>
    <tr >
      <td width="3%"  >&nbsp;</td>
      <td width="18%" >Dental Status Code </td>
      <td width="79%" >
<%
if(vEditInfo != null) 
	strTemp = (String)vEditInfo.elementAt(1);
else	
	strTemp = WI.fillTextValue("status_code");
%>
	  <input name="status_code" type="text" size="16" maxlength="12" value="<%=strTemp%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
    </tr>
    
    <tr >
      <td >&nbsp;</td>
      <td >Dental Status Name </td>
      <td >
<%
if(vEditInfo != null) 
	strTemp = (String)vEditInfo.elementAt(2);
else	
	strTemp = WI.fillTextValue("status_name");
%>
	  <input name="status_name" type="text" size="32" maxlength="32" value="<%=strTemp%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
    </tr>
    <tr >
      <td >&nbsp;</td>
      <td >Operation : </td>
      <td >
<%
if(vEditInfo != null) 
	strTemp = (String)vEditInfo.elementAt(3);
else	
	strTemp = WI.fillTextValue("edit_del_stat");

if(strTemp.length() == 0) 
	strTemp = "2";

if(strTemp.equals("0")) 
	strErrMsg = " checked";
else	
	strErrMsg = "";
%>
	  <input name="edit_del_stat" type="radio" value="0"<%=strErrMsg%>> Read Only Allowed
<%
if(strTemp.equals("1")) 
	strErrMsg = " checked";
else	
	strErrMsg = "";
%>
      <input name="edit_del_stat" type="radio" value="1"<%=strErrMsg%>> Edit Only Allowed
<%
if(strTemp.equals("2")) 
	strErrMsg = " checked";
else	
	strErrMsg = "";
%>
      <input name="edit_del_stat" type="radio" value="2"<%=strErrMsg%>> Edit/Delete Allowed
	  </td>
    </tr>
     <tr >
      <td height="35"></td>
      <td colspan="2" align="center">
<%if(iAccessLevel > 1){
	if(strPreparedToEdit.equals("0")){%>
		  	<input type="submit" name="12" value="Save Information" style="font-size:11px; height:22px;border: 1px solid #FF0000;" onClick="document.form_.page_action.value='1'">
		  	&nbsp;&nbsp;&nbsp;
	<%}else{%>
			<input type="submit" name="12" value="Edit Information" style="font-size:11px; height:22px;border: 1px solid #FF0000;" onClick="document.form_.page_action.value='2'; document.form_.info_index.value=<%=vEditInfo.remove(0)%>">
	  		&nbsp;&nbsp;&nbsp;
			<input type="submit" name="12" value="Cancel Edit" style="font-size:11px; height:22px;border: 1px solid #FF0000;" onClick="document.form_.page_action.value='';document.form_.status_code.value='';document.form_.status_name.value=''">
	<%}
}%>
	 </td>
    </tr>
   <tr >
      <td height="18" colspan="3" ><hr size="1"></td>
    </tr>
  </table>
<%
if(vRetResult != null && vRetResult.size() > 0) {%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr >
      <td height="22" colspan="6" bgcolor="#FFFF9F" align="center" style="font-weight:bold; font-size:11px;" class="thinborder">::: List of Dental Status ::: </td>
    </tr>
    <tr style="font-weight:bold">
      <td width="25%" height="22" class="thinborder">Status Code </td>
      <td width="30%" class="thinborder">Status Name </td>
      <td width="25%" class="thinborder">Edit/Delete Status </td>
      <td width="10%" class="thinborder">Edit</td>
      <td width="10%" class="thinborder">Delete</td>
    </tr>
<%int iStatus = 0;
for(int i = 0; i < vRetResult.size(); i += 4){
iStatus = Integer.parseInt((String)vRetResult.elementAt(i + 3));
if(iStatus == 0)
	strTemp = "Read only";
else if (iStatus == 1)
	strTemp = "Edit only";
else	
	strTemp = "Edit/Delete Allowed";
%>
    <tr >
      <td class="thinborder" height="22"><%=vRetResult.elementAt(i + 1)%></td>
      <td class="thinborder"><%=vRetResult.elementAt(i + 2)%></td>
      <td class="thinborder"><%=strTemp%></td>
      <td class="thinborder"><%if(iStatus == 0) {%>Not Allowed<%}else{%>
		  	<input type="submit" name="12" value="Edit" style="font-size:11px; height:22px;border: 1px solid #FF0000;" onClick="document.form_.page_action.value='3'; document.form_.info_index.value=<%=vRetResult.elementAt(i)%>">
	  <%}%>
	  </td>
      <td class="thinborder"><%if(iStatus == 2) {%>
		  	<input type="button" name="12" value="Delete" style="font-size:11px; height:22px;border: 1px solid #FF0000;" onClick="PageAction('0','<%=vRetResult.elementAt(i)%>')">
	  <%}else{%>Not Allowed<%}%></td>
    </tr>
<%}%>
  </table>
<%}//only if staff %>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    
    <tr>
      <td height="10" colspan="5">&nbsp;</td>
    </tr>
  </table>

  <table  width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr >
      <td height="25" colspan="9">&nbsp;</td>
    </tr>
    <tr >
      <td height="25" colspan="9" bgcolor="#697A8F" class="footerDynamic">&nbsp;</td>
    </tr>
  </table>
<input type="hidden" name="page_action">
<input type="hidden" name="info_index" value="">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
