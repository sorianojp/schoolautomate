
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/reportlink.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../jscript/td.js"></script>
<script language="JavaScript">
	function CreateReport(){
		document.form_.create_report.value = "1";
		document.form_.submit();
	}
	
	function DeleteReport(strInfoIndex){
		document.form_.delete_report.value = "1";
		document.form_.info_index.value = strInfoIndex;
		document.form_.submit();
	}
</script>
<body bgcolor="#DEC9CC" topmargin="0" bottommargin="0">
<%@ page language="java" import="utility.*,lms.LmsUtil,lms.CatalogReport,java.util.Vector" %>
<%
	WebInterface WI      = new WebInterface(request);
	DBOperation dbOP = null;
	String strErrMsg = null;
	int iAccessLevel = 0;
	String strTemp   = null;
	
	
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("LIB_CATALOGING"),"0"));
	}
	if(iAccessLevel == -1) {//for fatal error.
		request.getSession(false).setAttribute("go_home","../lms/");
		request.getSession(false).setAttribute("errorMessage","Please login to access this page.");
		response.sendRedirect("../../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0) {//NOT AUTHORIZED.
		response.sendRedirect("../../../commfile/unauthorized_page.jsp");
		return;
	}

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"LIB_Cataloging-REPORTS","create_report.jsp");
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

String[] astrSortByName = {"Call Number","Copyright","Book Title"};
String[] astrSortByVal = {"call_number","publisher_date","book_title"};

CatalogReport ctlgReport = new CatalogReport();
Vector vRetResult = null;


if(WI.fillTextValue("create_report").length() > 0){
	if(!ctlgReport.createExcelReport(dbOP, request))
		strErrMsg = ctlgReport.getErrMsg();
	else
		strErrMsg = "Report successfully created.";	
}


if(WI.fillTextValue("delete_report").length() > 0){
	if(!ctlgReport.deleteReport(dbOP, request))
		strErrMsg = ctlgReport.getErrMsg();
	else
		strErrMsg = "Report Successfully Deleted.";
}

vRetResult = ctlgReport.getExcelReports(dbOP);
if(vRetResult == null)
	strErrMsg = ctlgReport.getErrMsg();
	
%>

<form name="form_" method="post" action="./create_report.jsp">
  <table width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr bgcolor="#A8A8D5"> 
      <td height="25" colspan="8" bgcolor="#A8A8D5"><div align="center"><font color="#FFFFFF" ><strong>:::: 
          CATALOGING : REPORTS - CREATE REPORT PAGE ::::</strong></font></div></td>
    </tr>
  </table>
	  
  <table width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td width="24%" height="30" class="thinborderBOTTOM">
	  <font size="1"><a href="main_page.jsp" target="_self"><img src="../../images/go_back.gif" border="0" ></a>(go to main report)</font></td>      
    </tr>
  </table>
  <table width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
		<td height="25">&nbsp;</td>
		<td colspan="3"><strong><font size="2" color="#FF0000"><%=WI.getStrValue(strErrMsg)%></font></strong></td>
	</tr>
   
    
	
	<tr> 
      <td width="3%" height="25">&nbsp;</td>
      <td width="17%" height="25">Location</td>	  
      <td width="" height="25" colspan="2">	  
	  <select name="location">
	  	 <option value="">All</option>
		 <%=dbOP.loadCombo("loc_index", "loc_name", " from LMS_LIBRARY_LOC order by loc_index", WI.fillTextValue("location"), false)%>
    </select>    </tr>
	<tr> 
      <td width="33" height="28">&nbsp;</td>
      <td width="89" height="28">Call Number From</td>
	  <%
	  strTemp = WI.fillTextValue("call_no_from");
	  %>
      <td width="762" height="28" colspan="2">	  
    <input type="text" name="call_no_from" value="<%=strTemp%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="60" maxlength="128">    </tr>
	
	<tr> 
      <td width="33" height="28">&nbsp;</td>
      <td width="89" height="28">Call Number To</td>
	  <%
	  strTemp = WI.fillTextValue("call_no_to");
	  %>
      <td width="762" height="28" colspan="2">	  
    <input type="text" name="call_no_to" value="<%=strTemp%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="60" maxlength="128">    </tr>
	
	<tr> 
      <td width="33" height="28">&nbsp;</td>
      <td width="89" height="28">Location Symbol </td>
	  <%strTemp = WI.fillTextValue("CTYPE_INDEX");%>
      <td width="762" height="28" colspan="2"><select name="CTYPE_INDEX"
	  	  style="font-family:Verdana, Arial, Helvetica, sans-serif;font-size: 10;">
        <option value="">All</option>
        <%=dbOP.loadCombo("CTYPE_INDEX","DESCRIPTION, CTYPE_CODE"," from LMS_CLOG_CTYPE WHERE IS_VALID = 1 AND IS_DEL = 0 order by DESCRIPTION asc",
		  	strTemp, false)%>
      </select>
	</tr>	
	
	<tr>
          	<td height="25" width="3%">&nbsp;</td>
		  	<td width="17%">Sort by: </td>
		  	<td>
				<select name="sort_by1">					
					<%=ctlgReport.constructSortByDropList(WI.fillTextValue("sort_by1"),astrSortByName,astrSortByVal)%>
				</select>
				<select name="sort_by1_con">
                  <option value="asc">Ascending</option>
                  <%if(WI.fillTextValue("sort_by1_con").equals("desc")){%>
                  <option value="desc" selected="selected">Descending</option>
                  <%}else{%>
                  <option value="desc">Descending</option>
                  <%}%>
                </select></td>
	    </tr>
	
    <tr> 
      <td height="10" colspan="4"></td>
    </tr>
	
    <tr> 
	  <td colspan="2">&nbsp;</td>
      <td height="20"><input type="button" name="cmdCreate" value="CREATE REPORT" onClick="CreateReport();" /></td>
    </tr>
</table>


<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		
	</table>

<%if(vRetResult != null && vRetResult.size() > 0){%>
<table width="100%" border="0" cellspacing="0" cellpadding="0">
<tr>
	<td width="64%" height="25">File Name</td>
	<!--<td width="10%" height="35" valign="bottom"><div align="left">Size</div></td>-->
	<td width="9%" height="25" align="center">TYPE</td>
	<td width="15%" height="25" align="center">DATE MODIFIED</td>
	<td width="12%" height="25" align="center">OPTION</td>
</tr>

<%for(int i=0;i<vRetResult.size();i+=6){%>
<tr>
	<td width="64%" height="25">
	<a href="<%=(String)vRetResult.elementAt(i+5)%>"><%=(String)vRetResult.elementAt(i+1)%></a></td>
	<!--<td width="10%" height="35" valign="bottom"><div align="left"><//%=(String)vRetResult.elementAt(1)%></div></td>-->
	<td width="9%" height="25">FILE</td>
	<td width="15%" height="25"><%=(String)vRetResult.elementAt(i+3)%></td>	
	<td width="12%" height="25" align="center">
		<a href="javascript:DeleteReport('<%=(String)vRetResult.elementAt(i)%>');"><img src="../../images/delete.gif" border="0"></a>
	</td>
</tr>
<%}%>
</table>
<%}%>
<input type="hidden" name="info_index" value="<%=WI.fillTextValue("info_index")%>" >
<input type="hidden" name="delete_report" >
<input type="hidden" name="create_report" >
</form>
	
</body>
</html>
<%
dbOP.cleanUP();
%>