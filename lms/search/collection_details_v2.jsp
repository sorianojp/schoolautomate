<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../css/tableBorder.css" rel="stylesheet" type="text/css">
<link href="../../css/tabStyle.css" rel="stylesheet" type="text/css">
</head>
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

Vector vRetResult = null;
Vector vI  = null;//Book copy/issue info.
Vector vBI = null;//Basic information.
Vector vAD = null;//Added Description.
Vector vSH = null;//Subject heading.
Vector vAE = null;//Added entries

LmsUtil lUtil     = new LmsUtil();
vRetResult = lUtil.getDetailedBookInfo(dbOP, WI.fillTextValue("accession_no"),request);
if(vRetResult == null || vRetResult.size() == 0) 
	strErrMsg = lUtil.getErrMsg();
else {
	vI  = (Vector)vRetResult.elementAt(0);//System.out.println(vI);
	vBI = (Vector)vRetResult.elementAt(1);
	vAD = (Vector)vRetResult.elementAt(2);
	vSH = (Vector)vRetResult.elementAt(3);
	vAE = (Vector)vRetResult.elementAt(4);
}
%>

<body bgcolor="#F2DFD2">
  <table width="100%" border="0" cellspacing="0" cellpadding="0">
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
    
	<td background="../../images/tableft.gif" height="24" width="10">&nbsp;</td>	
    <td width="140" bgcolor="#00468C" align="center"><a href="collection_details.jsp?accession_no=<%=WI.fillTextValue("accession_no")%>">Detailed Description</a></td>    
	<td background="../../images/tabright.gif" width="10">&nbsp;</td>
	
	<td background="../../images/tableft_selected.gif" height="24" width="10">&nbsp;</td>    
	<td width="150" bgcolor="#A9B9D1" align="center"  class="tabFont">Detailed Description(v2)</td>    
	<td background="../../images/tabright_selected.gif" width="10">&nbsp;</td>
	
	<td background="../../images/tableft_selected.gif" height="24" width="10">&nbsp;</td>    
	<td width="150" bgcolor="#A9B9D1" align="center"  class="tabFont">Bibliographic Format</td>    
	<td background="../../images/tabright_selected.gif" width="10">&nbsp;</td>
	
  </tr>
</table>
	  
