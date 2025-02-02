<%@ page language="java" import="utility.*,lms.CatalogAuthorCode,java.util.Vector" %>
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	
	String strFormName = null;
	java.util.StringTokenizer strToken = new java.util.StringTokenizer(WI.fillTextValue("opner_info"),".");
	if(strToken.hasMoreElements()) {
		strFormName = strToken.nextToken();
	
	}
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../css/tableBorder.css" rel="stylesheet" type="text/css">
<link href="../../../css/reportlink.css" rel="stylesheet" type="text/css">
</head>

<script language="JavaScript">
//called for add or edit.
function PageAction(strAction, strInfoIndex) {
	document.form_.page_action.value = strAction;
	if(strInfoIndex.length > 0)
		document.form_.info_index.value = strInfoIndex;
	if(strAction == 1) 
		document.form_.hide_save.src = "../../../images/blank.gif";
	document.form_.submit();
}
function PrepareToEdit(strInfoIndex) {
	document.form_.page_action.value = "";
	document.form_.prepareToEdit.value = "1";
	document.form_.info_index.value = strInfoIndex;
	document.form_.submit();
}
function SearchResult()
{
	document.form_.page_action.value = "";
	document.form_.print_pg.value = "";
	document.form_.submit();
}
function FocusAC() {
<%if(WI.fillTextValue("search_only").length() == 0) {%>
	document.form_.author.focus();
<%}%>
}
<%
if(WI.fillTextValue("opner_info").length() > 0){%>
function CopyID(strStudID)
{
	window.opener.document.<%=WI.fillTextValue("opner_info")%>.value=strStudID;
	window.opener.focus();
	<%
	if(strFormName != null){%>
	//window.opener.document.<%=strFormName%>.submit();
	<%}%>
	
	self.close();
}
<%}%>
</script>

<%
	String strErrMsg = null;
	String strTemp   = null;
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"LIB_Cataloging-author code","ac.jsp");
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
														"LIB_Cataloging","Manage author code",request.getRemoteAddr(),
														"ac.jsp");
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
	String strPrepareToEdit = WI.getStrValue(WI.fillTextValue("prepareToEdit"),"0");

	CatalogAuthorCode ctlgAC = new CatalogAuthorCode(request);
	Vector vEditInfo  = null;Vector vRetResult = null;

	strTemp = WI.fillTextValue("page_action");
	if(strTemp.length() > 0) {
		if(ctlgAC.operateOnAuthorCode(dbOP, request, Integer.parseInt(strTemp)) == null)
			strErrMsg = ctlgAC.getErrMsg();
		else {
			if(strTemp.compareTo("0") == 0)
				strErrMsg = "Author code information successfully removed.";
			if(strTemp.compareTo("1") == 0)
				strErrMsg = "Author code information successfully added.";
			if(strTemp.compareTo("2") == 0)
				strErrMsg = "Author code information successfully edited.";

			strPrepareToEdit = "0";
		}
	}

	
	//get vEditInfoIf it is called.
	if(strPrepareToEdit.compareTo("1") == 0) {
		vEditInfo = ctlgAC.operateOnAuthorCode(dbOP, request,3);
		if(vEditInfo == null)
			strErrMsg = ctlgAC.getErrMsg();
	}


String[] astrDropListEqual = {"Starts with","Equal to","Ends with","Contains"};
String[] astrDropListValEqual = {"starts","equals","ends","contains"};
String[] astrSortByName    = {"Alphabet","Order No."};
String[] astrSortByVal     = {"author","author_code"};

int iSearchResult = 0;

//if(WI.fillTextValue("search_info").length() > 0){
	vRetResult = ctlgAC.searchAC(dbOP, request);
	if(vRetResult == null)
		strErrMsg = ctlgAC.getErrMsg();
	else	
		iSearchResult = ctlgAC.getSearchCount();
//}
%>

