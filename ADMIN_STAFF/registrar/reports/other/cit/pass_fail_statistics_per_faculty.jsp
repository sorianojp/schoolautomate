<%@ page language="java" import="utility.*,java.util.Vector,enrollment.ReportRegistrar" %>
<%
	WebInterface WI = new WebInterface(request);
	String strCIndex = WI.getStrValue((String) request.getSession(false).getAttribute("info_faculty_basic.c_index"));
	String strDIndex = WI.getStrValue((String) request.getSession(false).getAttribute("info_faculty_basic.d_index"));
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
<title>Teller</title>
</head>
<link href="../../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../../css/reportlink.css" rel="stylesheet" type="text/css">
<link href="../../../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head><style type="text/css">
<!--
body {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 12px;
}
table{
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
}
td {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
 }

th {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
 }
-->
</style>
<script language="JavaScript" src="../../../../../jscript/common.js"></script>
<script language="JavaScript">
function ReloadPage(){
	document.form_.print_page.value = "";
	document.form_.submit();
}
function PageAction(){
   document.form_.proceed.value="1";
	this.ReloadPage();
}

function PrintPage(){
	document.form_.print_page.value = "1";
	document.form_.submit();
}
</script>
<body bgcolor="#D2AE72">
<%
	DBOperation dbOP = null;
	
	String strErrMsg = null;
	String strTemp   = null;
	
	if(WI.fillTextValue("print_page").length() > 0){%>
		<jsp:forward page="./pass_fail_statistics_per_faculty_print.jsp"></jsp:forward>
	<%return;}
	
    //add security here.

	try{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Enrollment-Other report","pass_fail_statistics_per_faculty.jsp");
	}
	catch(Exception exp){
		exp.printStackTrace();%>
        <p align="center"><font face="Verdana, Arial, Helvetica, sans-serif" size="3">Error in opening connection</font></p>
		<%return;
	}
	
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"Admin/staff-Registrar Management","REPORTS",request.getRemoteAddr(),
														"pass_fail_statistics_per_faculty.jsp");

if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
	request.getSession(false).setAttribute("errorMessage",comUtil.getErrMsg());
	response.sendRedirect("../../../../../commfile/fatal_error.jsp");
	return;
}
else if(iAccessLevel == 0)//NOT AUTHORIZED.
{
	dbOP.cleanUP();
	response.sendRedirect("../../../../../commfile/unauthorized_page.jsp");
	return;
}	
	
	
	
	String strCollegeName = null;	
	if(strCIndex.length() >0){
		strTemp =" select c_name from COLLEGE where C_INDEX ="+strCIndex;
		strCollegeName = dbOP.getResultOfAQuery(strTemp, 0);
	}
		
Vector vRetResult = null;
Vector vRetSubject = null;

String[] astrSortByName = {
	"Subject Code",
	"Subject Title",
	"Section",
	"Class size",
	"Pass Count",
	"Failed Count"
};
String[] astrSortByVal = {
	"sub_code",
	"sub_name",
	"section",
	"no_enrolled",
	"pass",
	"fail"
};
String[] astrSemester={"Summer", "First Semester", "Second Semester","Third Semester"};


ConstructSearch conSearch = new ConstructSearch();

enrollment.FacultyManagement FM = new enrollment.FacultyManagement();
ReportRegistrar RR = new ReportRegistrar();
String strFacultyIndex = WI.fillTextValue("faculty");

		
%>
<form name="form_" action="pass_fail_statistics_per_faculty.jsp" method="post">
<table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF" id="header">
	<tr bgcolor="#A49A6A" >
		<td height="25" colspan="5" align="center" style="font-weight:bold; color:#FFFFFF"> :::: 
		<%=WI.getStrValue(strCollegeName,"&nbsp;")%> ::::
		</td>
	</tr>
