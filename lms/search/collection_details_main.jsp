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
	
	alert("Click OK to print this page");
	window.print();
}
</script>

<%@ page language="java" import="utility.*,lms.LmsUtil,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	
	String strErrMsg = null;
	String strTemp = null;
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"LMS-Search-view detail","collection_details.jsp");
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
	
	String strSchCode = dbOP.getSchoolIndex();	
	if(strSchCode == null)
		strSchCode = "";	
	
Vector vRetResult  = null;
Vector vCopyDetail = new Vector();
Vector vSH         = new Vector();
Vector vAuthor     = new Vector();

LmsUtil lUtil     = new LmsUtil();
vRetResult = lUtil.getBriefAndDetailedBookInfo(dbOP, WI.fillTextValue("accession_no"),false);

if(vRetResult == null || vRetResult.size() == 0) 
	strErrMsg = lUtil.getErrMsg();
else {
	vCopyDetail  = (Vector)vRetResult.remove(0);//System.out.println(vI);
	vSH          = (Vector)vRetResult.remove(0);
	vAuthor      = (Vector)vRetResult.remove(0);
}	
%>



<body bgcolor="#F2DFD2">
<form>
  <table width="100%" border="0" cellspacing="0" cellpadding="0" id="myADTable1">
    <tr bgcolor="#A8A8D5"> 
      <td height="20" bgcolor="#A8A8D5"><div align="center"><font color="#FFFFFF" ><strong>:::: 
          COLLECTION INFORMATION SUMMARY ::::</strong></font></div></td>
    </tr>
    <tr> 
    <td height="20"><font size="3" color="#FF0000">&nbsp;&nbsp;&nbsp;&nbsp;<%=WI.getStrValue(strErrMsg)%></font></td>
    </tr>
</table>
<table border="0" cellspacing="0" cellpadding="0" id="myADTable2">
  <tr>
	<td background="../../images/tableft_selected.gif" height="24" width="10">&nbsp;</td>
    <td width="120" bgcolor="#A9B9D1" align="center"  class="tabFont">Brief Description </td>
    <td background="../../images/tabright_selected.gif" width="10">&nbsp;</td>
    <td background="../../images/tableft.gif" height="24" width="10">&nbsp;</td>
    <td width="140" bgcolor="#00468C" align="center"><a href="collection_details.jsp?accession_no=<%=WI.fillTextValue("accession_no")%>">Detailed Description</a></td>
    <td background="../../images/tabright.gif" width="10">&nbsp;</td>
<!--
    <td background="../../images/tableft.gif" height="24" width="10">&nbsp;</td>
    <td width="150" bgcolor="#00468C" align="center"><a href="collection_details_v2.jsp?accession_no=<%=WI.fillTextValue("accession_no")%>">Detailed Description(v2)</a></td>
    <td background="../../images/tabright.gif" width="10">&nbsp;</td>
-->

	<%if(strSchCode.startsWith("CIT")){%>
	<!--<td background="../../images/tableft_selected.gif" height="24" width="10">&nbsp;</td>    -->
	<td background="../../images/tableft.gif" height="24" width="10">&nbsp;</td>
	<td width="150" bgcolor="#00468C" align="center"  class="tabFont"><a href="collection_bibliographic_format.jsp?accession_no=<%=WI.fillTextValue("accession_no")%>">Citation</a></td>    
	<!--<td background="../../images/tabright_selected.gif" width="10">&nbsp;</td>-->
	<td background="../../images/tabright.gif" width="10">&nbsp;</td>
	<%}%>
  </tr>
</table>

	  
<%if(strErrMsg == null) {%>  

<table cellpadding="0" cellspacing="0" width="100%">
  <tr bgcolor="#DDDDEE"> 
    <td height="20" colspan="3" class="thinborderBOTTOM"><font color="#FF0000">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;::: 
      COLLECTION BASIC ENTRY :::</font></td>
  </tr>
  <tr> 
    <td width="1%" height="20"></td>
    <td width="18%">Book Location </td>
    <td width="81%"><%=WI.getStrValue(vRetResult.elementAt(0))%></td>
  </tr>
  <tr> 
    <td height="20"></td>
    <td>Classification Number </td>
    <td><%=WI.getStrValue(vRetResult.elementAt(1))%></td>
  </tr>
  <tr>
    <td height="20"></td>
    <td>Author Code</td>
    <td><%=WI.getStrValue(vRetResult.elementAt(2))%></td>
  </tr>
  <tr> 
    <td height="20"></td>
    <td>Copyright</td>
    <td><%=WI.getStrValue(vRetResult.elementAt(3))%></td>
  </tr>
  
  <tr> 
    <td height="18" colspan="3"><hr size="1"></td>
  </tr>
  <tr> 
    <td height="20"></td>
    <td>Title</td>
    <td><%=WI.getStrValue(vRetResult.elementAt(4))%><%=WI.getStrValue((String)vRetResult.elementAt(5)," ::: ","","")%>
	<%=WI.getStrValue((String)vRetResult.elementAt(13)," = ","","")%></td>
  </tr>
  <tr>
    <td height="20"></td>
    <td>Author</td>
    <td><%=WI.getStrValue(vRetResult.elementAt(6))%></td>
  </tr>
  <tr>
    <td height="20"></td>
    <td>Edition</td>
    <td><%=WI.getStrValue(vRetResult.elementAt(7))%></td>
  </tr>
  <tr> 
    <td height="18" colspan="3"><hr size="1"></td>
  </tr>
  <tr>
    <td height="20"></td>
    <td><b><u>Copy Detail :</u></b> </td>
    <td>&nbsp;</td>
  </tr>
  <tr>
    <td height="20"></td>
    <td colspan="2">
		<table width="100%" cellpadding="0" cellspacing="0" class="thinborder">
			<tr style="font-weight:bold">
				<td height="20" class="thinborder" width="20%">&nbsp;Accession Number</td>
				<td class="thinborder" width="20%">&nbsp;Barcode Number</td>
				<td class="thinborder" width="15%">&nbsp;Book Status</td>
				<td class="thinborder" width="20%">&nbsp;Collection Location </td>
				<td class="thinborder" width="25%">&nbsp;Library Location</td>
			</tr>
		    <%for (int i = 0; i < vCopyDetail.size(); i += 5) {%>
			<tr>
		      <td height="20" class="thinborder">&nbsp;<%=vCopyDetail.elementAt(i + 1)%></td>
		      <td class="thinborder">&nbsp;<%=vCopyDetail.elementAt(i)%></td>
		      <td class="thinborder">&nbsp;<%=vCopyDetail.elementAt(i + 2)%></td>
		      <td class="thinborder">&nbsp;<%=vCopyDetail.elementAt(i + 4)%></td>
		      <td class="thinborder">&nbsp;<%=vCopyDetail.elementAt(i + 3)%></td>
			</tr>
		    <%}%>
        </table>	</td>
  </tr>
</table>

<table width="100%" border="0" cellspacing="0" cellpadding="0" id="myADTable3">
  <tr>
      <td align="right">
	  <a href="javascript:PrintPg();"><img src="../images/print_recommend.gif" border="0"></a><font size="1">click to print collection details</font></td>
  </tr>
</table>
</form>
<%}//only if strErrMsg != null
%>
</body>
</html>
<%
dbOP.cleanUP();
%>