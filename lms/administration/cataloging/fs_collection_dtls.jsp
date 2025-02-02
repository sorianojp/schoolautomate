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

function PrintPg(strType){
	
	var pgLoc = "./fs_collection_dtls_summary_print.jsp?fs_index="+document.form_.fs_index.value;
	if(strType == "2")
		pgLoc = "./fs_collection_dtls_detailed_print.jsp";
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
	
	vFSInfo = mgmtLedg.operateOnFSProfile(dbOP, request,5);
	if(vFSInfo == null)
		strErrMsg = mgmtLedg.getErrMsg();
	vRetResult = mgmtLedg.getFSBookColletionSummary(dbOP, WI.fillTextValue("fs_index"));
	if(vRetResult == null)
		strErrMsg = mgmtLedg.getErrMsg();
	
	String[] astrFSStat = {"In-active","Active"};
%>

<body bgcolor="#DEC9CC">
<form action="./fs_collection_dtls.jsp" method="post" name="form_">
  <table width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr bgcolor="#A8A8D5"> 
      <td height="25" colspan="8" bgcolor="#A8A8D5"><div align="center"><font color="#FFFFFF" ><strong>:::: 
          CATALOGING MANAGEMENT - FUNDING SOURCE - DETAILS OF COLLECTIONS BY FUNDING 
          SOURCE PAGE ::::</strong></font></div></td>
    </tr>
	</table>
	  
  <table width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr > 
      <td height="25">&nbsp;&nbsp;&nbsp;<font size="1"><a href='fs_main.htm'><img src="../../images/go_back.gif" border="0"></a></font><font size="3" color="#FF0000">&nbsp;&nbsp;<font size="3" color="#FF0000"><strong> 
        <%=WI.getStrValue(strErrMsg,"Message : ","","")%></strong></font></font></td>
    </tr>
  </table>
  <table width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr > 
      <td width="3%" height="25"></td>
      <td width="97%">Funding Source : 
        <select name="fs_index" onChange="ReloadPage()"
		style="font-family:Verdana, Arial, Helvetica, sans-serif;font-size: 10;">
          <option value="">ALL</option>
          <%
String strStatus = null;
strTemp = WI.fillTextValue("fs_index");
for(int i = 0; vFSInfo != null && i < vFSInfo.size(); i += 8){
	if(strTemp.compareTo((String)vFSInfo.elementAt(i)) == 0){
		strStatus = (String)vFSInfo.elementAt(i + 3);%>
          <option value="<%=(String)vFSInfo.elementAt(i)%>" selected><%=(String)vFSInfo.elementAt(i + 1)+"("+(String)vFSInfo.elementAt(i + 2)+")"%></option>
          <%}else{%>
          <option value="<%=(String)vFSInfo.elementAt(i)%>"><%=(String)vFSInfo.elementAt(i + 1)+"("+(String)vFSInfo.elementAt(i + 2)+")"%></option>
          <%}
}//end of for loop	%>
        </select></td>
    </tr>
<%
if(strTemp.length() > 0 && vFSInfo != null && vFSInfo.size() > 0)
	strStatus = (String)vFSInfo.elementAt(3);
	
if(strStatus != null){
%>
   <tr >
      <td height="25"></td>
      <td>Status : <font size="2"><strong><%=astrFSStat[Integer.parseInt(strStatus)]%><a href='javascript:ViewCollection("<%=strStatus%>","");'> 
<%
if(vRetResult != null && vRetResult.size() > 0){%>
        <img src="../../images/view_admin.gif" border="0"></a></strong></font><font size="1">View 
        all collection for this funding source.</font>
<%}%>		</td>
    </tr>
<%}
if(vRetResult == null || vRetResult.size() == 0) {%>
   <tr >
      <td height="25"></td>
      <td align="center"><strong><BR>
        </strong><BR> <FONT size="4">NO COLLECTION FOUND IN DATABASE.</FONT></td>
    </tr>
<%}%>
    
  </table>
<%
if(vRetResult != null && vRetResult.size() > 0){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" class="thinborder">
    <tr> 
      <td height="25" class="thinborder"><a href="javascript:PrintPg('1');"> 
        <img src="../../images/print.gif" border="0"></a>Click to print collection summary</td>
      <td height="25" colspan="3" class="thinborderBOTTOM" align="right">
	  <a href="javascript:PrintPg('2');"> 
        <img src="../../images/print.gif" border="0"></a>Click to print collection details
	  </td>
      </tr>
    <tr> 
      <td height="25" colspan="4" bgcolor="#DDDDEE" class="thinborder"><div align="center">LISTING 
          OF LIBRARY COLLECTIONS AS OF <strong> <%=WI.getTodaysDate(1)%> </strong></div></td>
    </tr>
    <tr> 
      <td width="52%" height="25" class="thinborder"><div align="center"><font size="1"><strong> 
          MATERIAL TYPE</strong></font></div></td>
      <td width="17%" class="thinborder"><div align="center"><font size="1"><strong>NO. 
          OF COPIES </strong></font></div></td>
      <td width="15%" class="thinborder"><div align="center"><font size="1"><strong>TOTAL 
          VALUE</strong></font></div></td>
      <td width="16%" class="thinborder"><div align="center"><font size="1"><strong>VIEW 
          LIBRARY COLLECTION DETAIL</strong></font></div></td>
    </tr>
    <%for(int i = 0; i < vRetResult.size(); i += 8){
	//show the funding source name if not repeating..
	if(vRetResult.elementAt(i + 1) != null){%>
    <tr> 
      <td height="25" colspan="4" class="thinborder">&nbsp;&nbsp;&nbsp;<%=(String)vRetResult.elementAt(i + 1)%> 
	  ::: <%=(String)vRetResult.elementAt(i + 2)%> ::: <font size="2"><strong>
	  <%=astrFSStat[Integer.parseInt((String)vRetResult.elementAt(i + 3))]%></strong></font></td>
    </tr>
	<%}%>
    <tr> 
      <td height="25" class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i + 4)%></td>
      <td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i + 5)%></td>
      <td class="thinborder">&nbsp;<%=WI.getStrValue(vRetResult.elementAt(i + 6))%></td>
      <td class="thinborder" align="center">
	  <a href='javascript:ViewCollection("<%=(String)vRetResult.elementAt(i)%>","<%=(String)vRetResult.elementAt(i + 7)%>");'>
	  <img src="../../images/view_admin.gif" border="0"></a>	  </td>
    </tr>
    <%}%>
  </table>
<%}%>  
<input type="hidden" name="print_page">
</form>
	
</body>
</html>
<%
dbOP.cleanUP();
%>