<%@ page language="java" import="utility.*, health.HMReports ,java.util.Vector " %>
<%
String[] strColorScheme = CommonUtil.getColorScheme(8);
//strColorScheme is never null. it has value always.
boolean bolIsSchool = false;
if( (new CommonUtil().getIsSchool(null)).equals("1"))
	bolIsSchool = true;

%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<script language="javascript"  src ="../../../jscript/common.js" ></script>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<style type="text/css">
.bgDynamic {
	background-color:<%=strColorScheme[1]%>
}
.footerDynamic {
	background-color:<%=strColorScheme[2]%>
}
</style>
</head>
<script language="JavaScript">
function ReloadPage()
{
	document.form_.print_page.value= "";
	document.form_.submit();
}
function StartSearch()
{
	document.form_.executeSearch.value = "1";
	document.form_.print_page.value= "";
	this.SubmitOnce('form_');
}

function PrintPg(){
	document.form_.print_page.value="1";
	this.SubmitOnce("form_");
}
</script>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	Vector vRetResult = null;
 
	String strInfoIndex = null;
	String strErrMsg = null;
	String strTemp = null;
	String strTemp2 = null;
	int iSearchResult = 0;
	String[] astrSortByName    = {"ID Number","FirstName", "Blood Group"};
	String[] astrSortByVal     = {"id_number","fname","bg"};
	
	if (WI.fillTextValue("print_page").length() > 0){ %>
		<jsp:forward page="./blood_group_report_print.jsp"/>
	<% return;}

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Health Monitoring-Clinic Visit Log","blood_group_report.jsp");
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
														"Health Monitoring","Clinic Visit Log",request.getRemoteAddr(),
														"blood_group_report.jsp");
if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
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
  String[] strConvertAlphabet = {"A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z"};
	HMReports hmReports = new HMReports();
	String[] astrDropListEqual = {"Equal to","Starts with","Ends with","Contains"};
	String[] astrDropListValEqual = {"equals","starts","ends","contains"};

	String[] astrList = {"Starts with","Ends with","Contains"};
	String[] astrListVal = {"starts","ends","contains"};

	
	if (WI.fillTextValue("executeSearch").compareTo("1")==0){
	vRetResult = hmReports.getBloodGroupList(dbOP, request);
	if(vRetResult == null)
		strErrMsg = hmReports.getErrMsg();
	else
		iSearchResult = hmReports.getSearchCount();
	
	if (strErrMsg == null)
		strErrMsg = hmReports.getErrMsg();
	}
