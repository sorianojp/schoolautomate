<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../css/tableBorder.css" rel="stylesheet" type="text/css">
<link href="../../css/tabStyle.css" rel="stylesheet" type="text/css">
</head>
<script src="../../jscript/common.js"></script>
<script language="JavaScript">
function PrintPg() {
	document.bgColor = "#FFFFFF";

	document.getElementById('myADTable1').deleteRow(0);
	document.getElementById('myADTable1').deleteRow(0);
	
	document.getElementById('myADTable2').deleteRow(0);
	
	document.getElementById('myADTable3').deleteRow(0);
	document.getElementById('myADTable4').deleteRow(0);
	
	
	alert("Click OK to print this page");
	window.print();
}
</script>

<%@ page language="java" import="utility.*,lms.Search,lms.LmsUtil,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	
	String strErrMsg = null;
	String strTemp = null;
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"LMS-Search-view detail","collection_bibliographic_format.jsp");
	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		//ErrorLog.logError(exp,"admission_application_sch_veiwall.jsp","While Opening DB Con");

		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		Error in opening connection</font></p>
		<%
		return;
	}

Vector vRetResult  = new Vector();
Search searchBook = new Search(request);

vRetResult = searchBook.getBiblioCitation(dbOP,WI.fillTextValue("accession_no"));	
if(vRetResult == null)
	strErrMsg = searchBook.getErrMsg();	

%>

<body bgcolor="#F2DFD2">
<form>
  <table width="100%" border="0" cellspacing="0" cellpadding="0" id="myADTable1">
    <tr bgcolor="#A8A8D5"> 
      <td height="20" bgcolor="#A8A8D5"><div align="center"><font color="#FFFFFF" ><strong>:::: 
          COLLECTION INFORMATION BIOGRAPHY ::::</strong></font></div></td>
    </tr>
    <tr> 
    <td height="20"><font size="3" color="#FF0000">&nbsp;&nbsp;&nbsp;&nbsp;<%=WI.getStrValue(strErrMsg)%></font></td>
    </tr>
</table>
<table border="0" cellspacing="0" cellpadding="0" id="myADTable2">
  <tr>
    <td background="../../images/tableft.gif" height="24" width="10">&nbsp;</td>
    <td width="120" bgcolor="#00468C" align="center"><a href="collection_details_main.jsp?accession_no=<%=WI.fillTextValue("accession_no")%>">Brief Description</a></td>
    <td background="../../images/tabright.gif" width="10">&nbsp;</td>
	<td background="../../images/tableft.gif" height="24" width="10">&nbsp;</td>
    <td width="140" bgcolor="#00468C" align="center"  class="tabFont"><a href="collection_details.jsp?accession_no=<%=WI.fillTextValue("accession_no")%>">Detailed Description</a> </td>
    <td background="../../images/tabright.gif" width="10">&nbsp;</td>
	<td background="../../images/tableft_selected.gif" height="24" width="10">&nbsp;</td>    
	<td width="150" bgcolor="#A9B9D1" align="center"  class="tabFont">Citation</td>    
	<td background="../../images/tabright_selected.gif" width="10">&nbsp;</td>
  </tr>
</table>

	  
<%if(strErrMsg == null) {%>  
 
<table cellpadding="0" cellspacing="0" width="100%" border="0" id="myADTable4">
	<tr bgcolor="#DDDDEE"> 
    	<td height="20" colspan="3" class="thinborderBOTTOM"><font color="#FF0000">::: BIBLIOGRAPHIC CITATION :::</font></td>
	</tr>      
</table>

<%if(vRetResult != null && vRetResult.size() > 0){
String strAPAFormat     = (String)vRetResult.remove(0);
String strChicagoFormat = (String)vRetResult.remove(0);
String strHarvardFormat = (String)vRetResult.remove(0);
String strMLAFormat     = (String)vRetResult.remove(0);

%>
<table width="100%" border="0" cellspacing="0" cellpadding="0">
	<tr><td height="15" colspan="3" style="padding-left:30px;"><strong>APA</strong></td></tr> 
	<tr><Td style="padding-left:30px;"><%=strAPAFormat%></Td></tr>
	<tr><td height="10"></td></tr>
	<tr><td height="15" colspan="3" style="padding-left:30px;"><strong>Chicago/Turabian</strong></td></tr> 
	<tr><Td style="padding-left:30px;"><%=strChicagoFormat%></Td></tr>
	<tr><td height="10"></td></tr>
	<tr><td height="15" colspan="3" style="padding-left:30px;"><strong>Harvard</strong></td></tr> 
	<tr><Td style="padding-left:30px;"><%=strHarvardFormat%></Td></tr>
	<tr><td height="10"></td></tr>
	<tr><td height="15" colspan="3" style="padding-left:30px;"><strong>MLA</strong></td></tr> 
	<tr><Td style="padding-left:30px;"><%=strMLAFormat%></Td></tr>
</table>
<%}%>

<table width="100%" border="0" cellspacing="0" cellpadding="0" id="myADTable3">
  <tr>
      <td align="right">
	  <a href="javascript:PrintPg();"><img src="../images/print_recommend.gif" border="0"></a><font size="1">click to print bibliography</font></td>
  </tr>
</table>
</form>
<%}//only if strErrMsg != null%>
</body>
</html>
<%
dbOP.cleanUP();
%>