</table>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
	<tr>
		<td height="25" colspan="4">&nbsp;&nbsp;&nbsp;
		<font size="3"><strong><%=WI.getStrValue(strErrMsg)%></strong></font>		</td>
	</tr>
	<tr>
		<td width="6%" height="25">&nbsp;</td>
		<td>School Year:</td>
		<td width="83%" colspan="2">
		<%	strTemp = WI.fillTextValue("sy_from");
			if(strTemp.length() ==0)
				strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
		%>
		<input name="sy_from" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
		onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
		onKeyPress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
		onKeyUp='DisplaySYTo("form_","sy_from","sy_to")'>
		- 
		<%	strTemp = WI.fillTextValue("sy_to");
			if(strTemp.length() ==0)
				strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_to");
		%>
		<input name="sy_to" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
		onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
		readonly="yes"> - 
		<select name="semester">
		<option value="1">1st Sem</option>
		<%	strTemp = WI.fillTextValue("semester");
			if(strTemp.length() ==0)
			  strTemp = (String)request.getSession(false).getAttribute("cur_sem");
			  if(strTemp.compareTo("2") ==0){%>
			<option value="2" selected>2nd Sem</option>
			<%}else{%>
			<option value="2">2nd Sem</option>
			<%}if(strTemp.compareTo("3") ==0){%>
			<option value="3" selected>3rd Sem</option>
			<%}else{%>
			<option value="3">3rd Sem</option>
			<%}if(strTemp.compareTo("0") ==0){%>
			<option value="0" selected>Summer</option>
			<%}else{%>
			<option value="0">Summer</option>
			<%}%>
		</select>		</td>
	</tr>
	<tr>
		<td width="6%" height="25">&nbsp;</td>
		<td>Department :</td>
		<td colspan="2">
		<%  String strDepartment = null;
			if(strCIndex.length() >0 && strDIndex.length() > 0){
			strTemp = " select d_name from DEPARTMENT "
					+ " where IS_DEL= 0 "
					+ " AND C_INDEX ="+strCIndex 
					+ " and d_index= "+strDIndex;
			strDepartment = dbOP.getResultOfAQuery(strTemp, 0);
		%>
		<%=WI.getStrValue(strDepartment)%>
		<%	}else{%>
		<select name="department" onchange="ReloadPage();">
		<option value="0">Please select department</option>
		<%=dbOP.loadCombo(" D_INDEX "," D_NAME "," from DEPARTMENT where IS_DEL= 0 AND C_INDEX ="+strCIndex+" order by D_NAME asc",request.getParameter("department"), false)%>
		</select>
		<%	}%>		</td>
	</tr>	
	<tr>
		<td width="6%" height="25">&nbsp;</td>
		<td width="11%">Faculty:</td>
		<%  
			String strFacultyList = " from INFO_FACULTY_BASIC "
					+ " join USER_TABLE on "
					+ " (USER_TABLE.USER_INDEX = INFO_FACULTY_BASIC.USER_INDEX) " 
					+ " where INFO_FACULTY_BASIC.IS_VALID =1 "
					+ " and INFO_FACULTY_BASIC.IS_DEL= 0  "
					+ " and exists(select * from FACULTY_LOAD "
					+ " where IS_VALID = 1 and USER_INDEX= INFO_FACULTY_BASIC.USER_INDEX) ";
			if(strDIndex.length()>0)
				strFacultyList += " and D_INDEX= " +strDIndex;	  
			else
				strFacultyList += " and D_INDEX= " +request.getParameter("department");
			
			strFacultyList +=" order by lname";           
		%>
		<td colspan="2">
		<select name="faculty">		
		<option value="">Select All</option>
		<%=dbOP.loadCombo("INFO_FACULTY_BASIC.user_index","fname+ ' ' +lname",strFacultyList,request.getParameter("faculty"), false)%></select>		</td>
	</tr>
	<tr>
		<td height="3" colspan="4">&nbsp;</td>
	</tr>
	<tr>
		<td valign="top" colspan="4">
		<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr>
          	<td height="25" width="6%">&nbsp;</td>
		  	<td width="14%">&nbsp;&nbsp;Sort by: </td>
		  	<td width="20%">
				<select name="sort_by1">
					<option value="">N/A</option>
					<%=conSearch.constructSortByDropList(WI.fillTextValue("sort_by1"),astrSortByName,astrSortByVal)%>
				</select></td>
		    <td width="20%">
				<select name="sort_by2">
              		<option value="">N/A</option>
             		<%=conSearch.constructSortByDropList(WI.fillTextValue("sort_by2"),astrSortByName,astrSortByVal)%>
				</select></td>
		    <td width="40%">
				<select name="sort_by3">
					<option value="">N/A</option>
              		<%=conSearch.constructSortByDropList(WI.fillTextValue("sort_by3"),astrSortByName,astrSortByVal)%>
            	</select></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
		    <td>&nbsp;</td>
		    <td>
				<select name="sort_by1_con">
              		<option value="asc">Ascending</option>
              	<%if(WI.fillTextValue("sort_by1_con").equals("desc")){%>
              		<option value="desc" selected="selected">Descending</option>
              	<%}else{%>
              		<option value="desc">Descending</option>
              	<%}%>
				</select></td>
			<td>
				<select name="sort_by2_con">
              		<option value="asc">Ascending</option>
              	<%if(WI.fillTextValue("sort_by2_con").equals("desc")){%>
              		<option value="desc" selected="selected">Descending</option>
              	<%}else{%>
              		<option value="desc">Descending</option>
              	<%}%>
            	</select></td>
			<td>
				<select name="sort_by3_con">
              		<option value="asc">Ascending</option>
              	<%if(WI.fillTextValue("sort_by3_con").equals("desc")){%>
              		<option value="desc" selected="selected">Descending</option>
              	<%}else{%>
              		<option value="desc">Descending</option>
              	<%}%>
            	</select></td>
		</tr>
	</table>		</td>
	</tr>
	<tr>
		<td height="3" colspan="4">&nbsp;</td>
	</tr>
	<tr>
		<td height="25" colspan="2">&nbsp;</td>
		<td colspan="2"><a href="javascript:PageAction();">
		<img src="../../../../../images/form_proceed.gif" border="0"></a></td>
	</tr>
	<tr>
		<td height="25" colspan="4">&nbsp;</td>
	</tr>
	<tr>
		<td height="19" colspan="4"><hr size="1"></td>
	</tr>
