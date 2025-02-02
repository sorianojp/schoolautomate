<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<%response.setHeader("Pragma","No-Cache");
response.setDateHeader("Expires",0);
response.setHeader("Cache-Control","no-Cache");
%>
</head>
<script language="JavaScript">
function PageAction(strAction,strBookIndex) {
	if(strAction == 0) {//call this for delete only.
		document.form_.page_action.value = "0";
		document.form_.info_index.value = strBookIndex;
		document.form_.submit();
	}else{//this is for edit. 
		this.EditCollection(strBookIndex);
	}
}
function EditCollection(strBookIndex) {
	//forward location.
	var loadPg = "./copy_information_edit.jsp?info_index="+strBookIndex;
	var win=window.open(loadPg,"myfile",'dependent=yes,width=1000,height=650,top=5,left=5,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function PringPg() {
	//I have to popup the same page.
	var loadPg = "./copy_information_view.jsp?copy_info_index="+document.form_.copy_info_index.value+"&print_pg=1";
	var win=window.open(loadPg,"myfile",'dependent=yes,width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
</script>
<body bgcolor="#F2DFD2">
<%@ page language="java" import="utility.*,lms.CatalogLibCol,java.util.Vector" %>
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp   = null;
	
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"LIB_Cataloging-LIBRARY COLLECTION","copy_information_view.jsp");
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
														"LIB_Cataloging","LIBRARY COLLECTION",request.getRemoteAddr(),
														"copy_information_view.jsp");
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

	CatalogLibCol ctlgLibCol = new CatalogLibCol();
	Vector vRetResult = null;
	
	strTemp = WI.fillTextValue("page_action");
	if(strTemp.length() > 0) {
		if(ctlgLibCol.operateOnBasicEntry(dbOP, request, Integer.parseInt(strTemp)) == null)
			strErrMsg = ctlgLibCol.getErrMsg();
		else {
			strErrMsg = "Collection entry information successfully removed.";
		}
	}

//get all copy information.
vRetResult = ctlgLibCol.getCopyDetail(dbOP, WI.fillTextValue("copy_info_index"));
if(vRetResult == null) 
	strErrMsg = ctlgLibCol.getErrMsg();

boolean bolIsPrintCalled = false;
if(WI.fillTextValue("print_pg").compareTo("1") == 0)
	bolIsPrintCalled = true;

%>

<form action="./copy_information_view.jsp" method="post" name="form_">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A"> 
      <td width="100%" height="25" bgcolor="#A8A8D5"><div align="center"><font color="#FFFFFF"><strong>:::: 
          CATALOGING - LIBRARY COLLECTION - COPY INFORMATION PAGE ::::</strong></font></div></td>
    </tr>
<%if(!bolIsPrintCalled){%>
    <tr valign="top" > 
      <td height="25"><font size="1">&nbsp;<a href="./add_collection_standard.jsp" target="_self"><img src="../../images/go_back_rec.gif" width="54" height="29" border="0"></a>&nbsp;&nbsp;<font size="3" color="#FF0000"><strong> 
        <%=WI.getStrValue(strErrMsg,"Message : ","","")%></strong></font></font></td>
    </tr>
<%}%>
  </table>
<%
if(vRetResult != null && vRetResult.size() > 0) {%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" class="thinborder">
    <tr> 
      <td  height="25" colspan="3" class="thinborder"><font size="1">TOTAL COPIES IN COLLECTION : 
        <strong><%=(vRetResult.size() - 1)/9%></strong></font></td>
      <td  height="25" colspan="3" class="thinborder"><font size="1">TOTAL COPIES AVAILABLE : <strong>
	  <%=(String)vRetResult.elementAt(0)%></strong></font></td>
    </tr>
    <tr> 
      <td width="9%" class="thinborder"><div align="center"><strong><font size="1">COL 
          IMAGE</font></strong></div></td>
      <td width="19%"  height="25" class="thinborder"><div align="center"><font size="1"><strong>CALL 
          NUMBER </strong></font></div></td>
      <td width="15%" class="thinborder"><div align="center"><font size="1"><strong>ACCESSION/BARCODE 
          NUMBER </strong></font></div></td>
      <td width="10%" class="thinborder"><div align="center"><strong><font size="1">STATUS</font></strong></div></td>
      <td width="31%" class="thinborder"><div align="center"><font size="1"><strong>DESCRIPTION</strong></font></div></td>
<%if(!bolIsPrintCalled){%>
      <td width="16%" class="thinborder"><div align="center"><font size="1"><strong>OPTIONS</strong></font></div></td>
<%}%>
    </tr>
<%
for(int i = 1; i < vRetResult.size(); i += 9){%>
    <tr> 
      <td class="thinborder" align="center">&nbsp;<img src="../../images/<%=(String)vRetResult.elementAt(i + 1)%>" border="1"></td>
      <td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i + 2)%></td>
      <td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i + 3)%> / <%=WI.getStrValue((String)vRetResult.elementAt(i + 4),"Barcode not set")%></td>
      <td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i + 5)%></td>
      <td class="thinborder">&nbsp;PD:<%=(String)vRetResult.elementAt(i + 8)%><br>
	  Series Name: <%=WI.getStrValue((String)vRetResult.elementAt(i + 6),"not defined")%>, 
	  Series Vol.: <%=WI.getStrValue((String)vRetResult.elementAt(i + 7),"not defined")%></td>
<%if(!bolIsPrintCalled){%>
      <td class="thinborder" align="center">
<%
if(iAccessLevel > 1){%>
	  <a href='javascript:PageAction("2","<%=(String)vRetResult.elementAt(i)%>");'><img src="../../images/edit_recommend.gif" border="0"></a>
<%if(iAccessLevel == 2) {%>
	  <a href='javascript:PageAction("0","<%=(String)vRetResult.elementAt(i)%>");'><img src="../../images/delete_recommend.gif" border="0"></a>
<%}
}%>
	  </td>
<%}//only if print is not called.
%>    </tr>
<%}%>
  </table>

<%if(!bolIsPrintCalled){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" >
    <tr> 
      <td height="51" colspan="8" valign="bottom"><div align="center"><font size="1">
	  <a href="javascript:PringPg();"><img src="../../images/print_recommend.gif" border="0"></a>click 
          to print copy list</font></div></td>
    </tr>
  </table>
 <%}//if print is not called. 
 
 }//if vRetResult is not null.%>
 
 <%if(bolIsPrintCalled){//call printl.%>
 <script language="JavaScript">
window.print();
window.setInterval("javascript:window.close();",0);
</script>
<%}%>

 
<input type="hidden" name="info_index">
<input type="hidden" name="page_action">
<input type="hidden" name="copy_info_index" value="<%=WI.fillTextValue("copy_info_index")%>">
<input type="hidden" name="print_pg">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>