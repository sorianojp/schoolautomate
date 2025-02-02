<%@ page language="java" import="utility.*,java.util.Vector,hr.HRApplicantSearch" %>
<%
String[] strColorScheme = CommonUtil.getColorScheme(5);
//strColorScheme is never null. it has value always.
WebInterface WI = new WebInterface(request);
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<style type="text/css">
.bgDynamic {
	background-color:<%=strColorScheme[1]%>
}
.footerDynamic {
	background-color:<%=strColorScheme[2]%>
}
</style>
<head>
<title>HR Assessment</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">

<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript">
function  ShowList(bolReload){
	document.staff_profile.show_list.value="1";
	document.staff_profile.print_page.value = "";
	if(bolReload)
		document.staff_profile.submit();
}
function PrintPage(){
	document.staff_profile.print_page.value = "1";
	document.staff_profile.submit();
}
function View201(strRefID) {
	var loadPg = "./hr_applicant_201.jsp?appl_id="+strRefID;
	
	var win=window.open(loadPg,"myfile",'dependent=yes,width=700,height=600,top=0,left=0,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

<%
if(WI.fillTextValue("opner_info").length() > 0){%>
function CopyID(strStudID)
{
	window.opener.document.<%=WI.fillTextValue("opner_info")%>.value=strStudID;
	self.close();
	window.opener.focus();
}
<%}%>
</script>
<link href="../../css/fontstyle.css" rel="stylesheet" type="text/css">
<style>

TD{
	font-size:11px;
	font-family:Verdana;
}
SELECT{
	font-size:12px;
}

table.thinborder{
	border-top-width: 1px;
	border-right-width: 1px;
	border-top-style: solid;
	border-right-style: solid;
	border-top-color: #000000;
	border-right-color: #000000;
}
td.thinborder{
	font-family: Verdana, Arial, Helvetica, sans-serif;
	font-size: 11px;
	border-bottom-width: 1px;
	border-left-width: 1px;
	border-bottom-style: solid;
	border-left-style: solid;
	border-bottom-color: #000000;
	border-left-color: #000000;
}
</style>
</head>
<%
	DBOperation dbOP = null;	
	String strErrMsg = null;
	String strTemp = null;
	int iSearchResult = 0;
	
	if (WI.fillTextValue("print_page").equals("1")){ %>
	<jsp:forward page="./hr_applicant_viewall_print.jsp" /> 
<%	return;}	
try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-HR Management-REPORTS AND STATISTICS-Applicants","hr_applicant_viewall.jsp");

	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		if(strErrMsg == null)
		strErrMsg = "Error in opening DB Connection.";
		%>

		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		  Error in opening connection </font></p>
		<%
		return;
	}
//authenticate this user.
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"HR Management","APPLICANTS DIRECTORY",request.getRemoteAddr(),
														"hr_applicant_viewall.jsp");
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
Vector vRetResult = null;

HRApplicantSearch hrStat = new HRApplicantSearch (request);

if ( WI.fillTextValue("show_list").equals("1")){
	vRetResult = hrStat.searchApplicants(dbOP);
	
//	System.out.println(vRetResult);
	
	if(vRetResult == null)
		strErrMsg = hrStat.getErrMsg();
	else	
		iSearchResult = hrStat.getSearchCount();
		
//	System.out.println(strErrMsg);
}

String[] astrDropListEqual = {"Equal to","Starts with","Ends with","Contains"};
String[] astrDropListValEqual = {"equals","starts","ends","contains"};
String[] astrDropListGT = {"Equal","at least","at most"};
String[] astrDropListValGT = {"'='","'>='","'<='"};
String[] astrSortByName    = {"Reference ID", "Last Name","First Name","Date Application"};
String[] astrSortByVal     = {"APPLICANT_ID","lname","fname","APPLICATION_DATE"};

String[] astrIsSuitable ={ "&nbsp;",
						   "<img src=\"../../../images/tick.gif\">"};
						   
String[] astrConvertIntvStatus = {"REJECTED","ACCEPTED","PENDING","WL","---"};


boolean bolShowIntvResult = true;
if(WI.fillTextValue("remove_intv_result").length() > 0 && WI.fillTextValue("final_intv_result").length() == 0 &&
	WI.fillTextValue("ok_interview").length() == 0) {
	
	bolShowIntvResult = false;
}		
%>

