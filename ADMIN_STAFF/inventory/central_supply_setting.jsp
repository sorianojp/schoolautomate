<%@ page language="java" import="utility.*, java.util.Vector, inventory.InventorySetting" %>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../css/fontstyle.css" rel="stylesheet" type="text/css">
<style type="text/css">
<!--
.style1 {
	font-size: 10px;
	font-weight: bold;
}
-->
</style>
</head>
<script language="JavaScript" src="../../jscript/common.js"></script>
<script language="JavaScript">
function SetFocus()
{
	document.form_.d_index.focus();
}

function AddRecord()
{
	document.form_.page_action.value = "1";
	this.SubmitOnce("form_");
}

function PrepareToEdit(strInfoIndex){
	document.form_.page_action.value = "";
	document.form_.info_index.value=strInfoIndex;
	document.form_.prepareToEdit.value = "1";
	this.SubmitOnce("form_");
}
function EditRecord(){
	document.form_.page_action.value = "2";
	this.SubmitOnce("form_");
}

function DeleteRecord(strInfoIndex){
	document.form_.page_action.value = "0";
	document.form_.info_index.value = strInfoIndex;
	this.SubmitOnce("form_");
}

function CancelRecord(){
	location ="./central_supply_setting.jsp";
}

</script>
<body bgcolor="#D2AE72" onLoad="SetFocus();">
<%
 
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = "";
	String strTemp = null;

	//authenticate user access level	
	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("INVENTORY-LOG"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("INVENTORY"),"0"));
		}
	}
	


//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-eDaily Time Record-Set Allowed late time in","central_supply_setting.jsp");
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

InventorySetting invSetting = new InventorySetting();

String strCentralDept = null;
String strPrepareToEdit = WI.getStrValue(WI.fillTextValue("prepareToEdit"),"0");

Vector vRetResult  = null;
Vector vEditInfo = null;
strTemp = WI.fillTextValue("page_action");
if(strTemp.length() > 0){
	if(strTemp.compareTo("0") == 0){
		if(invSetting.operateOnInventorySetting(dbOP, request, 0) != null)
			strErrMsg = "Setting recorded successfully.";
		else
			strErrMsg = invSetting.getErrMsg();
	}else	if(strTemp.compareTo("1") == 0){
		if(invSetting.operateOnInventorySetting(dbOP, request, 1) != null)
			strErrMsg = "Setting recorded successfully.";
		else
			strErrMsg = invSetting.getErrMsg();
	}else	if(strTemp.compareTo("2") == 0){
		if(invSetting.operateOnInventorySetting(dbOP, request, 2) != null)
			strErrMsg = "Setting recorded successfully.";
		else
			strErrMsg = invSetting.getErrMsg();
	}
}
	if (strPrepareToEdit.equals("1")){
		vEditInfo = invSetting.operateOnInventorySetting(dbOP, request, 3);
		if (vEditInfo == null)
			strErrMsg = invSetting.getErrMsg();
	}
	vRetResult = invSetting.operateOnInventorySetting(dbOP, request, 4);
	if(vRetResult == null)
		strErrMsg = invSetting.getErrMsg();
