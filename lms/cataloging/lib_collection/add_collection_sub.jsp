<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Faculty Reference Page</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="javascript" src="../../../jscript/common.js"></script>
<script language="JavaScript">
function Cancel() {
	document.form_.info_index.value = "";
	document.form_.page_action.value = "";
	this.SubmitOnce('form_');
}
function PageAction(strAction, strInfoIndex) {
	if(strInfoIndex.length > 0) 
		document.form_.info_index.value = strInfoIndex;
	document.form_.page_action.value = strAction;
	this.SubmitOnce('form_');
}

</script>
<body bgcolor="#F2DFD2">
<%@ page language="java" import="utility.*,lms.CatalogLibCol,java.util.Vector " %>
<%
	DBOperation dbOP = null;
	Vector vBookInfo = null;
	WebInterface WI = new WebInterface(request);
	
	String strErrMsg = null;
	String strTemp = null;
	

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"LIB_Cataloging-LIBRARY COLLECTION","add_collection_sub.jsp");
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
														"add_collection_sub.jsp");
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

Vector vRetResult = new Vector();

String strPageAction= WI.fillTextValue("page_action");

CatalogLibCol clc = new CatalogLibCol();
String strSubCode = WI.fillTextValue("sub_code");
String strBookIndex = dbOP.mapBookIDToBookIndex(WI.fillTextValue("accession_number"));
if(strBookIndex != null)
	vBookInfo = clc.viewBasicEntry(dbOP, strBookIndex);
else	
	strErrMsg = "Book information not found for accession number : "+WI.fillTextValue("accession_number");

if(vBookInfo != null && vBookInfo.size() > 0) {
	strTemp = WI.fillTextValue("page_action");
		if(strTemp.length() > 0) {
			if(clc.operateOnAddSub(dbOP, request, Integer.parseInt(strTemp)) != null )
				strErrMsg = "Operation successful.";
			else
				strErrMsg = clc.getErrMsg();
	}

	vRetResult = clc.operateOnAddSub(dbOP, request, 4);
}
%>
<form name="form_" method="post" action="./add_collection_sub.jsp">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A8A8D5">
      <td height="25" colspan="2" bgcolor="#A8A8D5"><div align="center"><font color="#FFFFFF"><strong>::::
          CATALOGING - LIBRARY COLLECTION- ASSIGN SUBJECT PAGE ::::</strong></font></div></td>
    </tr>
  </table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr> 
      <td width="100%" height="25"> 
		<strong>&nbsp;<%=WI.getStrValue(strErrMsg)%></strong></td>
    </tr>
  </table>
<%if(vBookInfo != null && vBookInfo.size() > 0) {%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
   <tr bgcolor="#DDDDEE"> 
      <td height="20" colspan="5" class="thinborderALL"><font color="#FF0000"><strong>&nbsp;&nbsp;&nbsp;BOOK 
        INFORMATION : </strong></font></td>
    </tr>
    <tr> 
      <td width="2%" height="25">&nbsp;</td>
      <td width="20%">Accession Number</td>
      <td width="24%"> &nbsp;<%=WI.fillTextValue("accession_number")%></td>
      <td width="19%">Barcode Number</td>
      <td width="35%">&nbsp;<%=(String)vBookInfo.elementAt(36)%></td>
    </tr>
    <tr > 
      <td height="25">&nbsp;</td>  
      <td>Title</td>
      <td>&nbsp;<%=(String)vBookInfo.elementAt(1)%></td>
      <td>Subtitle</td>
      <td>&nbsp;<%=WI.getStrValue((String)vBookInfo.elementAt(2),"")%></td>
    </tr>
    <tr > 
      <td height="24">&nbsp;</td>
      <td>Author</td>
      <td colspan="3">&nbsp;<%=WI.getStrValue((String)vBookInfo.elementAt(11),"")%></td>
     </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
      <tr>
      	<td height="25"></td>
      	<td height="25" colspan="5">&nbsp;&nbsp;Filter Subject 
      		<input type="text" name="filter_sub" value='<%=WI.fillTextValue("filter_sub")%>' class="textbox" 
			onKeyUp="AutoScrollListSubject('filter_sub','sub_code',true,'form_');">
      	</td>
      </tr>
      <tr>
      <td height="25">&nbsp;</td>
      <td height="25" colspan="5">&nbsp;&nbsp;Subject Code : 
        <select name="sub_code">
         <% if (WI.fillTextValue("sub_group").length()!=0){ %>
          <%=dbOP.loadCombo("sub_index","sub_code+'&nbsp;'+sub_name as sub_list"," from subject where IS_DEL=0 order by sub_list asc", strSubCode, false)%> 
          <%}else{%>
          <%=dbOP.loadCombo("sub_index","sub_code+'&nbsp;&nbsp; ('+sub_name+')' as sub_list"," from subject where IS_DEL=0 order by sub_list asc", strSubCode, false)%> 
          <%}%>
        </select></td>
    </tr>
    <tr> 
      <td height="39">&nbsp;</td>
      <td height="39" colspan="2">
	  <font size="1">&nbsp;&nbsp;<a href='javascript:PageAction(1,"");'><img src="../../images/save_recommend.gif" border="0" name="hide_save"></a> 
	  Click to save entries</font></td>
    </tr>
  </table>
<% 
if (vRetResult != null && vRetResult.size()>0){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#B9B292"> 
      <td height="25" colspan="2" bgcolor="#A8A8D5"><div align="center">LIST OF 
          ASSIGNED SUBJECTS FOR BOOK: <strong><%=(String)vBookInfo.elementAt(1)%></strong> </div></td>
    </tr>
   
  </table>
  <table width="100%" border="0" cellspacing="0" cellpadding="0" class="thinborder">
    <tr> 
      <td width="86%" height="25" class="thinborder"><div align="center"><strong><font size="1">SUBJECT 
          CODE ::: SUBJECT TITLE</font></strong></div></td>
      <td width="14%" class="thinborder"><div align="center"><strong><font size="1">OPTION</font></strong></div></td>
    </tr>
    <%
for (int i = 0; i< vRetResult.size() ; i+=3) {%>
    <tr> 
      <td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+1)%> ::: <%=(String)vRetResult.elementAt(i+2)%></td>
      <td class="thinborder"><div align="center"><a href='javascript:PageAction("0","<%=(String)vRetResult.elementAt(i)%>")'><img src="../../../images/delete.gif" border="1"></a></div></td>
    </tr>
    <%} // end for loop
}%>
  </table>
<%}//if vBookInfo is not null%>  
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <td width="12%"></tr>
    <tr>
      <td width="84%">&nbsp;</td>
      <td width="16%" height="25">&nbsp; </td>
    </tr>
    <tr bgcolor="#B8CDD1">
      <td height="25" colspan="8" bgcolor="#A8A8D5">&nbsp;</td>
    </tr>
  </table>
  <input type="hidden" name="page_action">
  <input type="hidden" name="info_index">
  <input type="hidden" name="accession_number" value="<%=WI.fillTextValue("accession_number")%>">
<!-- add in pages with subject scroll -->
<%=dbOP.constructAutoScrollHiddenField()%>

  </form>
</body>
</html>
<%
dbOP.cleanUP();
%>
