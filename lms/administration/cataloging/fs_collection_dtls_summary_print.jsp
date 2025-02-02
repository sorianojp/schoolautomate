<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript">
function ReloadPage(){
	document.form_.submit();
}
function ViewCollection(strFSIndex,strMatTypeIndex) {
	var pgLoc = "./fs_collection_dtls_view.jsp?funding_source_index="+strFSIndex+"&mat_type_index="+strMatTypeIndex;
	var win=window.open(pgLoc,"myfile",'dependent=yes,width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
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
								"lms-Administration-CATALOGING","fs_collection_dtls.jsp");
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
														"fs_collection_dtls.jsp");
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

	MgmtCatalog mgmtLedg = new MgmtCatalog();
	Vector vRetResult = new Vector();
	Vector vFSInfo    = null;//Funding source information, -> code, name and status.
	

	vRetResult = mgmtLedg.getFSBookColletionSummary(dbOP, WI.fillTextValue("fs_index"));
	if(vRetResult == null)
		strErrMsg = mgmtLedg.getErrMsg();
	
	String[] astrFSStat = {"In-active","Active"};
%>

<body>

	  
  
  
<%
if(vRetResult != null && vRetResult.size() > 0){%>

<table width="100%" border="0" cellpadding="0" cellspacing="0">
	<tr><td align="center" height="25">
		<%=SchoolInformation.getSchoolName(dbOP, true, false)%><br>
		<%=SchoolInformation.getAddressLine1(dbOP, false, false)%>
	</td></tr>
	<tr>
	    <td align="center" height="25">&nbsp;</td>
    </tr>
</table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" class="thinborder">    
    <tr> 
      <td height="25" colspan="3" bgcolor="#DDDDEE" class="thinborder"><div align="center">LISTING 
          OF LIBRARY COLLECTIONS AS OF <strong> <%=WI.getTodaysDate(1)%> </strong></div></td>
    </tr>
    <tr> 
      <td width="52%" height="25" class="thinborder"><div align="center"><font size="1"><strong> 
          MATERIAL TYPE</strong></font></div></td>
      <td width="17%" class="thinborder"><div align="center"><font size="1"><strong>NO. 
          OF COPIES </strong></font></div></td>
      <td width="15%" class="thinborder"><div align="center"><font size="1"><strong>TOTAL 
          VALUE</strong></font></div></td>
      </tr>
    <%for(int i = 0; i < vRetResult.size(); i += 8){
	//show the funding source name if not repeating..
	if(vRetResult.elementAt(i + 1) != null){%>
    <tr> 
      <td height="25" colspan="3" class="thinborder">&nbsp;&nbsp;&nbsp;<%=(String)vRetResult.elementAt(i + 1)%> 
	  ::: <%=(String)vRetResult.elementAt(i + 2)%> ::: <font size="2"><strong>
	  <%=astrFSStat[Integer.parseInt((String)vRetResult.elementAt(i + 3))]%></strong></font></td>
    </tr>
	<%}%>
    <tr> 
      <td height="25" class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i + 4)%></td>
      <td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i + 5)%></td>
      <td class="thinborder">&nbsp;<%=WI.getStrValue(vRetResult.elementAt(i + 6))%></td>
      </tr>
    <%}%>
  </table>
<script>window.print();</script>
<%}%>  

	
</body>
</html>
<%
dbOP.cleanUP();
%>