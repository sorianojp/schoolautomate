
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/reportlink.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">	
</head>
<script language="JavaScript" src="../../../jscript/common.js"></script>

<script language="JavaScript">
function ReloadPage(){
	document.form_.search_result.value = "1";
	document.form_.print_page.value = "";
	document.form_.submit();
}

function PrintPage(){
	document.form_.print_page.value = "1";
	document.form_.submit();
}

</script>
<body bgcolor="#DEC9CC" topmargin="0" bottommargin="0">
<%@ page language="java" import="utility.*,lms.CatalogReport,java.util.Vector" %>
<%
	WebInterface WI      = new WebInterface(request);
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp   = null;
	
	if(WI.fillTextValue("print_page").length() > 0){%>
		<jsp:forward page="./periodical_report_print.jsp"></jsp:forward>
<%	return;}

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"LIB_Cataloging-REPORTS","periodical_report.jsp");
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
*/

String[] astrDropListEqual = {"Any Keywords","All Keywords","Contains","Equal to","Starts with","Ends with"};
String[] astrDropListValEqual = {"any","all","contains","equals","starts","ends"};
String[] astrDropListBoolean = {"and","or","not"};
String[] astrDropListValBoolean = {"and","or","not"};
String[] astrSortByName    = {"Accession No","Title","Author"};
String[] astrSortByVal     = {"accession_no","book_title","author_name"};

Vector vRetResult = null;
CatalogReport CR = new CatalogReport();
int iElemCount = 0;
int iSearchResult  = 0;

if(WI.fillTextValue("search_result").length() > 0){
	vRetResult = CR.generatePeriodicalReport(dbOP, request);
	if(vRetResult == null)
		strErrMsg = CR.getErrMsg();
	else{
		iSearchResult = CR.getSearchCount();
		iElemCount = CR.getElemCount();
	}
}
	
%>

<form name="form_" method="post" action="./periodical_report.jsp">
  <table width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr bgcolor="#A8A8D5"> 
      <td height="25" colspan="2" bgcolor="#A8A8D5"><div align="center"><font color="#FFFFFF" ><strong>:::: 
          CATALOGING : REPORTS - PERIODICAL REPORT::::</strong></font></div></td>
    </tr>
 
    <tr> 
		<td width="94%" style="padding-left:20px;"><%=WI.getStrValue(strErrMsg)%></td>
      <td width="6%" height="30">
	  <font size="1"><a href="main_page.jsp" target="_self"><img src="../../images/go_back.gif" border="0" ></a></font></td>     
    </tr>
  </table>
  
  <table width="100%" border="0" cellspacing="0" cellpadding="0">    
    <tr> 
      <td width="3%" height="25">&nbsp;</td>
      <td width="18%" height="25">Title of Periodical</td>	 
      <td width="79%">
	  <select name="BOOK_TITLE_CON">
		<%=CR.constructGenericDropList(WI.fillTextValue("BOOK_TITLE_CON"),astrDropListEqual,astrDropListValEqual)%> 
      </select>
		
	  <input type="text" name="BOOK_TITLE" value="<%=WI.fillTextValue("BOOK_TITLE")%>" 
		class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
		onBlur="style.backgroundColor='white'" size="64" maxlength="512"></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Title of the Article</td>	  
      <td>
	  <select name="BOOK_SUB_TITLE_CON">
		<%=CR.constructGenericDropList(WI.fillTextValue("BOOK_SUB_TITLE_CON"),astrDropListEqual,astrDropListValEqual)%> 
      </select>
	  <input type="text" name="BOOK_SUB_TITLE" value="<%=WI.fillTextValue("BOOK_SUB_TITLE")%>" 
		class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
		onBlur="style.backgroundColor='white'" size="64" maxlength="512"></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>Author of the Article</td>	 
      <td>
	  <select name="AUTHOR_NAME_CON">
		<%=CR.constructGenericDropList(WI.fillTextValue("AUTHOR_NAME_CON"),astrDropListEqual,astrDropListValEqual)%> 
      </select>
	  	<input type="text" name="AUTHOR_NAME" value="<%=WI.fillTextValue("AUTHOR_NAME")%>" 
		class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
		onBlur="style.backgroundColor='white'" size="32" maxlength="64"></td>
    </tr>
	
	
	
   
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Subject of the Article</td>	  
      <td>
	  <select name="subject_of_article_con">
		<%=CR.constructGenericDropList(WI.fillTextValue("subject_of_article_con"),astrDropListEqual,astrDropListValEqual)%> 
      </select>
	  <input type="text" name="subject_of_article" value="<%=WI.fillTextValue("subject_of_article")%>" 
		class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
		onBlur="style.backgroundColor='white'" size="40" maxlength="512"></td>
    </tr>
    <tr>
        <td height="25">&nbsp;</td>
        <td>&nbsp;</td>
        <td>
		<a href="javascript:ReloadPage()"><img src="../../images/form_proceed.gif" border="0"></a>
		</td>
    </tr>
  </table>
  
