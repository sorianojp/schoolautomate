<%
String strSchCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchCode == null)
	strSchCode = "";
boolean bolIsCGH = strSchCode.startsWith("CGH");//bolIsCGH = true;
boolean bolShowGWAPercent = false;
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../../jscript/td.js"></script>
<script language="JavaScript">
function ReloadPage()
{
	if(document.form_.course_index.selectedIndex >=0)
	{
		document.form_.cn.value = document.form_.course_index[document.form_.course_index.selectedIndex].text;
		<%if(!bolIsCGH){%>
			//document.form_.mn.value = document.form_.major_index[document.form_.major_index.selectedIndex].text;
		<%}%>
	}
	else
	{
		document.form_.cn.value = "";
		document.form_.mn.value = "";
	}
}
function PrintPage() {
	document.bgColor = "#FFFFFF";
	document.getElementById('myADTable1').deleteRow(0);
	document.getElementById('myADTable1').deleteRow(0);
	document.getElementById('myADTable1').deleteRow(0);
	document.getElementById('myADTable1').deleteRow(0);
	document.getElementById('myADTable1').deleteRow(0);
	document.getElementById('myADTable1').deleteRow(0);
	document.getElementById('myADTable1').deleteRow(0);

/**
	document.getElementById('myADTable2').deleteRow(0);
	document.getElementById('myADTable2').deleteRow(0);
	document.getElementById('myADTable2').deleteRow(0);
	document.getElementById('myADTable2').deleteRow(0);
	document.getElementById('myADTable2').deleteRow(0);
	document.getElementById('myADTable2').deleteRow(0);
**/
	document.getElementById('myADTable3').deleteRow(0);
	document.getElementById('myADTable3').deleteRow(0);

	document.getElementById('myADTable4').deleteRow(0);
	document.getElementById('myADTable4').deleteRow(0);
	
	alert("Click OK to print this page");
	window.print();//called to remove rows, make bk white and call print.
}
function SelectAll() {
	if(!document.form_.max_disp)
		return;
		
	var iMaxDisp = document.form_.max_disp.value;
	if(document.form_.sel_all.checked) {//check all.
		for( i = 0; i < eval(iMaxDisp); ++i)
			eval('document.form_.save_'+i+'.checked=true');
	}
	else {///uncheck all. 
		for( i = 0; i < eval(iMaxDisp); ++i)
			eval('document.form_.save_'+i+'.checked=false');
	}
}
function AutoCreate() {
	document.form_.auto_create.value = "1";
	document.form_.submit();
}
</script>
<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*,enrollment.GradeSystemExtn,java.util.Vector " %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);

	String strErrMsg = null;
	String strTemp = null;
	String[] astrConvertToSem = {"Summer","1st Sem","2nd Sem","3rd Sem","4th Sem"};
	String[] astrConvertToYear = {"","1st Year","2nd Year","3rd Year","4th Year","5th Year","6th Year"};

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Registrar Management-REPORT-Assign Section","assign_section.jsp");
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
														"Registrar Management","REPORTS",request.getRemoteAddr(),
														"assign_section.jsp");
if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
	request.getSession(false).setAttribute("errorMessage",comUtil.getErrMsg());
	response.sendRedirect("../../../../commfile/fatal_error.jsp");
	return;
}
else if(iAccessLevel == 0)//NOT AUTHORIZED.
{
	dbOP.cleanUP();
	response.sendRedirect("../../../../commfile/unauthorized_page.jsp");
	return;
}

//end of authenticaion code.
Vector vRetResult = null;
GradeSystemExtn gsE = new GradeSystemExtn();

if(WI.fillTextValue("auto_create").length() > 0)
	strErrMsg = gsE.autoCreateSection(dbOP, request);	

if(WI.fillTextValue("page_action").length() > 0) {
	if(gsE.operateOnAssignSection(dbOP, request, 1) != null) 
		strErrMsg = "Section information successfully updated.";
	else	
		strErrMsg = gsE.getErrMsg();
}


if(WI.fillTextValue("show_result").length() > 0 && WI.fillTextValue("sy_from").length() > 0) {
	if(WI.fillTextValue("show_notassigned").length() > 0) 
		vRetResult = gsE.operateOnAssignSection(dbOP, request, 5);
	else	
		vRetResult = gsE.operateOnAssignSection(dbOP, request, 4);
}
String strSectionList = null;
%>

<form name="form_" action="./assign_section.jsp" method="post" onSubmit="SubmitOnceButton(this);">
  <table bgcolor="#FFFFFF"  width="100%" border="0" cellspacing="0" cellpadding="0" id="myADTable1">
    <tr bgcolor="#A49A6A"> 
      <td height="25" colspan="4" align="center"><font color="#FFFFFF"><strong>:::: 
        ASSIGN SECTION PAGE ::::</strong></font></td>
    </tr>
    <tr> 
      <td width="2%" height="25" >&nbsp;</td>
      <td height="25" colspan="3" >&nbsp;&nbsp;&nbsp;<strong><%=WI.getStrValue(strErrMsg)%></strong></td>
    </tr>
    <tr> 
      <td height="25" >&nbsp;</td>
      <td >Course </td>
      <td colspan="2" ><select name="course_index" onChange="ReloadPage();">
          <%=dbOP.loadCombo("course_index","course_name",
		  " from course_offered where IS_DEL=0 and is_valid=1 and degree_type=0 and is_offered=1 order by course_name asc",
		  request.getParameter("course_index"), false)%> 
		 </select></td>
    </tr>
    <tr> 
      <td width="2%" height="25" >&nbsp;</td>
      <td width="8%" height="25" >SY/Term </td>
      <td width="41%" >
