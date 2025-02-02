<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../jscript/td.js"></script>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript">
function PrintPg() {
	document.getElementById('myADTable1').deleteRow(0);
	
	var oRows = document.getElementById('myADTable2').getElementsByTagName('tr');
	var iRowCount = oRows.length;
	oRows = document.getElementById('myADTable2');
	for(i = 0; i < iRowCount; ++i)
		oRow.deleteRow(0);

	document.getElementById('myADTable3').deleteRow(0);
	
	alert("Click OK to print this page");
	window.print();//called to remove rows, make bk white and call print.

}
function ReloadPage()
{
	document.form_.print_pg.value = "";
	document.form_.reloadPage.value = "1";
	document.form_.submit();
}
function ShowResult() {
	document.form_.print_pg.value = "";
	document.form_.reloadPage.value = "";
	document.form_.submit();
}
</script>
<body>
<%@ page language="java" import="utility.*,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	WebInterface WI  = new WebInterface(request);
	String strTemp   = null;
	String strErrMsg = null;
//add security here.
	try {
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Fee Assessment & Payments-REPORTS","list_stud_with_late_fine_spc.jsp");
	}
	catch(Exception exp) {
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
														"Fee Assessment & Payments","Reports",request.getRemoteAddr(),
														"list_stud_with_late_fine_spc.jsp");
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
String strSchCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchCode == null)
	strSchCode = "";

//end of authenticaion code.
Vector vRetResult = null;

if(WI.fillTextValue("sy_from").length() > 0 && WI.fillTextValue("semester").length() > 0 && WI.fillTextValue("reloadPage").length() ==0) {
	enrollment.ReportFeeAssessment REA = new enrollment.ReportFeeAssessment();
	if(strSchCode.startsWith("NEU"))
		vRetResult = REA.getStudListWithFineSPCVerson2(dbOP, request);
	else	
		vRetResult = REA.getStudListWithFineSPC(dbOP, request);
		
	if(vRetResult == null)
		strErrMsg = REA.getErrMsg();	
}

String[] astrConvertToSem = {"SUMMER","FIRST SEMESTER","SECOND SEMESTER",
						"THIRD SEMESTER","FOURTH SEMESTER"};

boolean bolIsBasic = false;
if(WI.fillTextValue("is_basic").length() > 0) 
	bolIsBasic = true;
	
%>
<form action="./list_stud_with_late_fine_spc.jsp" method="post" name="form_">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" id="myADTable1">
    <tr>
      <td width="100%" align="center" class="thinborderBOTTOM"><strong>:::: LIST OF STUDENTS WITH FINE ::::</strong></td>
    </tr>
  </table>

  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" id="myADTable2">
    <tr> 
      <td width="2%" height="25"></td>
      <td width="12%"><strong><%=WI.getStrValue(strErrMsg)%></strong></td>
      <td width="86%">&nbsp;</td>
    </tr>
    
    <tr> 
      <td height="25">&nbsp;</td>
      <td>SY-Term</td>
      <td> 
        <%
strTemp = WI.fillTextValue("sy_from");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
%> <input name="sy_from" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp='DisplaySYTo("form_","sy_from","sy_to")'>
        - 
        <%
strTemp = WI.fillTextValue("sy_to");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_to");
%> <input name="sy_to" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  readonly="yes">
        - 
        <select name="semester">
          <option value="">ALL</option>
          <%