<body bgcolor="#DEC9CC" onLoad="FocusAC();">
<form action="./ac.jsp" method="post" name="form_">
<%
if(WI.fillTextValue("search_only").length() == 0) {%>

  <table width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr bgcolor="#A8A8D5"> 
      <td height="25" colspan="8" bgcolor="#A8A8D5"><div align="center"><font color="#FFFFFF" ><strong>:::: 
          AUTHOR CODE MANAGEMENT PAGE ::::</strong></font></div></td>
    </tr>
	</table>
	  
  <table width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25" colspan="3">&nbsp;&nbsp;&nbsp;<font size="3" color="#FF0000"><strong> 
        <%=WI.getStrValue(strErrMsg,"Message : ","","")%></strong></font></td>
    </tr>
    <tr> 
      <td width="4%" height="25">&nbsp;</td>
      <td>Three figure Alphabet</td>
      <td width="77%"> 
<%
if(vEditInfo != null && vEditInfo.size() > 0) 
	strTemp = (String)vEditInfo.elementAt(1);
else	
	strTemp = WI.fillTextValue("author");
%> <input type="text" name="author" size="16" maxlength="16" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'" value="<%=strTemp%>"></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Order Number.</td>
      <td> <%
if(vEditInfo != null && vEditInfo.size() > 0) 
	strTemp = (String)vEditInfo.elementAt(2);
else	
	strTemp = WI.fillTextValue("author_code");
%> <input type="text" name="author_code" size="12" maxlength="12" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'" value="<%=strTemp%>"></td>
    </tr>
    <%
if(iAccessLevel > 1) {%>
    <tr> 
      <td height="38">&nbsp;</td>
      <td width="19%"><font color="#FF0000">&nbsp;</font></td>
      <td><font size="1"> 
        <%if(strPrepareToEdit.compareTo("1") != 0) {%>
        <a href='javascript:PageAction(1,"");'><img src="../../images/save.gif" border="0" name="hide_save"></a> 
        Click to save entries 
        <%}else{%>
        <a href='javascript:PageAction(2, "");'><img src="../../images/edit.gif" border="0"></a> 
        Click to edit event 
        <%}%>
        <a href="./ac.jsp"><img src="../../images/cancel.gif" border="0"></a> 
        Click to clear entries </font></td>
    </tr>
    <%}%>
  </table>
<%}//do not show if search_only is called.%>  
  <table width="100%" cellspacing="0" cellpadding="0" class="thinborder">
    <tr bgcolor="#DDDDEE"> 
      <td height="26" colspan="3" class="thinborder"> <div align="center"><font color="#FF0000"><strong>::: 
          SEARCH CONDITION :::</strong></font></div></td>
    </tr>
    <tr> 
      <td width="32%" height="25" class="thinborder"><div align="center"><strong><font size="1">THREE 
          FIGURE ALPHABET</font></strong></div></td>
      <td width="34%" class="thinborder"><div align="center"><strong><font size="1">ORDER 
          NUMBER </font></strong></div></td>
      <td width="34%" class="thinborder"><div align="center"><strong><font size="1">SORT 
          RESULT </font></strong></div></td>
    </tr>
    <tr> 
      <td height="25" class="thinborder"><select name="author_con">
          <%=ctlgAC.constructGenericDropList(WI.fillTextValue("author_con"),astrDropListEqual,astrDropListValEqual)%> </select> 
		  <input type="text" name="author_s" value="<%=WI.fillTextValue("author_s")%>" 
		class="textbox" onfocus="style.backgroundColor='#D3EBFF'" 
		onblur="style.backgroundColor='white'" size="12"></td>
      <td class="thinborder"><select name="author_code_con">
          <%=ctlgAC.constructGenericDropList(WI.fillTextValue("author_code_con"),astrDropListEqual,astrDropListValEqual)%> </select> 
		  <input type="text" name="author_code_s" value="<%=WI.fillTextValue("author_code_s")%>" 
		class="textbox" onfocus="style.backgroundColor='#D3EBFF'" 
		onblur="style.backgroundColor='white'" size="12"></td>
      <td class="thinborder"><div align="center">
          <select name="sort_by1">
            <option value="">N/A</option>
            <%=ctlgAC.constructSortByDropList(WI.fillTextValue("sort_by1"),astrSortByName,astrSortByVal)%> 
          </select>
          <select name="sort_by1_con">
            <option value="asc">Ascending</option>
            <%
if(WI.fillTextValue("sort_by1_con").compareTo("desc") ==0){%>
            <option value="desc" selected>Descending</option>
            <%}else{%>
            <option value="desc">Descending</option>
            <%}%>
          </select>
        </div></td>
    </tr>
    <tr>
      <td height="43" class="thinborder">&nbsp;</td>
      <td class="thinborder" valign="bottom"><font size="1"><a href="javascript:SearchResult();"><img src="../../../images/refresh.gif" border="1"></a> 
        Click to search</font></td>
      <td class="thinborder">&nbsp;</td>
    </tr>
  </table>
  <br>
