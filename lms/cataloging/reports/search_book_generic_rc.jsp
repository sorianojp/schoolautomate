<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="javascript" src="../../../jscript/common.js"></script>
<script language="javascript">
function Search(strCol) {
	window.opener.document.form_.search_by.value = document.form_.search_by[document.form_.search_by.selectedIndex].value;
	
//	if(strCol == "1")
		document.form_.searchCollection.value = strCol;			
	
	document.form_.submit();
}
function setValue(strIsFromVal,strValue, strIndexVal) {
	var frIndex;
	var toIndex;
	if(strIsFromVal == "1") {
		document.form_.from_index.value = strIndexVal;
		window.opener.document.form_.input_fr.value = strValue;
		document.form_.from_index.value = strIndexVal;
	}
	else {	
		document.form_.to_index.value = strIndexVal;
		window.opener.document.form_.input_to.value = strValue;
		document.form_.to_index.value = strIndexVal;
	}
	
	frIndex = document.form_.from_index.value;
	toIndex = document.form_.to_index.value;
	if(frIndex.length > 0 && toIndex.length > 0) {
		if(eval(frIndex) > eval(toIndex)){
			alert("To selection must be greater than From selection");
			return;
		}
	}
}
</script>
<body bgcolor="#DEC9CC">
<%@ page language="java" import="utility.*,lms.CatalogReport,java.util.Vector" %>
<%
/**
	Report type 1 = Bibliography Report 
				2 = Shelf List
				3 = Author Card 
				4 = Subject Card 
				5 = Title Card 
*/

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp   = null;
	