</table>




<%
if(WI.fillTextValue("proceed").length()>0){ 


Vector vFacultyIndex = new Vector();	
if(strFacultyIndex.length() == 0){
	strTemp = "select INFO_FACULTY_BASIC.USER_INDEX "+strFacultyList;
	java.sql.ResultSet rs = dbOP.executeQuery(strTemp);
	while(rs.next())
		vFacultyIndex.addElement(rs.getString(1));
	rs.close();

}else
	vFacultyIndex.addElement(strFacultyIndex);
	

	
	
		

while(vFacultyIndex.size() > 0){
	strFacultyIndex = (String)vFacultyIndex.remove(0);
	
	
	strTemp = " and user_table.user_index = "+strFacultyIndex;
	
	vRetResult = FM.viewFacBasicWithLoadStat(dbOP, WI.fillTextValue("sy_from"), WI.fillTextValue("sy_to"), WI.fillTextValue("semester"),strTemp);
	if(vRetResult == null)
		strErrMsg = RR.getErrMsg();
	
	vRetSubject = RR.getPassFailPerFaculty(dbOP, request, strFacultyIndex);
	if(vRetSubject == null)
		strErrMsg = RR.getErrMsg();



if(vRetResult!= null && vRetResult.size()>0){%>
<table width="100%" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
	<tr>
		<td width="6%" height="25">&nbsp;</td>
		<td width="17%">Name:</td>
		<td width="77%"><%=WI.getStrValue((String)vRetResult.elementAt(2),"&nbsp;")%></td>
	</tr>
	<tr>
		<td height="25">&nbsp;</td>
		<td>Total Load:</td>
		<td><%=WI.getStrValue((String)vRetResult.elementAt(6),"0")%></td>
	</tr>
	
	<tr>
		<td height="25">&nbsp;</td>
		<td>College/Department:</td>
		<td><%=WI.getStrValue((String)vRetResult.elementAt(5),"0")%></td>
	</tr>
	
</table>
<%


if(vRetSubject != null && vRetSubject.size() > 0){

double dTemp = 0d;
osaGuidance.GDPsychologicalTestReport gdRpt = new osaGuidance.GDPsychologicalTestReport();
%>

<table width="100%" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
   <tr bgcolor="#A49A6A">
		<td height="25" colspan="8" align="center" style="font-weight:bold; color:#FFFFFF" class="thinborder">
		:::: Faculty Pass-Fail Statistics ::::</td>
   </tr>  
   <tr>
		<td width="13%" rowspan="2" align="center" class="thinborder"><strong>Subject Code</strong></td>
		<td width="37%" rowspan="2" align="center" class="thinborder"><strong>Subject Title</strong></td>
		<td width="22%" rowspan="2" align="center" class="thinborder"><strong>Section</strong></td>	
		<td width="8%" rowspan="2" align="center" class="thinborder"><strong>Class size</strong></td>
		<td height="25" colspan="2" align="center" class="thinborder"><strong>Pass</strong></td>
		<td colspan="2" align="center" class="thinborder"><strong>Fail</strong></td>
   </tr>
   <tr>
       <td width="5%" height="25" align="center" class="thinborder"><strong>Count</strong></td>
       <td width="5%" align="center" class="thinborder"><strong>%age</strong></td>
       <td width="5%" align="center" class="thinborder"><strong>Count</strong></td>
       <td width="5%" align="center" class="thinborder"><strong>%age</strong></td>
   </tr>
   <%for(int i=0; i<vRetSubject.size(); i+=10){%>
   <tr>
	   <td class="thinborder" height="25"><%=WI.getStrValue((String)vRetSubject.elementAt(i+1),"&nbsp;")%></td>   
	   <td class="thinborder"><%=WI.getStrValue((String)vRetSubject.elementAt(i+2),"&nbsp;")%></td>   
	   <td class="thinborder"><%=WI.getStrValue((String)vRetSubject.elementAt(i+3),"&nbsp;")%></td>   
	   <td class="thinborder" align="center"><%=WI.getStrValue((String)vRetSubject.elementAt(i+4),"0")%></td>
	   <td class="thinborder" align="center"><%=WI.getStrValue((String)vRetSubject.elementAt(i+5),"0")%></td>
	   <%
	   
	   strTemp = WI.getStrValue((String)vRetSubject.elementAt(i+4),"0");
	   strErrMsg =WI.getStrValue((String)vRetSubject.elementAt(i+5),"0");
	   
	   dTemp = gdRpt.getPercentage( Double.parseDouble(strErrMsg),  Double.parseDouble(strTemp), 100);
	   %>
	   <td class="thinborder" align="center"><%=CommonUtil.formatFloat(dTemp, 1)%></td>
	   <td class="thinborder" align="center"><%=WI.getStrValue((String)vRetSubject.elementAt(i+6),"0")%></td>
	   <%
	   
	   strTemp = WI.getStrValue((String)vRetSubject.elementAt(i+4),"0");
	   strErrMsg =WI.getStrValue((String)vRetSubject.elementAt(i+6),"0");
	   
	   dTemp = gdRpt.getPercentage( Double.parseDouble(strErrMsg),  Double.parseDouble(strTemp), 100);
	   %>
       <td class="thinborder" align="center"><%=CommonUtil.formatFloat(dTemp, 1)%></td>
   </tr>
   <%}//end of vRetSubject%>
</table>
<%}
}//end of vRetResult!= null && vRetResult.size()>0 && vRetSubject!=null && vRetSubject.size()>0 

}//end while%>
<table width="100%" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
	<tr><td align="right"><a href="javascript:PrintPage();"><img src="../../../../../images/print.gif" border="0" /></a>
		<font size="1">Click to print report</font>
	</td></tr>
</table>
<%}
%>  




<table width="100%" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
	<tr bgcolor="#FFFFFF">
		<td height="25"></td>
	</tr>
	<tr bgcolor="#A49A6A">
		<td height="25">&nbsp;</td>
	</tr>
</table>
<input type="hidden" name="proceed"/>
<input type="hidden" name="print_page" />
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
