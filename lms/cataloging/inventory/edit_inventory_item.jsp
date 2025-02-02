<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title></title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../css/tableBorder.css" rel="stylesheet" type="text/css">
<link href="../css/reportlink.css" rel="stylesheet" type="text/css">

<style>
.trigger{
	cursor: pointer;
	cursor: hand;
}
.branch{
	display: block;
	margin-left: 16px;
}
</style>
</head>
<script src="../../../Ajax/ajax.js"></script>
<script src="../../../jscript/common.js"></script>
<script src="../../../jscript/date-picker.js"></script>

<script language="JavaScript">
function CloseWindow(){		
	if(document.form_.donot_call_close_wnd.value.length >0)
		return;
	
	window.opener.document.form_.submit();
	window.opener.focus();
	self.close();
}

function updateRecord(){
	document.form_.donot_call_close_wnd.value = "1";
	document.form_._update.value = '1';
	document.form_.submit();
}

</script>
<%@ page language="java" import="utility.*,lms.CirculationReport,java.util.Vector" %>
<%
	String strTemp = null;
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strUserIndex  = null;
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"LIB_Cataloging-INVENTORY","edit_inventory_item.jsp");
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
														"LIB_Cataloging","INVENTORY",request.getRemoteAddr(),
														"edit_inventory_item.jsp");
if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../lms/");
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
CirculationReport CR = new CirculationReport();
Vector vRetResult = new Vector();
int iSearchResult = 0;
String strInfoIndex = null;

if(WI.fillTextValue("_update").length() > 0){
	if(CR.operateOfInventory(dbOP, request, 2) == null)
		strErrMsg = CR.getErrMsg();
	else
		strErrMsg = "Item Inventory successfully updated.";
}

if(WI.fillTextValue("info_index").length() > 0){
	vRetResult = CR.operateOfInventory(dbOP, request, 3);
	if(vRetResult == null)
		strErrMsg = CR.getErrMsg();
	else
		strInfoIndex = (String)vRetResult.elementAt(0);
}




%>
<body bgcolor="#D0E19D"  onUnload="CloseWindow();">
<form action="./edit_inventory_item.jsp" method="post" name="form_" onSubmit="SubmitOnceButton(this);">
  <table width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr bgcolor="#77A251"> 
      <td height="25" colspan="5"><div align="center"><font color="#FFFFFF" ><strong>:::: 
          INVENTORY UPDATE ::::</strong></font></div></td>
    </tr>
    <tr> 
      <td height="25" colspan="2">&nbsp;&nbsp;&nbsp;<font size="3" color="#FF0000"><strong> 
        <%=WI.getStrValue(strErrMsg,"Message : ","","")%></strong></font></td>
		<td align="right"><a href="javascript:CloseWindow();">
	  <img src="../../../images/close_window.gif" width="71" height="32" border="0" align="right"></a> &nbsp; &nbsp; &nbsp; </td>
    </tr>
<%if(vRetResult != null && vRetResult.size() > 0){%>	
    <tr> 
      <td width="10%" height="23"><font size="1">Book Title</font> </td>
      <td width="60%">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(3))%></td>
	  <td colspan="2">&nbsp;</td>
    </tr>
	
	<tr> 
      <td width="10%" height="23"><font size="1">Call Number</font> </td>
      <td width="60%">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(15))%></td>
	  <td>&nbsp;</td>
    </tr>
	
	<tr> 
      <td width="10%" height="23"><font size="1">Accession No.</font> </td>
      <td width="60%">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(1))%></td>
	  <td>&nbsp;</td>
    </tr>
	<tr> 
      <td width="10%" height="23"><font size="1">Material Type</font> </td>
      <td width="50%" colspan="2">&nbsp;
	  <select name="MATERIAL_TYPE_INDEX" 
	  		style="font-family:Verdana, Arial, Helvetica, sans-serif;font-size: 10; width:300px;">
          <%=dbOP.loadCombo("MATERIAL_TYPE_INDEX","MATERIAL_TYPE"," from LMS_MAT_TYPE order by  MATERIAL_TYPE_INDEX asc",
		  	WI.fillTextValue("MATERIAL_TYPE_INDEX"), false)%> 
        </select>
       </td>	  
    </tr>
	
	
	<tr><td colspan="3" height="15">&nbsp;</td></tr>
	<tr>  
	  <td>&nbsp;</td>     
      <td width="" colspan="2">&nbsp;
	  <a href="javascript:updateRecord();">
	  <img src="../../images/update.gif" border="1"></a>
	  </td>	  
    </tr>
	
    <tr> 
      <td height="19" colspan="4"><div align="right">  
          <hr size="1">
        </div></td>
    </tr>
<%}%>
  </table>

  
<input type="hidden" name="user_id" value="<%=WI.fillTextValue("user_id")%>"  />
<input type="hidden" name="_update" value="<%=WI.fillTextValue("_update")%>"/>
<input type="hidden" name="page_action" />
<input type="hidden" name="info_index" value="<%=strInfoIndex%>" />
<input type="hidden" name="donot_call_close_wnd">
<input type="hidden" name="LOC_INDEX" value="<%=WI.fillTextValue("LOC_INDEX")%>" >
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>