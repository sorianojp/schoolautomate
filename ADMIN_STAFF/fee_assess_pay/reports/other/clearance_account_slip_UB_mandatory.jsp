<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../../Ajax/ajax.js"></script>
<script language="JavaScript">
function ReloadPage() {
	document.form_.show_result.value='';
	document.form_.submit();
}
function ShowResult(){
	document.form_.show_result.value = "1";
	document.form_.submit();
}

</script>
<body>
<%@ page language="java" import="utility.*, java.util.Vector, java.util.Date"%>
<%
	DBOperation dbOP = null;
	WebInterface WI  = new WebInterface(request);
	String strErrMsg = null;
	String strTemp   = null;

//authenticate this user.
	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("FEE ASSESSMENT & PAYMENTS-REPORTS"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("FEE ASSESSMENT & PAYMENTS"),"0"));
		}
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("REGISTRAR-REPORTS"),"0"));
		}
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("REGISTRAR MANAGEMENT"),"0"));
		}
	}
	
	if(iAccessLevel == -1)//for fatal error.
	{
		request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		request.getSession(false).setAttribute("errorMessage","Please login to access this page.");
		response.sendRedirect("../../../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0)//NOT AUTHORIZED.
	{
		response.sendRedirect("../../../../commfile/unauthorized_page.jsp");
		return;
	}
	
//add security here.
	try	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Fee Assess & Payment - Reports - Installment Dues.",
								"installment_dues_ul.jsp");
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

String strSQLQuery = null; Vector vRetResult = new Vector();

strTemp = WI.fillTextValue("page_action");
strErrMsg = null;

if(strTemp.length() > 0) {
	if(strTemp.equals("1")) {
		String strSubIndex     = WI.fillTextValue("sub_i");
		String strCLESignatory = WI.fillTextValue("cle_signatory_i");
		
		if(strSubIndex.length() == 0)
			strErrMsg = "Please select a subject.";
		else if(strCLESignatory.length() == 0)
			strErrMsg = "Please select a clearance type.";
		if(strErrMsg == null)
			strSQLQuery = "update subject set cle_signatory_i = "+strCLESignatory+" where sub_index = "+strSubIndex;
	}
	else 
		strSQLQuery = "update subject set cle_signatory_i = null where sub_index = "+WI.fillTextValue("info_index");
	
	if(strSQLQuery != null)
		dbOP.executeUpdateWithTrans(strSQLQuery, null, null, false);
}

//get the details already created. 
if(WI.fillTextValue("limit_view").length() > 0) 
	strSQLQuery = " and cle_signatory_i = "+WI.fillTextValue("cle_signatory_i");
else	
	strSQLQuery = "";

strSQLQuery  = "select sub_index, sub_code, sub_name, cle_signatory from subject "+
			" join CLE_SIGNATORY on (CLE_SIGNATORY.cle_signatory_index = cle_signatory_i) "+
			" where is_del = 0 "+strSQLQuery+" order by cle_signatory, sub_code";
java.sql.ResultSet rs = dbOP.executeQuery(strSQLQuery);
while(rs.next()) {
	vRetResult.addElement(rs.getString(1));//[0] sub_index, 	
	vRetResult.addElement(rs.getString(2));//[1] sub_code, 	
	vRetResult.addElement(rs.getString(3));//[2] sub_name, 	
	vRetResult.addElement(rs.getString(4));//[3] cle_signatory, 	
}
rs.close();
%>
<form action="./clearance_account_slip_UB_mandatory.jsp" method="post" name="form_">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" id='myADTable1'>
    <tr>
      <td width="100%" height="25" align="center" class="thinborderBOTTOM" valign="bottom"><strong>:::: MANDATORY CLEARANCE SET UP ::::</strong></td>
    </tr>
    <tr >
      <td height="25">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<font size="3"><b><%=WI.getStrValue(strErrMsg)%></b></font></td>
    </tr>
  </table>

	<table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" id='myADTable2'>
    <tr>
      <td height="25">&nbsp;</td>
      <td>Subject code Filter </td>
      <td>
	  <input name="sub_code_filter" type="text" size="16" maxlength="12" value="<%=WI.fillTextValue("sub_code_filter")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
	  
	  <input type="image" src="../../../../images/refresh.gif">
	  </td>
    </tr>
    <tr> 
      <td width="3%" height="25">&nbsp;</td>
      <td width="13%">Subject</td>
      <td>
<%
strTemp = WI.fillTextValue("sub_code_filter");
if(strTemp.length() > 0) 
	strTemp = " and sub_code like '"+strTemp+"%'";
%>
      <select name="sub_i" style="width:500px;">
          <%=dbOP.loadCombo("sub_index","sub_code, sub_name",
		  " from subject where cle_signatory_i is null and is_del = 0 "+strTemp+" and exists (select sub_index from curriculum where sub_index = subject.sub_index and is_valid = 1 and (lab_unit > 0 or hour_lab > 0)) order by sub_code",
		  WI.fillTextValue("sub_i"), false)%> </select>	  </td>
      </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Clearance Type </td>
      <td>
      <select name="cle_signatory_i">
          <%=dbOP.loadCombo("cle_signatory_index","cle_signatory"," from CLE_SIGNATORY where cle_signatory like 'lab-%' order by cle_signatory",
		  		WI.fillTextValue("cle_signatory_i"), false)%> </select>	  
				
<%strTemp = WI.fillTextValue("limit_view");
if(strTemp.length() > 0) 
	strTemp = " checked";
else	
	strTemp = "";
%>
			<input type="checkbox" name="limit_view" value="1" <%=strTemp%>> Limit Display to selected clerance type only		
				
		</td>
      </tr>
	 
    <tr>
      <td>&nbsp;</td>
      <td colspan="2"></td>
      </tr>

    <tr> 
      <td height="25">&nbsp;</td>
      <td >&nbsp;</td>
      <td>      	
			<input type="image" src="../../../../images/save.gif" border="0" onClick="document.form_.page_action.value='1'">	  </td>
      </tr>
  </table>
<%if(vRetResult != null && vRetResult.size() > 0) {%>  
	<table width="100%" cellpadding="0" cellspacing="0" border="0">
		<tr>
			<td align="center" style="font-size:11px; font-weight:bold">List of Subjects Having Mandatory Clerance Requirement</td>
		</tr>
	</table>
	<table width="100%" cellpadding="0" cellspacing="0" border="0" class="thinborder">
		<tr align="center" style="font-weight:bold" bgcolor="#DDDDDD">
			<td class="thinborder" width="15%">Clearance Type</td>
			<td class="thinborder" width="25%">Subject Code</td>
			<td class="thinborder" width="50%">Subject Name</td>
			<td class="thinborder">Delete</td>
		</tr>
		<%for(int i = 0; i < vRetResult.size(); i += 4) {%>
			<tr>
			  <td class="thinborder"><%=vRetResult.elementAt(i + 1)%></td>
			  <td class="thinborder"><%=vRetResult.elementAt(i + 2)%></td>
			  <td class="thinborder"><%=vRetResult.elementAt(i + 3)%></td>
			  <td class="thinborder" align="center"><a href="#"><img src="../../../../images/delete.gif" border="0" onClick="document.form_.page_action.value='0';document.form_.info_index.value='<%=vRetResult.elementAt(i)%>';document.form_.submit();"></a></td>
		   </tr>
		<%}%>
	</table>
	
<%}//only if vRetResult is not null%>	
	
<input type="hidden" name="page_action" value="">
<input type="hidden" name="info_index">
</form>
</script>
</body>
</html>
<%
dbOP.cleanUP();
%>