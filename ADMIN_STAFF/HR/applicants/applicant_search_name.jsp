<%@ page language="java" import="utility.*,hr.HRApplicantSearch,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	
	String strFormName = null;
	java.util.StringTokenizer strToken = new java.util.StringTokenizer(WI.fillTextValue("opner_info"),".");
	if(strToken.hasMoreElements()) {
		strFormName = strToken.nextToken();
	}
String[] strColorScheme = CommonUtil.getColorScheme(5);
//strColorScheme is never null. it has value always.
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Search Student</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/reportlink.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<style type="text/css">
td{
	font-size:11px;
}
</style>
<style type="text/css">
.bgDynamic {
	background-color:<%=strColorScheme[1]%>
}
.footerDynamic {
	background-color:<%=strColorScheme[2]%>
}
</style>
</head>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript">
function PrintPg() {
	document.search_util.print_pg.value = "1";
	document.search_util.invalidate_id.value = "";
	this.SubmitOnce('search_util');	
}
function ReloadPage()
{
	document.search_util.searchApplent.value = "";
	document.search_util.print_pg.value = "";
	document.search_util.invalidate_id.value = "";
	this.SubmitOnce('search_util');
}

function SetSearchResult(){
	document.search_util.show_result.value ="1";
}

function JumpToPage(){
	document.search_util.show_result.value ="1";
	document.search_util.submit();
}


<%
if(WI.fillTextValue("opner_info").length() > 0){%>
function CopyID(strStudID)
{
	window.opener.document.<%=WI.fillTextValue("opner_info")%>.value=strStudID;
	window.opener.focus();
	<%
	if(strFormName != null){%>
	window.opener.document.<%=strFormName%>.submit();
	<%}%>
	
	self.close();
}
<%}%>
</script>

<body bgcolor="#D2AE72" class="bgDynamic">
<%
	String strErrMsg = null;
	String strTemp = null;
	Vector vRetResult = null;

// if this page is calling print page, i have to forward page to print page.
	if(WI.fillTextValue("print_pg").compareTo("1") == 0) {%>
		<jsp:forward page="./applicant_search_name_print.jsp" />
	<%	return;
	}

	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-HR Management-Applicants Directory","applicant_search_name.jsp");
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

//Invalidate a temp student's enrollment if it is called.


String[] astrDropListEqual = {"Equal to","Starts with","Ends with","Contains"};
String[] astrDropListValEqual = {"equals","starts","ends","contains"};
String[] astrSortByName = {"Applicant ID","Last name","First name"};
String[] astrSortByVal  = {"applicant_id","lname","fname"};


int iSearchResult = 0;
String[] astrConvertPmt = {"","One Pmt","Two Pmt","","",""};
HRApplicantSearch searchAppl = new HRApplicantSearch(request);
if(WI.fillTextValue("show_result").equals("1")){
	vRetResult = searchAppl.searchApplicantName(dbOP);
	if(vRetResult == null)
		strErrMsg = searchAppl.getErrMsg();
	else	
		iSearchResult = searchAppl.getSearchCount();
}

%>
<form action="./applicant_search_name.jsp" method="post" name="search_util">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="4" bgcolor="#A49A6A" class="footerDynamic"><div align="center"><font color="#FFFFFF"><strong>:::: 
          APPLICANT SEARCH PAGE ::::</strong></font></div></td>
    </tr>
	</table>

  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25" colspan="6">&nbsp;&nbsp;&nbsp;&nbsp;<font size="3"><%=WI.getStrValue(strErrMsg)%></font></td>
    </tr>
    <tr> 
      <td width="3%" height="25">&nbsp;</td>
      <td width="11%">Applicant ID</td>
      <td width="10%"><select name="id_number_con">
          <%=searchAppl.constructGenericDropList(WI.fillTextValue("id_number_con"),astrDropListEqual,astrDropListValEqual)%> </select> </td>
      <td width="26%"><input type="text" name="id_number" value="<%=WI.fillTextValue("id_number")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
      <td width="9%"> Position</td>
      <td width="41%">&nbsp;<select name="position_applied">
	  <option value=""> ANY</option>
	  <%=dbOP.loadCombo("distinct position_applied","emp_type_name",
	  				" from hr_employment_type join hr_appl_user_table " + 
					" on (hr_employment_type.emp_type_index = hr_appl_user_table.position_applied) " + 
					" where hr_appl_user_table.is_valid = 1 order by emp_type_name",
					WI.fillTextValue("position_applied"), false)%>
	  </select>
	  </td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Lastname</td>
      <td><select name="lname_con">
          <%=searchAppl.constructGenericDropList(WI.fillTextValue("lname_con"),astrDropListEqual,astrDropListValEqual)%> </select></td>
      <td><input type="text" name="lname" value="<%=WI.fillTextValue("lname")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
      <td>Firstname</td>
      <td><select name="fname_con">
          <%=searchAppl.constructGenericDropList(WI.fillTextValue("fname_con"),astrDropListEqual,astrDropListValEqual)%> 
        </select>
        <input type="text" name="fname" value="<%=WI.fillTextValue("fname")%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
    </tr>
    <tr> 
      <td height="25" colspan="6"><hr size="1"></td>
    </tr>
  </table>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td  width="3%" height="25">&nbsp;</td>
      <td width="8%">Sort by</td>
      <td width="25%"> <select name="sort_by1">
          <option value="">N/A</option>
          <%=searchAppl.constructSortByDropList(WI.fillTextValue("sort_by1"),astrSortByName,astrSortByVal)%> </select> <select name="sort_by1_con">
          <option value="asc">Ascending</option>
          <%
