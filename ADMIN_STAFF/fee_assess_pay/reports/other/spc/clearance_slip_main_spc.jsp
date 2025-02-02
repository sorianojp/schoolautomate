<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<link href="../../../../../css/common.css" rel="stylesheet" type="text/css">
<link href="../../../../../css/fontstyle.css" rel="stylesheet" type="text/css">

</head>

<script language="JavaScript" src="../../../../../jscript/common.js"></script>

<script language="JavaScript">

function ReloadPage(){
	document.form_.print_page.value = "";
	document.form_.submit();
}

function PrintPage(){	
	if(document.form_.course_index.value == ""){
		alert("Please select course.");
		return;	
	}

	document.form_.print_page.value = "1";
	document.form_.submit();
}

</script>
<body bgcolor="#D2AE72" onLoad="document.form_.stud_id.focus();">
<%@ page language="java" import="utility.*,java.util.Vector " %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);

	String strErrMsg = null;
	String strTemp = null;
	
	
	if(WI.fillTextValue("print_page").length() > 0){%>
		<jsp:forward page="./clearance_slip_print_spc.jsp" ></jsp:forward>
	<%return;}

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Fee-Fee assessment & Payments-Reports-Clearance Slip",
								"clearance_slip_main_spc.jsp");
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
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,
											(String)request.getSession(false).getAttribute("userId"),
											"FEE ASSESSMENT & PAYMENTS","REPORTS",request.getRemoteAddr(),"clearance_slip_main_spc.jsp");

if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
	request.getSession(false).setAttribute("errorMessage","You are logged out. Please login again.");
	response.sendRedirect("../../../../../commfile/fatal_error.jsp");
	return;
}
else if(iAccessLevel == 0)//NOT AUTHORIZED.
{
	dbOP.cleanUP();
	response.sendRedirect("../../../../../commfile/unauthorized_page.jsp");
	return;
}

String strSYFrom = WI.fillTextValue("sy_from");
String strSem    = WI.fillTextValue("semester");

String strCourseIndex = WI.fillTextValue("course_index");
String strMajorIndex  = WI.fillTextValue("major_index");
String strYearLevel   = WI.fillTextValue("year_level");

%>

<form name="form_" action="clearance_slip_main_spc.jsp" method="post" >

  <table bgcolor="#FFFFFF"  width="100%" border="0" cellspacing="0" cellpadding="0" id="myADTable1">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="5" align="center" class="style3"><strong class="style3">::::
        CLEARANCE SLIP  ::::</strong></td>
    </tr>
    <tr>
      <td height="25" colspan="5">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<strong style="font-size:14px; color:#FF0000"><%=WI.getStrValue(strErrMsg)%></strong>&nbsp;         </td>
      </tr>

    <tr>
       <td width="3%">&nbsp;</td>      
      <td width="17%">&nbsp;&nbsp;SY-Term</td>
      <td colspan="3">