//add security here.
	try
	{
		dbOP = new DBOperation();
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
	CatalogReport CR  = new CatalogReport(request);
	Vector vRetResult = null;
	int iSearchResult = 0;
	
	//aaron
	String strSchCode = dbOP.getSchoolIndex();
	if(strSchCode == null)
		strSchCode = "";
	//strSchCode = "DBTC";	
	boolean bolIsDBTC = strSchCode.startsWith("DBTC");

if(WI.fillTextValue("searchCollection").compareTo("1") == 0){
	vRetResult = CR.searchBook(dbOP);
	if(vRetResult == null)
		strErrMsg = CR.getErrMsg();
	else	
		iSearchResult = CR.getSearchCount();
}

/**
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"LIB_Cataloging","LIBRARY COLLECTION",request.getRemoteAddr(),
														"add_collection_standard.jsp");
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

	CatalogDDC ctlgDDC       = new CatalogDDC();
	CatalogLibCol ctlgLibCol = new CatalogLibCol();
	LmsUtil lUtil            = new LmsUtil();
	
	
	Vector vEditInfo  = null;boolean bolOpSuccess = true;

	strTemp = WI.fillTextValue("page_action");
	if(strTemp.length() > 0) {
		if(ctlgLibCol.operateOnBasicEntry(dbOP, request, Integer.parseInt(strTemp)) == null)
			strErrMsg = ctlgLibCol.getErrMsg();
		else {
			bolOpSuccess = true;
			if(strTemp.compareTo("1") == 0)
				strErrMsg = "Collection entry information successfully added.";
			if(strTemp.compareTo("2") == 0 || WI.fillTextValue("operation_").compareTo("2") == 0)
				strErrMsg = "Collection entry information successfully edited.";
			else if(strTemp.compareTo("5") == 0) 
				strErrMsg = "Collection infromation successfully duplicated.";
			else if(strTemp.compareTo("6") == 0) 
				strErrMsg = "All copies of collection information successfully edited.";
				
		}
	}

	
//get vEditInfoIf it is called.
if(WI.fillTextValue("ACCESSION_NO").length() > 0) {
	vEditInfo = ctlgLibCol.operateOnBasicEntry(dbOP, request,3);
	if(vEditInfo == null && strErrMsg == null)
		strErrMsg = ctlgLibCol.getErrMsg();
	if(vEditInfo != null && vEditInfo.size() > 0) 
		strInfoIndex = (String)vEditInfo.elementAt(0);
}
if(vEditInfo != null && vEditInfo.size() > 0 && WI.fillTextValue("reload_main").length() > 0)
	bolUseEditVal = true;

//I have to get here number of copies.
Vector vNoOfCopies = null; int iNoOfCopy = 0;
if(vEditInfo != null && vEditInfo.size() > 0) {
	vNoOfCopies = lUtil.getNoOfCopy(dbOP, (String)vEditInfo.elementAt(0));
	if(vNoOfCopies == null) 
		strErrMsg = lUtil.getErrMsg();
	else	
		iNoOfCopy = vNoOfCopies.size();
}
//iNoOfCopy = 2;
String strBookStatus = null;

if(vEditInfo != null && vEditInfo.size() > 0) {
	strBookStatus = dbOP.mapOneToOther("LMS_BOOK_STAT","BOOK_INDEX",(String)vEditInfo.elementAt(0), "BS_REF_INDEX",null);
}

String strSchCode = (String)request.getSession(false).getAttribute("school_code");
**/
%>

<form name="form_" method="post" action="./search_book_generic_rc.jsp" onSubmit="SubmitOnceButton(this);">
  <table width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr bgcolor="#A8A8D5"> 
      <td height="25" colspan="8" bgcolor="#A8A8D5"><div align="center"><font color="#FFFFFF" ><strong>:::: 
          SEARCH PAGE ::::</strong></font></div></td>
    </tr>
  </table>
	  
  <table width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr > 
      <td height="25">Search By </td>
      <td height="25"><select name="search_by" onChange="Search('0');">
        <option value="1">Title</option>
<%
strTemp = WI.fillTextValue("search_by");
if(strTemp.equals("2"))
	strErrMsg = " selected";
else	
	strErrMsg = "";
%>        <option value="2" <%=strErrMsg%>>Author</option>
<%
if(strTemp.equals("3"))
	strErrMsg = " selected";
else	
	strErrMsg = "";
%>        <option value="3" <%=strErrMsg%>>Subject</option>
<%
if(strTemp.equals("4"))
	strErrMsg = " selected";
else	
	strErrMsg = "";
%>        <option value="4" <%=strErrMsg%>>Accession NO</option>
      </select></td>
      <td height="25" align="right"><a href="javascript:window.close();"><img src="../../../images/close_window.gif" border="1"></a>&nbsp;</td>
    </tr>
	
	
	<%if(bolIsDBTC){%>
	<tr > 
      <td width="20%" height="25">Lib Location </td>
      <td colspan="2"><select name="LOC_INDEX" style="font-family:Verdana, Arial, Helvetica, sans-serif;font-size: 12;">          
          <%=dbOP.loadCombo("LOC_INDEX","LOC_NAME"," from LMS_LIBRARY_LOC order by LOC_INDEX asc",WI.fillTextValue("LOC_INDEX"), false)%> </select>	  </td>
    </tr>
	
	<tr > 
      <td width="20%" height="25">Section</td>
      <td colspan="2">
	  <select name="CTYPE_INDEX" style="font-family:Verdana, Arial, Helvetica, sans-serif;font-size: 12;">          
          <%=dbOP.loadCombo("CTYPE_INDEX","DESCRIPTION, CTYPE_CODE"," from LMS_CLOG_CTYPE where is_valid = 1 order by DESCRIPTION asc",WI.fillTextValue("CTYPE_INDEX"), false)%> </select>	  </td>
    </tr>
	<!--
	<tr > 
      <td width="" height="25">Department</td>
      <td width="" colspan="2">
	  <select name="LOC_INDEX" style="font-family:Verdana, Arial, Helvetica, sans-serif;font-size: 12;">          
          <%=dbOP.loadCombo("LOC_INDEX","LOC_NAME"," from LMS_LIBRARY_LOC order by LOC_INDEX asc",WI.fillTextValue("LOC_INDEX"), false)%> </select>
	  </td>
    </tr>-->
	
	<%}%>

<%
if(WI.fillTextValue("search_by").equals("4")){
%>	

	
    <tr >
        <td height="25">From</td>
        <td><input name="accession_no_fr" type="text" size="32" maxlength="32" value="<%=WI.fillTextValue("accession_no_fr")%>" class="textbox"></td>
        <td></td>
    </tr>
    <tr >
        <td width="20%" height="25">To</td>
        <td width="32%"><input name="accession_no_to" type="text" size="32" maxlength="32" value="<%=WI.fillTextValue("accession_no_to")%>" class="textbox"></td>
        <td width="48%">
		<input type="submit" name="Submit" value="&nbsp;Show Result&nbsp;" 
			style="font-size:12px; height:23px;border: 1px solid #FF0000; font-family:Verdana, Arial, Helvetica, sans-serif"
	   onClick="Search('1');">
		</td>
    </tr>
<%}else{%>
    <tr > 
      <td width="20%" height="25">Contains </td>
      <td width="32%"><input name="nearest_val" type="text" size="32" maxlength="32" value="<%=WI.fillTextValue("nearest_val")%>" class="textbox"></td>
      <td width="48%"><!--<a href="javascript:Search('1');"><img src="../../images/form_proceed.gif" border="0"></a>-->
	  <input type="submit" name="Submit" value="&nbsp;Show Result&nbsp;" style="font-size:12px; height:23px;border: 1px solid #FF0000; font-family:Verdana, Arial, Helvetica, sans-serif"
	   onClick="Search('1');">	  </td>
    </tr>
<%}%>	
	
	
	
	
    <tr > 
      <td height="15" colspan="3"><hr size="1" color="#0099FF"></td>
    </tr>
  </table>
  
  <%
if(vRetResult != null && vRetResult.size() > 0){%>
  <table width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="25" colspan="2" bgcolor="#DDDDEE" class="thinborderALL"><div align="center"><strong><font color="#FF0000">SEARCH 
        RESULT</font></strong></div></td>
    </tr>
    <tr>
      <td width="72%" class="thinborderLEFT"><b> Total Collection Found: <%=iSearchResult%> - Showing(<%=CR.getDisplayRange()%>)</b></td>
      <td width="28%" class="thinborderRIGHT" height="25">&nbsp;
          <%
	  //if more than one page , constuct page count list here.  - 20 default display per page)
		int iPageCount = iSearchResult/CR.defSearchSize;
		if(iSearchResult % CR.defSearchSize > 0) ++iPageCount;

		if(iPageCount > 1)
		{%>
          <div align="right">Jump To page:
            <select name="jumpto" onChange="Search('1');">
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
<%
strTemp = WI.fillTextValue("search_by");
if(strTemp.equals("1"))
	strTemp = "TITLE";
else if(strTemp.equals("2"))
	strTemp = "AUTHOR";
else if(strTemp.equals("4"))
	strTemp = "ACCESSION NO";
else	
	strTemp = "SUBJECT";
%>  
  <table width="100%" border="0" cellpadding="0" cellspacing="0" class="thinborder">
    <tr bgcolor="#FFFFDD">
      <td width="80%" height="25" class="thinborder"><div align="center"><font size="1"><strong><%=strTemp%></strong></font></div></td>
      <td class="thinborder" width="10%"><div align="center"><strong>FROM VALUE</strong></div></td>
      <td class="thinborder" width="10%"><div align="center"><strong>TO VALUE</strong></div></td>
    </tr>
    <%
for(int i = 0; i < vRetResult.size(); ++i){
	strTemp = ConversionTable.replaceString((String)vRetResult.elementAt(i),"'","\\\'");
	strTemp = ConversionTable.replaceString(strTemp,"\"","&quot;");
	//System.out.println(strTemp);%>
    <tr>
      <td height="25" class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i)%></td>
      <td class="thinborder" align="center"><input type="radio" name="from_val" onClick="javascript:setValue('1','<%=strTemp%>','<%=i%>');"></td>
      <td class="thinborder" align="center"><input type="radio" name="to_val" onClick="javascript:setValue('0','<%=strTemp%>','<%=i%>');"></td>
    </tr>
<%}%>
  </table>
  <%}//show only if vRetResult is not null%>
  
<input type="hidden" name="searchConCSV" value="<%=WI.fillTextValue("searchConCSV")%>">
<input type="hidden" name="publish_fr" value="<%=WI.fillTextValue("publish_fr")%>">
<input type="hidden" name="publish_to" value="<%=WI.fillTextValue("publish_to")%>">
<input type="hidden" name="searchCollection" value="<%=WI.fillTextValue("searchCollection")%>">
<input type="hidden" name="from_index" value="<%=WI.fillTextValue("from_index")%>">
<input type="hidden" name="to_index" value="<%=WI.fillTextValue("to_index")%>">
</form>
	
</body>
</html>
<%
dbOP.cleanUP();
%>