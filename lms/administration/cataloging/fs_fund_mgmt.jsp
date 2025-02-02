<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript">
function ViewDetail(strFSIndex) {
	var pgLoc = "./fs_fund_mgmt_update.jsp?view_all=1&funding_source_index="+strFSIndex;
	var win=window.open(pgLoc,"myfile",'dependent=yes,width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function ReloadPage() {
	document.form_.submit();
}
</script>
<%@ page language="java" import="utility.*,lms.MgmtCatalog,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);

	String strErrMsg = null;
	String strTemp   = null;
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"lms-Administration-CATALOGING","fs_fund_mgmt.jsp");
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
														"LIB_Administration","CATALOGING",request.getRemoteAddr(),
														"fs_fund_mgmt.jsp");
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
	MgmtCatalog mgmtFS = new MgmtCatalog();
	Vector vRetResult = null;
	vRetResult = mgmtFS.viewFSLedgerSummary(dbOP);	
	if(vRetResult == null)
		strErrMsg = mgmtFS.getErrMsg();
	
%>
<body bgcolor="#DEC9CC">
<form name="form_">
  <table width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr bgcolor="#A8A8D5"> 
      <td height="25" colspan="8" bgcolor="#A8A8D5"><div align="center"><font color="#FFFFFF" ><strong>:::: 
          CATALOGING MANAGEMENT - FUNDING SOURCE - FUNDS MANAGEMENT PAGE ::::</strong></font></div></td>
    </tr>
	</table>
	  
  <table width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr > 
      <td height="25">&nbsp;&nbsp;&nbsp;<a href='fs_main.htm'><img src="../../images/go_back.gif" border="0"></a>
	  <font size="3" color="#FF0000">&nbsp;<strong><%=WI.getStrValue(strErrMsg,"Message : ","","")%></strong></font></td>
    </tr>
  </table>
<%
if(vRetResult != null && vRetResult.size() > 0) {%>
  <table width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr > 
      <td width="2%" height="15">&nbsp;</td>
      <td width="49%" height="15" align="center"><a href="javascript:ReloadPage();"> 
        <img src="../../../images/refresh.gif" border="1"></a> <font size="1">click to reload 
        the page</font></td>
      <td width="49%" align="right"><img src="../../images/print.gif" width="60" height="29"><font size="1">click 
        to print list</font></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" class="thinborder">
    <tr> 
      <td height="25" colspan="7" bgcolor="#DDDDEE" class="thinborder"><div align="center">CURRENT 
          SUMMARY FUND STATUS OF EXISTING FUNDING SOURCE (For Cash Allocation)</div></td>
    </tr>
    <tr> 
      <td width="11%" height="25" class="thinborder"><div align="center"><font size="1"><strong> 
          CODE NO.</strong></font></div></td>
      <td width="28%" class="thinborder"><div align="center"><font size="1"><strong>NAME</strong></font></div></td>
      <td width="8%" class="thinborder"><div align="center"><font size="1"><strong><font size="1">STATUS</font></strong></font></div></td>
      <td width="14%" class="thinborder"><div align="center"><font size="1"><strong>TOTAL 
          ALLOCATION</strong></font></div></td>
      <td width="13%" class="thinborder"><div align="center"><font size="1"><strong>TOTAL 
          SPENT</strong></font></div></td>
      <td width="13%" class="thinborder"><div align="center"><strong><font size="1"><strong><strong>BALANCE 
          AS OF DATE</strong></strong></font></strong></div></td>
      <td width="13%" class="thinborder"><div align="center"><font size="1"><strong>UPDATE 
          FUND ALLOCATION</strong></font></div></td>
    </tr>
<%
	String[] astrFSStat = {"In-active","Active"};//System.out.println(vRetResult);
	for(int i = 3; i < vRetResult.size(); i += 8){%>
    <tr> 
      <td height="25" class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i + 1)%></td>
      <td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i + 2)%></td>
      <td class="thinborder">&nbsp;<%=astrFSStat[Integer.parseInt((String)vRetResult.elementAt(i + 3))]%></td>
      <td class="thinborder">&nbsp;
	  <% if(vRetResult.elementAt(i + 4) != null){%>
	  <%=CommonUtil.formatFloat((String)vRetResult.elementAt(i + 4),true)%>
	  <%}%>
	  </td>
      <td class="thinborder">&nbsp;
        <% if(vRetResult.elementAt(i + 5) != null){%>
        <%=CommonUtil.formatFloat((String)vRetResult.elementAt(i + 5),true)%> 
        <%}%>
      </td>
      <td class="thinborder">&nbsp;
        <% if(vRetResult.elementAt(i + 6) != null){%>
        <%=CommonUtil.formatFloat((String)vRetResult.elementAt(i + 6),true)%> 
        <%}%>
      </td>
      <td class="thinborder"> 
	  <div align="center"><a href='javascript:ViewDetail(<%=(String)vRetResult.elementAt(i)%>);'><img src="../../images/view_admin.gif" border="0"></a> 
        </div></td>
    </tr>
    <%}%>
  </table>
<%}%>  
</form>
	
</body>
</html>
<%
dbOP.cleanUP();
%>