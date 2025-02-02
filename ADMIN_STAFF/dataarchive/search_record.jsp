<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>

<title>Search Record</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../css/fontstyle.css" rel="stylesheet" type="text/css">
</head>

<script language="javascript">
function PrintPg() {
	document.form_.print_pg.value = "1";
	document.form_.submit();	
}
function ReloadPage()
{
	document.form_.searchRecord.value = "";
	document.form_.print_pg.value = "";
	document.form_.submit();
}
function SearchRecord()
{
	document.form_.searchRecord.value = "1";
	document.form_.print_pg.value = "";
	document.form_.submit();
}
function ViewDetail(strRecordIndex)
{
//popup window here. 
	var pgLoc = "./record_viewprint.jsp?info_index="+strRecordIndex;
	var win=window.open(pgLoc,"EditWindow",'width=800,height=450,top=10,left=0,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function SetSelectValue(strRecordNo)
{
	document.form_.selectValue.value = strRecordNo;
}
</script>

<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*,dataarchive.Search,java.util.Vector" %>
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
	Vector vRetResult = null;

// if this page is calling print page, i have to forward page to print page.
	if(WI.fillTextValue("print_pg").compareTo("1") == 0) {%>
		<jsp:forward page="./search_record_print.jsp" />
	<%	return;
	}

	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Data Archive-SEARCH","search_record.jsp");
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
	//authenticate this user.
	CommonUtil comUtil = new CommonUtil();
	int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
															"Data Archive","Search",request.getRemoteAddr(),
															"search_record.jsp");
	if(iAccessLevel == -1)//for fatal error.
	{
		dbOP.cleanUP();
		request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		request.getSession(false).setAttribute("errorMessage",comUtil.getErrMsg());
		response.sendRedirect("../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0)//NOT AUTHORIZED.
	{
		dbOP.cleanUP();
		response.sendRedirect("../../commfile/unauthorized_page.jsp");
		return;
	}
	
//end of authenticaion code.
String[] astrDropListEqual    = {"Equal to","Starts with","Ends with","Contains"};
String[] astrDropListValEqual = {"equals","starts","ends","contains"};
String[] astrDropListGT       = {"Equal to","Less than","More than"};
String[] astrSortByName       = {"Category","Record Number","First Name","Last Name"};
String[] astrSortByVal        = {"DA_RECORD.catg_index","record_no","fname","lname"};


int iSearchResult = 0;

Search searchRecord = new Search(request);
if(WI.fillTextValue("searchRecord").compareTo("1") == 0){
	vRetResult = searchRecord.searchRecord(dbOP);
	if(vRetResult == null)
		strErrMsg = searchRecord.getErrMsg();
	else	
		iSearchResult = searchRecord.getSearchCount();
}

%>
<form method="post" action="./search_record.jsp" name="form_">
<table width="100%" border="0">
  <tr>
    <td height="25" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF" ><strong>::: 
        SEARCH ARCHIVE :::</strong></font></div></td>
  </tr>
</table>

  <table width="100%" border="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="10%">Category</td>
      <td width="12%"> <select name="catg_con">
          <%=searchRecord.constructGenericDropList(WI.fillTextValue("catg_con"),astrDropListEqual,astrDropListValEqual)%> </select> </td>
      <td colspan="2"> <input type="text" name="catg_name" value="<%=WI.fillTextValue("catg_name")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'"> 
      </td>
      <td>Record # 
        <select name="record_no_con">
          <%=searchRecord.constructGenericDropList(WI.fillTextValue("record_no_con"),astrDropListEqual,astrDropListValEqual)%> </select> <input type="text" name="record_no" value="<%=WI.fillTextValue("record_no")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'"> 
      </td>
    </tr>
    <tr> 
      <td>Lastname</td>
      <td><select name="lname_con">
          <%=searchRecord.constructGenericDropList(WI.fillTextValue("lname_con"),astrDropListEqual,astrDropListValEqual)%> </select></td>
      <td colspan="2"> <input type="text" name="lname" value="<%=WI.fillTextValue("lname")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'"> 
      </td>
      <td>Year Grad: 
        <input name="year_grad" type="text" size="5" maxlength="4" class="textbox"
		onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'" value="<%=WI.fillTextValue("year_grad")%>"> 
      </td>
    </tr>
    <tr> 
      <td>Firstname</td>
      <td><select name="fname_con">
          <%=searchRecord.constructGenericDropList(WI.fillTextValue("fname_con"),astrDropListEqual,astrDropListValEqual)%> </select></td>
      <td colspan="2"> <input type="text" name="fname" value="<%=WI.fillTextValue("fname")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'"> 
      </td>
      <td>CD Vol # : 
        <select name="cd_vol_no_con">
          <%=searchRecord.constructGenericDropList(WI.fillTextValue("cd_vol_no_con"),astrDropListEqual,astrDropListValEqual)%> </select> <input type="text" name="cd_vol_no" value="<%=WI.fillTextValue("cd_vol_no")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'"></td>
    </tr>
    <tr> 
      <td>Course</td>
      <td colspan="4"><select name="course_index" onChange="ReloadPage();">
          <option value="">ANY</option>
          <%=dbOP.loadCombo("course_index","course_name"," from course_offered where IS_DEL=0 and is_valid=1 "+
 						" order by course_name asc", request.getParameter("course_index"), false)%> 
        </select></td>
    </tr>
    <tr> 
      <td>Major</td>
      <td colspan="4"><select name="major_index">
          <option value="">ANY</option>
          <%
if(WI.fillTextValue("course_index").length()>0){
 strTemp = " from major where IS_DEL=0 and course_index="+request.getParameter("course_index")+" order by major_name asc";
%>
          <%=dbOP.loadCombo("major_index","major_name"," from major where IS_DEL=0 and course_index="+
 			request.getParameter("course_index")+" order by major_name asc", request.getParameter("major_index"), false)%> 
          <%}%>
        </select></td>
    </tr>
    <tr> 
      <td></td>
      <td colspan="3">&nbsp; </td>
      <td>&nbsp;</td>
    </tr>
    <tr> 
      <td>Sort Result</td>
      <td colspan="3"><select name="sort_by1">
          <option value="">N/A</option>
          <%=searchRecord.constructSortByDropList(WI.fillTextValue("sort_by1"),astrSortByName,astrSortByVal)%> </select> <select name="sort_by1_con">
          <option value="asc">Ascending</option>
          <%
if(WI.fillTextValue("sort_by1_con").compareTo("desc") ==0){%>
          <option value="desc" selected>Descending</option>
          <%}else{%>
          <option value="desc">Descending</option>
          <%}%>
        </select></td>
      <td><select name="sort_by2">
          <option value="">N/A</option>
          <%=searchRecord.constructSortByDropList(WI.fillTextValue("sort_by2"),astrSortByName,astrSortByVal)%> </select> <select name="sort_by2_con">
          <option value="asc">Ascending</option>
          <%
if(WI.fillTextValue("sort_by2_con").compareTo("desc") ==0){%>
          <option value="desc" selected>Descending</option>
          <%}else{%>
          <option value="desc">Descending</option>
          <%}%>
        </select></td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td colspan="4"><input type="image" src="../../images/form_proceed.gif" onClick="SearchRecord();"></td>
    </tr>
<%
if(strErrMsg != null){%>
    <tr>
      <td>&nbsp;</td>
      <td colspan="4"><font size="3"><%=strErrMsg%></font></td>
    </tr>
<%}%>
  </table>
<%
if(vRetResult != null && vRetResult.size() > 0){%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="25" colspan="3"><div align="right">
	  <a href="javascript:PrintPg();"><img src="../../images/print.gif" border="0"></a> 
          <font size="1">click to print result</font></div></td>
    </tr>
    <tr>
      <td height="25" colspan="3" bgcolor="#003399"><div align="center"><strong><font color="#FFFFFF">SEARCH
          RESULT</font></strong></div></td>
    </tr>
    <tr>
      <td width="66%" ><b> Total Students : <%=iSearchResult%> - Showing(<%=searchRecord.getDisplayRange()%>)</b></td>
      <td width="34%">
        <%
	  //if more than one page , constuct page count list here.  - 20 default display per page)
		int iPageCount = iSearchResult/searchRecord.defSearchSize;
		if(iSearchResult % searchRecord.defSearchSize > 0) ++iPageCount;

		if(iPageCount > 1)
		{%>
        <div align="right">Jump To page:
          <select name="jumpto" onChange="SearchRecord();">
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

  <table width="100%" border="1" bgcolor="#FFFFFF" cellpadding="0" cellspacing="0">
    <tr> 
      <td width="18%" height="25"><div align="center"><font size="1"><strong>CATEGORY 
          NAME </strong></font></div></td>
      <td width="15%"><div align="center"><font size="1"><strong>RECORD # </strong></font></div></td>
      <td width="18%"><div align="center"><font size="1"><strong>NAME (lname, 
          fname, mname)</strong></font></div></td>
      <td width="14%"><div align="center"><font size="1"><strong>CD VOL # </strong></font></div></td>
      <td width="18%"><div align="center"><font size="1"><strong>CD LOCATION </strong></font></div></td>
      <td width="18%"><font size="1"><strong>ARCHIVE FORMAT</strong></font></td>
      <td width="10%"><div align="center"><font size="1" ><strong>VIEW DETAIL 
          </strong></font></div></td>
    </tr>
    <%
for(int i = 0 ; i < vRetResult.size(); i +=10 ){%>
    <tr> 
      <td height="25"><%=(String)vRetResult.elementAt(i + 1)%></td>
      <td><%=(String)vRetResult.elementAt(i + 2)%></td>
      <td><%=(String)vRetResult.elementAt(i + 3)%>, <%=(String)vRetResult.elementAt(i + 4)%>,<%=WI.getStrValue(vRetResult.elementAt(i + 5))%></td>
      <td><%=WI.getStrValue(vRetResult.elementAt(i + 6),"&nbsp;")%></td>
      <td><%=WI.getStrValue(vRetResult.elementAt(i + 7),"&nbsp;")%></td>
      <td><%=(String)vRetResult.elementAt(i + 8)%></td>
      <td align="center"><a href='javascript:ViewDetail("<%=(String)vRetResult.elementAt(i)%>");'>
	  <img src="../../images/view.gif" border="0"></a></td>
    </tr>
<%}%>	
  </table>

  <table width="100%" border="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="50%" align="right">&nbsp; </td>
      <td width="50%">&nbsp;</td>
    </tr>
  </table>
<%}//only if return result is > 0%>	

<table width="100%" cellpadding="0" cellspacing="0" >
    <tr>
      <td height="25" bgcolor="#FFFFFF">&nbsp;</td>
    </tr>
    <tr>
      <td height="25" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
<input type="hidden" name="selectValue">
<input type="hidden" name="searchRecord" value="<%=WI.fillTextValue("searchRecord")%>">
<input type="hidden" name="print_pg">
 </form>

</body>
</html>
<%
dbOP.cleanUP();
%>