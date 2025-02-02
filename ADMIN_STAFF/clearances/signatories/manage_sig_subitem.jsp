<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="javascript"  src ="../../../jscript/common.js" ></script>
<script>
function PageAction(strAction, strInfoIndex) {
	if(strInfoIndex.length > 0) 
		document.form_.info_index.value = strInfoIndex;
	document.form_.page_action.value = strAction;
	this.SubmitOnce('form_');
}
function PrepareToEdit(strInfoIndex) {
	document.form_.info_index.value = strInfoIndex;
	document.form_.page_action.value = "";
	document.form_.prepareToEdit.value = "1";
	this.SubmitOnce('form_');
}
function Cancel() {
	document.form_.info_index.value = "";
	document.form_.page_action.value = "";
	document.form_.prepareToEdit.value = "";
	this.SubmitOnce('form_');
}
function viewList(table,indexname,colname,labelname){
	var loadPg = "../../HR/hr_updatelist.jsp?opner_form_name=form_&tablename=" + table + "&indexname=" + indexname + "&colname=" + colname+"&label="+labelname;
	var win=window.open(loadPg,"myfile",'dependent=yes,width=650,height=350,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
</script>
<%@ page language="java" import="utility.*,clearance.ClearanceSignatory, java.util.Vector " buffer="16kb"%>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	Vector vEditInfo  = null;
	Vector vRetResult = null;
	
	String strInfoIndex = null;
	String strPrepareToEdit = null;
	String strErrMsg = null;
	String strTemp = null;
	strPrepareToEdit = WI.getStrValue(request.getParameter("prepareToEdit"),"0");


//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Clearances-Clearance Signatories-Manage Signatory Items","manage_sig_subitem.jsp");
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
														"Clearances","Clearance Signatories",request.getRemoteAddr(),
														"manage_sig_subitem.jsp");
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
	ClearanceSignatory clrSig = new ClearanceSignatory();
	
	strTemp = WI.fillTextValue("page_action");
	if(strTemp.length() > 0) {
		if(clrSig.operateOnSubItems(dbOP, request, Integer.parseInt(strTemp)) != null ) {
			strPrepareToEdit = "0";
			strErrMsg = "Operation successful.";
		}
		else
			strErrMsg = clrSig.getErrMsg();
	}
	
		
	if(strPrepareToEdit.compareTo("1") == 0) {
		vEditInfo = clrSig.operateOnSubItems(dbOP, request, 3);
		if(vEditInfo == null && strErrMsg == null ) 
			strErrMsg = clrSig.getErrMsg();
	}
	//view all 
	
	vRetResult = clrSig.operateOnSubItems(dbOP, request, 4);
	if (strErrMsg==null)
		strErrMsg=clrSig.getErrMsg();
	
%>


<body bgcolor="#D2AE72">
<form name="form_" action="./manage_sig_subitem.jsp" method="post" >
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A"> 
      <td height="25" colspan="5" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF" ><strong>:::: 
          CLEARANCES- MANAGE SIGNATORY ITEMS PAGE ::::</strong></font></div></td>
    </tr>
</table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25" colspan="4">&nbsp;&nbsp;&nbsp;<font size="3"><strong><%=WI.getStrValue(strErrMsg)%></strong></font></td>
    </tr>
    <tr> 
      <td width="4%" height="30">&nbsp;</td>
      <td width="16%"> Signatory Items</td>
      <td width="80%" colspan="2" valign="middle">
    <%
	if(vEditInfo != null && vEditInfo.size() > 0)
		{
		strTemp = (String)vEditInfo.elementAt(5);
		}
	else
		{		
		strTemp = WI.fillTextValue("sig_item_index");
		}
	%>
      <select name="sig_item_index">
          <option value="">Select Signatory Item</option>
          <%=dbOP.loadCombo("CLE_SIGNATORY_INDEX","CLE_SIGNATORY"," FROM CLE_SIGNATORY", strTemp, false)%>
        </select>
        <a href='javascript:viewList("CLE_SIGNATORY","CLE_SIGNATORY_INDEX","CLE_SIGNATORY","SIGNATORY")'>
        <img src="../../../images/update.gif" border="0"></a>
        <font size="1">click to update list of SIGNATORY ITEMS</font></td>
    </tr>
    <tr>
      <td height="30">&nbsp;</td>
      <td>Sub- Signatory Item</td>
  	<%if(vEditInfo != null && vEditInfo.size() > 0)
		strTemp = WI.getStrValue((String)vEditInfo.elementAt(2),"");
	else	
		strTemp = WI.fillTextValue("subsig_item");
	%>
      <td height="25" colspan="2" valign="middle"><input name="subsig_item" type="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="32" value="<%=strTemp%>"></td>
    </tr>
    <tr> 
      <td height="30">&nbsp;</td>
      <td>Effective Date</td>
      <%
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(3);
		else	
			strTemp = WI.fillTextValue("eff_date_fr");
	%>
      <td height="25" colspan="2" valign="middle"><input name="eff_date_fr" type= "text" class="textbox" id="date"  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=strTemp%>" size="12" maxlength="12" readonly="true"> 
        <a href="javascript:show_calendar('form_.eff_date_fr');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" width="20" height="16" border="0"></a> 
      	  <% if(strPrepareToEdit.compareTo("0") != 0) {%>
      	 to 
      	 <%	if(vEditInfo != null && vEditInfo.size() > 0){
				if (vEditInfo.elementAt(4) == null)
					strTemp = "";
				else
					strTemp = (String)vEditInfo.elementAt(4);}
		else{	
			strTemp = WI.fillTextValue("eff_date_to");}
	%> 
      	 <input name="eff_date_to" type= "text" class="textbox" id="date"  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=strTemp%>" size="12" maxlength="12" readonly="true"> 
        <a href="javascript:show_calendar('form_.eff_date_to');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" width="20" height="16" border="0"></a></td><%}%>
    </tr>
    <tr> 
      <td height="15" colspan="4"><font size="1">&nbsp; </font><font size="1">&nbsp; 
        </font></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25" colspan="2"><font size="1">
        <%if(strPrepareToEdit.compareTo("1") != 0) {%>
        <a href='javascript:PageAction(1,"");'><img src="../../../images/add.gif" border="0" name="hide_save"></a> Click to add entry
        <%}else{%>
        <a href='javascript:PageAction(2, "");'><img src="../../../images/edit.gif" border="0"></a> Click to edit event
        <a href="javascript:Cancel();"><img src="../../../images/cancel.gif" border="0"></a> Click to clear entries </font>
        <%}%>
        </td>
    </tr>
    <tr> 
      <td height="25" colspan="4">&nbsp;</td>
    </tr>
  </table>
  <% if(vRetResult != null && vRetResult.size() > 0) {%>
  <table width="100%" border="0" cellpadding="1" cellspacing="0"  bgcolor="#FFFFFF" class="thinborder">
    <tr bgcolor="#ABA37C"> 
      <td height="23" colspan="6" class="thinborder"> <div align="center"> <strong><font size="2">LIST 
          OF CLEARANCE SIGNATORY ITEMS</font></strong></div></td>
    </tr>
    <tr> 
      <td width="23%" height="23" class="thinborder"> <div align="center"><font size="1"><strong>SIGNATORY 
          ITEM </strong></font></div></td>
      <td width="28%" class="thinborder"> <div align="center"><font size="1"><strong>SUB 
          CATEGORY </strong></font></div></td>
      <td width="16%" class="thinborder"><div align="center"><font size="1"><strong>EFFECTIVE 
          DATE FROM</strong></font></div></td>
      <td width="16%" class="thinborder"><div align="center"><font size="1"><strong>EFFECTIVE 
          DATE TO</strong></font></div></td>
      <td colspan="2" align="center" class="thinborder"> <font size="1"><strong>&nbsp; 
        OPTIONS</strong> </font> <div align="center"></div></td>
    </tr>
    <%
    for (int i = 0; i<vRetResult.size(); i+=6) { %>
    <tr> 
      <td class="thinborder" height="25"><%if (i>0 && ((String)vRetResult.elementAt(i+1)).compareTo((String)vRetResult.elementAt(i-5))==0){%> &nbsp; <%}else{%>
        <%=(String)vRetResult.elementAt(i+1)%>
        <%}%></td>
      <td class="thinborder"><%if (vRetResult.elementAt(i+2)!=null &&((String)vRetResult.elementAt(i+2)).length()>0){%><%=(String)vRetResult.elementAt(i+2)%><%}else{%>&nbsp;<%}%></td>
      <td class="thinborder"><%=(String)vRetResult.elementAt(i+3)%></td>
      <td class="thinborder"><%if (vRetResult.elementAt(i+4)== null){%>
        <font size="1">PRESENT</font>
        <%} else {%>
        <%=(String)vRetResult.elementAt(i+4)%>
        <%}%></td>
      <td width="7%" class="thinborder"> <font size="1"> 
        <% if(iAccessLevel ==2 || iAccessLevel == 3){%>
        <a href='javascript:PrepareToEdit("<%=(String)vRetResult.elementAt(i)%>");'><img src="../../../images/edit.gif" border="0"></a> 
        <%}else{%>
        Not authorized to edit 
        <%}%>
        </font></td>
      <td width="10%" class="thinborder"><font size="1"> 
        <% if(iAccessLevel ==2){%>
        <a href='javascript:PageAction("0","<%=(String)vRetResult.elementAt(i)%>")'><img src="../../../images/delete.gif" border="0"></a> 
        <%}else{%>
        Not authorized to delete 
        <%}%>
        </font></td>
    </tr>
    <%}%>
  </table>
    <%}%>
   <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
     <td height="25"  colspan="3" bgcolor="#A49A6A">&nbsp;</td>
    
  </table>
	<input name = "info_index" type = "hidden"  value="<%=WI.fillTextValue("info_index")%>">
	<input type="hidden" name="prepareToEdit" value="<%=strPrepareToEdit%>">
	<input type="hidden" name="page_action">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>