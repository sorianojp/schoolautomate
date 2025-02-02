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
function ReloadPage() {
	document.form_.page_action.value = "";
	document.form_.submit();
}
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
	location = "./phs_entry_mgmt.jsp";
}
function PrintPg() {

}
function FocusID() {
	document.form_.entry_name.focus();
}
function UpdateResponse(strIndex) {
	var loadPg = "./phs_entry_mgmt_update_res_type.jsp?hm_entry_index="+strIndex;
	var win=window.open(loadPg,"myfile",'dependent=yes,width=700,height=500,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
} 
//if no option, i have to check the past medical history only.
</script>

<body bgcolor="#8C9AAA" onLoad="FocusID();" class="bgDynamic">
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
								"Admin/staff-Health Monitoring-Present Health Status","phs_entry_mgmt.jsp");
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
														"phs_entry_mgmt.jsp");
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
	if(presentHealthStat.oprateOnHealthStatusEntryMgmt(dbOP, request,Integer.parseInt(strTemp)) == null) {
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
vRetResult = presentHealthStat.oprateOnHealthStatusEntryMgmt(dbOP, request,4);//view all. 

if(strPrepareToEdit.compareTo("1") == 0)
	vEditInfo = presentHealthStat.oprateOnHealthStatusEntryMgmt(dbOP, request,3);//edit information.

if(bolShowEditInfo) {
	if(vEditInfo == null || vEditInfo.size() == 0)
		bolShowEditInfo = false;
}

%>
<form action="./phs_entry_mgmt.jsp" method="post" name="form_">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#697A8F"> 
      <td height="25" colspan="3" class="footerDynamic"><div align="center"><font color="#FFFFFF" ><strong>:::: 
          PRESENT HEALTH STATUS - HEALTH STATUS ENTRY MGMT. PAGE ::::</strong></font></div></td>
    </tr>
    <tr > 
      <td height="25" colspan="3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; <font size="3"><%=WI.getStrValue(strErrMsg)%></font></td>
    </tr>
    <tr > 
      <td width="2%" height="25">&nbsp;</td>
      <td width="16%">Entry Name</td>
      <td width="82%">
<%
if(bolShowEditInfo)
	strTemp = (String)vEditInfo.elementAt(1);
else
	strTemp = WI.fillTextValue("entry_name");
%>
	  <input name="entry_name" type="text" size="32" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        <a href="javascript:ReloadPage();"><img src="../../../images/refresh.gif" border="0"></a>Click 
        to refresh the page.</td>
    </tr>
    <tr > 
      <td height="25">&nbsp;</td>
      <td>Response</td>
      <td>
<%
if(bolShowEditInfo)
	strTemp = (String)vEditInfo.elementAt(2);
else
	strTemp = WI.fillTextValue("response");
%>	  <select name="response">
          <option value="0">Yes/No</option>
 <%
 if(strTemp.compareTo("1") ==0){%>
          <option value="1" selected>Duration Set</option>
 <%}else{%>
          <option value="1">Duration Set</option>
 <%}if(strTemp.compareTo("2") ==0){%>
          <option value="2" selected>No Option</option>
 <%}else{%>
          <option value="2">No Option</option>
<%}%>        </select> </td>
    </tr>
    <tr > 
      <td height="10">&nbsp;</td>
      <td><strong>Tick at least one</strong></td>
      <td>
<%
if(bolShowEditInfo)
	strTemp = (String)vEditInfo.elementAt(3);
else
	strTemp = WI.fillTextValue("used_in_present");
if(strTemp.compareTo("1") == 0)
	strTemp = " checked";
else	
	strTemp = "";
%>	  <input type="checkbox" name="used_in_present" value="1"<%=strTemp%>>
        Used in Present Health Status</td>
    </tr>
    <tr > 
      <td height="10">&nbsp;</td>
      <td>&nbsp;</td>
      <td>
<%
if(bolShowEditInfo)
	strTemp = (String)vEditInfo.elementAt(4);
else
	strTemp = WI.fillTextValue("used_in_past");
if(strTemp.compareTo("1") == 0)
	strTemp = " checked";
else	
	strTemp = "";
%>	  <input type="checkbox" name="used_in_past" value="1"<%=strTemp%>>
        Past Medical History</td>
    </tr>
    <tr > 
      <td height="10">&nbsp;</td>
      <td>&nbsp;</td>
      <td>
<%
if(bolShowEditInfo)
	strTemp = (String)vEditInfo.elementAt(5);
else
	strTemp = WI.fillTextValue("used_in_family");
if(strTemp.compareTo("1") == 0)
	strTemp = " checked";
else	
	strTemp = "";%>	  <input type="checkbox" name="used_in_family" value="1"<%=strTemp%>>
        Used in Family History</td>
    </tr>
    <tr >
      <td height="10">&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
    <tr > 
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td>
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
    <tr > 
      <td height="10">&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
  </table>
<%
if(vRetResult != null && vRetResult.size() > 0){%>
  <table width="100%" border="1" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="25" colspan="9" bgcolor="#C4D0CC"><div align="center"><strong><font color="#FFFFFF">LIST 
          OF ENTRIES FOR HEALTH RECORD</font></strong></div></td>
    </tr>
    <tr> 
      <td width="42%" height="25"><div align="left"><font size="1"><strong>&nbsp;&nbsp;ENTRY NAME</strong></font></div></td>
      <td width="6%"><font size="1"><strong>PRESENT</strong></font></td>
      <td width="6%"><font size="1"><strong>HISTORY</strong></font></td>
      <td width="6%"><font size="1"><strong>FAMILY</strong></font></td>
      <td width="5%"><font size="1"><strong>RESPONSE</strong></font></td>
      <td width="5%"><font size="1"><strong>UPDATE</strong></font></td>
      <td width="5%"><font size="1"><strong>EDIT</strong></font></td>
      <td width="5%"><font size="1"><strong>DELETE</strong></font></td>
    </tr>
 <%
 String[] astrConvertResponse = {"Yes/No","Duration Set", "No Option"};
 int iResponse = 0;//response type, yes/no or duration.
 for(int i = 0 ; i< vRetResult.size() ; i += 6){
 iResponse = Integer.parseInt((String)vRetResult.elementAt(i + 2));
 %>
    <tr> 
      <td>&nbsp;&nbsp;<%=(String)vRetResult.elementAt(i + 1)%></td>
      <td>&nbsp;<% if( ((String)vRetResult.elementAt(i+3)).compareTo("1") ==0){%>
        <img src="../../../images/tick.gif"> 
        <%}%>
      </td>
      <td>&nbsp;<% if( ((String)vRetResult.elementAt(i+4)).compareTo("1") ==0){%>
        <img src="../../../images/tick.gif"> 
        <%}%>
      </td>
      <td>&nbsp;
<% if( ((String)vRetResult.elementAt(i+5)).compareTo("1") ==0){%>
        <img src="../../../images/tick.gif"> 
        <%}%>
      </td>
      <td><%=astrConvertResponse[iResponse]%></td>
      <td>&nbsp;
<%if(iResponse == 1){//show only if it is duration set type.%>
   <a href='javascript:UpdateResponse("<%=(String)vRetResult.elementAt(i)%>");'>
   									<img src="../../../images/update.gif" border="0"></a>
<%}%>
	   </td>
      <td>
        <%if(iAccessLevel > 1){%>
        <a href='javascript:PrepareToEdit("<%=(String)vRetResult.elementAt(i)%>");'><img src="../../../images/edit.gif" border="0"></a> 
        <%}else{%>
        NA 
        <%}%>
      </td>
      <td>
        <%if(iAccessLevel == 2 ){%>
        <a href='javascript:PageAction("0","<%=(String)vRetResult.elementAt(i)%>");'><img src="../../../images/delete.gif" border="0"></a> 
        <%}else{%>
        NA 
        <%}%>
      </td>
    </tr>
 <%}%>
  </table>
 <%}//end of display if vRetResult.size() > 0%>
  
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="10" colspan="5">&nbsp;</td>
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

</form>
</body>
</html>
<%
dbOP.cleanUP();
%>