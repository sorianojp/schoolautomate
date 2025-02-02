<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="javascript"  src ="../../../jscript/common.js" ></script>
<script>
<!--
function PageAction(strAction, strInfoIndex) {
	if(strInfoIndex.length > 0) 
		document.form_.info_index.value = strInfoIndex;
	document.form_.page_action.value = strAction;
	this.SubmitOnce('form_');
}
function ReloadPage()
{
	document.form_.page_action.value="";
	this.SubmitOnce('form_');
}
function ChangeSigIndex()
{
	document.form_.sig_index.value = document.form_.sig_item_index.value;
	this.SubmitOnce('form_');
}
function OpenSearch() {
	var pgLoc = "../../../search/srch_emp.jsp?opner_info=form_.emp_id";
	var win=window.open(pgLoc,"PrintWindow",'width=900,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
-->
</script>
<%@ page language="java" import="utility.*, clearance.ClearanceSignatory, java.util.Vector " buffer="16kb"%>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	Vector vRetResult = null;
	
	String strInfoIndex = null;
	String strErrMsg = null;
	String strTemp = null;
	String strTemp2 = null;

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Clearances-Clearance Signatories-Manage Items Signatories","manage_signatories.jsp");
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
														"manage_signatories.jsp");
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
	boolean bolFatalErr = false;
	ClearanceSignatory clrSig = new ClearanceSignatory();
	
	strTemp = WI.fillTextValue("page_action");
	if(strTemp.length() > 0) {
		if(clrSig.operateOnSignatory(dbOP, request, Integer.parseInt(strTemp)) != null ) {
			strErrMsg = "Operation successful.";
		}
		else
			strErrMsg = clrSig.getErrMsg();
	}
			
	vRetResult = clrSig.operateOnSignatory(dbOP, request, 4);

if (strErrMsg==null)
{
	strErrMsg = clrSig.getErrMsg();
}
%>
<body bgcolor="#D2AE72">
<form name="form_" action="./manage_signatories.jsp" method="post" >
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A"> 
      <td height="25" colspan="5" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF" ><strong>:::: 
          CLEARANCES- MANAGE ITEMS SIGNATORIES PAGE ::::</strong></font></div></td>
    </tr>
</table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25" colspan="4"><font size="3"><strong><%=WI.getStrValue(strErrMsg)%></strong></font></td>
    </tr>
    <tr> 
      <td height="30">&nbsp;</td>
      <td>Signatory Items</td>
      <%strTemp = WI.fillTextValue("sig_item_index");%>
      <td colspan="2" valign="middle"><select name="sig_item_index" onchange="ChangeSigIndex();">
          <option value="">Select Signatory Item</option>
<%=dbOP.loadCombo("CLE_SIGNATORY.CLE_SIGNATORY_INDEX","CLE_SIGNATORY"," FROM CLE_SIGNATORY WHERE EXISTS (SELECT CLE_SUBSIG_INDEX FROM CLE_SUB_SIGNATORY WHERE CLE_SIGNATORY.CLE_SIGNATORY_INDEX = CLE_SUB_SIGNATORY.CLE_SIGNATORY_INDEX AND CLE_SUB_SIGNATORY.IS_VALID = 1 AND CLE_SUB_SIGNATORY.IS_DEL = 0)", strTemp, false)%>
        </select>
      </td>
    </tr>
    <tr> 
      <td height="30">&nbsp;</td>
      <td>Sub-item</td>
      <td height="25" colspan="2" valign="middle">
	<%strTemp2 = WI.fillTextValue("sig_subitem");%>
       <select name="sig_subitem">
              <% 
              if(WI.fillTextValue("sig_item_index").length() > 0)
      		{
      			strTemp = " FROM CLE_SUB_SIGNATORY WHERE IS_DEL=0 AND IS_VALID=1  AND CLE_SIGNATORY_INDEX ="+WI.fillTextValue("sig_item_index")+
      			" order by CLE_SUBSIG asc" ;%>	
                  
              <%=dbOP.loadCombo("CLE_SUBSIG_INDEX"," CLE_SUBSIG",strTemp, strTemp2, false)%>
             <% }%> 
      </select>
      </td>
    </tr>
    <tr> 
        <td height="15" colspan="4"><font size="1">&nbsp; </font><font size="1">&nbsp; 
        </font></td>
    </tr>
    <tr>
    	<td width="2%" height="25">&nbsp;</td>
    	<td width="13%">College</td>
    	<td colspan="2"><select name="c_index" onChange="ReloadPage();">
          <option value="">N/A</option>
          <%strTemp = WI.fillTextValue("c_index");
			if(strTemp == null || strTemp.trim().length() == 0) strTemp = "0";
				if(strTemp.compareTo("0") ==0)
					strTemp2 = "Offices";
				else
					strTemp2 = "Department";%>
          <%=dbOP.loadCombo("c_index","C_NAME"," from COLLEGE where IS_DEL=0 order by c_name asc", strTemp, false)%>
        </select></td>
    </tr>
    <tr>
    	<td width="2%" height="25"></td>
    	<td width="13%"><%=strTemp2%></td>
    	<td colspan="2"><%String strTemp3 = WI.fillTextValue("d_index");%>
	  <select name="d_index">
          <option value="">ALL</option>
          <%=dbOP.loadCombo("d_index","d_NAME"," from department where IS_DEL=0 "+WI.getStrValue(request.getParameter("c_index"), "AND C_INDEX = ", " ", " AND (C_INDEX = 0 OR C_INDEX IS NULL)")+ "order by d_name asc",strTemp3, false)%>
        </select></td>
    </tr>
    <tr> 
      <td width="2%" height="25">&nbsp;</td>
      <td width="13%">Signatory</td>
      <td width="40%%"><font size="1"> 
        <input name="emp_id" type="text" id="emp_id" size="20" maxlength="20"  class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        (Employee ID) </font></td>
      <td width="45%"><font size="1"><a href="javascript:OpenSearch();"><img src="../../../images/search.gif" border="0"></a> 
        click to search Employee ID</font></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25" colspan="2"><a href='javascript:PageAction(1,"");'><img src="../../../images/add.gif" border="0" name="hide_save"></a><font size="1" face="Verdana, Arial, Helvetica, sans-serif">click 
        to add entry</font></td>
    </tr>
    <tr> 
      <td height="25" colspan="4">&nbsp;</td>
    </tr>
  </table>
  <% if(vRetResult != null && vRetResult.size() > 0) {%>
  <table width="100%" border="0" cellpadding="1" cellspacing="0"  bgcolor="#FFFFFF" class="thinborder">
	<tr bgcolor="#ABA37C"> 
		<td height="23" colspan="7" class="thinborder"> 
			<div align="center"> <strong><font size="2">LIST 
				OF CLEARANCE ITEMS SIGNATORIES</font></strong></div>
		</td>
	</tr>
	<tr> 
		<td width="11%" height="23" class="thinborder"> 
			<div align="center"><font size="1"><strong>SIGNATORY ITEMS </strong></font></div>
		</td>
		<td width="11%" class="thinborder"><div align="center"><font size="1"><strong>SUB ITEM </strong></font></div></td>
		<td width="14%" class="thinborder">
			<div align="center"><font size="1"><strong>EFFECTIVE DATE FROM</strong></font></div>
		</td>
		<td width="14%" class="thinborder">
			<div align="center"><font size="1"><strong>EFFECTIVE DATE TO</strong></font></div>
		</td>
		<td width="20%" class="thinborder"> 
			<div align="center"><font size="1"><strong>COLLEGE/ DEPARTMENT</strong></font></div>
		</td>
		<td width="19%" class="thinborder"><div align="center"><font size="1"><strong>ID/ NAME</strong></font></div></td>
		<td width="11%" class="thinborder">&nbsp;  </td>
	</tr>
	<% for (int i = 0; i<vRetResult.size(); i+=9) { %>
	<tr> 
		<td class="thinborder" height="25"><font size="1"> 
			<%if (i>0 && ((String)vRetResult.elementAt(i+1)).compareTo((String)vRetResult.elementAt(i-8))==0){%>
			&nbsp; 	<%}else{%><%=(String)vRetResult.elementAt(i+1)%><%}%>
			</font></td>
		<td class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i+2),"","","&nbsp;")%></td>
		<td class="thinborder"><font size="1"><%=(String)vRetResult.elementAt(i+3)%></font></td>
		<td class="thinborder"><font size="1"><%=WI.getStrValue((String)vRetResult.elementAt(i+4),"","","PRESENT")%></font></td>
		<td class="thinborder"><font size="1">
		<%=WI.getStrValue((String)vRetResult.elementAt(i+5),"","","&nbsp;")%>
		<%=WI.getStrValue((String)vRetResult.elementAt(i+6)," :::<br>","","")%></font></td>
		<td class="thinborder"><%=(String)vRetResult.elementAt(i+7)%>:::<br><%=(String)vRetResult.elementAt(i+8)%></td>
		<td class="thinborder"> <a href='javascript:PageAction(0,"<%=(String)vRetResult.elementAt(i)%>");'><img src="../../../images/delete.gif" width="55" height="28" border="0"></a></td>
	</tr>
	<%}%>
</table>
<%}%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="25"  colspan="3">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25"  colspan="3" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
	<input name = "info_index" type = "hidden"  value="<%=WI.fillTextValue("info_index")%>">
	<input type="hidden" name="page_action">
	<input type="hidden" name="sig_index">
	</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
