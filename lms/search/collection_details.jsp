<%


WebInterface WI = new WebInterface(request);
//String strSchCode = WI.getStrValue((String)request.getSession(false).getAttribute("school_code"));
//if(strSchCode == null)
//	strSchCode = "";
	
//
%>

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
	boolean bolIsCIT = strSchCode.startsWith("CIT");
	boolean bolUPHD = false;
	if(strSchCode.startsWith("UPH") && SchoolInformation.getInfo5(dbOP,false,false) == null)
		bolUPHD = true;
	
	
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
          COLLECTION INFORMATION DETAIL ::::</strong></font></div></td>
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
	<td background="../../images/tableft_selected.gif" height="24" width="10">&nbsp;</td>
    <td width="140" bgcolor="#A9B9D1" align="center"  class="tabFont">Detailed Description </td>
    <td background="../../images/tabright_selected.gif" width="10">&nbsp;</td>
<!--
    <td background="../../images/tableft.gif" height="24" width="10">&nbsp;</td>
    <td width="150" bgcolor="#00468C" align="center"><a href="collection_details_v2.jsp?accession_no=<%=WI.fillTextValue("accession_no")%>">Detailed Description(v2)</a></td>
    <td background="../../images/tabright.gif" width="10">&nbsp;</td>
-->	
	<!--<td background="../../images/tableft_selected.gif" height="24" width="10">&nbsp;</td>    -->
	
	
	<%if(bolIsCIT){%>
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
      COLLECTION DETAILED DESCRIPTION :::</font></td>
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
    <td height="20"></td>
    <td>Publisher</td>
    <td><%=WI.getStrValue(vRetResult.elementAt(8))%></td>
  </tr>
  <tr>
    <td height="20"></td>
    <td>Place of Publication </td>
    <td><%=WI.getStrValue(vRetResult.elementAt(9))%></td>
  </tr>
  <tr>
    <td height="20"></td>
    <td>Description</td>
    <td><%=WI.getStrValue(vRetResult.elementAt(10))%></td>
  </tr>
  <tr>
    <td height="20"></td>
    <td>ISBN</td>
    <td><%=WI.getStrValue(vRetResult.elementAt(11))%></td>
  </tr>
  <%if(!bolIsCIT){%>
  <tr>
    <td height="20"></td>
    <td>Price</td>
    <td><%=WI.getStrValue(vRetResult.elementAt(12))%></td>
  </tr>
  <%}%>
  	<tr>
		<td height="20"></td>
		<td>Web URL</td>
		<td><a target="_blank" href="<%=WI.getStrValue(vRetResult.elementAt(14))%>" title="<%=WI.getStrValue(vRetResult.elementAt(15))%>"><font color="#0000CC"><%=WI.getStrValue(vRetResult.elementAt(14))%></font></a></td>
	  </tr>
  
  <tr>
    <td height="20"></td>
    <td>Subject Heading </td>
    <td><table width="40%" cellpadding="0" cellspacing="0" class="thinborder">
      
      <%for (int i = 0; i < vSH.size(); i += 2) {%>
      <tr>
        <td height="20" class="thinborder">&nbsp;<%=vSH.elementAt(i + 1)%></td>
        </tr>
      <%}%>
    </table></td>
  </tr>
  <tr>
    <td height="10"></td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
  </tr>
  <tr>
    <td height="20"></td>
    <td>Added Entry  </td>
    <td><table width="40%" cellpadding="0" cellspacing="0" class="thinborder">
      <%for (int i = 0; i < vAuthor.size(); i += 1) {%>
      <tr>
        <td height="20" class="thinborder">&nbsp;<%=vAuthor.elementAt(i)%></td>
      </tr>
      <%}%>
    </table></td>
  </tr>
  <tr> 
    <td height="18" colspan="3">&nbsp;</td>
  </tr>
  <%if(strSchCode.startsWith("EAC") || bolUPHD || true){%>
  <tr>
    <td height="20"></td>
    <td valign="top">Added Description  </td>
    <td valign="top">
		<table width="80%" border="0" cellspacing="0" cellpadding="0">
		<tr> 
		  <td height="20" colspan="3" bgcolor="#DDDDEE"><font color="#FF0000">SERIES 
			STATEMENT/ADDED ENTRY--TITLE :</font></td>
		</tr>
		<tr> 
      
      <td class="thinborderTOPLEFTBOTTOM" height="20">Series</td>
      <td class="thinborderALL" height="20"><%=WI.getStrValue(vRetResult.elementAt(16),"&nbsp;")%></td>
    </tr>    <tr> 
     
      <td class="thinborder" height="20">Volume</td>
      <td class="thinborderLEFTRIGHTBOTTOM"><%=WI.getStrValue(vRetResult.elementAt(17),"&nbsp;")%></td>
    </tr>
		<tr> 
		  <td height="20" colspan="3" bgcolor="#DDDDEE"><font color="#FF0000">NOTE FIELDS :</font></td>
		</tr>
		<tr>       
      <td class="thinborderTOPLEFTBOTTOM" height="20">General</td>
      <td class="thinborderALL"><%=WI.getStrValue(vRetResult.elementAt(18),"&nbsp;")%></td>
		</tr>
	
	<%if(!bolIsCIT){%>
	<tr>    
      <td class="thinborder" height="20">Summary</td>
      <td class="thinborderLEFTRIGHTBOTTOM"><%=WI.getStrValue(vRetResult.elementAt(19),"&nbsp;")%></td>
    </tr>
	<%}
	if(bolIsCIT){%>
	<tr>    
      <td class="thinborder" height="20">Dissertation</td>
      <td class="thinborderLEFTRIGHTBOTTOM"><%=WI.getStrValue(vRetResult.elementAt(25),"&nbsp;")%></td>
    </tr>
	<tr>    
      <td class="thinborder" height="20">Bibliography</td>
      <td class="thinborderLEFTRIGHTBOTTOM"><%=WI.getStrValue(vRetResult.elementAt(26),"&nbsp;")%></td>
    </tr>
	<tr>    
      <td class="thinborder" height="20">Contents</td>
      <td class="thinborderLEFTRIGHTBOTTOM"><%=WI.getStrValue(vRetResult.elementAt(27),"&nbsp;")%></td>
    </tr>
	<tr>    
      <td class="thinborder" height="20">Scale</td>
      <td class="thinborderLEFTRIGHTBOTTOM"><%=WI.getStrValue(vRetResult.elementAt(28),"&nbsp;")%></td>
    </tr>
	<tr>    
      <td class="thinborder" height="20">Creation</td>
      <td class="thinborderLEFTRIGHTBOTTOM"><%=WI.getStrValue(vRetResult.elementAt(29),"&nbsp;")%></td>
    </tr>
	<tr>    
      <td class="thinborder" height="20">Summary</td>
      <td class="thinborderLEFTRIGHTBOTTOM"><%=WI.getStrValue(vRetResult.elementAt(19),"&nbsp;")%></td>
    </tr>
	<tr>    
      <td class="thinborder" height="20">Production</td>
      <td class="thinborderLEFTRIGHTBOTTOM"><%=WI.getStrValue(vRetResult.elementAt(30),"&nbsp;")%></td>
    </tr>
	<tr>    
      <td class="thinborder" height="20">System Details</td>
      <td class="thinborderLEFTRIGHTBOTTOM"><%=WI.getStrValue(vRetResult.elementAt(31),"&nbsp;")%></td>
    </tr>
	<tr>    
      <td class="thinborder" height="20">Language</td>
      <td class="thinborderLEFTRIGHTBOTTOM"><%=WI.getStrValue(vRetResult.elementAt(32),"&nbsp;")%></td>
    </tr>
	<tr>    
      <td class="thinborder" height="20">Local</td>
      <td class="thinborderLEFTRIGHTBOTTOM"><%=WI.getStrValue(vRetResult.elementAt(33),"&nbsp;")%></td>
    </tr>
	<%}%>
	
    <tr bgcolor="#DDDDEE">      
      <td height="20" colspan="2"><font color="#FF0000">TARGET AUDIENCE NOTE:</font></td>
    </tr>
    <tr>     
      <td class="thinborderTOPLEFTBOTTOM" height="20" width="41%">Reading Grade Level</td>
      <td class="thinborderALL" width="59%"><%=WI.getStrValue(vRetResult.elementAt(20),"&nbsp;")%></td>
    </tr>
    <tr> 
     
      <td class="thinborder" height="20">Interest Age Level</td>
      <td class="thinborderLEFTRIGHTBOTTOM"><%=WI.getStrValue(vRetResult.elementAt(21),"&nbsp;")%></td>
    </tr>
    <tr>      
      <td class="thinborder" height="20">Interest Grade Level</td>
      <td class="thinborderLEFTRIGHTBOTTOM"><%=WI.getStrValue(vRetResult.elementAt(22),"&nbsp;")%></td>
    </tr>
    <tr> 
      <td class="thinborder" height="20">Special Audience Characteristics</td>
      <td class="thinborderLEFTRIGHTBOTTOM"><%=WI.getStrValue(vRetResult.elementAt(23),"&nbsp;")%></td>
    </tr>
    <tr>
      <td class="thinborder" height="20">Motivation Interest Level</td>
      <td class="thinborderLEFTRIGHTBOTTOM"><%=WI.getStrValue(vRetResult.elementAt(24),"&nbsp;")%></td>
    </tr>
   
  </table>
	</td>
  </tr>
 <%}%>
  <tr> 
    <td height="18" colspan="3">&nbsp;</td>
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