%>
<body bgcolor="#8C9AAA" class="bgDynamic">
<form action="./blood_group_report.jsp" method="post" name="form_">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#697A8F"> 
      <td width="61%" height="28" class="footerDynamic"><div align="center"><font color="#FFFFFF" ><strong>:::: 
          BLOOD GROUP- LISTINGS PAGE ::::</strong></font></div></td>
    </tr>
    <tr bgcolor="#697A8F"> 
      <td height="18" bgcolor="#FFFFFF"><%=WI.getStrValue(strErrMsg)%></td>
    </tr>
  </table>
  
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
<%if(bolIsSchool){%>
	<tr bgcolor="#697A8F">
      <td width="3%" height="33" bgcolor="#FFFFFF">&nbsp;</td>
      <td width="16%" bgcolor="#FFFFFF">Patient option </td>
      <td width="81%" bgcolor="#FFFFFF">
			<select name="user_type">
        <option value="">Show All</option>
        <% if(WI.fillTextValue("user_type").equals("0")){%>
        <option value="0" selected>Show only Employees</option>
        <%}else{%>
        <option value="0">Show only Employees</option>
        <%}%>
        <% if(WI.fillTextValue("user_type").equals("1")){%>
        <option value="1" selected>Show only students</option>
        <%}else{%>
        <option value="1">Show only students</option>
        <%}%>				
      </select></td>
    </tr>
<%}//show only if called from school.. 
else{%>
	<input type="hidden" name="user_type" value="0">
<%}%>
    <tr bgcolor="#697A8F">
      <td width="3%" height="25" bgcolor="#FFFFFF">&nbsp;</td>
      <td width="16%" bgcolor="#FFFFFF">BLOOD GROUP</td>
      <td width="81%" bgcolor="#FFFFFF"><select name="group">
			<%
				strTemp = WI.fillTextValue("group");
			%>
				<option value="">All</option>
        <%if(strTemp.compareTo("1") ==0){%>
        <option value="1" selected>A</option>
        <%}else{%>
        <option value="1">A</option>
        <%}if(strTemp.compareTo("2") ==0){%>
        <option value="2" selected>B</option>
        <%}else{%>
        <option value="2">B</option>
        <%}if(strTemp.compareTo("3") ==0){%>
        <option value="3" selected>AB</option>
        <%}else{%>
        <option value="3">AB</option>
        <%}if(strTemp.compareTo("4") ==0){%>
        <option value="4" selected>O</option>
        <%}else{%>
        <option value="4">O</option>
        <%}%>
      </select>
        <select name="rh">
					<%
						strTemp = WI.fillTextValue("rh");
					%>
					<option value="">All</option>
					<%if(strTemp.compareTo("0") ==0){%>
          <option value="0" selected>+ve</option>
          <%}else{%>
          <option value="0">+ve</option>					
          <%}if(strTemp.compareTo("1") ==0){%>
          <option value="1" selected>-ve</option>
          <%}else{%>
          <option value="1">-ve</option>
          <%}%>
        </select></td>
    </tr>
    <tr bgcolor="#697A8F">
      <td height="25" bgcolor="#FFFFFF">&nbsp;</td>
      <td colspan="2" bgcolor="#FFFFFF">Search   whose lastname starts 
        with
        <select name="lname_from" onChange="ReloadPage();">
          <%
	 strTemp = WI.fillTextValue("lname_from");
	 int j = 0; //displays from and to to avoid conflict -- check the page ;-)
	 for(int i=0; i<26; ++i){
	 if(strTemp.compareTo(strConvertAlphabet[i]) ==0){
	 j = i; %>
          <option selected><%=strConvertAlphabet[i]%></option>
          <%}else{%>
          <option><%=strConvertAlphabet[i]%></option>
          <%}
			}%>
        </select>
to
<select name="lname_to">
  <option value="0"></option>
  <%
			 strTemp = WI.fillTextValue("lname_to");
			 
			 for(int i=++j; i<26; ++i){
			 if(strTemp.compareTo(strConvertAlphabet[i]) ==0){%>
  <option selected><%=strConvertAlphabet[i]%></option>
  <%}else{%>
  <option><%=strConvertAlphabet[i]%></option>
  <%}
		}%>