<body bgcolor="#663300" class="bgDynamic">
<form action="./hr_applicant_viewall.jsp" method="post" name="staff_profile">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A"> 
      <td height="25" bgcolor="#A49A6A" class="footerDynamic"><div align="center"><font color="#FFFFFF" ><strong>:::: 
          APPLICANTS SUMMARY ::::</strong></font></div></td>
    </tr>
    <tr>
      <td height="25"><font color="#FF0000" size="3"><strong>&nbsp;<%=WI.getStrValue(strErrMsg)%></strong></font></td>
    </tr>
  </table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td width="100%" height="25"> 
        <table width="95%" border="0" align="center" cellpadding="5" cellspacing="0">
          <tr> 
            <td width="43%"> Position Applying for<br> <select name="emp_type_index">
                <option value="">All</option>
                <%=dbOP.loadCombo("distinct emp_type_index",
									"emp_type_name",
									" from HR_APPL_USER_TABLE join hr_employment_type " + 
									" on(hr_appl_user_table.POSITION_APPLIED = hr_employment_type.emp_type_index) " +
									" where HR_APPL_USER_TABLE.is_valid =1 ",WI.fillTextValue("emp_type_index"),false)%> </select></td>
            <td width="57%">Skills<br> <select name="skills_index">
                <option value="">Any</option>
                <%=dbOP.loadCombo("SKILL_NAME_INDEX","SKILL_NAME", " from HR_PRELOAD_SKILL_NAME order by skill_name",
								WI.fillTextValue("skills_index"),false)%> </select></td>
          </tr>
          <tr> 
            <td>Highest Educational <br> <select name="edu_type_index">
                <option value="">All</option>
                <%=dbOP.loadCombo("edu_type_index","edu_name",
					" from HR_PRELOAD_EDU_TYPE order by order_no", WI.fillTextValue("edu_type_index"),false)%> </select> </td>
            <td>License <br> <select name="license_index">
                <option value="">Any</option>
                <%=dbOP.loadCombo("license_index","license_name",
			  	" from hr_preload_license order by license_name", WI.fillTextValue("license_index"),false)%> </select></td>
          </tr>
          <tr> 
            <td>Experience : 
              <select name="exp_years_con">
                <%=hrStat.constructGenericDropList(WI.fillTextValue("exp_years_con"),astrDropListGT,astrDropListValGT)%> </select> 
				<input name="exp_years" type="text" size="4"  class="textbox"
			  	onBlur="style.backgroundColor='white';AllowOnlyFloat('staff_profile','exp_years')" 
				onFocus="style.backgroundColor='#D3EBFF'" value="<%=WI.fillTextValue("exp_years")%>"
			  	onKeyUp="AllowOnlyFloat('staff_profile','exp_years')">
            years</td>
            <td>
			<input type="checkbox" name="remove_intv_result" value="checked" <%=WI.fillTextValue("remove_intv_result")%>> 
			Remove Interview Result </td>
          </tr>
          <tr>
            <td> Course: 
	  <select name="degree_earned" style="font-size:10px; width:250px;">
          <option value=""> &nbsp;</option>
          <%=dbOP.loadCombo("distinct HR_APPL_INFO_EDU_HIST.degree_earned", "HR_APPL_INFO_EDU_HIST.degree_earned"," from HR_APPL_INFO_EDU_HIST where is_valid=1 order by HR_APPL_INFO_EDU_HIST.degree_earned",WI.fillTextValue("c_index"), false)%> 
	   </select>			</td>
            <td>Final Interview Result: 
			<select name="final_intv_result">
				<option value=""></option>
<%
strTemp = WI.fillTextValue("final_intv_result");
if(strTemp.equals("2"))
	strErrMsg = " selected";
else	
	strErrMsg = "";
%>
				<option value="2"<%=strErrMsg%>>Pending</option>
<%
strTemp = WI.fillTextValue("final_intv_result");
if(strTemp.equals("0"))
	strErrMsg = " selected";
else	
	strErrMsg = "";
%>
				<option value="0"<%=strErrMsg%>>Rejected</option>
<%
strTemp = WI.fillTextValue("final_intv_result");
if(strTemp.equals("3"))
	strErrMsg = " selected";
else	
	strErrMsg = "";
%>
				<option value="3"<%=strErrMsg%>>Waiting List</option>
<%
strTemp = WI.fillTextValue("final_intv_result");
if(strTemp.equals("1"))
	strErrMsg = " selected";
else	
	strErrMsg = "";
%>
				<option value="1"<%=strErrMsg%>>Accepted</option>
			</select>
			
			</td>
          </tr>
          <tr> 
            <td>Show Only Applicants suitable for Interivew 
<%
	if (WI.fillTextValue("ok_interview").equals("1"))
		strTemp = "checked";
	else
		strTemp = "";
%>
              <input type="checkbox" name="ok_interview" value="1" <%=strTemp%>> </td>
            <td><input type="image" src="../../../images/form_proceed.gif" width="81" height="21" onClick="ShowList(false)"></td>
          </tr>
          <tr> 
            <td colspan="2"><hr size="1" noshade></td>
          </tr>
          <tr> 
            <td colspan="2">Order by : 
              <select name="sort_by1">
          <option value="">N/A</option>
          <%=hrStat.constructSortByDropList(WI.fillTextValue("sort_by1"),astrSortByName,astrSortByVal)%> 
        </select> 
              <select name="sort_by1_con">
                <option value="asc">Ascending</option>
                <%