<%if(vRetResult != null && vRetResult.size() > 0) {%>
  <table width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25"><%
	  if(WI.fillTextValue("opner_info").length() > 0){%>
	  NOTE : Please click ID number to copy ID to form it is called from.
	  <%}%></td>
      <td height="25" align="right">
	  <!--<a href="javascript:PrintPg();"><img src="../../images/print.gif" border="0"></a> 
        <font size="1">click to print result</font>--></td>
    </tr>
    <tr> 
      <td width="66%" ><b> Total Result: <%=iSearchResult%> - Showing(<%=ctlgAC.getDisplayRange()%>)</b></td>
      <td width="34%"> <%
	  //if more than one page , constuct page count list here.  - 20 default display per page)
		int iPageCount = iSearchResult/ctlgAC.defSearchSize;
		if(iSearchResult % ctlgAC.defSearchSize > 0) ++iPageCount;

		if(iPageCount > 1)
		{%> <div align="right">Jump To page: 
          <select name="jumpto" onChange="SearchResult();">
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
  <table width="100%" cellspacing="0" cellpadding="0" class="thinborder">
    <tr bgcolor="#DDDDEE"> 
      <td height="26" colspan="3" class="thinborder"> <div align="center"><font color="#FF0000"><strong>::: 
          LIST OF AUTHOR CODE :::</strong></font></div></td>
    </tr>
    <tr> 
      <td width="31%" height="25" class="thinborder"><div align="center"><strong><font size="1">THREE 
          FIGURE ALPHABET</font></strong></div></td>
      <td width="45%" class="thinborder"><div align="center"><strong><font size="1">ORDER 
          NUMBER </font></strong></div></td>
<%
if(WI.fillTextValue("search_only").length() == 0) {%>
      <td width="24%" class="thinborder" align="center"><strong><font size="1">OPERATION</font></strong></td>
<%}%>
    </tr>
    <%
for(int i = 0; i < vRetResult.size(); i += 3){%>
    <tr> 
      <td height="25" class="thinborder">&nbsp;<font size="1">
        <%
		if(WI.fillTextValue("opner_info").length() > 0) {%>
        <a href='javascript:CopyID("<%=(String)vRetResult.elementAt(i+1)%><%=(String)vRetResult.elementAt(i + 2)%>");'> 
        <%=(String)vRetResult.elementAt(i+1)%></a> 
        <%}else{%>
        <%=(String)vRetResult.elementAt(i+1)%> 
        <%}%>
        </font></td>
      <td class="thinborder"><font size="1">&nbsp;<%=(String)vRetResult.elementAt(i + 2)%></font></td>
<%
if(WI.fillTextValue("search_only").length() == 0) {//do not show edit / delete if search only is called.%>
      <td class="thinborder"><font size="1">&nbsp; 
        <%
if(iAccessLevel > 1){%>
        <a href='javascript:PrepareToEdit("<%=(String)vRetResult.elementAt(i)%>");'><img src="../../images/edit.gif" width="53" height="28" border="0"></a> 
        <%}if(iAccessLevel == 2){%>
        <a href='javascript:PageAction("0","<%=(String)vRetResult.elementAt(i)%>");'><img src="../../images/delete.gif" width="53" height="26" border="0"></a> 
        <%}%>
        </font></td>
<%}//end of WI.fillTextValue("search_only")%>		
    </tr>
    <%}//end of for loop.%>
  </table>
<%}//end of vRetResult%>
<input type="hidden" name="page_action">
<input type="hidden" name="info_index" value="<%=WI.fillTextValue("info_index")%>">
<input type="hidden" name="prepareToEdit" value="<%=strPrepareToEdit%>">

<input type="hidden" name="search_info" value="1">
<input type="hidden" name="print_pg">
<!-- Instruction -- set the opner_info = > form_.author to the parent window to copy the student ID -->
<input type="hidden" name="opner_info" value="<%=WI.fillTextValue("opner_info")%>">

<input type="hidden" name="search_only" value="<%=WI.fillTextValue("search_only")%>">

</form>
	
</body>
</html>
<%
dbOP.cleanUP();
%>