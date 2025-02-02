<%@ page language="java" import="utility.*,search.SearchStudent,java.util.Vector" %>
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	
	String strFormName = null;
	java.util.StringTokenizer strToken = new java.util.StringTokenizer(WI.fillTextValue("opner_info"),".");
	if(strToken.hasMoreElements())
		strFormName = strToken.nextToken();	
	
	if(WI.fillTextValue("print_pg").compareTo("1") == 0) {%>
		<jsp:forward page="./srch_stud_simple_print.jsp" />
	<%	return;
	}
String strSchCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchCode != null && strSchCode.startsWith("CIT") && WI.fillTextValue("forced_").length() == 0) {
	response.sendRedirect("./srch_stud_detail.jsp");
return;}

boolean bolMultipleEntry = WI.fillTextValue("multiple_entry").equals("1");
boolean bolPreventReload = false;
if(WI.fillTextValue("prevent_reload").length() > 0) 
	bolPreventReload = true;
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Search Student</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../css/reportlink.css" rel="stylesheet" type="text/css">
<link href="../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../jscript/common.js"></script>
<script language="JavaScript">
function PrintPg() {
	document.search_util.print_pg.value = "1";
	this.SubmitOnce("search_util");	
}
function ReloadPage()
{
	document.search_util.print_pg.value = "";
	document.search_util.searchStudent.value = "";
	this.SubmitOnce("search_util");
}
function SearchStudent()
{
	document.search_util.print_pg.value = "";
	document.search_util.searchStudent.value = "1";
	this.SubmitOnce("search_util");
}
function ViewDetail(strStudID)
{
//popup window here. 
	var pgLoc = "./stud_info_view.jsp?stud_id="+escape(strStudID);
	var win=window.open(pgLoc,"EditWindow",'width=924,height=450,top=10,left=0,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
<%
if(WI.fillTextValue("opner_info").length() > 0){%>
function CopyID(strStudID)
{
	<%if(bolMultipleEntry){%>
		if(window.opener.document.<%=WI.fillTextValue("opner_info")%>.value.length > 0) 
			window.opener.document.<%=WI.fillTextValue("opner_info")%>.value+=","+strStudID;
		else	
			window.opener.document.<%=WI.fillTextValue("opner_info")%>.value=strStudID;
		return;
	<%}else{%>
		window.opener.document.<%=WI.fillTextValue("opner_info")%>.value=strStudID;
	<%}%>
	
	<%
	if(strFormName != null && !bolPreventReload){%>
	window.opener.document.<%=strFormName%>.submit();
	<%}%>
	
	self.close();
	window.opener.focus();
}
<%}%>
function focusID() {
	document.search_util.lname.focus();
}
</script>

<body bgcolor="#D2AE72" onLoad="focusID();">
<%
	String strErrMsg = null;
	String strTemp = null;
	Vector vRetResult = null;

	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Students Affairs-SEARCH-Students","srch_stud.jsp");
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

String[] astrDropListEqual = {"Equal to","Starts with","Ends with","Contains"};
String[] astrDropListValEqual = {"equals","starts","ends","contains"};
String[] astrSortByName    = {"Student ID","Lastname","Firstname"};
String[] astrSortByVal     = {"id_number","lname","fname","gender"};


int iSearchResult = 0;

SearchStudent searchStud = new SearchStudent(request);
if(WI.fillTextValue("searchStudent").compareTo("1") == 0){
	vRetResult = searchStud.searchGeneric(dbOP);
	if(vRetResult == null)
		strErrMsg = searchStud.getErrMsg();
	else	
		iSearchResult = searchStud.getSearchCount();
}

%>
<form action="./srch_stud.jsp" method="post" name="search_util">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="4" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF"><strong>::::
          SEARCH STUDENT PAGE ::::</strong></font></div></td>
    </tr>
  </table>

  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25" colspan="6">&nbsp;&nbsp;&nbsp;&nbsp;<font size="3"><%=WI.getStrValue(strErrMsg)%></font></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td colspan="5"><a href="./srch_stud_detail.jsp?multiple_entry=<%=WI.fillTextValue("multiple_entry")%>&opner_info=<%=WI.fillTextValue("opner_info")%>&prevent_reload=<%=WI.fillTextValue("prevent_reload")%>">Go to comprehensive Search (slower than simple search) </a></td>
    </tr>
    <tr> 
      <td width="3%" height="25">&nbsp;</td>
      <td width="11%">Student ID </td>
      <td width="10%"><select name="id_number_con">
          <%=searchStud.constructGenericDropList(WI.fillTextValue("id_number_con"),astrDropListEqual,astrDropListValEqual)%> </select> </td>
      <td width="26%"><input type="text" name="id_number" value="<%=WI.fillTextValue("id_number")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
      <td width="8%">&nbsp;</td>
      <td width="42%">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Lastname</td>
      <td><select name="lname_con">
          <%=searchStud.constructGenericDropList(WI.fillTextValue("lname_con"),astrDropListEqual,astrDropListValEqual)%> </select></td>
      <td><input type="text" name="lname" value="<%=WI.fillTextValue("lname")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
      <td>Firstname</td>
      <td><select name="fname_con">
        <%=searchStud.constructGenericDropList(WI.fillTextValue("fname_con"),astrDropListEqual,astrDropListValEqual)%>
      </select>
      <input type="text" name="fname" value="<%=WI.fillTextValue("fname")%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
    </tr>
    
    <tr> 
      <td height="19" colspan="6"><hr size="1"></td>
    </tr>
  </table>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td  width="3%" height="25">&nbsp;</td>
      <td width="8%">Sort by</td>
      <td width="27%">
	  <select name="sort_by1" style="font-size:10px">
	 	<option value="">N/A</option>
          <%=searchStud.constructSortByDropList(WI.fillTextValue("sort_by1"),astrSortByName,astrSortByVal)%> 
      </select>
        <select name="sort_by1_con" style="font-size:10px">
          <option value="asc">Asc</option>
<%
if(WI.fillTextValue("sort_by1_con").compareTo("desc") ==0){%>
          <option value="desc" selected>Desc</option>
<%}else{%>
          <option value="desc">Desc</option>
<%}%>
        </select></td>
      <td width="28%"><select name="sort_by2" style="font-size:10px">
	 	<option value="">N/A</option>
          <%=searchStud.constructSortByDropList(WI.fillTextValue("sort_by2"),astrSortByName,astrSortByVal)%> 
        </select> 
        <select name="sort_by2_con" style="font-size:10px">
          <option value="asc">Asc</option>
<%
if(WI.fillTextValue("sort_by2_con").compareTo("desc") ==0){%>
          <option value="desc" selected>Desc</option>
<%}else{%>
          <option value="desc">Desc</option>
<%}%>
        </select></td>
      <td width="34%"><select name="sort_by3" style="font-size:10px">
	 	<option value="">N/A</option>
          <%=searchStud.constructSortByDropList(WI.fillTextValue("sort_by3"),astrSortByName,astrSortByVal)%> 
        </select> 
        <select name="sort_by3_con" style="font-size:10px">
          <option value="asc">Asc</option>
<%
if(WI.fillTextValue("sort_by3_con").compareTo("desc") ==0){%>
          <option value="desc" selected>Desc</option>
<%}else{%>
          <option value="desc">Desc</option>
<%}%>
        </select></td>
      <td width="0%">&nbsp;</td>
    </tr>
    <tr> 
      <td height="18">&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td><a href="javascript:SearchStudent();"><img src="../images/form_proceed.gif" border="0"></a></td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
  </table>
<%
if(vRetResult != null && vRetResult.size() > 0){%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="25" colspan="3" align="right"><a href="javascript:PrintPg();"><img src="../images/print.gif" border="0"></a></td>
    </tr>
    <tr> 
      <td height="25" colspan="3" bgcolor="#B9B292"><div align="center"><strong><font color="#FFFFFF">SEARCH 
          RESULT</font></strong></div></td>
    </tr>
    <tr> 
      <td width="66%" ><b> Total Students : <%=iSearchResult%> - Showing(<%=searchStud.getDisplayRange()%>)</b></td>
      <td width="34%" colspan="2"> <%
	  //if more than one page , constuct page count list here.  - 20 default display per page)
		int iPageCount = iSearchResult/searchStud.defSearchSize;
		if(iSearchResult % searchStud.defSearchSize > 0) ++iPageCount;

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

  <table  bgcolor="#FFFFFF" width="100%" border="1" cellspacing="0" cellpadding="0">
    <tr> 
      <td  width="10%" height="25" ><div align="center"><strong><font size="1">STUDENT D</font></strong></div></td>
      <td width="15%"><div align="center"><strong><font size="1">LASTNAME</font></strong></div></td>
      <td width="15%"><div align="center"><strong><font size="1">FIRSTNAME</font></strong></div></td>
      <td width="5%"><div align="center"><strong><font size="1">MIDDLE NAME </font></strong></div></td>
      <td width="5%"><div align="center"><strong><font size="1">VIEW DETAIL</font></strong></div></td>
    </tr>
    <%
for(int i=0; i<vRetResult.size(); i+=5){%>
    <tr> 
      <td height="25" valign="top"><font size="1"> 
        <%if(WI.fillTextValue("opner_info").length() > 0) {%>
        <a href='javascript:CopyID("<%=(String)vRetResult.elementAt(i+1)%>");'> 
        <%=(String)vRetResult.elementAt(i+1)%></a> 
        <%}else{%>
        <%=(String)vRetResult.elementAt(i+1)%> 
        <%}%>
        </font></td>
      <td height="25" valign="top"><font size="1"><%=(String)vRetResult.elementAt(i+2)%></font></td>
      <td valign="top"><font size="1">&nbsp;<%=(String)vRetResult.elementAt(i+3)%></font></td>
      <td valign="top">&nbsp;<font size="1"><%=WI.getStrValue(vRetResult.elementAt(i+4))%></font></td>
      <td align="center"><a href='javascript:ViewDetail("<%=(String)vRetResult.elementAt(i+1)%>");'><img src="../images/view.gif" width="34" height="25" border="0"></a></td>
    </tr>
<%}%>
  </table>
  <table  bgcolor="#FFFFFF"width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td width="69%" height="25"><div align="right"> </div></td>
      <td width="31%">&nbsp;</td>
    </tr>
  </table>
<%}//vRetResult is not null
%>
  <table  bgcolor="#999900" width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr>
    <td height="25" bgcolor="#A49A6A">&nbsp;</td>
  </tr>
</table>
<input type="hidden" name="print_pg">
<input type="hidden" name="searchStudent" value="<%=WI.fillTextValue("searchStudent")%>">
<!-- Instruction -- set the opner_from_name to the parent window to copy the student ID -->
<input type="hidden" name="opner_info" value="<%=WI.fillTextValue("opner_info")%>">

<!-- 0 = simple search -->
<input type="hidden" name="search_type" value="0">

<!-- if multiple_entry=1 , there is multiple entry in the field, so
i have to append and do not close the window and no reloading of parent wnd -->
<input type="hidden" name="multiple_entry" value="<%=WI.fillTextValue("multiple_entry")%>">

<input type="hidden" name="prevent_reload" value="<%=WI.fillTextValue("prevent_reload")%>">
<input type="hidden" name="forced_" value="<%=WI.fillTextValue("forced_")%>">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>