if(WI.fillTextValue("sort_by1_con").compareTo("desc") ==0){%>
                <option value="desc" selected>Descending</option>
                <%}else{%>
                <option value="desc">Descending</option>
                <%}%>
              </select> &nbsp;&nbsp;<select name="sort_by2">
          <option value="">N/A</option>
          <%=hrStat.constructSortByDropList(WI.fillTextValue("sort_by2"),astrSortByName,astrSortByVal)%> 
        </select> <select name="sort_by2_con">
                <option value="asc">Ascending</option>
                <% if(WI.fillTextValue("sort_by2_con").compareTo("desc") ==0){%>
                <option value="desc" selected>Descending</option>
                <%}else{%>
                <option value="desc">Descending</option>
                <%}%>
              </select> </td>
          </tr>
        </table>
      </td>
    </tr>
  </table>
<% if (vRetResult  != null && vRetResult.size() > 0)  {%>
  <table width="100%" border="0" align="center" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="66%" height="42" ><b> Total Result : <%=iSearchResult%> - Showing(<%=hrStat.getDisplayRange()%>)</b></td>
      <td width="34%">
        <%
	  //if more than one page , constuct page count list here.  - 20 default display per page)
	  
	if (hrStat.defSearchSize != 0) {	  
	  
		int iPageCount = iSearchResult/hrStat.defSearchSize;
		if(iSearchResult % hrStat.defSearchSize > 0) ++iPageCount;

		if(iPageCount > 1)
		{%>
        <div align="right">Jump To page:
          <select name="jumpto" onChange="ShowList(true);">
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
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr bgcolor="#FFFFCC"> 
      <td height="25" colspan="8" class="thinborderLEFT"><div align="center"><strong>LIST OF APPLICANTS</strong></div>
        <div align="center"></div></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr style="font-weight:bold" align="center"> 
      <td width="12%" height="25" class="thinborder"><font size="1">Reference ID</font></td>
      <td width="28%" class="thinborder"><font size="1">Name</font></td>
      <td width="20%" class="thinborder"><font size="1">Applicant Course</font></td>
      <td width="15%" class="thinborder"><font size="1">Application Date </font></td>
      <td width="24%" class="thinborder"><font size="1">Contact Information </font></td>
<%if(bolShowIntvResult) {%>
      <td width="10%" class="thinborder"><font size="1">Status</font></td>
      <td width="11%" class="thinborder"><font size="1">Suitable for Interview </font></td>
<%}%>
      <td width="6%" class="thinborder"><font size="1">View All Information</font></td>
    </tr>
<% for (int i = 0; i < vRetResult.size(); i+=11) {%>
    <tr> 
      <td height="25" class="thinborder">&nbsp;
        <%if(WI.fillTextValue("opner_info").length() > 0) {%>
        <a href='javascript:CopyID("<%=(String)vRetResult.elementAt(i+1)%>");'> 
        <%=(String)vRetResult.elementAt(i+1)%></a> 
        <%}else{%>			
				<%=(String)vRetResult.elementAt(i+1)%>
				<%}%>			
			</td>
      <td class="thinborder">&nbsp;<%=WI.formatName((String)vRetResult.elementAt(i+2),
	  												(String)vRetResult.elementAt(i+3),
													(String)vRetResult.elementAt(i+4),4)%></td>
      <td class="thinborder"><%=WI.getStrValue(vRetResult.elementAt(i+10),"&nbsp;")%></td>
      <td align="center" class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+7)%></td>
<% strTemp = WI.getStrValue((String)vRetResult.elementAt(i+5));
	if (WI.getStrValue((String)vRetResult.elementAt(i+6)).length() > 0) {
		if (strTemp.length() == 0)
			strTemp = WI.getStrValue((String)vRetResult.elementAt(i+6));
		else
			strTemp += "<br>&nbsp;" + WI.getStrValue((String)vRetResult.elementAt(i+6));
	}
%> 
      <td class="thinborder">&nbsp;<%=strTemp%></td>
<%if(bolShowIntvResult) {%>
      <td align="center" class="thinborder">
   <%=astrConvertIntvStatus[Integer.parseInt(WI.getStrValue((String)vRetResult.elementAt(i+9),"4"))]%>	   </td>
      <td align="center" class="thinborder">
	  <%=astrIsSuitable[Integer.parseInt(WI.getStrValue((String)vRetResult.elementAt(i+8), "0"))]%>	  </td>
<%}%>
      <td align="center" class="thinborder"><a href="javascript:View201('<%=(String)vRetResult.elementAt(i+1)%>')"><img src="../../../images/view.gif" border="0"></a>	  </td>
    </tr>
<%}%>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF">
    <tr> 
      <td height="25"  colspan="3"><div align="center"><a href="javascript:PrintPage()"><img src="../../../images/print.gif" border="0"></a><font size="1">click 
          to print summary</font></div></td>
    </tr>
  </table>
<%}%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="24">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25" bgcolor="#A49A6A" class="footerDynamic">&nbsp;</td>
    </tr>
  </table>
<input type="hidden" name="show_list" value="">
<input type="hidden" name="print_page" value="">
<input type="hidden" name="opner_info" value="<%=WI.fillTextValue("opner_info")%>">

</form>
</body>
</html>
<% 
	dbOP.cleanUP();
%>
