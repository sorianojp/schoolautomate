<%@ page language="java" import="utility.*,health.PresentHealthStatus,java.util.Vector " %>
<%
String[] strColorScheme = CommonUtil.getColorScheme(8);
//strColorScheme is never null. it has value always.
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<style type="text/css">
.bgDynamic {
	background-color:<%=strColorScheme[1]%>
}
.footerDynamic {
	background-color:<%=strColorScheme[2]%>
}
</style>
</head>
<script language="JavaScript">
function PrepareToEdit(strInfoIndex)
{
	document.form_.page_action.value = "";
	document.form_.prepareToEdit.value = 1;
	document.form_.info_index.value = strInfoIndex;
	document.form_.submit();
}

function PageAction(strPageAction, strInfoIndex)
{
	document.form_.page_action.value = strPageAction;
	document.form_.info_index.value = strInfoIndex;
	document.form_.prepareToEdit.value == 0;

	document.form_.submit();
}
function CancelRecord()
{
	location = "./phs_entry_mgmt_update_res_type.jsp";
}
</script>
<body bgcolor="#8C9AAA" class="bgDynamic">
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
	String strPrepareToEdit=WI.fillTextValue("prepareToEdit");
	if(strPrepareToEdit.length() == 0) strPrepareToEdit="0";

	boolean bolShowEditInfo = true; //it is false if there is error in edit info.

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Health Monitoring-Present Health Status",
								"phs_entry_mgmt_update_res_type.jsp");
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
														"Health Monitoring","Present Health Status",request.getRemoteAddr(),
														"phs_entry_mgmt_update_res_type.jsp");
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

PresentHealthStatus presentHealthStat = new PresentHealthStatus();

//check for add - edit or delete
strTemp = WI.fillTextValue("page_action");
if(strTemp.length() > 0) {//called for adde,edit or delete.
	if(presentHealthStat.oprateOnDurationUpdate(dbOP, request,Integer.parseInt(strTemp)) == null) {
		strErrMsg = presentHealthStat.getErrMsg();
		bolShowEditInfo = false;
	}	
	else {	
		strErrMsg = "Operation is successful.";
		strPrepareToEdit = "0";
	}		
}

//get all levels created.
Vector vRetResult = null;
Vector vEditInfo = null;
vRetResult = presentHealthStat.oprateOnDurationUpdate(dbOP, request,4);//view all. 

if(strPrepareToEdit.compareTo("1") == 0)
	vEditInfo = presentHealthStat.oprateOnDurationUpdate(dbOP, request,3);//edit information.

if(bolShowEditInfo) {
	if(vEditInfo == null || vEditInfo.size() == 0)
		bolShowEditInfo = false;
}

%>
<form action="./phs_entry_mgmt_update_res_type.jsp" method="post" name="form_">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#697A8F">
      <td width="100%" height="25" class="footerDynamic"><div align="center"><font color="#FFFFFF" ><strong>:::: 
          PRESENT HEALTH STATUS - HEALTH STATUS ENTRY MGMT. - UPDATE RESPONSE 
          TYPE - DURATION PAGE ::::</strong></font></div></td>
    </tr>
    <tr >
      <td height="25">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; <font size="3"><%=WI.getStrValue(strErrMsg)%></font></td>
    </tr>
  </table>
<%
if(WI.fillTextValue("hm_entry_index").length() > 0){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="6%" height="30">&nbsp;</td>
      <td width="24%" height="30">Entry name</td>
      <td height="30"><%=dbOP.mapOneToOther("HM_ENTRY_DETAIL","HM_ENTRY_INDEX",
	  	WI.fillTextValue("hm_entry_index"),"ENTRY_NAME",null)%></td>
    </tr>
    <tr> 
      <td height="18" colspan="3"><hr size="1"></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25">Options </td>
      <td height="25"> 
<%
if(bolShowEditInfo)
	strTemp = (String)vEditInfo.elementAt(2);
else
	strTemp = WI.fillTextValue("option");
%>
        <input name="option" type="text" size="32" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"> 
      </td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Display Order</td>
      <td>
<%
if(bolShowEditInfo)
	strTemp = (String)vEditInfo.elementAt(1);
else
	strTemp = WI.fillTextValue("disp_order");
%>
        <input name="disp_order" type="text" size="2" maxlength="2" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"></td>
    </tr>
    <tr> 
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
      <td width="70%" height="18">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25" colspan="2">
        <%
if(strPrepareToEdit.compareTo("0") == 0 && iAccessLevel > 1)
{%>
        <a href='javascript:PageAction(1,"");'><img src="../../../images/add.gif" border="0"></a><font size="1" >click 
        to add </font> 
        <%}else if(iAccessLevel > 1){%>
        <a href='javascript:PageAction(2,"<%=(String)vEditInfo.elementAt(0)%>");'><img src="../../../images/edit.gif" border="0"></a><font size="1" >click 
        to save changes </font><a href="javascript:CancelRecord();"><img src="../../../images/cancel.gif" border="0"></a> 
        <font size="1" >click to cancel or go previous </font> 
        <%}%>
      </td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
    </tr>
  </table>
<%
if(vRetResult != null && vRetResult.size() > 0){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="25" colspan="5" bgcolor="#C4D0CC"><div align="center"><strong><font color="#330099">LIST 
          OF OPTIONS FOR <font color="#FF0000">DURATION</font> RESPONSE TYPE</font></strong></div></td>
    </tr>
    <tr>
      <td width="4%">&nbsp;</td>
      <td width="13%" height="25"><div align="center"><strong><font size="1">DISP 
          ORDER</font></strong></div></td>
      <td width="60%"><div align="center"><strong><font size="1">OPTION</font></strong></div></td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
<%for(int i = 0 ; i < vRetResult.size() ; i += 3){%>
    <tr>
      <td>&nbsp;</td>
      <td height="25"><%=(String)vRetResult.elementAt(i + 1)%></td>
      <td><%=(String)vRetResult.elementAt(i + 2)%></td>
      <td width="8%">
        <%if(iAccessLevel > 1){%>
        <a href='javascript:PrepareToEdit("<%=(String)vRetResult.elementAt(i)%>");'><img src="../../../images/edit.gif" border="0"></a> 
        <%}else{%>
        NA 
        <%}%>
      </td>
      <td width="15%">
        <%if(iAccessLevel == 2 ){%>
        <a href='javascript:PageAction("0","<%=(String)vRetResult.elementAt(i)%>");'><img src="../../../images/delete.gif" border="0"></a> 
        <%}else{%>
        NA 
        <%}%>
      </td>
    </tr>
<%}%>
  </table>
 <%}//end of display only if vRetResult != null
}//if(WI.fillTextValue("hm_entry_index").length() > 0) 
%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="25" colspan="5"><div align="center"></div></td>
    </tr>
    <tr> 
      <td height="10" colspan="5">&nbsp;</td>
    </tr>
  </table>

  <table bgcolor="#FFFFFF" width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr >
      <td height="25" colspan="9" bgcolor="#697A8F" class="footerDynamic">&nbsp;</td>
    </tr>
  </table>
  
<input type="hidden" name="info_index" value="<%=WI.fillTextValue("info_index")%>">
<input type="hidden" name="prepareToEdit" value="<%=strPrepareToEdit%>">
<input type="hidden" name="page_action" value="">
<input type="hidden" name="hm_entry_index" value="<%=WI.fillTextValue("hm_entry_index")%>">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>