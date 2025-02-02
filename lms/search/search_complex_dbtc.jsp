<%@ page language="java" import="utility.*,lms.Search,java.util.Vector" %>
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
<link href="../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../css/tableBorder.css" rel="stylesheet" type="text/css">
<link href="../../css/reportlink.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../jscript/common.js"></script>
<script language="JavaScript">
function PrintPg() {
	document.form_.print_pg.value = "1";
	this.SubmitOnce("form_");	
}
function ReloadPage()
{
	document.form_.searchCollection.value = "";
	document.form_.print_pg.value = "";
	this.SubmitOnce("form_");
}
function GoToNext() {
	this.SearchCollection();
	this.SubmitOnce("form_");	
}
function SearchCollection()
{
	document.form_.searchCollection.value = "1";
	document.form_.print_pg.value = "";
}
function ViewDetail(strAccessionNo) {
//popup window here. 
	var pgLoc = "./collection_details.jsp?accession_no="+escape(strAccessionNo);
	var win=window.open(pgLoc,"EditWindow",'width=924,height=600,top=10,left=0,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function MyCollection(strAccessionNo) {
	var pgLoc = "../home/my_collection.jsp?accession_no="+escape(strAccessionNo);
	var win=window.open(pgLoc,"EditWindow",'width=1000,height=650,top=10,left=0,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function Reserve(strAccessionNo) {

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
	document.form_.book_title.focus();
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
								"LMS-Search-Complex","search_complex_dbtc.jsp");
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
	
//check if cataloger.
CommonUtil comUtil = new CommonUtil();
//iAccessLevel == 2 -> cataloger.
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"LIB_Cataloging","LIBRARY COLLECTION",request.getRemoteAddr(),
														"add_collection_standard.jsp");
	
	

String[] astrDropListEqual = {"Equal to","Starts with","Ends with","Contains", "Any Keywords","All Keywords"};
String[] astrDropListValEqual = {"equals","starts","ends","contains","any","all"};
String[] astrSortByName    = {"Accession No","Title","Author"};
String[] astrSortByVal     = {"accession_no","book_title","author_name"};


int iSearchResult = 0;

Search searchBook = new Search(request);
if(WI.fillTextValue("searchCollection").compareTo("1") == 0){
	vRetResult = searchBook.searchBookComlex(dbOP);
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
<form method="POST" name="form_" action="./search_complex_dbtc.jsp" >
  <table border="0" width="100%" cellpadding="0" cellspacing="0">
    <tr> 
      <td bgcolor="#A8A8D5" colspan="7" height="25" align="center"><font color="#FFFFFF" ><strong>:::: 
        SEARCH COLLECTION - COMPREHENSIVE SEARCH PAGE ::::</strong></font></td>
    </tr>
    <tr> 
      <td colspan="7" height="25">&nbsp;&nbsp;&nbsp;&nbsp;<font color="red" size="3"><strong><%=WI.getStrValue(strErrMsg)%></strong></font></td>
    </tr>
    <tr> 
      <td width="12%" class="thinborderNONE">Book Title</td>
      <td width="6%"> <select name="title_con" style="font-family:Verdana, Arial, Helvetica, sans-serif;font-size: 10;">
      <%=searchBook.constructGenericDropList(WI.fillTextValue("title_con"),astrDropListEqual,astrDropListValEqual)%> </select> </td>
      <td width="21%"> <input type="text" name="book_title" size="18" value="<%=WI.fillTextValue("book_title") %>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" style="font-size:11px">      </td>
      <td width="1%">&nbsp; </td>
      <td width="16%" class="thinborderNONE"><div align="right">Call No.&nbsp;</div></td>
      <td width="13%" > <select name="call_no_con" style="font-family:Verdana, Arial, Helvetica, sans-serif;font-size: 10;">
      <%=searchBook.constructGenericDropList(WI.fillTextValue("call_no_con"),astrDropListEqual,astrDropListValEqual)%> </select></td>
      <td> <input type="text" name="call_no" size="20" value="<%= WI.fillTextValue("call_no") %>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" style="font-size:11px">      </td>
    </tr>
    <tr> 
      <td width="12%" class="thinborderNONE">Sub. Heading </td>
      <td colspan="6"> <select name="SUB_HEADING" style="font-family:Verdana, Arial, Helvetica, sans-serif;font-size: 10;">
           <option value="">Any</option>
         <%=dbOP.loadCombo("SUB_HEADING_INDEX","HEAD_NAME"," from LMS_SUB_HEADING order by  SUB_HEADING_INDEX asc", WI.fillTextValue("SUB_HEADING"), false)%> 
        </select>
        &nbsp;&nbsp;&nbsp;&nbsp; 
        <select name="sh_con" style="font-family:Verdana, Arial, Helvetica, sans-serif;font-size: 10;">
          <%=searchBook.constructGenericDropList(WI.fillTextValue("sh_con"),astrDropListEqual,astrDropListValEqual)%> </select>
        &nbsp;&nbsp;&nbsp;&nbsp; 
        <input type="text" name="sh" size="20" value="<%= WI.fillTextValue("sh") %>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" style="font-size:11px">      </td>
    </tr>
    <tr> 
      <td class="thinborderNONE">Type</td>
      <td colspan="6"> <select name="bookTypeCon" style="font-family:Verdana, Arial, Helvetica, sans-serif;font-size: 10;">
          <option value="">Any</option>
          <%
	String strBookType = WI.fillTextValue("bookTypeCon");
	if(strBookType.compareTo("1") == 0) {%>
          <option value="1" selected>can be issued</option>
          <%}else{%>
          <option value="1">can be issued</option>
          <%}if(strBookType.compareTo("0") ==0){%>
          <option value="0" selected>can't be issued</option>
          <%}else{%>
          <option value="0">can't be issued</option>
          <%}%>
        </select> </td>
    </tr>
    <tr> 
      <td width="12%" class="thinborderNONE">ISBN No. </td>
      <td width="6%"> <select name="isbn_con" style="font-family:Verdana, Arial, Helvetica, sans-serif;font-size: 10;">
      <%=searchBook.constructGenericDropList(WI.fillTextValue("isbn_con"),astrDropListEqual,astrDropListValEqual)%> </select> </td>
      <td width="21%"> <input type="text" name="isbn" size="18" value="<%=WI.fillTextValue("isbn") %>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" style="font-size:11px">      </td>
      <td width="1%">&nbsp; </td>
      <td width="16%" class="thinborderNONE"><div align="right">Accession No&nbsp;</div></td>
      <td width="13%"> <select name="accession_no_con" style="font-family:Verdana, Arial, Helvetica, sans-serif;font-size: 10;">
      <%=searchBook.constructGenericDropList(WI.fillTextValue("accession_no_con"),astrDropListEqual,astrDropListValEqual)%> </select> </td>
      <td width="31%"> <input type="text" name="accession_no" size="18" value = "<%= WI.fillTextValue("accession_no") %>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" style="font-size:11px">      </td>
    </tr>
    <tr> 
      <td width="12%" class="thinborderNONE">Bar Code</td>
      <td> <select name="barcode_con" style="font-family:Verdana, Arial, Helvetica, sans-serif;font-size: 10;">
          <%=searchBook.constructGenericDropList(WI.fillTextValue("barcode_con"),astrDropListEqual,astrDropListValEqual)%> </select> </td>
      <td> <input type="text" name="barcode" size="18" value="<%=WI.fillTextValue("barcode") %>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" style="font-size:11px">      </td>
      <td width="1%">&nbsp; </td>
      <td width="16%" class="thinborderNONE"><div align="right">Author&nbsp;</div></td>
      <td width="13%"> <select name="author_con" style="font-family:Verdana, Arial, Helvetica, sans-serif;font-size: 10;">
      <%=searchBook.constructGenericDropList(WI.fillTextValue("author_con"),astrDropListEqual,astrDropListValEqual)%> </select></td>
      <td width="31%"> <input type="text" name="author" size="18" value="<%=WI.fillTextValue("author") %>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" style="font-size:11px">      </td>
    </tr>
    <tr> 
      <td width="12%">&nbsp;</td>
      <td width="6%">&nbsp;</td>
      <td width="21%">&nbsp;</td>
      <td width="1%">&nbsp; </td>
      <td width="16%"><div align="right"></div></td>
      <td width="13%" >&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
    <tr> 
      <td width="12%" class="thinborderNONE">Publisher</td>
      <td width="6%"> <select name="publisher_con" style="font-family:Verdana, Arial, Helvetica, sans-serif;font-size: 10;">
      <%=searchBook.constructGenericDropList(WI.fillTextValue("publisher_con"),astrDropListEqual,astrDropListValEqual)%> </select> </td>
      <td width="21%"> <input type="text" name="publisher" size="18" value="<%=WI.fillTextValue("publisher") %>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" style="font-size:11px">      </td>
      <td width="1%">&nbsp; </td>
      <td width="16%" class="thinborderNONE" > <div align="right">Status&nbsp;</div></td>
      <td colspan="2">
	  <select name="book_status" style="font-family:Verdana, Arial, Helvetica, sans-serif;font-size: 10;">
          <option value="">Any</option>
<%
if(iAccessLevel != 2)
	strTemp = " where BS_REF_INDEX <3 ";
else	
	strTemp = "";
%>
          <%=dbOP.loadCombo("BS_REF_INDEX","STATUS"," from LMS_BOOK_STAT_REF "+strTemp+" order by BS_REF_INDEX asc",
		  	WI.fillTextValue("book_status"), false)%> </select> &nbsp; </td>
    </tr>
	
	
    <tr> 
      <td width="12%" class="thinborderNONE">Book Loc.</td>
      <td colspan="2"> <select name="BOOK_LOC_INDEX"
	  style="font-family:Verdana, Arial, Helvetica, sans-serif;font-size: 10;">
           <option value="">Any</option>
         <%=dbOP.loadCombo("BOOK_LOC_INDEX","LOCATION"," from LMS_BOOK_LOC order by LOCATION asc",
		  	WI.fillTextValue("BOOK_LOC_INDEX"), false)%> </select> </td>
      <td width="1%">&nbsp;</td>
      <td width="16%" class="thinborderNONE"><div align="right">Col. Location&nbsp;</div></td>
      <td colspan="2"><select name="LOC_INDEX"
	  style="font-family:Verdana, Arial, Helvetica, sans-serif;font-size: 10;">
          <option value="">Any</option>
          <%=dbOP.loadCombo("LOC_INDEX","LOC_NAME"," from LMS_LIBRARY_LOC order by LOC_NAME asc",
		  	WI.fillTextValue("LOC_INDEX"), false)%> </select></td>
    </tr>
	
	<%//aaron%>
	<tr> 
      <td width="12%" class="thinborderNONE">Library Loc.</td>
      <td colspan="2"> <select name="LOC_INDEX" style="font-family:Verdana, Arial, Helvetica, sans-serif;font-size: 10;">           
         <%=dbOP.loadCombo("LOC_INDEX","loc_name"," from LMS_LIBRARY_LOC order by LOC_INDEX asc", WI.fillTextValue("LOC_INDEX"), false)%> </select> </td>
      <td width="1%">&nbsp;</td>
    </tr>
	
	
    <tr> 
      <td width="12%">&nbsp;</td>
      <td colspan="2">&nbsp; </td>
      <td width="1%">&nbsp;</td>
      <td width="16%">&nbsp;</td>
      <td colspan="2">&nbsp;</td>
    </tr>
    <!-- added for sorting ;-) -->
    <tr> 
      <td width="12%" valign="top" class="thinborderNONE">Sort Result</td>
      <td colspan="6" align="left" valign="top"><select name="sort_by1" style="font-family:Verdana, Arial, Helvetica, sans-serif;font-size: 10;">
          <option value="">N/A</option>
          <%=searchBook.constructSortByDropList(WI.fillTextValue("sort_by1"),astrSortByName,astrSortByVal)%> </select> <select name="sort_by1_con" style="font-family:Verdana, Arial, Helvetica, sans-serif;font-size: 10;">
          <option value="asc">Ascending</option>
          <%
if(WI.fillTextValue("sort_by1_con").compareTo("desc") ==0){%>
          <option value="desc" selected>Descending</option>
          <%}else{%>
          <option value="desc">Descending</option>
          <%}%>
        </select> &nbsp;&nbsp;&nbsp; <select name="sort_by2" style="font-family:Verdana, Arial, Helvetica, sans-serif;font-size: 10;">
          <option value="">N/A</option>
          <%=searchBook.constructSortByDropList(WI.fillTextValue("sort_by2"),astrSortByName,astrSortByVal)%> </select> <select name="sort_by2_con" style="font-family:Verdana, Arial, Helvetica, sans-serif;font-size: 10;">
          <option value="asc">Ascending</option>
          <%
if(WI.fillTextValue("sort_by2_con").compareTo("desc") ==0){%>
          <option value="desc" selected>Descending</option>
          <%}else{%>
          <option value="desc">Descending</option>
          <%}%>
        </select> &nbsp;&nbsp;&nbsp; <select name="sort_by3" style="font-family:Verdana, Arial, Helvetica, sans-serif;font-size: 10;">
          <option value="">N/A</option>
          <%=searchBook.constructSortByDropList(WI.fillTextValue("sort_by3"),astrSortByName,astrSortByVal)%> </select> <select name="sort_by3_con" style="font-family:Verdana, Arial, Helvetica, sans-serif;font-size: 10;">
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
      <td width="12%">&nbsp;</td>
      <td colspan="2"></td>
      <td width="1%"></td>
      <td width="16%"></td>
      <td colspan="2"></td>
    </tr>
    <tr> 
      <td width="12%">&nbsp;</td>
      <td colspan="6"><input name="image" type="image" onClick="SearchCollection();" src="../images/search_recommend.gif" border="1"> 
        <font size="1">Search collection (Leave all fields blank 
        to display all collection) 
        <input type="image" onClick="SearchCollection();" src="../../images/clear.gif" border="1">
        Clear entries</font></td>
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
        click to print result</td>
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
			strTemp = WI.fillTextValue("jumpto");
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
      <td class="thinborder" width="6%"><div align="center"><font size="1"><strong>View 
          Detail </strong> </font></div></td>
      <td class="thinborder" width="6%"><div align="center"><font size="1"><strong>MyCollection</strong><br>
	  <%if(aiMaxBookAllowed != null){%><%=aiMaxBookAllowed[0]%>(<%=aiMaxBookAllowed[0]-aiMaxBookAllowed[1]%>)<%}%>
	  </font></div></td>
      <td class="thinborder" width="6%"><div align="center"><font size="1"><strong>Reserve</strong><br>
	  <%if(vBookReserveInfo != null){%><%=vBookReserveInfo.elementAt(0)%>(<%=vBookReserveInfo.elementAt(1)%>)<%}%></font></div></td>
	  </font></div></td>
    </tr>
    <%String strCheckOutColor = "";
for(int i = 0; i < vRetResult.size(); i += 10){
	if( ((String)vRetResult.elementAt(i + 9)).compareTo("0") == 0) 
		strCheckOutColor = " bgcolor=#DDDDDD";
	else	
		strCheckOutColor = "";%>
    <tr<%=strCheckOutColor%>> 
      <td height="25" class="thinborder">&nbsp;<img src="../images/<%=(String)vRetResult.elementAt(i + 7)%>" border="1"> 
        &nbsp;<%=(String)vRetResult.elementAt(i + 6)%></td>
      <td class="thinborder"> <%if(WI.fillTextValue("opner_info").length() > 0) {%> <a href='javascript:CopyAccessionNo("<%=(String)vRetResult.elementAt(i+1)%>");'> 
        <%=(String)vRetResult.elementAt(i+1)%>/<%=(String)vRetResult.elementAt(i + 2)%></a> <%}else{%> <%=(String)vRetResult.elementAt(i+1)%>/<%=(String)vRetResult.elementAt(i + 2)%> <%}%> </td>
      <td class="thinborder">&nbsp;:::<%=(String)vRetResult.elementAt(i + 3)%>::: <br>
        &nbsp; <%=WI.getStrValue(vRetResult.elementAt(i + 4))%></td>
      <td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i + 8)%></td>
      <td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i + 5)%> <%if(strCheckOutColor.length() > 0) {%>
        <br>
        (Not for checkout)
        <%}%></td>
      <td class="thinborder" align="center"> <a href='javascript:ViewDetail("<%=(String)vRetResult.elementAt(i + 1)%>");'><img src="../images/view_collection_dtls.gif" border="0"></a> 
      </td>
      <td class="thinborder" align="center"> <%if(bolIsLoggedIn){%> <a href='javascript:MyCollection("<%=(String)vRetResult.elementAt(i + 1)%>");'><img src="../images/my_collection.gif" border="0"></a> 
        <%}else if(i == 0){%>
        <strong>Log in reqd.</strong>
        <%}else{%>
        &nbsp;
        <%}%> </td>
      <td class="thinborder" align="center"> <%if(bolIsLoggedIn){%> <a href='javascrpt:Reserve("<%=(String)vRetResult.elementAt(i + 1)%>");'><img src="../images/reserve.gif" border="0"></a> 
        <%}else if(i == 0){%>
        <strong>Log in reqd.</strong>
        <%}else{%>
        &nbsp;
        <%}%> </td>
    </tr>
    <%}%>
  </table>
<%}//end of vRetResult not null.%>
<input type="hidden" name="searchCollection" value="<%=WI.fillTextValue("searchCollection")%>">
<input type="hidden" name="print_pg">
<input type="hidden" name="iAccessLevel" value="<%=iAccessLevel%>">
<!-- Instruction -- set the opner_from_name to the parent window to copy the student ID -->
<input type="hidden" name="opner_info" value="<%=WI.fillTextValue("opner_info")%>">
<input type="hidden" name="opner_info2" value="<%=WI.fillTextValue("opner_info2")%>">
<input type="hidden" name="opner_info2_val" value="<%=WI.fillTextValue("opner_info2_val")%>">

</form>
</body>
</html>
<%
dbOP.cleanUP();
%>