<%
strTemp = WI.fillTextValue("sy_from");
if(strTemp.length() == 0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from");	
//System.out.println((String)request.getSession(false).getAttribute("cur_sch_yr_from"));  
%>
        <input name="sy_from" type="text" size="4" maxlength="4" value="<%=WI.getStrValue(strTemp)%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeyUp='DisplaySYTo("form_","sy_from","sy_to")'>
to
<%
strTemp = WI.fillTextValue("sy_to");
if(strTemp.length() == 0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_to");	  
%>
<input name="sy_to" type="text" size="4" maxlength="4" value="<%=WI.getStrValue(strTemp)%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  readonly="yes"> 
- 
<select name="semester">
  <option value="1">1st Sem</option>
  <%
strTemp = WI.fillTextValue("semester");
if(strTemp.length() == 0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sem");
	
if(strTemp == null) 
	strTemp = "";
if(strTemp.compareTo("2") ==0){%>
  <option value="2" selected>2nd Sem</option>
  <%}else{%>
  <option value="2">2nd Sem</option>
  <%}if(strTemp.compareTo("3") ==0){%>
  <option value="3" selected>3rd Sem</option>
  <%}else{%>
  <option value="3">3rd Sem</option>
  <%}if(strTemp.compareTo("4") ==0){%>
  <option value="4" selected>4th Sem</option>
  <%}else{%>
  <option value="4">4th Sem</option>
  <%}if(strTemp.compareTo("0") ==0){%>
  <option value="0" selected>Summer</option>
  <%}else{%>
  <option value="0">Summer</option>
  <%}%>
</select> </td>
    </tr>
    
	 <tr>
		<td height="25" width="3%">&nbsp;</td>
		<td width="13%">&nbsp;&nbsp;College</td>
		<td colspan="4"><select name="c_index" style="width:400px;" onChange="ReloadPage();">
         <option value="">Select College</option>
          <%=dbOP.loadCombo("c_index","c_name"," from college where IS_DEL=0 order by c_name asc",
		  		request.getParameter("c_index"), false)%> </select></td>
	</tr>
	<tr>
		<td height="25" width="3%">&nbsp;</td>
		<td width="13%">&nbsp;&nbsp;Course</td>
		<td colspan="3">
		<%
		if(WI.fillTextValue("c_index").length() > 0)
		{
			strTemp = " from course_offered where IS_DEL=0 and is_valid=1 and is_offered = 1 and c_index="+WI.fillTextValue("c_index")+
					" order by course_code asc" ;
		}
		else
			strTemp = " from course_offered where IS_DEL=0 AND IS_VALID=1 and is_offered = 1 order by course_code asc";
		%>
			<select name="course_index" style="width:400px;">
				<option value="">Select Course</option>
				<%=dbOP.loadCombo("course_index","course_code, course_name", strTemp, WI.fillTextValue("course_index"),false)%>
			</select>
		</td>
	</tr>
	
	<tr>
		<td height="25" width="3%">&nbsp;</td>
		<td width="13%">&nbsp;&nbsp;Year Level</td>
		<td colspan="3">
		<select name="year_level">
			<option value="">Select Year Level</option>
		<%
		strTemp = WI.fillTextValue("year_level");
		if(strTemp.equals("1"))
			strErrMsg = "selected";
		else
			strErrMsg = "";
		%><option value="1" <%=strErrMsg%>>1st Year</option>
		<%
		if(strTemp.equals("2"))
			strErrMsg = "selected";
		else
			strErrMsg = "";
		%><option value="2" <%=strErrMsg%>>2nd Year</option>
		<%
		if(strTemp.equals("3"))
			strErrMsg = "selected";
		else
			strErrMsg = "";
		%><option value="3" <%=strErrMsg%>>3rd Year</option>
		<%
		if(strTemp.equals("4"))
			strErrMsg = "selected";
		else
			strErrMsg = "";
		%><option value="4" <%=strErrMsg%>>4th Year</option>
		<%
		if(strTemp.equals("5"))
			strErrMsg = "selected";
		else
			strErrMsg = "";
		%><option value="5" <%=strErrMsg%>>5th Year</option>
		<%
		if(strTemp.equals("6"))
			strErrMsg = "selected";
		else
			strErrMsg = "";
		%><option value="6" <%=strErrMsg%>>6th Year</option>
		</select>
		</td>
	</tr>
	<tr>
	   <td height="25">&nbsp;</td>
	   <td>&nbsp; Section</td>
	   <td colspan="3">
		<select name="section_name">
          <option value=""></option>
<%
String strCon = "";
strCourseIndex = WI.getStrValue(strCourseIndex, "0");
String strDegreeType = "select degree_type from course_offered where course_index = " + strCourseIndex;
strDegreeType = dbOP.getResultOfAQuery(strDegreeType, 0);

String strCurTableName =  "curriculum";

if(strDegreeType == null)
	strCurTableName = "curriculum";
else if (strDegreeType.equals("1")) 
	strCurTableName = "cculum_masters";

else if (strDegreeType.equals("2")) 
	strCurTableName = "cculum_medicine";




if (strCourseIndex.length() > 0 && !strCourseIndex.equals("0"))
	strCon = " and " + strCurTableName + ".course_index = " + strCourseIndex;
if (strMajorIndex.length() > 0)
	strCon = strCon + " and " + strCurTableName + ".major_index = " + strMajorIndex;
if (strYearLevel.length() > 0)
	strCon = strCon + " and " + strCurTableName + ".year = " + strYearLevel;




strTemp = " from e_sub_section  where e_sub_section.is_valid = 1 and e_sub_section.offering_sy_from ="+strSYFrom+" and offering_sem = "+strSem+
		"  and exists (select * from " + strCurTableName + " where sub_index = e_sub_section.sub_index " + strCon + ") order by section ";



%>
          <%=dbOP.loadCombo("distinct section","section",strTemp, WI.fillTextValue("section_name"), false)%>
          
        </select>
		</td>
	   </tr>
	 <tr><td colspan="3">&nbsp;</td></tr>
	 <tr><td colspan="2">&nbsp;</td><td><a href="javascript:PrintPage();"><img src="../../../../../images/print.gif" border="0"></a>
	 	<font size="1">Click to print clearance</font>
	 </td></tr>
  </table>
  


  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" id="myADTable4">
    <tr>
      <td colspan="8" height="25">&nbsp;</td>
    </tr>
    <tr>
      <td colspan="8" height="25" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>

<input type="hidden" name="print_page" value="" >
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
