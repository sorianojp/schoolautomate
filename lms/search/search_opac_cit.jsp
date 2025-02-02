<%@ page language="java" import="utility.*,lms.Search,lms.LmsUtil,java.util.Vector" %>
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
	document.search_util.print_pg.value = "1";
	this.SubmitOnce("search_util");	
}
function ReloadPage(){
	
	document.search_util.searchCollection.value = "";
	document.search_util.print_pg.value = "";	
	document.form_.submit();
	
}
function GoToNext() {
	this.SearchCollection();
	this.SubmitOnce("search_util");	
}
function SearchCollection() {
	CallOnUnLoad();
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
	document.search_util.search_field1_val.focus();
}

////////// to show in progress.. 
	function CallOnLoad() {
		document.all.processing.style.visibility='hidden';	
		document.bgColor = "#F2DFD2";
	}
	function CallOnUnLoad() {
		document.all.processing.style.visibility='visible';	
		document.bgColor = "#DDDDDD";
		//alert("call on unload");
	}
	
/////////////// end of showing in progress..
</script>

<body onLoad="focusID();CallOnLoad();" bgcolor="#DDDDDD">
<!-- Printing information. -->
<div id="processing" style="position:absolute; top:0px; left:0px; width:250px; height:50px;  visibility:visible">
<table cellpadding=0 cellspacing=0 border=0 Width=100% Height=100% align=Center class="thinborderALL">
      <tr>
            <td align="center" class="v10blancong" bgcolor="#FFCC66">
			<p style="font-size:12px; font-weight:bold; font-family:Verdana, Arial, Helvetica, sans-serif"> Processing Request. Please wait...
			<br> <font color='red'>Loading Page <label id="page_progress"></label></font></p>
			
			<!--<img src="../../../Ajax/ajax-loader2.gif">--></td>
      </tr>
</table>
</div>