//	if(strCentralDept != null && strCentralDept.length() > 0){
//		strDeptName = "select d_name from department where is_del = 0 and d_index = " + strCentralDept;
//		strDeptName = dbOP.getResultOfAQuery(strDeptName,0);
//	}
%>	
<form action="central_supply_setting.jsp" method="post" name="form_">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A"> 
      <td width="100%" height="25" align="center"><font color="#FFFFFF" ><strong>:::: 
        INVENTORY - SETTINGS ::::</strong></font></td>
    </tr>
    <tr > 
      <td height="25">&nbsp;&nbsp;&nbsp;<font size="3"><%=WI.getStrValue(strErrMsg)%></font></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#C78D8D">
      <td width="3%" height="25">&nbsp;</td>
      <td colspan="2"><strong><font color="#FFFFFF">CENTRAL SUPPLIES</font></strong></td>
    </tr>
    
    
    <tr>
      <td height="29">&nbsp;</td>
      <td width="26%">Department</td>
			<%
			if(vEditInfo != null && vEditInfo.size() > 0)
				strCentralDept = (String) vEditInfo.elementAt(0);
			else
				strCentralDept = WI.fillTextValue("d_index");
			%>
      <td width="71%" height="29">
			<select name="d_index">
				<option value="">Select Office</option>
				<%=dbOP.loadCombo("d_index","d_NAME"," from department where is_del = 0 " + 
													" and (c_index = 0 or c_index is null) " +
													" order by d_name asc",strCentralDept, false)%>
      </select></td>
    </tr>
    <tr>
      <td height="29">&nbsp;</td>
      <td>ORDER No. </td>
			<%
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String) vEditInfo.elementAt(2);
			else
				strTemp = WI.fillTextValue("d_index");
			%>			
      <td height="29"><select name="order_no">
        <%for(int i = 1;i < 5; i++){%>
        <%if(strTemp.equals(Integer.toString(i))){%>
        <option value="<%=i%>" selected><%=i%></option>
        <%}else{%>
        <option value="<%=i%>"><%=i%></option>
        <%}%>
        <%}%>
      </select></td>
    </tr>
  </table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellpadding="0" cellspacing="0">
    
    <tr >
      <td height="25">&nbsp;</td>
    </tr>
    <tr > 
      <td height="25"><div align="center">
        <% if (iAccessLevel > 1) {
	  if (vEditInfo == null) {%>
        <a href="javascript:AddRecord()"><img src="../../images/save.gif" width="48" height="28"  border="0"></a><font size="1">click 
          to save entries </font>
        <%}else{%>
        <a href="javascript:EditRecord()"><img src="../../images/edit.gif" width="40" height="26"  border="0"></a><font size="1">click 
          to change entries </font>
        <%} // end else if vEditInfo == null %>
        <a href="javascript:CancelRecord()"><img src="../../images/cancel.gif" border="0"></a><font size="1">click 
          to cancel/clear entries</font>
        <%} // end iAccessLevel > 1%>
</div></td>
    </tr>
  </table>
	<%if(vRetResult != null && vRetResult.size() > 0){%>
	<table width="100%" border="1" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF">    
    <tr> 
      <td height="25" colspan="4" bgcolor="#B9B292">&nbsp;</td>
    </tr>
    <tr> 
      <td width="54%" height="26" align="center"><span class="style1">DEPARTMENT</span></td>
      <td width="25%" align="center">Central Supply Number </td>
      <td colspan="2" align="center"><span class="style1">OPTIONS</span></td>
    </tr>
    
    <% 	for (int i = 0; i< vRetResult.size() ; i+=3) {%>
    <tr> 
      <td height="30">&nbsp;<%=(String)vRetResult.elementAt(i+1)%></td>
      <td align="center">&nbsp;<%=(String)vRetResult.elementAt(i+2)%></td>
      <td width="10%" align="center"> 
        <% if (iAccessLevel > 1) {%>
        <a href='javascript:PrepareToEdit(<%=(String)vRetResult.elementAt(i)%>);'><img src="../../images/edit.gif" width="40" height="26" border="0"></a>
        <%}else{%>
        NA
        <%}%>        </td>
      <td width="11%" align="center"> 
        <% if (iAccessLevel == 2) {%>
        <a href='javascript:DeleteRecord(<%=(String)vRetResult.elementAt(i)%>);'><img src="../../images/delete.gif" width="55" height="28" border="0"></a>
        <%}else{%>
        NA
        <%}%>        </td>
    </tr>
    <%}// end for loop%>
  </table>
	<%}%>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellpadding="0" cellspacing="0">		
    <tr > 
      <td height="25">&nbsp;</td>
    </tr>
    <tr > 
      <td height="25" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
  <input type="hidden" name="addRecord">
	<input type="hidden" name="prepareToEdit" value="<%=strPrepareToEdit%>">
	<input type="hidden" name="info_index" value="<%=WI.fillTextValue("info_index")%>">
	<input type="hidden" name="page_action"">	
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>