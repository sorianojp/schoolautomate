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
	Vector vFSInfo    = null;
	
	Vector vFSInfoSummary    =  mgmtLedg.getFSBookColletionSummary(dbOP, WI.fillTextValue("fs_index"));
	if(vFSInfoSummary == null)
		strErrMsg = mgmtLedg.getErrMsg();
	
	String[] astrFSStat = {"In-active","Active"};
%>

<body>

	  
  
  
<%
if(vFSInfoSummary != null && vFSInfoSummary.size() > 0){

String strSchName = SchoolInformation.getSchoolName(dbOP, true, false);
String strSchAddr    = SchoolInformation.getAddressLine1(dbOP, false, false);

boolean bolPageBreak = false;
int iRowCount  =0 ;
int iMaxRowCount = 35;

for(int i = 0; i < vFSInfoSummary.size(); i+=8){

strTemp = (String)vFSInfoSummary.elementAt(i);
request.setAttribute("funding_source_index",strTemp);
vFSInfo = mgmtLedg.operateOnFSProfile(dbOP, request,3);
if(vFSInfo == null)
	continue;


mgmtLedg.defSearchSize = 0;
vRetResult = mgmtLedg.getFSBookColletionDetailed(dbOP, request, strTemp, (String)vFSInfoSummary.elementAt(i+7));	
if(vRetResult == null)
	continue;

%>

<table width="100%" border="0" cellpadding="0" cellspacing="0">
	<tr><td align="center" height="25">
		<%=strSchName%><br>
		<%=strSchAddr%>
	</td></tr>
	<tr>
	    <td align="center" height="25">&nbsp;</td>
    </tr>
</table>

<table width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr > 
      <td width="3%" height="25"></td>
      <td width="10%">F S Code</td>
      <td width="28%"><font size="1"><strong><%=(String)vFSInfo.elementAt(1)%></strong></font></td>
      <td width="59%">Status: <font size="1"><strong><%=astrFSStat[Integer.parseInt((String)vFSInfo.elementAt(3))]%></strong></font> </td>
    </tr>
    <tr > 
      <td height="25">&nbsp;</td>
      <td height="25">F S Name</td>
      <td height="25" colspan="2"><font size="1"><strong><%=(String)vFSInfo.elementAt(2)%></strong></font></td>
    </tr>
    <tr > 
      <td height="15" colspan="4"><hr size="1"></td>
    </tr>
  </table>

  
<%
if(vRetResult != null && vRetResult.size() > 0){%>
  
  
  <table width="100%" border="0" cellspacing="0" cellpadding="0" class="thinborder">
    <tr> 
      <td height="25" colspan="6" bgcolor="#DDDDEE" class="thinborder"><div align="center">LISTS 
          OF LIBRARY COLLECTIONS 
<%
	strTemp = null;

	if(WI.getStrValue((String)vFSInfoSummary.elementAt(i+7)).length() > 0)
		strTemp = dbOP.mapOneToOther("LMS_MAT_TYPE", "MATERIAL_TYPE_INDEX", (String)vFSInfoSummary.elementAt(i+7), "MATERIAL_TYPE",null);
		
	
	if(strTemp != null) {%>
		  UNDER MATERIAL TYPE : <strong><%=strTemp%></strong></div></td>
<%}%>
    </tr>
	<tr> 
      <td width="9%" height="25" class="thinborder"><div align="center"><font size="1"><strong> 
          CALL NO. </strong></font></div></td>
      <td width="12%" class="thinborder"><div align="center"><font size="1"><strong>ACCESSION 
          NUMBER </strong></font></div></td>
      <td width="11%" class="thinborder"><div align="center"><font size="1"><strong>BARCODE 
          NUMBER</strong></font></div></td>
      <td width="33%" class="thinborder"><div align="center"><font size="1"><strong>TITLE 
          / SUBTITLE</strong></font></div></td>
      <td width="18%" class="thinborder"><div align="center"><font size="1"><strong>AUTHOR</strong></font></div></td>
      <td width="17%" class="thinborder"><div align="center"><font size="1"><strong>PUBLISHER</strong></font></div></td>
    </tr>
<%for(int j = 0; j < vRetResult.size();j += 10){%>
    <tr> 
      <td height="25" class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(j + 3)%></td>
      <td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(j + 4)%></td>
      <td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(j + 5)%></td>
      <td class="thinborder">&nbsp;<%=WI.getStrValue(vRetResult.elementAt(j + 6))%><%=WI.getStrValue((String)vRetResult.elementAt(j +7),"/","","")%></td>
      <td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(j + 8)%></td>
      <td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(j + 9)%></td>
    </tr>
<%}%>
  </table>
<%}//only if vRetResult.size () > 0

}//end of for loop vFSInfoSummary%>
<script>window.print();</script>
<%}%>  

	
</body>
</html>
<%
dbOP.cleanUP();
%>