strTemp = WI.fillTextValue("semester");
if(strTemp.length() ==0 && WI.fillTextValue("page_value").length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sem");
if(strTemp.compareTo("0") ==0){%>
          <option value="0" selected>Summer</option>
          <%}else{%>
          <option value="0">Summer</option>
          <%}if(strTemp.compareTo("1") ==0){%>
          <option value="1" selected>1st Sem</option>
          <%}else{%>
          <option value="1">1st Sem</option>
          <%}if(strTemp.compareTo("2") == 0){%>
          <option value="2" selected>2nd Sem</option>
          <%}else{%>
          <option value="2">2nd Sem</option>
          <%}if(strTemp.compareTo("3") == 0){%>
          <option value="3" selected>3rd Sem</option>
          <%}else{%>
          <option value="3">3rd Sem</option>
          <%}%>
        </select>      
		<font style="font-weight:bold; font-size:11px; color:#0000FF">
			  <input type="checkbox" name="is_basic" value="checked" <%=WI.fillTextValue("is_basic")%> onClick="document.form_.reloadPage.value='1';document.form_.submit();"> Process Report for Grade School 
		</font>			  
		</td>
    </tr>
    
<%if(!bolIsBasic){%>    
    <tr> 
      <td height="25"></td>
      <td>College</td>
      <td><select name="c_index" onChange="ReloadPage();">
          <option value="">All</option>
          <%=dbOP.loadCombo("c_index","c_name"," from college where IS_DEL=0 order by c_name asc",
		  		request.getParameter("c_index"), false)%> </select> </td>
    </tr>
    <tr> 
      <td height="25"></td>
      <td>Course</td>
      <td><select name="course_index" onChange="ReloadPage();">
          <option value="">All</option>
          <%
strTemp = WI.fillTextValue("c_index");
if(strTemp.length() > 0){%>
          <%=dbOP.loadCombo("course_index","course_name"," from course_offered where IS_DEL=0 and is_valid=1 and c_index="+strTemp+" order by course_name asc",
		  		request.getParameter("course_index"), false)%> 
          <%}%>
        </select> </td>
    </tr>
<!--
    <tr> 
      <td height="25"></td>
      <td></td>
      <td>Major</td>
      <td colspan="3"><select name="major_index" onChange="ReloadPage();">
          <option></option>
          <%
strTemp = WI.fillTextValue("course_index");
if(strTemp.compareTo("0") != 0 && strTemp.length() > 0)
{
strTemp = " from major where is_del=0 and course_index="+strTemp ;
%>
          <%=dbOP.loadCombo("major_index","major_name",strTemp, request.getParameter("major_index"), false)%> 
          <%}%>
        </select></td>
    </tr>
-->    <tr> 
      <td height="25"></td>
      <td>Year Level</td>
      <td><select name="year_level">
          <option value="">All</option>
          <%
strTemp =WI.fillTextValue("year_level");
if(strTemp.compareTo("1") ==0)
{%>
          <option value="1" selected>1st</option>
          <%}else{%>
          <option value="1">1st</option>
          <%}if(strTemp.compareTo("2") ==0){%>
          <option value="2" selected>2nd</option>
          <%}else{%>
          <option value="2">2nd</option>
          <%}if(strTemp.compareTo("3") ==0)
{%>
          <option value="3" selected>3rd</option>
          <%}else{%>
          <option value="3">3rd</option>
          <%}if(strTemp.compareTo("4") ==0)
{%>
          <option value="4" selected>4th</option>
          <%}else{%>
          <option value="4">4th</option>
          <%}if(strTemp.compareTo("5") ==0)
{%>
          <option value="5" selected>5th</option>
          <%}else{%>
          <option value="5">5th</option>
          <%}if(strTemp.compareTo("6") ==0)
{%>
          <option value="6" selected>6th</option>
          <%}else{%>
          <option value="6">6th</option>
          <%}%>
        </select> </td>
    </tr>
<%}else{%>
    <tr> 
      <td height="25"></td>
      <td>Grade Level</td>
      <td><select name="edu_level">
		<option value="">All</option>
          <%=dbOP.loadCombo("distinct edu_level","edu_level_name"," from bed_level_info order by edu_level", request.getParameter("edu_level"), false)%> 
		</select></td>
    </tr>
<%}%>
    <tr> 
      <td height="25"></td>
      <td>Student ID </td>
      <td>
	  <input name="id_number" type="text" size="16" value="<%=WI.fillTextValue("id_number")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
	  </td>
    </tr>
    <tr>
      <td height="25"></td>
      <td>&nbsp;</td>
      <td><input name="button" type="button" style="font-size:11px; height:25px;border: 1px solid #FF0000;" onClick="ShowResult();" value="Show Result"></td>
    </tr>
  </table>
<%if(vRetResult != null && vRetResult.size() > 0){%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" id="myADTable3">
    <tr> 
      <td><div align="right"><font size="1"><a href="javascript:PrintPg();"><img src="../../../images/print.gif" border="0"></a> 
          Click to print&nbsp;&nbsp;&nbsp;</font></div></td>
    </tr>
  </table>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td align="center"><font style="font-size:14px; font-weight:bold">
	  <%=SchoolInformation.getSchoolName(dbOP,true,false)%></font>
	  <br>
	  <%=astrConvertToSem[Integer.parseInt(WI.fillTextValue("semester"))]%>, <%=WI.fillTextValue("sy_from")%> - <%=WI.fillTextValue("sy_to")%><br><br>
	  List of Late Enrollment Fine
	  <div align="right" style="font-size:9px;">
	  	Date and time printed: <%=WI.getTodaysDateTime()%> 
	  </div>
	  </td>
    </tr>
  </table>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" class="thinborder">
    <tr style="font-weight:bold" align="center"> 
      <td width="4%" class="thinborder" style="font-size:9px;">Count</td>
      <td width="16%" height="24" class="thinborder" style="font-size:9px;">Student ID</td>
      <td width="35%" class="thinborder" style="font-size:9px;">Student Name</td>
      <td width="15%" class="thinborder" style="font-size:9px;">Course-Yr</td>
      <td width="15%" class="thinborder" style="font-size:9px;">Date Of Fine</td>
      <td width="15%" class="thinborder" style="font-size:9px;" align="right">Fine Amount</td>
    </tr>
	<%for(int i = 1; i < vRetResult.size(); i += 8) {%>
		<tr> 
		  <td width="4%" class="thinborder"><%=i/8 + 1%> </td>
		  <td width="16%" height="22" class="thinborder"><%=vRetResult.elementAt(i + 1)%></td>
		  <td width="35%" class="thinborder"><%=vRetResult.elementAt(i + 2)%></td>
		  <td width="15%" class="thinborder"><%=vRetResult.elementAt(i + 4)%><%=WI.getStrValue((String)vRetResult.elementAt(i + 5), " - ", "","")%></td>
		  <td width="15%" class="thinborder"><%=vRetResult.elementAt(i + 6)%></td>
		  <td width="15%" class="thinborder" align="right"><%=((String)vRetResult.elementAt(i + 7)).substring(1)%></td>
		</tr>
	<%}%>
  </table>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td align="right" style="font-weight:bold">Total Amount: <%=((String)vRetResult.remove(0)).substring(1)%></td>
    </tr>
  </table>
   
<%}//end if vRetResult is not null%>

<input type="hidden" name="reloadPage">
<input type="hidden" name="print_pg">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>