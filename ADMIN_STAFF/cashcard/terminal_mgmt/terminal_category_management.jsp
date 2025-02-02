<%@ page language="java" import="utility.*, cashcard.TerminalManagement, java.util.Vector"%>
<%
	WebInterface WI = new WebInterface(request);
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
<title>Terminal Category Management</title>
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="javascript" src="../../../jscript/common.js"></script>
<script language="javascript">

	function PageAction(strAction, strInfoIndex) {
		if(strAction == '0') {
			if(!confirm('Are you sure you want to delete this terminal category?'))
				return;
		}
		
		document.form_.page_action.value = strAction;
		if(strAction == '1') 
			document.form_.prepareToEdit.value='';
		if(strInfoIndex.length > 0)
			document.form_.info_index.value = strInfoIndex;
		document.form_.submit();
	}
	
	function PrepareToEdit(strInfoIndex) {
		document.form_.page_action.value = "";
		document.form_.prepareToEdit.value = "1";
		document.form_.info_index.value = strInfoIndex;
		document.form_.submit();
	}
	
	function RefreshPage(){
		location = "./terminal_category_management.jsp";
	}
	
	function FocusField(){
		document.form_.category.focus();
	}
	
</script>
<%
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;
	
	//add security here.
	//authenticate this user.
	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("CASH CARD-TERMINAL MANAGEMENT"),"0"));
		if(iAccessLevel == 0)
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("CASH CARD"),"0"));
	}
	if(iAccessLevel == -1)//for fatal error.
	{
		request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		request.getSession(false).setAttribute("errorMessage","You are already logged out. Please login again.");
		response.sendRedirect("../../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0)//NOT AUTHORIZED.
	{
		response.sendRedirect("../../../commfile/unauthorized_page.jsp");
		return;
	}	
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Cash Card-Terminal Management","terminal_category_management.jsp");
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
	
	String strPrepareToEdit = WI.getStrValue(WI.fillTextValue("prepareToEdit"),"0");
	Vector vEditInfo = null;
	Vector vRetResult = null;
	
	TerminalManagement tm = new TerminalManagement();
	
	strTemp = WI.fillTextValue("page_action");
	if(strTemp.length() > 0) {
		if(tm.operateOnTerminalCatg(dbOP, request, Integer.parseInt(strTemp)) == null)
			strErrMsg = tm.getErrMsg();
		else {
			if(strTemp.equals("0"))
				strErrMsg = "Category successfully removed.";
			else if(strTemp.equals("1"))
				strErrMsg = "Category successfully added.";
			else if(strTemp.equals("2"))
				strErrMsg = "Category successfully edited.";
			
			strPrepareToEdit = "0";
		}
	}
	
	if(strPrepareToEdit.equals("1")) {
		vEditInfo = tm.operateOnTerminalCatg(dbOP, request, 3);
		if(vEditInfo == null)
			strErrMsg = tm.getErrMsg();
	}
	
	vRetResult = tm.operateOnTerminalCatg(dbOP, request, 4);
	if (vRetResult == null && strTemp.length() == 0)
		strErrMsg = tm.getErrMsg();
%>		
<body bgcolor="#D2AE72" onLoad="FocusField();">
<form name="form_" action="./terminal_category_management.jsp" method="post">

	<table bgcolor="#FFFFFF"  width="100%" border="0" cellspacing="0" cellpadding="0">
		<tr bgcolor="#A49A6A">
			<td height="25" colspan="4" align="center"><font color="#FFFFFF">
				<strong>:::: TERMINAL CATEGORY MANAGEMENT PAGE ::::</strong></font></td>
		</tr>
		<tr>
			<td height="25" >&nbsp;</td>
			<td colspan="2"><strong><font size="2" color="#FF0000"><%=WI.getStrValue(strErrMsg)%></font></strong></td>
		</tr>
		<tr>
			<td width="3%" height="25" >&nbsp;</td>
			<td width="17%">Category Name:</td>
			<td width="80%">
				<%
					if(vEditInfo!= null && vEditInfo.size() > 0)
						strTemp = (String)vEditInfo.elementAt(1);//terminal category name.
					else
						strTemp = WI.fillTextValue("category");
				%>
				<input type="text" name="category" value="<%=strTemp%>" class="textbox" size="32" maxlength="64"
					onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
		</tr>
		<tr> 
			<td height="25" colspan="2">&nbsp;</td>
			<td>
				<%
					if(vEditInfo!= null)
						strTemp = (String)vEditInfo.elementAt(2);//terminal status is_canteen.
					else
						strTemp = WI.fillTextValue("is_canteen");
					
					if(strTemp.equals("1"))
						strTemp = "checked";
					else
						strTemp = "";
				%>
				<input type="checkbox" name="is_canteen" value="1" <%=strTemp%>/>
				<font size="1">tick if category is <strong>canteen </strong></font></td>
		</tr>
		<tr>
			<td height="15" colspan="3">&nbsp;</td>
		</tr>
		<tr>
			<td height="25" colspan="2">&nbsp;</td>
			<td>
				<%if(strPrepareToEdit.equals("0")) {%>
					<a href="javascript:PageAction('1', '');"><img src="../../../images/save.gif" border="0"></a>
					<font size="1">Click to save category information.</font>
				<%}else {
					if(vEditInfo!=null){%>
						<a href="javascript:PageAction('2', '<%=(String)vEditInfo.elementAt(0)%>');">
						<img src="../../../images/edit.gif" border="0"></a>
						<font size="1">Click to edit category information.</font>
					    <%}
				}%>
				<a href="javascript:RefreshPage();"><img src="../../../images/refresh.gif" border="0"></a>
				<font size="1">Click to refresh page.</font></td>	
		</tr> 
		<tr>
			<td height="15" colspan="3">&nbsp;</td>
		</tr> 
	</table>
	
<%if(vRetResult != null && vRetResult.size() > 0){%>
	<table width="100%" cellspacing="0" cellpadding="0" class="thinborder" bgcolor="#FFFFFF">
		<tr> 
		  	<td height="20" colspan="3" bgcolor="#B9B292" class="thinborder">
				<div align="center"><strong>::: LIST OF TERMINAL CATEGORY ::: </strong></div></td>
		</tr>
		<tr> 
			<td height="33" width="60%" class="thinborder" align="center"><strong>Category Name</strong></td>
			<td width="15%" class="thinborder" align="center"><strong>Canteen Status</strong></td>
			<td width="25%" class="thinborder" align="center"><strong>Options</strong></td>
    </tr>
	<%for(int i = 0; i < vRetResult.size(); i += 3){%>
    <tr> 
      	<td height="25" class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i + 1)%></td>
      	<td align="center" class="thinborder">
	  		<%if(((String)vRetResult.elementAt(i + 2)).equals("0")){%> 
				<img src="../../../images/x.gif" width="12" height="14"> 
        	<%}else{%>
				<img src="../../../images/tick.gif"> 
			<%}%></td>
      	<td class="thinborder" align="center">
	  		<%if(iAccessLevel > 1){%>
				<a href="javascript:PrepareToEdit('<%=(String)vRetResult.elementAt(i)%>');">
				<img src="../../../images/edit.gif" border="0"></a>
				<%if(iAccessLevel == 2){%>
					<a href="javascript:PageAction('0','<%=(String)vRetResult.elementAt(i)%>');">
					<img src="../../../images/delete.gif" border="0"></a>
				<%}
			}else{%>
				Not authorized.
			<%}%></td>
    </tr>
<%}%>
  </table>
<%}//end of vRetResult%>

	<table width="100%" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF"> 
		<tr bgcolor="#FFFFFF">
			<td height="25"colspan="3">&nbsp;</td>
		</tr> 
		<tr bgcolor="#A49A6A"> 
			<td width="50%" height="25" colspan="3">&nbsp;</td>
		</tr>
	</table>

	<input type="hidden" name="page_action">
	<input type="hidden" name="info_index">
	<input type="hidden" name="prepareToEdit" value="<%=strPrepareToEdit%>">
</form>		
</body>
</html>
<%
dbOP.cleanUP();
%>