<%
	String strErrMsg  = null;
	String strTemp    = null;
	Vector vRetResult = null;
	String strTemp2   = null;
	try
	{
		dbOP = new DBOperation();
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

String[] astrDropListEqual = {"Any Keywords","All Keywords","Contains","Equal to","Starts with","Ends with"};
String[] astrDropListValEqual = {"any","all","contains","equals","starts","ends"};
String[] astrDropListBoolean = {"and","or","not"};
String[] astrDropListValBoolean = {"and","or","not"};
String[] astrSortByName    = {"Title","Author","Copyright"};
String[] astrSortByVal     = {"book_title","author_name","publisher_date"};



int iSearchResult = 0;
int iElemCount = 0;

Search searchBook = new Search(request);
if(WI.fillTextValue("searchCollection").compareTo("1") == 0){
	vRetResult = searchBook.searchBookOPAC(dbOP);	
	
	if(vRetResult == null)
		strErrMsg = searchBook.getErrMsg();
	else{
		iSearchResult = searchBook.getSearchCount();
		iElemCount = searchBook.getElemCount();
	}
}

boolean bolIsLoggedIn = false;
if( (String)request.getSession(false).getAttribute("userId") != null)
	bolIsLoggedIn = true;
int[] aiMaxBookAllowed  = null;

if(bolIsLoggedIn)
	aiMaxBookAllowed = new lms.LmsMyHome().maxBookListAllowed(dbOP, (String)request.getSession(false).getAttribute("userIndex"),false);

String strSchoolIndex = dbOP.getSchoolIndex();
if(strSchoolIndex == null)
	strSchoolIndex = "";
	
boolean bolShowSubject = true;
if(strSchoolIndex.startsWith("UI"))
	bolShowSubject = false;

%>
<form action="search_opac_cit.jsp" method="post" name="search_util">
  <table width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25" bgcolor="#A8A8D5"><div align="center"><font color="#FFFFFF" ><strong>:::: 
          Online Public Access (OPAC) ::::</strong></font></div></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;&nbsp;&nbsp;&nbsp;<font size="3" color="#FF0000"><%=WI.getStrValue(strErrMsg)%></font></td>
    </tr>
  </table>
	  
  <table width="100%" border="0" cellspacing="0" cellpadding="0">
    
	<tr>
      <td height="25">&nbsp;</td>
      <td colspan="3" class="thinborderNONE" style="font-weight:bold; font-size:10px;"><a href="search_acquisition_book.jsp?ctlg_search=2">Search for new acquired book</a></td>
    </tr>
	
    <tr>
      <td height="25">&nbsp;</td>
      <td colspan="3" class="thinborderNONE" style="font-weight:bold; font-size:10px;">Note : Please do not add commonly used words like a, an, the, in</td>
    </tr>
	
    <tr> 
      <td width="22" height="25">&nbsp;</td>
      <td width="63" height="25" class="thinborderNONE">
	  <select name="search_field1" style="font-size:11px;">	  
<%
strTemp = WI.fillTextValue("search_field1");
if(strTemp.equals("all"))
	strErrMsg = "selected";
else	
	strErrMsg = "";
%>		<option value="all" <%=strErrMsg%>>All</option>	
	
<%
if(strTemp.equals("author_name"))
	strErrMsg = "selected";
else	
	strErrMsg = "";
%>		<option value="author_name" <%=strErrMsg%>>Author</option>

<%	
if(strTemp.equals("publisher_date"))
	strErrMsg = "selected";
else	
	strErrMsg = "";
%>		<option value="publisher_date" <%=strErrMsg%>>Copyright</option>

<%	
if(strTemp.equals("publisher"))
	strErrMsg = "selected";
else	
	strErrMsg = "";
%>		<option value="publisher" <%=strErrMsg%>>Publisher</option>		

<%
if(strTemp.equals("term_type")  || strTemp.length() == 0)
	strErrMsg = "selected";
else	
	strErrMsg = "";
%>		<option value="term_type" <%=strErrMsg%>>Subject</option>

<%	
if(strTemp.equals("book_title"))
	strErrMsg = "selected";
else	
	strErrMsg = "";
%>		<option value="book_title" <%=strErrMsg%>>Title</option>
		

<%	
if(strTemp.equals("series_name"))
	strErrMsg = "selected";
else	
	strErrMsg = "";
%>		<option value="series_name" <%=strErrMsg%>>Series Title</option>

		
	  </select>	 
	  
	  
	  </td>
	  
	  
      <td width="781">
	  <select name="title_con" style="font-size:11px;">
	  <%
	  strTemp = WI.fillTextValue("title_con");
	  if(strTemp.length() == 0)
	  	strTemp = "all";
	  %>
<%=searchBook.constructGenericDropList(strTemp,astrDropListEqual,astrDropListValEqual)%> 
        </select>
	  <input name="search_field1_val" type="text" size="60" value="<%=WI.fillTextValue("search_field1_val")%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" style="font-size:11px;">
	  <select name="boolean_1" style="font-size:11px;">
<%=searchBook.constructGenericDropList(WI.fillTextValue("boolean_1"),astrDropListBoolean,astrDropListValBoolean)%> 
        </select></td>
    </tr>
  
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25" class="thinborderNONE">
		<select name="search_field3" style="font-size:11px;">
<%
strTemp = WI.fillTextValue("search_field3");
if(strTemp.equals("all") || strTemp.length() == 0)
	strErrMsg = "selected";
else	
	strErrMsg = "";
%>		<option value="all" <%=strErrMsg%>>All</option>	

<%
if(strTemp.equals("author_name"))
	strErrMsg = "selected";
else	
	strErrMsg = "";
%>		<option value="author_name" <%=strErrMsg%>>Author</option>

<%	
if(strTemp.equals("publisher_date"))
	strErrMsg = "selected";
else	
	strErrMsg = "";
%>		<option value="publisher_date" <%=strErrMsg%>>Copyright</option>

<%	
if(strTemp.equals("publisher"))
	strErrMsg = "selected";
else	
	strErrMsg = "";
%>		<option value="publisher" <%=strErrMsg%>>Publisher</option>		

<%
if(strTemp.equals("term_type"))
	strErrMsg = "selected";
else	
	strErrMsg = "";
%>		<option value="term_type" <%=strErrMsg%>>Subject</option>

<%	
if(strTemp.equals("book_title"))
	strErrMsg = "selected";
else	
	strErrMsg = "";
%>		<option value="book_title" <%=strErrMsg%>>Title</option>

<%	
if(strTemp.equals("series_name"))
	strErrMsg = "selected";
else	
	strErrMsg = "";
%>		<option value="series_name" <%=strErrMsg%>>Series Title</option>



		  </select>	  </td>
		  
      <td colspan="2">
	  <select name="author_con" style="font-size:11px;">
<%=searchBook.constructGenericDropList(WI.fillTextValue("author_con"),astrDropListEqual,astrDropListValEqual)%> 
        </select>
	  <input name="search_field3_val" type="text" size="60" value="<%=WI.fillTextValue("search_field3_val")%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" style="font-size:11px;"></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25" colspan="3" class="thinborderNONE">Search in Library Location 
	  <select name="library_loc">
	  <option value="">Any</option>
<%=dbOP.loadCombo("LOC_INDEX","LOC_NAME"," from LMS_LIBRARY_LOC where exists (select * from lms_lc_main where lms_lc_main.loc_index = LMS_LIBRARY_LOC.loc_index) order by LOC_NAME",
WI.fillTextValue("library_loc"), false)%>	  
	  </select>
	  &nbsp;&nbsp;&nbsp;
<%
strTemp = WI.fillTextValue("show_available");
if(strTemp.equals("1") || request.getParameter("print_pg") == null)
	strTemp = " checked";
%>
	  <input type="checkbox" value="1" name="show_available" <%=strTemp%>>Show only Available books	  
	  &nbsp;&nbsp;&nbsp;
	  <input type="checkbox" value="checked" name="show_checkout" <%=WI.fillTextValue("show_checkout")%>> Show book for check out only	  </td>
    </tr>
<%if(bolShowSubject){%>
    <tr>
      <td height="25">&nbsp;</td>
      <td colspan="3" class="thinborderNONE">Select a Subject to display the reference book(s) : <font size="1">(Listed subjects are having reference books set in system)</font></td>
    </tr>
    <tr valign="top" >
      <td height="25">&nbsp;</td>
      <td colspan="3"><select name="sub_index" title="SELECT A  SUBJECT"
	  	style="font-size:11px;font-family: Verdana, Geneva, Arial, Helvetica, sans-serif; width:800px">
        <option value=""></option>
<%=dbOP.loadCombo("sub_index","sub_code +'&nbsp;&nbsp;&nbsp;('+sub_name+')' as s_code"," from subject where is_del=0 and exists (select * from lms_lc_target_subject where lms_lc_target_subject.sub_index = subject.sub_index) order by s_code",WI.fillTextValue("sub_index"), false)%>
      </select></td>
    </tr>
<%}%>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25" class="thinborderNONE">Sort By </td>
      <td colspan="2"><select name="sort_by1" style="font-size:11px;">
          <option value="">N/A</option>
          <%=searchBook.constructSortByDropList(WI.fillTextValue("sort_by1"),astrSortByName,astrSortByVal)%> 
        </select><select name="sort_by1_con" style="font-size:11px;">
          <option value="asc">Ascending</option>
          <%if(WI.fillTextValue("sort_by1_con").compareTo("desc") ==0){%>
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
      <td height="25" align="right"> &nbsp;
	  <!--<a href="javascript:PrintPg();"><img src="../images/print_recommend.gif" border="0"></a> 
        <font size="1">click to print result</font>--></td>
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
    <tr style="font-weight:bold"> 
      <td width="12%" height="25" class="thinborder" align="center" style="font-size:9px;">Collection Type</td>
      <td width="15%" class="thinborder" align="center" style="font-size:9px;">Call No - Location Symbol</td>
      <!--<td width="6%" class="thinborder" align="center" style="font-size:9px;">Total Number of Copy </td>
      <td width="6%" class="thinborder" align="center" style="font-size:9px;">Copies Not Checked out </td>-->
      <td width="25%" class="thinborder" align="center" style="font-size:9px;">Title ::: Sub-Title</td>
      <td width="15%" class="thinborder" align="center" style="font-size:9px;">Author</td>
	  <td width="6%"  class="thinborder" align="center" style="font-size:9px;">Copyright</td>
	  <td width="9%"  class="thinborder" align="center" style="font-size:9px;">Location</td>
      <td width="6%"  class="thinborder" align="center" style="font-size:9px;">Book Status</td>
      <td width="6%"  class="thinborder" align="center" style="font-size:9px;">View Detail</td>
      
    </tr>
    <%String strCheckOutColor = "";
	//i for vRetResult; j for vLmsUtil; k for copydetail
		
for(int i = 0; i < vRetResult.size(); i+=iElemCount){
	
	if( ((String)vRetResult.elementAt(i + 15)).compareTo("0") == 0) 
		strCheckOutColor = " bgcolor=#DDDDDD";
	else	
		strCheckOutColor = "";%>
    <tr<%=strCheckOutColor%>> 
		<%
	strTemp = WI.getStrValue((String)vRetResult.elementAt(i + 11));
	%>
      <td height="25" class="thinborder">&nbsp;<%if(strTemp.length() > 0){%>
	  <font size="1"><img src="../images/<%=(String)vRetResult.elementAt(i + 12)%>" border="1">
	  &nbsp;<%=strTemp%></font><%}else{%>N/A<%}%></td>	  
	  
	  <%//strTemp = (String)vLmsUtil.elementAt(j+2)+"/"+(String)vLmsUtil.elementAt(j+1)+"/"+(String)vLmsUtil.elementAt(j+3)+" - "+(String)vLmsUtil.elementAt(j);%>
	  
      <td class="thinborder">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i + 5),"N/A")%></td>
	  
      <!--<td class="thinborder">&nbsp;<%=vRetResult.elementAt(i + 20)%></td>
      <td class="thinborder">&nbsp;<%=vRetResult.elementAt(i + 19)%></td>-->
      <td class="thinborder"><font size="1">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i + 3))%><br>&nbsp;
	  <%=WI.getStrValue((String)vRetResult.elementAt(i + 4))%></font></td>	  
      <td class="thinborder"><font size="1">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i + 13),"N/A")%></font></td>
      <td class="thinborder"><font size="1">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i + 6),"N/A")%></font></td>
	  <td class="thinborder"><font size="1">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i + 15),"N/A")%></font></td>
	  <td class="thinborder"><font size="1">&nbsp;
	  <%if(strCheckOutColor.length() > 0) {%><br>
	  	(For Library Use)
	  <%}else{%>
	  	<%=(String)vRetResult.elementAt(i+10)%>
	  <%}%>
	  </font></td>
	  
      <td class="thinborder" align="center">
	  <a href='javascript:ViewDetail("<%=(String)vRetResult.elementAt(i + 1)%>");'><img src="../images/view_collection_dtls.gif" border="0"></a>        </td>
      
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