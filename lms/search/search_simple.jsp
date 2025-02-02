<%@ page language="java" import="utility.*,lms.Search,java.util.Vector" %>
<%
	if(true) {%>
		<jsp:forward page="search_opac.jsp"></jsp:forward>		
	<%	return;
	}
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
<link href="../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../css/tableBorder.css" rel="stylesheet" type="text/css">
<link href="../../css/reportlink.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../jscript/common.js"></script>
<script language="JavaScript">
function PrintPg() {
	document.search_util.print_pg.value = "1";
	this.SubmitOnce("search_util");	
}
function ReloadPage()
{
	document.search_util.searchCollection.value = "";
	document.search_util.print_pg.value = "";
	this.SubmitOnce("search_util");
}
function GoToNext() {
	this.SearchCollection();
	this.SubmitOnce("search_util");	
}
function SearchCollection()
{
	document.search_util.searchCollection.value = "1";
	document.search_util.print_pg.value = "";
}
function ViewDetail(strAccessionNo) {
//popup window here. 
	var pgLoc = "./collection_details_main.jsp?accession_no="+escape(strAccessionNo);
	var win=window.open(pgLoc,"EditWindow",'width=924,height=600,top=10,left=0,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function MyCollection(strAccessionNo) {
	var pgLoc = "../home/my_collection.jsp?accession_no="+escape(strAccessionNo);
	var win=window.open(pgLoc,"EditWindow",'width=900,height=650,top=10,left=0,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function Reserve(strAccessionNo) {
	var pgLoc = "../home/reserve_book.jsp?accession_no="+escape(strAccessionNo);
	var win=window.open(pgLoc,"EditWindow",'width=900,height=650,top=10,left=0,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

<%
if(WI.fillTextValue("opner_info").length() > 0){%>
function CopyAccessionNo(strAccessionNo)
{
	window.opener.document.<%=WI.fillTextValue("opner_info")%>.value=strAccessionNo;
	<%
	if(WI.fillTextValue("opner_info2").length() > 0) {%>
	window.opener.document.<%=WI.fillTextValue("opner_info2")%>.value=<%=WI.fillTextValue("opner_info2_val")%>;
	<%}%>
	window.opener.focus();
	<%
	if(strFormName != null){%>
	window.opener.document.<%=strFormName%>.submit();
	<%}%>
	
	self.close();
}
<%}%>
function focusID() {
	document.search_util.book_title.focus();
}
</script>
<body bgcolor="#F2DFD2" onLoad="focusID();">
<%
	String strErrMsg = null;
	String strTemp = null;
	Vector vRetResult = null;

// if this page is calling print page, i have to forward page to print page.
	if(WI.fillTextValue("print_pg").compareTo("1") == 0) {%>
		<jsp:forward page="./search_simple_print.jsp" />
	<%	return;
	}

	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"LMS-Search-simple","search_simple.jsp");
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

String[] astrDropListEqual = {"Any Keywords","All Keywords","Equal to"};
String[] astrDropListValEqual = {"any","all","equals"};
String[] astrDropListBoolean = {"AND","OR","BUT NOT"};
String[] astrDropListValBoolean = {"and","or","not"};
String[] astrSortByName    = {"Accession No","Title","Author"};
String[] astrSortByVal     = {"accession_no","book_title","author_name"};
 
 
int iSearchResult = 0;

Search searchBook = new Search(request);
if(WI.fillTextValue("searchCollection").compareTo("1") == 0){
	vRetResult = searchBook.searchBookSimple(dbOP);
	if(vRetResult == null)
		strErrMsg = searchBook.getErrMsg();
	else	
		iSearchResult = searchBook.getSearchCount();
}

boolean bolIsLoggedIn = false;
if( (String)request.getSession(false).getAttribute("userId") != null)
	bolIsLoggedIn = true;
int[] aiMaxBookAllowed  = null;
Vector vBookReserveInfo = null;

if(bolIsLoggedIn) {
	aiMaxBookAllowed = new lms.LmsMyHome().maxBookListAllowed(dbOP, (String)request.getSession(false).getAttribute("userIndex"),false);
	vBookReserveInfo = new lms.BookReservation().getReservationInfo(dbOP, 
			(String)request.getSession(false).getAttribute("userIndex"),null,false);
}

%>
<form action="./search_simple.jsp" method="post" name="search_util">
  <table width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25" bgcolor="#A8A8D5"><div align="center"><font color="#FFFFFF" ><strong>:::: 
          SEARCH COLLECTION - SIMPLE SEARCH PAGE ::::</strong></font></div></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;&nbsp;&nbsp;&nbsp;<font size="3" color="#FF0000"><%=WI.getStrValue(strErrMsg)%></font></td>
    </tr>
  </table>
	  
  <table width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td width="22" height="25">&nbsp;</td>
      <td colspan="3" class="thinborderNONE">Material Type&nbsp; 
          <select name="MATERIAL_TYPE_INDEX" 
	  style="font-family:Verdana, Arial, Helvetica, sans-serif;font-size: 9px;">
            <option value="">ANY</option>
            <%=dbOP.loadCombo("MATERIAL_TYPE_INDEX","MATERIAL_TYPE"," from LMS_MAT_TYPE order by  MATERIAL_TYPE_INDEX asc",
		  	WI.fillTextValue("MATERIAL_TYPE_INDEX"), false)%> 
          </select>
        </div></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td width="63" height="25" class="thinborderNONE">Title</td>
      <td colspan="2">
	  <select name="title_con" style="font-size:11px;">
<%=searchBook.constructGenericDropList(WI.fillTextValue("title_con"),astrDropListEqual,astrDropListValEqual)%> 
        </select>
	  <input name="book_title" type="text" size="60" value="<%=WI.fillTextValue("book_title")%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" style="font-size:11px;">
	  <select name="boolean_1" style="font-size:11px;">
<%=searchBook.constructGenericDropList(WI.fillTextValue("boolean_1"),astrDropListBoolean,astrDropListValBoolean)%> 
        </select></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25" class="thinborderNONE">Subject</td>
      <td width="781">
	  <select name="sh_con" style="font-size:11px;">
<%=searchBook.constructGenericDropList(WI.fillTextValue("sh_con"),astrDropListEqual,astrDropListValEqual)%> 
	  </select> 
        <input name="sub_heading" type="text" size="60" value="<%=WI.fillTextValue("sub_heading")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" style="font-size:11px;"> 
		<select name="boolean_2" style="font-size:11px;">
<%=searchBook.constructGenericDropList(WI.fillTextValue("boolean_2"),astrDropListBoolean,astrDropListValBoolean)%> 
        </select>	  </td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25" class="thinborderNONE">Author</td>
      <td colspan="2">
	  <select name="author_con" style="font-size:11px;">
<%=searchBook.constructGenericDropList(WI.fillTextValue("author_con"),astrDropListEqual,astrDropListValEqual)%> 
        </select>
	  <input name="author" type="text" size="60" value="<%=WI.fillTextValue("author")%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" style="font-size:11px;"></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25" class="thinborderNONE">Sort By </td>
      <td colspan="2"><select name="sort_by1" style="font-size:11px;">
          <option value="">N/A</option>
          <%=searchBook.constructSortByDropList(WI.fillTextValue("sort_by1"),astrSortByName,astrSortByVal)%> 
        </select><select name="sort_by1_con" style="font-size:11px;">
          <option value="asc">Ascending</option>
          <%
if(WI.fillTextValue("sort_by1_con").compareTo("desc") ==0){%>
          <option value="desc" selected>Descending</option>
          <%}else{%>
          <option value="desc">Descending</option>
          <%}%>
        </select>
        &nbsp;&nbsp;
        <select name="sort_by2" style="font-size:11px;">
          <option value="">N/A</option>
          <%=searchBook.constructSortByDropList(WI.fillTextValue("sort_by2"),astrSortByName,astrSortByVal)%> 
        </select><select name="sort_by2_con" style="font-size:11px;">
          <option value="asc">Ascending</option>
          <%
if(WI.fillTextValue("sort_by2_con").compareTo("desc") ==0){%>
          <option value="desc" selected>Descending</option>
          <%}else{%>
          <option value="desc">Descending</option>
          <%}%>
        </select>
        &nbsp;&nbsp;<select name="sort_by3" style="font-size:11px;">
          <option value="">N/A</option>
<%=searchBook.constructSortByDropList(WI.fillTextValue("sort_by3"),astrSortByName,astrSortByVal)%> 
        </select><select name="sort_by3_con" style="font-size:11px;">
          <option value="asc">Ascending</option>
          <%
if(WI.fillTextValue("sort_by3_con").compareTo("desc") ==0){%>
          <option value="desc" selected>Descending</option>
<%}else{%>
          <option value="desc">Descending</option>
<%}%>
        </select></td>
    </tr>
    <tr> 
      <td height="35">&nbsp;</td>
      <td height="35">&nbsp;</td>
      <td colspan="2">&nbsp;
        <input type="image" src="../images/search_recommend.gif" onClick="SearchCollection();" border="1"> 
        <font size="1">Click to search book collection (Leave all fields blank 
        to display all books in collection record)</font></td>
    </tr>
  </table>
<%
if(vRetResult != null && vRetResult.size() > 0){%>
  <table width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25"><%
	  if(WI.fillTextValue("opner_info").length() > 0){%>
        NOTE : Please click Accession no. to copy ID. 
        <%}%></td>
      <td height="25" align="right"><a href="javascript:PrintPg();"><img src="../images/print_recommend.gif" border="0"></a> 
        <font size="1">click to print result</font></td>
    </tr>
    <tr> 
      <td height="25" colspan="2" bgcolor="#DDDDEE" class="thinborderALL"><div align="center"><strong><font color="#FF0000">SEARCH 
          RESULT</font></strong></div></td>
    </tr>
    <tr> 
      <td width="72%" class="thinborderLEFT"><b> Total Collection: <%=iSearchResult%> - Showing(<%=searchBook.getDisplayRange()%>)</b></td>
      <td width="28%" class="thinborderRIGHT" height="25"> &nbsp;<%
	  //if more than one page , constuct page count list here.  - 20 default display per page)
		int iPageCount = iSearchResult/searchBook.defSearchSize;
		if(iSearchResult % searchBook.defSearchSize > 0) ++iPageCount;

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
  <table width="100%" height="102" border="0" cellpadding="0" cellspacing="0" class="thinborder">
    <tr> 
      <td width="15%" height="25" class="thinborder"><div align="center"><font size="1"><strong>COLLECTION 
          TYPE </strong></font></div></td>
      <td width="16%" class="thinborder"><div align="center"><font size="1"><strong>ACCESSION 
          NO. / BARCODE</strong></font></div></td>
      <td width="30%" class="thinborder"><div align="center"><font size="1"><strong>::: 
          TITLE ::: <br>
          SUB TITILE</strong></font></div></td>
      <td width="15%" class="thinborder"><div align="center"><font size="1"><strong>AUTHOR</strong></font></div></td>
      <td width="6%" class="thinborder"><div align="center"><font size="1"><strong>BOOK 
          STATUS</strong></font></div></td>
      <td class="thinborder" width="6%"><div align="center"><font size="1"><strong>View Detail </strong> 
        </font></div></td>
      <td class="thinborder" width="6%"><div align="center"><font size="1"><strong>My Collection</strong><br>
	  <%if(aiMaxBookAllowed != null){%><%=aiMaxBookAllowed[0]%>(<%=aiMaxBookAllowed[0]-aiMaxBookAllowed[1]%>)<%}%>
	  </font></div></td>
      <td class="thinborder" width="6%"><div align="center"><font size="1"><strong>Reserve</strong><br>
	  <%if(vBookReserveInfo != null){%><%=vBookReserveInfo.elementAt(0)%>(<%=vBookReserveInfo.elementAt(1)%>)<%}%></font></div></td>
    </tr>
    <%String strCheckOutColor = "";
for(int i = 0; i < vRetResult.size(); i += 10){
	if( ((String)vRetResult.elementAt(i + 9)).compareTo("0") == 0) 
		strCheckOutColor = " bgcolor=#DDDDDD";
	else	
		strCheckOutColor = "";%>
    <tr<%=strCheckOutColor%>> 
      <td height="25" class="thinborder">&nbsp;<font size="1"><img src="../images/<%=(String)vRetResult.elementAt(i + 7)%>" border="1">
	  &nbsp;<%=(String)vRetResult.elementAt(i + 6)%></font></td>
      <td class="thinborder"><font size="1">
	  <%if(WI.fillTextValue("opner_info").length() > 0) {%>
	  <a href='javascript:CopyAccessionNo("<%=(String)vRetResult.elementAt(i+1)%>");'>
	  <%=(String)vRetResult.elementAt(i+1)%>/<%=(String)vRetResult.elementAt(i + 2)%></a>
	  <%}else{%>
	  <%=(String)vRetResult.elementAt(i+1)%>/<%=(String)vRetResult.elementAt(i + 2)%>
	  <%}%>
	  </font></td>
      <td class="thinborder"><font size="1">&nbsp;:::<%=(String)vRetResult.elementAt(i + 3)%>::: <br>&nbsp;
	  <%=WI.getStrValue(vRetResult.elementAt(i + 4))%></font></td>
      <td class="thinborder"><font size="1">&nbsp;<%=(String)vRetResult.elementAt(i + 8)%></font></td>
      <td class="thinborder"><font size="1">&nbsp;<%=(String)vRetResult.elementAt(i + 5)%>
	  <%if(strCheckOutColor.length() > 0) {%><br>(Not for checkout)<%}%></font></td>
      <td class="thinborder" align="center">
	  <a href='javascript:ViewDetail("<%=(String)vRetResult.elementAt(i + 1)%>");'><img src="../images/view_collection_dtls.gif" border="0"></a>        </td>
      <td class="thinborder" align="center">
	  <%if(bolIsLoggedIn){%>
	  <a href='javascript:MyCollection("<%=(String)vRetResult.elementAt(i + 1)%>");'><img src="../images/my_collection.gif" border="0"></a>
	  <%}else if(i == 0){%><strong>Log in reqd.</strong><%}else{%>&nbsp;<%}%>	  </td>
      <td class="thinborder" align="center">
	  <%if(bolIsLoggedIn){%>
	  <a href='javascript:Reserve("<%=(String)vRetResult.elementAt(i + 1)%>");'><img src="../images/reserve.gif" border="0"></a>
	  <%}else if(i == 0){%><strong>Log in reqd.</strong><%}else{%>&nbsp;<%}%>	  </td>
    </tr>
    <%}%>
  </table>
<%}//end of vRetResult not null.%>
<input type="hidden" name="searchCollection" value="<%=WI.fillTextValue("searchCollection")%>">
<input type="hidden" name="print_pg">
<!-- Instruction -- set the opner_from_name to the parent window to copy the student ID -->
<input type="hidden" name="opner_info" value="<%=WI.fillTextValue("opner_info")%>">
<input type="hidden" name="opner_info2" value="<%=WI.fillTextValue("opner_info2")%>">
<input type="hidden" name="opner_info2_val" value="<%=WI.fillTextValue("opner_info2_val")%>">
<%
if(WI.fillTextValue("book_status").length() > 0){%>
<input type="hidden" name="book_status" value="<%=WI.fillTextValue("book_status")%>">
<%}%>
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>