</select></td>
    </tr>
		<!--
		<%
			//String strCollegeIndex = WI.fillTextValue("c_index");
		%>
    <tr bgcolor="#697A8F">
      <td height="25" bgcolor="#FFFFFF">&nbsp;</td>
      <td bgcolor="#FFFFFF"><%//if(bolIsSchool){%>
		College
			<%//}else{%>
		Division
		<%//}%>		</td>
      <td bgcolor="#FFFFFF"><select name="c_index" onChange="ReloadPage();">
        <option value="">N/A</option>
        <%//=dbOP.loadCombo("c_index","c_name", " from college where is_del= 0", strCollegeIndex,false)%>
      </select></td>
    </tr>
    <tr bgcolor="#697A8F">
      <td height="25" bgcolor="#FFFFFF">&nbsp;</td>
      <td bgcolor="#FFFFFF">Department</td>
      <td bgcolor="#FFFFFF"><select name="d_index" onChange="ReloadPage();">
        <option value="">ALL</option>
        <%//if (strCollegeIndex.length() == 0){%>
        <%//=dbOP.loadCombo("d_index","d_name", " from department where is_del= 0", WI.fillTextValue("d_index"),false)%>
        <%//}else if (strCollegeIndex.length() > 0){%>
        <%//=dbOP.loadCombo("d_index","d_name", " from department where is_del= 0 and c_index = " + strCollegeIndex , WI.fillTextValue("d_index"),false)%>
        <%//}%>
      </select></td>
    </tr>
    <tr bgcolor="#697A8F">
      <td height="25" bgcolor="#FFFFFF">&nbsp;</td>
      <td bgcolor="#FFFFFF">Course</td>
      <td bgcolor="#FFFFFF"><select name="course_index" onChange="ReloadPage();">
        <option value="">N/A</option>
        <%//=dbOP.loadCombo("course_index","course_name"," from course_offered where IS_DEL=0 and is_valid=1 "+
 					//					" order by course_name asc", request.getParameter("course_index"), false)%>
      </select></td>
    </tr>
    <tr bgcolor="#697A8F">
      <td height="25" bgcolor="#FFFFFF">&nbsp;</td>
      <td bgcolor="#FFFFFF">Major</td>
      <td bgcolor="#FFFFFF"><select name="major_index">
          <option value="">N/A</option>
          <%
					//if(WI.fillTextValue("course_index").length()>0){
					//strTemp = " from major where IS_DEL=0 and course_index="+request.getParameter("course_index")+" order by major_name asc";
					%>
          <%//=dbOP.loadCombo("major_index","major_name"," from major where IS_DEL=0 and course_index="+
 						//	request.getParameter("course_index")+" order by major_name asc", request.getParameter("major_index"), false)%>
          <%//}%>
        </select>
        </td>
    </tr>
		-->
    <tr bgcolor="#697A8F">
      <td height="25" colspan="3" bgcolor="#FFFFFF"><hr size="1"></td>
    </tr>
    <tr bgcolor="#697A8F">
      <td height="25" bgcolor="#FFFFFF">&nbsp;</td>
      <td colspan="2" bgcolor="#FFFFFF">OPTION:</td>
    </tr>
    <tr bgcolor="#697A8F">
      <td height="25" bgcolor="#FFFFFF">&nbsp;</td>
			<%
				strTemp = WI.fillTextValue("show_not_set");
				
				if(strTemp.equals("1"))
					strTemp = " checked";
				else
					strTemp = "";				
			%>
      <td colspan="2" bgcolor="#FFFFFF"><input type="checkbox" value="1"<%=strTemp%> name="show_not_set">
      show also with no set blood group</td>
    </tr>
    <tr bgcolor="#697A8F"> 
      <td height="25" bgcolor="#FFFFFF">&nbsp;</td>
      <td colspan="2" bgcolor="#FFFFFF">SORT BY</td>
    </tr>
    <tr bgcolor="#697A8F"> 
      <td height="25" bgcolor="#FFFFFF">&nbsp;</td>
      <td colspan="2" bgcolor="#FFFFFF"><select name="sort_by1">
			<option value="">N/A</option>
	          <%=hmReports.constructSortByDropList(WI.fillTextValue("sort_by1"),astrSortByName,astrSortByVal)%> 
			</select>&nbsp;&nbsp;
			<select name="sort_by1_con">
				<option value="asc">Ascending</option>
			<% if(WI.fillTextValue("sort_by1_con").compareTo("desc") ==0){%>
	          <option value="desc" selected>Descending</option>
			<%}else{%>
	          <option value="desc">Descending</option>
			<%}%>
			</select>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
			<select name="sort_by2">
			<option value="">N/A</option>
	          <%=hmReports.constructSortByDropList(WI.fillTextValue("sort_by2"),astrSortByName,astrSortByVal)%> 
			</select>
			<select name="sort_by2_con">
					<option value="asc">Ascending</option>
			<% if(WI.fillTextValue("sort_by2_con").compareTo("desc") ==0){%>
	          <option value="desc" selected>Descending</option>
			<%}else{%>
	          <option value="desc">Descending</option>
			<%}%>
			</select></td>
    </tr>
    <tr bgcolor="#697A8F"> 
      <td height="43" bgcolor="#FFFFFF">&nbsp;</td>
      <td colspan="2" bgcolor="#FFFFFF"><a href="javascript:StartSearch();"><img src="../../../images/form_proceed.gif" border="0"></a></td>
    </tr>
  </table>
 <%if (vRetResult!=null && vRetResult.size()>0){%>
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <tr>
      <td align="right"><font size="2">Number of records per page :</font>
        <select name="num_rec_page">
          <% int iDefault = Integer.parseInt(WI.getStrValue(request.getParameter("num_rec_page"),"20"));
			for(int i =20; i <=45 ; i++) {
				if ( i == iDefault) {%>
          <option selected value="<%=i%>"><%=i%></option>
          <%}else{%>
          <option value="<%=i%>"><%=i%></option>
          <%}
			}%>
        </select>
        <a href="javascript:PrintPg()"> <img src="../../../images/print.gif" border="0"></a> <font size="1">click to print</font></td>
    </tr>
  </table>
  <table width="100%" border="0" bgcolor="#FFFFFF" class="thinborder" cellpadding="0" cellspacing="0">
    <tr bgcolor="#FFFF9F"> 
      <td height="25" colspan="3" align="center" class="thinborder"><strong><font size="2">BLOOD GROUP SEARCH RESULT </font></strong></td>
    </tr>
    <tr> 
      <td height="25" class="thinborder"><font size="1" face="Verdana, Arial, Helvetica, sans-serif">TOTAL 
        :<strong><%=iSearchResult%></strong></font></td>
      <td colspan="2" class="thinborder">  <div align="right"><font size="1"> 
          <%
	  //if more than one page , constuct page count list here.  - 20 default display per page)
		int iPageCount = iSearchResult/hmReports.defSearchSize;
		if(iSearchResult % hmReports.defSearchSize > 0) ++iPageCount;
		if(iPageCount > 1)
		{%>
          Jump To page: 
          <select name="jumpto" onChange="ReloadPage();">
            <%
			strTemp = request.getParameter("jumpto");
			if(strTemp == null || strTemp.trim().length() ==0) strTemp = "0";

			for( int i =1; i<= iPageCount; ++i )
			{
				if(i == Integer.parseInt(strTemp) ){%>
            <option selected value="<%=i%>"><%=i%> of <%=iPageCount%></option>
            <%}else{%>
            <option value="<%=i%>"><%=i%> of <%=iPageCount%></option>
            <%}}%>
          </select>
          <%} else {%>
          &nbsp; 
          <%}%></font>
          </div></td>
    </tr>
    <tr> 
      <td width="12%" height="25" align="center" class="thinborder"><font size="1"><strong>ID 
        #</strong></font></td>
      <td width="63%" align="center" class="thinborder"><font size="1"><strong>NAME</strong></font></td>
      <td width="25%" align="center" class="thinborder"><font size="1"><strong>BLOOD GROUP</strong></font></td>
    </tr>
    <%for(int i =0; i<vRetResult.size(); i+=8){%>
    <tr> 
      <td height="25" class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+1)%></td>
      <td class="thinborder">&nbsp;<%=WI.formatName((String)vRetResult.elementAt(i+2), (String)vRetResult.elementAt(i+3), (String)vRetResult.elementAt(i+4),4)%></td>
      <td class="thinborder">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i+7),"Not Set")%></td>
    </tr>
    <%}%>
  </table>
<%}%>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellpadding="0" cellspacing="0">
     <tr>
      <td height="10" colspan="9">&nbsp;</td>
    </tr>
    <tr>
      <td height="25" colspan="9" bgcolor="#697A8F" class="footerDynamic">&nbsp;</td>
    </tr>
  </table>
  <input type="hidden" name="executeSearch" value="<%=WI.fillTextValue("executeSearch")%>">
	<input type="hidden" name="print_page">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
