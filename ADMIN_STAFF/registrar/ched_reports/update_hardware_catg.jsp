<%@ page language="java" import="utility.*,java.util.Vector,chedReport.CHEDIctc"%>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
//authenticate this user.
	int iAccessLevel = 0;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("REGISTRAR MANAGEMENT-REPORTS"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("REGISTRAR MANAGEMENT"),"0"));
		}
	}
	
	if(iAccessLevel == -1)//for fatal error.
	{
		request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		request.getSession(false).setAttribute("errorMessage","Please login to access this page.");
		response.sendRedirect("../../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0)//NOT AUTHORIZED.
	{
		response.sendRedirect("../../../commfile/unauthorized_page.jsp");
		return;
	}

//add security hehol.
	try	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),"Admin/staff-CHED REPORTS-Update Fund Source","update_hardware_catg.jsp");
	}
	catch(Exception exp) {
		exp.printStackTrace();
		if(strErrMsg == null)
		strErrMsg = "Error in opening DB Connection.";
		%>

		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		  Error in opening connection </font></p>
		<%
		return;
	}


Vector vRetResult = null; Vector vEditInfo = null;
CHEDIctc chedICTC = new CHEDIctc();


String strPrepareToEdit = WI.getStrValue(WI.fillTextValue("prepareToEdit"),"0");
strTemp = WI.fillTextValue("page_action");
if(strTemp.length() > 0) {
	if(chedICTC.operateOnHardwareCatg(dbOP, request, Integer.parseInt(strTemp)) == null) 
		strErrMsg = chedICTC.getErrMsg();
	else {
		strErrMsg = "Request Processed successfully.";
		strPrepareToEdit = "0";
	}	
}
if(strPrepareToEdit.equals("1")) {
	vEditInfo = chedICTC.operateOnHardwareCatg(dbOP, request, 3);
	if(vEditInfo == null) {
		strErrMsg = chedICTC.getErrMsg();
		strPrepareToEdit = "0";
	}
}

vRetResult = chedICTC.operateOnHardwareCatg(dbOP, request, 4);
if(vRetResult != null && strErrMsg == null)
	strErrMsg = chedICTC.getErrMsg(); 

String[] astrHardTypeIndex = {"WorkStations","Servers","Printers","Accesories"} ;
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>CHED ICT REPORT</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript">
function PageAction(strAction, strInfoIndex) {
	if(strAction == '0') {
		if(!confirm("Are you sure you want to delete this information."))
			return;
	}
	document.form_.page_action.value = strAction;
	document.form_.info_index.value  = strInfoIndex;
}
function PreparedToEdit(strInfoIndex) {
	document.form_.page_action.value = '';
	document.form_.prepareToEdit.value = '1';
}
</script>
<body>
<form name="form_" action="./update_hardware_catg.jsp" method="post" onSubmit="SubmitOnceButton(this);">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="25" colspan="2" align="center" style="font-size:13px; font-weight:bold">::: Manage Hardware Category Information ::: </td>
    </tr>
    <tr> 
      <td height="25" colspan="2">&nbsp; <%=WI.getStrValue(strErrMsg,"<font size=\"3\" color=\"#FF0000\">","</font>", "")%></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="2" bgcolor="#FFFFFF">
    <tr> 
      <td height="25" width="20%">&nbsp;Hardware Type </td>
      <td>
<%
strTemp = WI.fillTextValue("hardware_type");
%> 
		<select name="hardware_type" onChange="document.form_.page_action.value='';document.form_.prepareToEdit.value='';document.form_.submit();">
          <% for (int i = 0; i < astrHardTypeIndex.length; ++i) {
				if (strTemp.equals(Integer.toString(i))) {%>
          <option value="<%=i%>" selected><%=astrHardTypeIndex[i]%></option>
          <%}else{%>
          <option value="<%=i%>"><%=astrHardTypeIndex[i]%></option>
          <%}
		 }%>
        </select></td>
    </tr>
    <tr> 
      <td height="25" class="body_font">&nbsp;Hardware Category </td>
      <td>
<%
if(vEditInfo != null && vEditInfo.size() > 0) 
	strTemp = (String)vEditInfo.elementAt(1);
else	
	strTemp = WI.fillTextValue("hard_catg");
%>
	  <input name="hard_catg" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="32" maxlength="32"></td>
    </tr>
    
    <tr> 
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
    <tr> 
      <td colspan="2"><div align="center">&nbsp; 
          <% if (iAccessLevel > 1)  {
		if (!strPrepareToEdit.equals("1")) {%>
          <input type="submit" name="_12" value="Create Hardware Category" onClick="document.form_.page_action.value='1';"> 
          <%}else{ %>
          <input type="submit" name="_12" value="Edit Information" onClick="document.form_.page_action.value='2';document.form_.info_index.value='<%=vEditInfo.remove(0)%>'">
		  &nbsp;&nbsp;&nbsp;
		  <input type="submit" name="_12" value="Cancel" onClick="document.form_.page_action.value='';document.form_.prepareToEdit.value='';"> 
          <%
		} // !strPrepareToEdit.equals("1")
 } // end iAccessLevel > 1
 %>
        </div></td>
    </tr>
  </table>

<% if (vRetResult != null && vRetResult.size() > 0) {%>
  <br> <br>
	  
  <table width="100%" border="0" cellpadding="0" cellspacing="0" class="thinborder">
    <tr> 
      <td width="60%" height="25" class="thinborder" align="center"><strong>Hardware Category</strong></td>
      <td width="20%" class="thinborder" align="center"><strong>Edit</strong></td>
      <td width="20%" class="thinborder" align="center"><b>Delete</b></td>
    </tr>
    <%
	boolean bolSystemGen = false;
	while(vRetResult.size() > 0) {
	strTemp = (String)vRetResult.remove(0);
	if(vRetResult.remove(1).equals("-1"))
		bolSystemGen = true;
	else	
		bolSystemGen = false;
	%>
    <tr> 
      <td height="25" class="thinborder"><%=vRetResult.remove(0)%></td>
      <td class="thinborder" align="center"><%if(bolSystemGen) {%>N/A<%}else{%><input type="submit" name="_12" value="Edit" onClick="document.form_.page_action.value='';document.form_.prepareToEdit.value='1';document.form_.info_index.value='<%=strTemp%>'"><%}%></td>
      <td class="thinborder" align="center"><%if(bolSystemGen) {%>N/A<%}else{%><input type="submit" name="_12" value="Delete" onClick="document.form_.page_action.value='0';document.form_.info_index.value='<%=strTemp%>'"><%}%></td>
    </tr>
    <%}%>
  </table>
 <% } // end if vRetResult %>
  <input type="hidden" name="info_index" value="">
  <input type="hidden" name="page_action" value="">
  <input type="hidden" name="prepareToEdit" value="<%=strPrepareToEdit%>">
</form>
</body>
</html>
<%
	dbOP.cleanUP();
%>