<%
strTemp = WI.fillTextValue("sy_from");
if(strTemp.length() == 0) 
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
if(strTemp == null)
	strTemp = "";
%>
		  <input name="sy_from" type="text" size="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="AllowOnlyInteger('form_','sy_from');style.backgroundColor='white'"
	  onKeyUp='AllowOnlyInteger("form_","sy_from");DisplaySYTo("form_","sy_from","sy_to")'>
        to 
<%
strTemp = WI.fillTextValue("sy_to");
if(strTemp.length() == 0) 
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_to");
if(strTemp == null)
	strTemp = "";
%>        <input name="sy_to" type="text" size="4" value="<%=strTemp%>" class="textbox"
		onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
		readonly="yes">
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
<select name="semester" onChange="ReloadPage();document.form_.submit()">
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
          <%}if(strTemp.compareTo("0") ==0){%>
          <option value="0" selected>Summer</option>
          <%}else{%>
          <option value="0">Summer</option>
          <%}%>
      </select></td>
      <td width="49%" >Year  
        <select name="year_level">
          <option value="1">1st</option>
          <%
strTemp = request.getParameter("year_level");
if(strTemp == null) strTemp = "";
if(strTemp.compareTo("2") ==0)
{%>
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
        </select></td>
    </tr>
    <tr>
      <td height="25" >&nbsp;</td>
      <td colspan="2" >	  
	  	<input name="show_notassigned" type="checkbox" value="checked" <%=WI.fillTextValue("show_notassigned")%>> 
	  	<font style="color:#0000FF; font-size:10px; font-weight:bold">Show Student not assigned Section </font>	  </td>
      <td>
	  <%if(WI.fillTextValue("sy_from").length() > 0){%>
	  	Section Name : 
		  <select name="section" onChange="ReloadPage();">
		  <option value="">Show ALL</option>
<%			
strSectionList = dbOP.loadCombo("distinct section","section", " from e_sub_section where IS_valid=1 and is_lec = 0 and offering_sy_from="+
			  WI.fillTextValue("sy_from")+" and offering_sem="+WI.fillTextValue("semester")+ " and exists (select * from curriculum where "+
			  " sub_index = e_sub_section.sub_index and course_index = "+WI.fillTextValue("course_index")+" and year="+WI.fillTextValue("year_level")+
			  " and is_valid = 1) order by e_sub_section.section",WI.fillTextValue("section"), false);%> 
			  <%=strSectionList%>
		 </select>
	  <%}%>	  </td>
    </tr>
    <tr>
      <td height="10" align="center">&nbsp;</td>
      <td height="10" colspan="3"><a href="javascript:AutoCreate();">Click to Auto create Section</a></td>
    </tr>
    <tr> 
      <td colspan="4" height="10" align="center">
	  	<input type="submit" name="1" value="Show Result" style="font-size:11px; height:28px;border: 1px solid #FF0000;" onClick="document.form_.show_result.value=1;document.form_.page_action.value=''">
	  </td>
    </tr>
  </table>
  <%
if(vRetResult != null && vRetResult.size() > 0){
%>
  <table bgcolor="#FFFFFF"  width="100%" border="0" cellspacing="0" cellpadding="0" class="thinborder">    
    <tr>
      <td class="thinborder" width="3%">SL #</td>
      <td class="thinborder" width="22%">Student ID </td>
      <td class="thinborder" width="35%">Student Name </td>
      <td class="thinborder" width="12%">Section </td>
      <td class="thinborder" width="18%">New Section </td>
      <td width="10%" class="thinborder" align="center">Select <br>
        <input type="checkbox" name="sel_all" value="checked" <%=WI.fillTextValue("sel_all")%> onClick="SelectAll();" checked="checked">        
        ALL</td>
    </tr>
<%int j = 0;
for(int i = 0; i < vRetResult.size(); i += 4, ++j){%>
    <tr>
      <td class="thinborder"><%=j + 1%>.</td>
      <td class="thinborder" height="22"><%=(String)vRetResult.elementAt(i + 1)%></td>
      <td class="thinborder"><%=(String)vRetResult.elementAt(i + 2)%></td>
      <td class="thinborder"><%=(String)vRetResult.elementAt(i + 3)%></td>
      <td class="thinborder">
	  <select name="section_<%=j%>" style="font-size:10px;">
	  <%=strSectionList%>
	  </select>	  </td>
      <td class="thinborder" align="center">
	  	<input type="checkbox" name="save_<%=j%>" value="<%=vRetResult.elementAt(i)%>" checked="checked">	  </td>
    </tr>
<%}%>
  </table>
<input type="hidden" name="max_disp" value="<%=j%>">
  <table bgcolor="#FFFFFF"  width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td  align="center" style="font-size:14px"><br>
		<input type="submit" name="1" value="Update Section Information" style="font-size:11px; height:28px;border: 1px solid #FF0000;" onClick="document.form_.show_result.value=1; document.form_.page_action.value='1';">      
	  </td>
    </tr>
  </table>
  
  <%
	}//vRetResult is not null
%>
<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" id="myADTable4">
    <tr>
      <td colspan="8" height="25">&nbsp;</td>
    </tr>
    <tr>
      <td colspan="8" height="25" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
  <input type="hidden" name="show_result">
  <input type="hidden" name="page_action">
  <input type="hidden" name="auto_create">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