<%if(strErrMsg == null) {%>  
<table cellpadding="0" cellspacing="0" width="100%" border="0">
  <tr> 
    <td height="30"><strong>NO OF COPY :<%=(String)vI.elementAt(0)%> &nbsp;BOOK STATUS :<%=(String)vI.elementAt(1)%> 
      <%if(vI.elementAt(2) != null) {%>
      &nbsp;ISSUED TO : <%=(String)vI.elementAt(2)%>&nbsp;RETURN DATE/TIME : <%=(String)vI.elementAt(3)%>
      <%}%>
      </strong> </td>
  </tr>
</table>
<table cellpadding="0" cellspacing="0" class="thinborderALL" width="100%">
  <tr bgcolor="#DDDDEE"> 
    <td height="20" colspan="3" class="thinborderBOTTOM"><font color="#FF0000">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;::: 
      COLLECTION BASIC ENTRY :::</font></td>
  </tr>
  <tr> 
    <td width="1%" height="20"></td>
    <td width="18%">Accession:::Barcode</td>
    <td width="81%"><strong><%=WI.fillTextValue("accession_no")%> ::: <%=(String)vBI.elementAt(36)%></strong></td>
  </tr>
  <tr> 
    <td height="20"></td>
    <td>Title:::Sub-Title</td>
    <td><%=(String)vBI.elementAt(1)%> <%=WI.getStrValue((String)vBI.elementAt(2),"::: ","","")%></td>
  </tr>
  <tr> 
    <td height="20"></td>
    <td>Responsibilty</td>
    <td><%=WI.getStrValue((String)vBI.elementAt(3))%></td>
  </tr>
  <tr> 
    <td height="20"></td>
    <td>Version</td>
    <td><%=WI.getStrValue((String)vBI.elementAt(4))%></td>
  </tr>
  <tr> 
    <td height="19" colspan="3"><hr size="1"></td>
  </tr>
  <tr> 
    <td height="20"></td>
    <td>Edition:::Sub-edition</td>
    <td><%=WI.getStrValue(vBI.elementAt(5))%> <%=WI.getStrValue((String)vBI.elementAt(6),"::: ","","")%></td>
  </tr>
  <tr> 
    <td height="10"></td>
    <td></td>
    <td></td>
  </tr>
  <tr> 
    <td height="20"></td>
    <td colspan="2">LCCN : <%=WI.getStrValue((String)vBI.elementAt(7),"&nbsp;&nbsp;-&nbsp;&nbsp;")%> &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;ISBN: 
      <%if(vBI.elementAt(8) != null && ((String)vBI.elementAt(8)).compareTo("0") != 0) {%>
	  <%=(String)vBI.elementAt(8)%>
	  <%}else{%> - <%}%> &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;ISSN: 
      <%=WI.getStrValue((String)vBI.elementAt(9),"&nbsp;&nbsp;-&nbsp;&nbsp;")%></td>
  </tr>
  <tr> 
    <td height="18" colspan="3"><hr size="1"></td>
  </tr>
  <tr> 
    <td height="20"></td>
    <td>Collection Type</td>
    <td><%=(String)vBI.elementAt(38)%></td>
  </tr>
  <tr> 
    <td height="10" colspan="3" align="center"><hr size="1"></td>
  </tr>
  <tr> 
    <td height="20"></td>
    <td>Author Name</td>
    <td><%=(String)vBI.elementAt(11)%></td>
  </tr>
  <tr> 
    <td height="20"></td>
    <td>Author Title</td>
    <td><%=WI.getStrValue(vBI.elementAt(13))%></td>
  </tr>
  <tr> 
    <td height="11" colspan="3"><hr size="1"></td>
  </tr>
  <tr> 
    <td height="20"></td>
    <td>Publication (Place :: Name:: Date published)</td>
    <td><%=WI.getStrValue((String)vBI.elementAt(17),"Not Set")%> :: <%=WI.getStrValue((String)vBI.elementAt(39),"Not Set")%> :: <%=WI.getStrValue((String)vBI.elementAt(16),"Not Set")%></td>
  </tr>
  <tr> 
    <td height="10"></td>
    <td></td>
    <td></td>
  </tr>
  <tr> 
    <td height="20"></td>
    <td>Material Type</td>
    <td><%=(String)vBI.elementAt(40)%></td>
  </tr>
  <tr> 
    <td height="20"></td>
    <td>Inclusion:::Size</td>
    <td><%=WI.getStrValue((String)vBI.elementAt(19),"Not Set")%> ::: <%=WI.getStrValue((String)vBI.elementAt(20),"Not Set")%></td>
  </tr>
  <tr> 
    <td height="20"></td>
    <td>Other Physical desc.</td>
    <td><%=WI.getStrValue((String)vBI.elementAt(21),"Not Set")%></td>
  </tr>
  <tr> 
    <td height="9" colspan="3"><hr size="1"></td>
  </tr>
  <tr> 
    <td height="20"></td>
    <td>Collection Loc</td>
    <td><%=(String)vBI.elementAt(41)%></td>
  </tr>
  <tr> 
    <td height="20"></td>
    <td>Book Loc Name</td>
    <td> <%=(String)vBI.elementAt(42)%> </td>
  </tr>
  <tr> 
    <td height="20"></td>
    <td>Circulation Type</td>
    <td> <%=(String)vBI.elementAt(43)%> <%=(String)vBI.elementAt(44)%> </td>
  </tr>
  <tr> 
    <td height="10" colspan="3"><hr size="1"></td>
  </tr>
  <!--
  <tr> 
    <td height="20"></td>
    <td>General Catg(DDC)</td>
    <td></td>
  </tr>
  <tr> 
    <td height="20"></td>
    <td>Sub-Catg (DDC)</td>
    <td></td>
  </tr>
  <tr> 
    <td height="20"></td>
    <td>Sub-Catg Entry</td>
    <td></td>
  </tr>
  <tr> 
    <td height="20"></td>
    <td>Sub-Catg Entry Class</td>
    <td></td>
  </tr>
  <tr> 
    <td height="10"></td>
    <td></td>
    <td></td>
  </tr>
-->
  <tr> 
    <td height="20"></td>
    <td colspan="2">Author Code: <%=(String)vBI.elementAt(29)%> &nbsp;&nbsp;&nbsp;&nbsp;Classification No. : <%=(String)vBI.elementAt(37)%> &nbsp;&nbsp;&nbsp;&nbsp;Call No.: <%=(String)vBI.elementAt(30)%> </td>
  </tr>
  <%if(vAD != null && vAD.size() > 0){%>
  <tr bgcolor="#DDDDEE"> 
    <td height="20" colspan="3" class="thinborderTOPBOTTOM"><font color="#FF0000">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;::: 
      ADDED DESCRIPTION :::</font></td>
  </tr>
  <tr> 
    <td height="20"></td>
    <td>Series:::Vol.</td>
    <td><%=WI.getStrValue((String)vAD.elementAt(1),"Not Set")%> ::: <%=WI.getStrValue((String)vAD.elementAt(2),"Not Set")%></td>
  </tr>
  <tr> 
    <td height="20"></td>
    <td>General</td>
    <td><%=WI.getStrValue((String)vAD.elementAt(3),"Not Set")%></td>
  </tr>
  <tr> 
    <td height="20"></td>
    <td>Summary</td>
    <td><%=WI.getStrValue((String)vAD.elementAt(4),"Not Set")%></td>
  </tr>
  <tr> 
    <td height="20"></td>
    <td>Reading Grade Level</td>
    <td><%=WI.getStrValue((String)vAD.elementAt(5),"Not Set")%></td>
  </tr>
  <tr> 
    <td height="20"></td>
    <td>Interest Age Level</td>
    <td><%=WI.getStrValue((String)vAD.elementAt(12),"Not Set")%></td>
  </tr>
  <tr> 
    <td height="20"></td>
    <td>Interest Grade level</td>
    <td><%=WI.getStrValue((String)vAD.elementAt(14),"Not Set")%></td>
  </tr>
  <tr> 
    <td height="20"></td>
    <td>Sp. Audiance characteristic</td>
    <td><%=WI.getStrValue((String)vAD.elementAt(8),"Not Set")%></td>
  </tr>
  <tr> 
    <td height="20"></td>
    <td>Motivation Interest Level</td>
    <td><%=WI.getStrValue((String)vAD.elementAt(13),"Not Set")%></td>
  </tr>
  <tr> 
    <td height="20"></td>
    <td>Web URL</td>
    <td><%=WI.getStrValue((String)vAD.elementAt(10),"Not Set")%></td>
  </tr>
  <tr> 
    <td height="20"></td>
    <td> Note(Desc.)</td>
    <td><%=WI.getStrValue((String)vAD.elementAt(11),"Not Set")%></td>
  </tr>
  <%}
if(vSH != null && vSH.size() > 0){%>
  <tr bgcolor="#DDDDEE"> 
    <td height="20" colspan="3" class="thinborderTOPBOTTOM"><font color="#FF0000">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;::: 
      SUBJECTS :::</font></td>
  </tr>
  <%for(int i =0; i < vSH.size(); i +=4 ){%>
  <tr> 
    <td height="20"></td>
    <td><%=(String)vSH.elementAt(i + 2)%></td>
    <td><%=(String)vSH.elementAt(i + 3)%></td>
  </tr>
  <%}//end of for loop.
}//end if vSH
if(vAE != null && vAE.size() > 0) {%>
  <tr bgcolor="#DDDDEE"> 
    <td height="20" colspan="3" class="thinborderTOPBOTTOM"><font color="#FF0000">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;::: 
      ADDED ENTRIES:::</font></td>
  </tr>
  <tr> 
    <td colspan="3" align="center"> <table width="95%" border="0" cellpadding="0" cellspacing="0" class="thinborder">
        <tr bgcolor="#cFcFcF"> 
          <td width="25%" height="20" class="thinborder"><div align="center"><font size="1"><strong> 
              NAME</strong></font></div></td>
          <td width="32%" class="thinborder"><div align="center"><font size="1"><strong>TITLE/RELATOR</strong></font></div></td>
          <td width="16%" class="thinborder"><div align="center"><font size="1"><strong>NUMERATION</strong></font></div></td>
          <td width="11%" class="thinborder"><div align="center"><font size="1"><strong>DATES</strong></font></div></td>
        </tr>
        <%
for(int i = 0; i < vAE.size(); i += 8){%>
        <tr> 
          <td height="20" class="thinborder">&nbsp;<%=(String)vAE.elementAt(i + 2)%></td>
          <td class="thinborder">&nbsp;<%=WI.getStrValue(vAE.elementAt(i + 4))%> <%=WI.getStrValue(vAE.elementAt(i + 6))%></td>
          <td class="thinborder">&nbsp;<%=WI.getStrValue(vAE.elementAt(i + 5))%></td>
          <td class="thinborder">&nbsp;<%=WI.getStrValue(vAE.elementAt(i + 3))%></td>
        </tr>
        <%}//for loop%>
      </table>
      <br> </td>
  </tr>
  <%}//end if vAE is not null.%>
</table>
<form>
<script src="../../jscript/td.js"></script>
<script language="JavaScript">
function PrintPg() {
	hideLayer('hide_');
	window.print();
}
</script>
<table width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr id="hide_">
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