<%
if(vRetResult != null && vRetResult.size() > 0){
%>
  
<table width="100%" border="0" cellspacing="0" cellpadding="0">
	<tr><td align="right" colspan="2"><a href="javascript:PrintPage();"><img src="../../images/print.gif" border="0"></a>
		<font size="1">Click to print report</font>
	</td></tr>
	<tr> 
      <td height="25" colspan="2" bgcolor="#DDDDEE" class="thinborderALL"><div align="center"><strong><font color="#FF0000">SEARCH 
          RESULT</font></strong></div></td>
    </tr>
    <tr> 
      <td width="72%" class="thinborderLEFT"><b> Total Collection: <%=iSearchResult%> - Showing(<%=CR.getDisplayRange()%>)</b></td>
      <td width="28%" class="thinborderRIGHT" height="25"> &nbsp;<%
	  //if more than one page , constuct page count list here.  - 20 default display per page)
		int iPageCount = iSearchResult/CR.defSearchSize;
		if(iSearchResult % CR.defSearchSize > 0) 
			++iPageCount;

		if(iPageCount > 1)
		{%> <div align="right">Jump To page: 
          <select name="jumpto" onChange="GoToNext();">
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
		<td width="26%" height="25" class="thinborder"><strong>Title of Periodicals</strong></td>
		<td width="22%" class="thinborder"><strong>Article Title</strong></td>
		<td width="18%" class="thinborder"><strong>Author</strong></td>
		<td width="19%" class="thinborder"><strong>Subject of Article</strong></td>
		<td width="15%" class="thinborder"><strong>Date</strong></td>
	</tr>
	<%
	
	String[] astrConvertMM = { "January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December" };
	
	
	for(int i = 0; i < vRetResult.size(); i+=iElemCount){
		strTemp = "";
		if(WI.getStrValue(vRetResult.elementAt(i+10)).length() > 0)
			strTemp = astrConvertMM[Integer.parseInt((String)vRetResult.elementAt(i+10))];
		if(WI.getStrValue(vRetResult.elementAt(i+11)).length() > 0)
			strTemp += " "+WI.getStrValue(vRetResult.elementAt(i+11));
		if(WI.getStrValue(vRetResult.elementAt(i+12)).length() > 0){
			if(WI.getStrValue(vRetResult.elementAt(i+11)).length() > 0 || WI.getStrValue(vRetResult.elementAt(i+10)).length() > 0)
				strTemp += ", ";
			strTemp += WI.getStrValue(vRetResult.elementAt(i+12));
		}
	%>
	<tr>
		<td class="thinborder" height="22"><%=WI.getStrValue(vRetResult.elementAt(i+2),"&nbsp;")%></td>
		<td class="thinborder"><%=WI.getStrValue(vRetResult.elementAt(i+3),"&nbsp;")%></td>
		<td class="thinborder"><%=WI.getStrValue(vRetResult.elementAt(i+4),"&nbsp;")%></td>
		<td class="thinborder"><%=WI.getStrValue(vRetResult.elementAt(i+13),"&nbsp;")%></td>
		<td class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
	</tr>
	<%}%>
</table>
  
  
<%}%>
<input type="hidden" name="print_page" value="">
<input type="hidden" name="search_result" value="">
</form>
	
</body>
</html>
<%
dbOP.cleanUP();
%>