if(WI.fillTextValue("sort_by1_con").compareTo("desc") ==0){%>
          <option value="desc" selected>Descending</option>
          <%}else{%>
          <option value="desc">Descending</option>
          <%}%>
        </select></td>
      <td width="25%"><select name="sort_by2">
          <option value="">N/A</option>
          <%=searchAppl.constructSortByDropList(WI.fillTextValue("sort_by2"),astrSortByName,astrSortByVal)%> </select> <select name="sort_by2_con">
          <option value="asc">Ascending</option>
          <% if(WI.fillTextValue("sort_by2_con").compareTo("desc") ==0){%>
          <option value="desc" selected>Descending</option>
          <%}else{%>
          <option value="desc">Descending</option>
          <%}%>
        </select></td>
      <td width="39%">&nbsp;</td>
      <td width="0%">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
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
      <td><input type="image" src="../../../images/form_proceed.gif" border="0" onClick="SetSearchResult()"></a></td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
  </table>
<%
if(vRetResult != null && vRetResult.size() > 0){%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="25" colspan="3" bgcolor="#FFFFFF" align="right">
	  <a href="javascript:PrintPg();"><img src="../../../images/print.gif" border="0"></a>
	  <font size="1">Click to print result</font></td>
    </tr>
    <tr>
      <td height="25" colspan="3" bgcolor="#B9B292"><div align="center"><strong><font color="#FFFFFF">SEARCH
          RESULT</font></strong></div></td>
    </tr>
    <tr>
      <td width="66%" height="42" ><b> Total Students : <%=iSearchResult%> - Showing(<%=searchAppl.getDisplayRange()%>)</b></td>
      <td width="34%">
        <%
	  //if more than one page , constuct page count list here.  - 20 default display per page)
	  
	if (searchAppl.defSearchSize != 0) {	  
	  
		int iPageCount = iSearchResult/searchAppl.defSearchSize;
		if(iSearchResult % searchAppl.defSearchSize > 0) ++iPageCount;

		if(iPageCount > 1)
		{%>
        <div align="right">Jump To page:
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
	        </div>
		  <%}
		  } // if defSearchSize != 0%>
        </td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF" class="thinborder">
    <tr> 
      <td  width="21%" height="25" class="thinborder" ><div align="center"><strong><font size="1">APPLICANT 
          ID </font></strong></div></td>
      <td width="41%" class="thinborder"><div align="center"><strong><font size="1">LNAME, FNAME, 
          MI </font></strong></div></td>
      <td width="38%" class="thinborder"><div align="center"><strong><font size="1">CONTACT INFORMATION</font></strong></div></td>
    </tr>
    <%
for(int i=0; i<vRetResult.size(); i+=6){%>
    <tr> 
      <td height="25" class="thinborder"><font size="1"> &nbsp; 
        <%if(WI.fillTextValue("opner_info").length() > 0) {%>
        <a href='javascript:CopyID("<%=(String)vRetResult.elementAt(i)%>");'> 
        <%=(String)vRetResult.elementAt(i)%></a> 
        <%}else{%>
        <%=(String)vRetResult.elementAt(i)%> 
        <%}%>
        </font></td>
      <td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+3)%>, <%=(String)vRetResult.elementAt(i+1)%> 
	  		<%=WI.getStrValue((String)vRetResult.elementAt(i+2)," ")%> </td>
			
<% strTemp = WI.getStrValue((String)vRetResult.elementAt(i+4));
   if (strTemp.length() == 0) 
   		strTemp = WI.getStrValue((String)vRetResult.elementAt(i+5));
	else
		strTemp += "<br>&nbsp; " + WI.getStrValue((String)vRetResult.elementAt(i+5));
%>
      <td class="thinborder">&nbsp; <%=strTemp%>
	  
      </td>
    </tr>
    <%}%>
  </table>
  <table  bgcolor="#FFFFFF"width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td width="69%" height="25"><div align="right"> </div></td>
      <td width="31%">&nbsp;</td>
    </tr>
  </table>
<%}//vRetResult is not null %>
  <table  bgcolor="#999900" width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr>
    <td height="25" bgcolor="#A49A6A" class="footerDynamic">&nbsp;</td>
  </tr>
</table>
<input type="hidden" name="show_result" value="0">
<input type="hidden" name="print_pg">
<input type="hidden" name="invalidate_id">

<!-- Instruction -- set the opner_from_name to the parent window to copy the student ID -->
<input type="hidden" name="opner_info" value="<%=WI.fillTextValue("opner_info")%>">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>