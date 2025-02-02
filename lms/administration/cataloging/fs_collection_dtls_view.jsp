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
function PrintPg() {

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
								"lms-Administration-CATALOGING","fs_collection_dtls_view.jsp");
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
														"fs_collection_dtls_view.jsp");
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
	MgmtCatalog mgmtCatalog = new MgmtCatalog();
	Vector vRetResult = null;
	Vector vFSInfo    = null;//Funding source information, -> code, name and status.
	
	request.setAttribute("funding_source_index",WI.fillTextValue("funding_source_index"));
	vFSInfo = mgmtCatalog.operateOnFSProfile(dbOP, request,3);
	if(vFSInfo == null)
		strErrMsg = mgmtCatalog.getErrMsg();


int iSearchResult = 0;
if(vFSInfo != null && vFSInfo.size() > 0){
	vRetResult = mgmtCatalog.getFSBookColletionDtls(dbOP, request);	
	if(vRetResult == null && strErrMsg == null) 
		strErrMsg = mgmtCatalog.getErrMsg();
	else	
		iSearchResult = mgmtCatalog.getSearchCount();	
}//only if vFSInfo is not null.
%>
<body bgcolor="#DEC9CC">
<form name="form_" method="post" action="./fs_collection_dtls_view.jsp">
  <table width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr bgcolor="#A8A8D5"> 
      <td height="25" colspan="8" bgcolor="#A8A8D5"><div align="center"><font color="#FFFFFF" ><strong>:::: 
          CATALOGING MANAGEMENT - FUNDING SOURCE - DETAILS OF COLLECTIONS BY FUNDING 
          SOURCE PAGE ::::</strong></font></div></td>
    </tr>
	</table>
	  
  <table width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr > 
      <td height="25"><font size="3" color="#FF0000">&nbsp;&nbsp;&nbsp;<%=WI.getStrValue(strErrMsg)%></font></td>
    </tr>
  </table>
<%
//outmost loop
if(vFSInfo != null && vFSInfo.size() > 0){
	String[] astrFSStat = {"In-active","Active"};
%>
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
      <td height="25" colspan="2"><font size="1"><strong><%=(String)vFSInfo.elementAt(2)%></strong></font
        ></td>
    </tr>
    <tr > 
      <td height="15" colspan="4"><hr size="1"></td>
    </tr>
  </table>
<%
if(vRetResult != null && vRetResult.size() > 0){%>
  <table width="100%" cellpadding="0" cellspacing="0" class="thinborder">
    <tr> 
      <td height="25" colspan="6" bgcolor="#DDDDEE" class="thinborder"><div align="center">LISTS 
          OF LIBRARY COLLECTIONS 
<%
	strTemp = null;
	if(WI.fillTextValue("mat_type_index").length() > 0)
		strTemp = dbOP.mapOneToOther("LMS_MAT_TYPE", "MATERIAL_TYPE_INDEX", WI.fillTextValue("mat_type_index"), "MATERIAL_TYPE",null);
	if(strTemp != null) {%>
		  UNDER MATERIAL TYPE : <strong><%=strTemp%></strong></div></td>
<%}%>
    </tr>
</table>
  <table width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="10">&nbsp;</td>
      <td align="right"><a href="javascript:PrintPg();"><img src="../../images/print.gif" border="0"></a> 
        <font size="1">click to print result</font></td>
    </tr>
    <tr> 
      <td width="66%" ><b> Total Result : <%=iSearchResult%> - Showing(<%=mgmtCatalog.getDisplayRange()%>)</b></td>
      <td width="34%"> <%
	  //if more than one page , constuct page count list here.  - 20 default display per page
		int iPageCount = iSearchResult/mgmtCatalog.defSearchSize;
		if(iSearchResult % mgmtCatalog.defSearchSize > 0) ++iPageCount;

		if(iPageCount > 1)
		{%> <div align="right">Jump To page: 
          <select name="jumpto" onChange="SearchStudent();">
            <%
			strTemp = request.getParameter("jumpto");
			if(strTemp == null || strTemp.trim().length() ==0) strTemp = "0";

			for( int i =1; i<= iPageCount; ++i )
			{
				if(i == Integer.parseInt(strTemp) ){%>
            <option selected value="<%=i%>"><%=i%> of <%=iPageCount%></option>
            <%}else{%>
            <option value="<%=i%>"><%=i%> of <%=iPageCount%></option>
            <%
					}
			}
			%>
          </select>
          <%}%>
        </div></td>
    </tr>
  </table>
  <table width="100%" border="0" cellspacing="0" cellpadding="0" class="thinborder">
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
<%for(int i = 0; i < vRetResult.size(); i += 9){%>
    <tr> 
      <td height="25" class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i + 2)%></td>
      <td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i + 3)%></td>
      <td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i + 4)%></td>
      <td class="thinborder">&nbsp;<%=WI.getStrValue(vRetResult.elementAt(i + 5))%>/<%=(String)vRetResult.elementAt(i + 6)%></td>
      <td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i + 7)%></td>
      <td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i + 8)%></td>
    </tr>
<%}%>
  </table>
<%}//only if vRetResult.size () > 0
}//only if funding sourse information exists.
%>
<input type="hidden" name="funding_source_index" value="<%=WI.fillTextValue("funding_source_index")%>">
<input type="hidden" name="mat_type_index" value="<%=WI.fillTextValue("mat_type_index")%>">

</form>
	
</body>
</html>
<%
dbOP.cleanUP();
%>