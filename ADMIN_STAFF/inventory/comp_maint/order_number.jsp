<%@ page language="java" import="utility.*,inventory.InvCPUMaintenance,java.util.Vector" %>
<%
String[] strColorScheme = CommonUtil.getColorScheme(6);
//strColorScheme is never null. it has value always.
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
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
<script language="javascript"  src ="../../../jscript/common.js" ></script>
<script language="JavaScript">
//called for add or edit.
function PageAction(strAction, strInfoIndex) {
	document.form_.page_action.value = strAction;
	if(strInfoIndex.length > 0)
		document.form_.info_index.value = strInfoIndex;
	if(strAction == 1) 
		document.form_.save.disabled = true;
		//document.form_.hide_save.src = "../../../images/blank.gif";
	document.form_.submit();
}
function PrepareToEdit(strInfoIndex) {
	document.form_.page_action.value = "";
	document.form_.prepareToEdit.value = "1";
	document.form_.info_index.value = strInfoIndex;
	document.form_.submit();
}
function ReloadPage() {
	document.form_.reloaded.value = "";
	document.form_.submit();
}
function CancelRecord(){
	location = "./order_number.jsp?is_for_sheet="+document.form_.is_for_sheet.value;
}

function CopyGroupName(){
	if(document.form_.group_select.value)
	document.form_.group_name.value = document.form_.group_select[document.form_.group_select.selectedIndex].text;
}

</script>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp   = null;

	String strPrepareToEdit = WI.getStrValue(WI.fillTextValue("prepareToEdit"),"0");
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Payroll - Schedule deduction","order_number.jsp");
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
														"INVENTORY","COMP_INV",request.getRemoteAddr(),
														"order_number.jsp");
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

	InvCPUMaintenance invOrder = new InvCPUMaintenance();
	Vector vRetResult = null;
	String strCodeIndex  = null;
	String strType = null;
	String strFieldType = null;
	int i = 0;
	String strPageAction = WI.fillTextValue("page_action");
	String strChecked = null;
	String strIsForSheet = WI.getStrValue(WI.fillTextValue("is_for_sheet"),"0");
	
	if(strPageAction.length() > 0){
		if(invOrder.operateOnOrderNo(dbOP, request, Integer.parseInt(strPageAction)) == null)
			strErrMsg =  invOrder.getErrMsg();
	}
	vRetResult  = invOrder.getComputerComponents(dbOP, request);
	vRetResult  = invOrder.operateOnOrderNo(dbOP, request, 4);

%>
<body bgcolor="#D2AE72" class="bgDynamic">
<form action="order_number.jsp" method="post" name="form_">
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A"> 
      <td height="25" colspan="5" class="footerDynamic"><div align="center"><font color="#FFFFFF" ><strong>:::: 
          PAYROLL: INVENTORY SETTING PAGE ::::</strong></font></div></td>
    </tr>
</table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25" colspan="3">&nbsp;&nbsp;&nbsp;<font size="3"><%=WI.getStrValue(strErrMsg)%></font></td>
    </tr>
    <tr>
      <td width="4%" height="25">&nbsp;</td>
      <td width="19%">Item Classifications</td>
      <td><select name="class_index">
        <%strTemp= WI.fillTextValue("class_index");%>
        <option value="">Select classification</option>
        <%=dbOP.loadCombo("inv_preload_class.inv_class_index","classification", 
				" from inv_reg_item " +
				" join pur_preload_item on (inv_reg_item.item_index = pur_preload_item.item_index) " +
				" join inv_preload_class on (pur_preload_item.inv_class_index = inv_preload_class.inv_class_index) " +
				" where exists(select * from inv_item_entry " +
		    " join inv_cpu_component on (inv_item_entry.inv_entry_index = inv_cpu_component.inv_entry_index) " +
    		" where inv_item_entry.item_reg_index = inv_reg_item.item_reg_index) " +
				" and not exists(select * from inv_column_order where class_index = pur_preload_item.inv_class_index) " +
				" order by classification", strTemp, false)%>
      </select></td>
    </tr>		 
    <tr>
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>    
    <tr>
      <td height="25">&nbsp;</td>
      <td>Order Number </td>
      <td><select name="order_no">
				<%for(i = 1;i < 26; i++){%>
				<%if(WI.fillTextValue("order_no").equals(Integer.toString(i))){%>
        <option value="<%=i%>" selected><%=i%></option>
				<%}else{%>
				<option value="<%=i%>"><%=i%></option>
				<%}%>
				<%}%>
      </select></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td colspan="2">Note:<font size="1"> Items that are not mapped will be considered as <strong>others</strong>.</font></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td colspan="2">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td width="77%" height="25"><font size="1">
        <%if(strPrepareToEdit.compareTo("1") != 0) {%>
        <!--
				<a href='javascript:PageAction(1,"");'><img src="../../../images/save.gif" border="0" name="hide_save"></a> 
				-->
				<input type="button" name="save" value=" Save " style="font-size:11px; height:26px;border: 1px solid #FF0000;" onClick="javascript:PageAction('1','');">
        Click to save entries 
        <%}%>
        <input type="button" name="cancel" value=" Cancel " style="font-size:11px; height:26px;border: 1px solid #FF0000;" 
				onClick="javascript:CancelRecord();">
      Click to clear </font></td>
    </tr>
  </table>
	<%if(vRetResult != null && vRetResult.size() > 0){%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" class="thinborder">
    <tr> 
      <td height="24" colspan="3" align="center" bgcolor="#B9B292" class="thinborder"><strong><font color="#FFFFFF">LIST OF 
          ITEM MAPPINGS </font></strong></td>
    </tr>
    <tr>
      <td width="23%" height="25" align="center" class="thinborder"><span class="thinborder" style="font-size:9px; font-weight:bold">Order Number </span></td> 
      <td width="51%" align="center" class="thinborder"><span class="thinborder" style="font-size:9px; font-weight:bold">Field</span></td>
      <%if(WI.fillTextValue("is_for_sheet").equals("0")){%>
			<%}%>
      <td width="26%" align="center" class="thinborder"><strong><font size="1">DELETE</font></strong></td>
    </tr>
		<%for(i = 0; i < vRetResult.size();i+=3){%>
    <tr>
      <td height="25" class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+2)%></td> 
      <td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+1)%></td>
       <td class="thinborder" align="center">&nbsp;
	  <a href='javascript:PageAction("0","<%=(String)vRetResult.elementAt(i)%>");'><img src="../../../images/delete.gif" border="0"></a>	  </td>
    </tr>
		<%}%>
  </table>
	<%}%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
     <tr>
      <td height="25">&nbsp;</td>
    </tr>
   <tr>
      <td height="25" bgcolor="#A49A6A" class="footerDynamic">&nbsp;</td>
    </tr>
  </table>
<input type="hidden" name="page_action">
<input type="hidden" name="info_index" value="<%=WI.fillTextValue("info_index")%>">
<input type="hidden" name="prepareToEdit" value="<%=strPrepareToEdit%>">
<input type="hidden" name="reloaded" value="<%=WI.fillTextValue("reloaded")%>">
<input type="hidden" name="is_for_sheet" value="<%=WI.fillTextValue("is_for_sheet")%>">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
