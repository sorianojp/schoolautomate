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
	//window.opener.document.form_.search_by.value = document.form_.search_by[document.form_.search_by.selectedIndex].value;	
	document.form_.searchCollection.value = strCol;
	if(strCol == "1")
		document.form_.submit();
}

function setValue(strSetupIndex,strTitle,strAuthor,strEdition,strPubPlace,strCopyYear,strPublisher,strMaterialType) {				
		
		window.opener.document.form_.setup_details_index.value = strSetupIndex;		
		window.opener.document.form_.BOOK_TITLE.value = strTitle;
		window.opener.document.form_.AUTHOR_NAME.value = strAuthor;
		window.opener.document.form_.BOOK_EDTION.value = strEdition;
		window.opener.document.form_.PUBLISHER_PLACE.value = strPubPlace;
		window.opener.document.form_.PUBLISHER_DATE.value = strCopyYear;
		window.opener.document.form_.PUBLISHER_INDEX.value = strPublisher;
		window.opener.document.form_.MATERIAL_TYPE_INDEX.value = strMaterialType;
		
		window.opener.ReloadPageMain();
		//window.opener.document.form_.submit();		
}

</script>
<body bgcolor="#DEC9CC">
<%@ page language="java" import="utility.*,lms.Search,java.util.Vector" %>
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


	Search search  = new Search(request);	
	Vector vRetResult = null;
	int iSearchResult = 0;
	boolean bolIsCtlgSearch = false;
	boolean bolIsOpacSearch = false;


if(WI.fillTextValue("ctlg_search").compareTo("1") == 0){
	bolIsCtlgSearch = true;
	bolIsOpacSearch = false;
}else{
	bolIsOpacSearch = true;
	bolIsCtlgSearch = false;
}


if(WI.fillTextValue("searchCollection").compareTo("1") == 0){
	vRetResult = search.searchBookAcquisition(dbOP);
	if(vRetResult == null)
		strErrMsg = search.getErrMsg();
	else	
		iSearchResult = search.getSearchCount();	
}

%>

<form name="form_" method="post" action="./search_acquisition_book.jsp">
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
%>        <option value="3" <%=strErrMsg%>>Copyright Year</option>

<%
if(strTemp.equals("4"))
	strErrMsg = " selected";
else	
	strErrMsg = "";
%>        <option value="4" <%=strErrMsg%>>Publisher</option>

<%
if(strTemp.equals("5"))
	strErrMsg = " selected";
else	
	strErrMsg = "";
%>        <option value="5" <%=strErrMsg%>>Supplier</option>


      </select>	  
	  </td>
	  <%if(bolIsCtlgSearch){%>
      <td height="25" align="right"><a href="javascript:window.close();"><img src="../../images/close_window.gif" border="0"></a>&nbsp;</td>
	  <%}%>
    </tr>
    <tr > 
      <td width="14%" height="25">Contains </td>
      <td width="29%"><input name="nearest_val" type="text" size="32" maxlength="32" value="<%=WI.fillTextValue("nearest_val")%>" class="textbox"></td>
      <td width="57%">
		  <input type="submit" name="Submit" value="&nbsp;Show Result&nbsp;" 
			style="font-size:12px; height:23px;border: 1px solid #FF0000; font-family:Verdana, Arial, Helvetica, sans-serif"
		   onClick="Search('1');">
	  </td>
    </tr>
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
  </table>
<%
strTemp = WI.fillTextValue("search_by");
if(strTemp.equals("1"))
	strTemp = "TITLE";
else if(strTemp.equals("2"))
	strTemp = "AUTHOR";
else	
	strTemp = "SUBJECT";
%>  
  <table width="100%" border="0" cellpadding="0" cellspacing="0" class="thinborder">
    <tr bgcolor="#FFFFDD">
	<%	
		if(bolIsCtlgSearch)
			strErrMsg = "4";
		else
			strErrMsg = "5";
	%>
      <td width="80%" height="25" class="thinborder" colspan="<%=strErrMsg%>"><div align="center"><font size="1"><strong><%=strTemp%></strong></font></div></td>
      <%if(bolIsCtlgSearch){%>
	  	<td class="thinborder" width="10%"><div align="center"><strong>SELECT</strong></div></td>      
	  <%}%>
    </tr>
	<tr>
		<td class="thinborder" width="15%">&nbsp;<strong>Author</strong></td>
		<td class="thinborder" width="25%">&nbsp;<strong>Title</strong></td>
		<td class="thinborder" width="15%">&nbsp;<strong>Supplier</strong></td>
		<!--<td class="thinborder" width="15%">&nbsp;<strong>College/Dept.</strong></td>-->
		<td class="thinborder">&nbsp;<strong>Publisher</strong></td>
		<%if(bolIsOpacSearch){%>
		<td class="thinborder">&nbsp;<strong>Status</strong></td>
		<%}%>
		<%if(bolIsCtlgSearch){%>
		<td class="thinborder">&nbsp;</td>
		<%}%>
	</tr>
    <%	
for(int i = 0; i < vRetResult.size(); i+=19){
	strTemp = ConversionTable.replaceString((String)vRetResult.elementAt(i),"'","\\\'");
	strTemp = ConversionTable.replaceString(strTemp,"\"","&quot;");
	//System.out.println(strTemp);%>
    <tr>
		<td height="25" class="thinborder">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i+1), "N/A")%></td>
		<td height="25" class="thinborder">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i+4), "N/A")%></td>
		<td height="25" class="thinborder">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i+12), "N/A")%></td>
	    <!--<td height="25" class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i)%></td>-->
		<td height="25" class="thinborder">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i+17), "N/A")%></td>
		<%if(bolIsOpacSearch){%>
		<td height="25" class="thinborder">&nbsp;On-Process</td>
		<%}if(bolIsCtlgSearch){%>
		<td class="thinborder" align="center"><input type="radio" name="from_val" 
		onClick="javascript:setValue(
			'<%=WI.getStrValue((String)vRetResult.elementAt(i))%>',
			'<%=WI.getStrValue((String)vRetResult.elementAt(i+4))%>',
			'<%=WI.getStrValue((String)vRetResult.elementAt(i+1))%>',
			'<%=WI.getStrValue((String)vRetResult.elementAt(i+2))%>',
			'<%=WI.getStrValue((String)vRetResult.elementAt(i+3))%>',
			'<%=WI.getStrValue((String)vRetResult.elementAt(i+13))%>',
			'<%=WI.getStrValue((String)vRetResult.elementAt(i+16))%>',
			'<%=WI.getStrValue((String)vRetResult.elementAt(i+18))%>');"></td>      
		<%}%>
    </tr>
<%}%>
	<!--<tr>
		<td colspan="6" align="center"><input type="submit" name="Submit" value="&nbsp;Get Data&nbsp;" 
			style="font-size:12px; height:23px;border: 1px solid #FF0000; font-family:Verdana, Arial, Helvetica, sans-serif"
	   		onClick="GetBookAcquisition('<%=WI.fillTextValue("setup_index")%>');"></td>
	</tr>-->
  </table>
  <%}//show only if vRetResult is not null%>
  

<input type="hidden" name="searchCollection" value="<%=WI.fillTextValue("searchCollection")%>">
<input type="hidden" name="setup_index" value="<%=WI.fillTextValue("setup_index")%>"/>
<input type="hidden" name="ctlg_search" value="<%=WI.fillTextValue("ctlg_search")%>"/>
</form>
	
</body>
</html>
<%
dbOP.cleanUP();
%>