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
</script>
<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*,enrollment.ReportRegistrarExtn,java.util.Vector" %>
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
								"Admin/staff-Registrar Management-REPORT-Subject Deficiency","subject_deficiency.jsp");
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
int iAccessLevel = 2;//comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
						//								"Registrar Management","TOP STUDENTS",request.getRemoteAddr(),
							//							"subject_deficiency.jsp");
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

ReportRegistrarExtn RR = new ReportRegistrarExtn();
if(WI.fillTextValue("show_result").length() > 0 && WI.fillTextValue("course_index").length() > 0) {
	vRetResult = RR.getSubjectDeficiency(dbOP, request);
	if(vRetResult == null)
		strErrMsg = RR.getErrMsg();
}

int iTotalRows = 0; int iRowPerPg = 0; int iCurRow = 0; int iCurPage = 0; int iTotalPg = 0 ;

boolean bolShowAll = false;
if(WI.fillTextValue("show_all").length() > 0) 
	bolShowAll = true;

if(WI.fillTextValue("rows_per_pg").length() > 0) 
	iRowPerPg = Integer.parseInt(WI.fillTextValue("rows_per_pg"));

%>

<form name="form_" action="./subject_deficiency.jsp" method="post" onSubmit="SubmitOnceButton(this);">
  <table bgcolor="#FFFFFF"  width="100%" border="0" cellspacing="0" cellpadding="0" id="myADTable1">
    <tr bgcolor="#A49A6A"> 
      <td height="25" colspan="4" align="center"><font color="#FFFFFF"><strong>:::: 
        SUBJECT DEFICIENCY PAGE ::::</strong></font></td>
    </tr>
    <tr> 
      <td width="1%" height="25" >&nbsp;</td>
      <td height="25" colspan="3" >&nbsp;&nbsp;&nbsp;<strong><%=WI.getStrValue(strErrMsg)%></strong></td>
    </tr>
    <tr> 
      <td width="1%" height="25" >&nbsp;</td>
      <td width="9%" height="25" >SY/Term </td>
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
	  	<input name="show_SY" type="checkbox" value="checked" <%=WI.fillTextValue("show_SY")%>> 
	  	<font style="color:#0000FF; font-size:10px; font-weight:bold">Show GWA for whole School Year.</font>	  </td>
      <td >
	  	<input name="show_all" type="checkbox" value="checked" <%=WI.fillTextValue("show_all")%>> 
	  	<font style="color:#0000FF; font-size:10px; font-weight:bold">Show All Students</font>	  
	    &nbsp;&nbsp;&nbsp;	
		<select name="rows_per_pg">
<%
for(int i = 30; i < 60; ++i) {
	if(iRowPerPg == i)
		strTemp = "selected";
	else	
		strTemp = "";
%>
	      <option value="<%=i%>"<%=strTemp%>><%=i%></option>
          <%}%>
        </select>
      <font size="1">Rows Per Pg</font></td>
    </tr>
    <tr>
      <td height="25" >&nbsp;</td>
      <td colspan="2" >GWA Filter : <select name="gwa_con">
          <option value="1"<%=strErrMsg%>>Greater than</option>
<%
strTemp = WI.fillTextValue("gwa_con");
if(strTemp.equals("0"))
	strErrMsg = " selected";
else	
	strErrMsg = "";
%>          <option value="0"<%=strErrMsg%>>Less than</option>
        </select>
	<input name="gwa_filter" type="text" size="3" value="<%=WI.fillTextValue("gwa_filter")%>" class="textbox"
		onfocus="style.backgroundColor='#D3EBFF'" onBlur="AllowOnlyFloat('form_','gwa_filter');style.backgroundColor='white'"
		onKeyup="AllowOnlyFloat('form_','gwa_filter');" style="font-size:12px">
		</td>
      <td >&nbsp;</td>
    </tr>
    <tr> 
      <td height="25" >&nbsp;</td>
      <td >Course </td>
      <td colspan="2" ><select name="course_index" onChange="ReloadPage();">
          <%=dbOP.loadCombo("course_index","course_name",
		  " from course_offered where IS_DEL=0 and is_valid=1 and degree_type=0 order by course_name asc",
		  request.getParameter("course_index"), false)%> </select></td>
    </tr>
    
    <tr>
      <td height="10" align="center">&nbsp;</td>
      <td height="10" colspan="3">Report Name : <span class="thinborder">
        <input name="report_name" type="text" size="55" 
		value="<%=WI.getStrValue(WI.fillTextValue("report_name"),"<<For example. Dean's lister/ Top student>>")%>" class="textbox"
		onfocus="document.form_.report_name.select();style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
		style="font-size:11px">
      </span></td>
    </tr>
    <tr> 
      <td colspan="4" height="10" align="center">
        <input type="submit" name="1" value="Show Deficiency List" style="font-size:11px; height:28px;border: 1px solid #FF0000;" onClick="document.form_.show_result.value=1; ReloadPage();">      </td>
    </tr>
  </table>
  <%
if(vRetResult != null && vRetResult.size() > 0){
Vector  vSubSummary = (Vector)vRetResult.remove(0);
%>
  <table bgcolor="#FFFFFF"  width="100%" border="0" cellspacing="0" cellpadding="0" id="myADTable3">
    <tr >
      <td width="100%" height="25">&nbsp;</td>
	  </td>
    </tr>
    <tr >
      <td height="25"><div align="right">  
	  
          <a href="javascript:PrintPage();"><img src="../../../../images/print.gif" border="0"></a>
          <font size="1"> click to print list</font></div></td>
    </tr>
  </table>
  <table bgcolor="#FFFFFF"  width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr >
      <td height="25" colspan="2" align="center"><font size="2">
      <strong><%=SchoolInformation.getSchoolName(dbOP,true,false)%></strong></font></td>
    </tr>
    <tr >
      <td height="20" colspan="2" class="thinborderBOTTOM"><div align="center"><strong>
<%
strTemp = WI.fillTextValue("report_name").toUpperCase();
if(strTemp.length() == 0 || strTemp.equals("<<For example. Dean's lister/ Top student>>".toUpperCase()))
	strTemp = "TOP STUDENT REPORT LIST";
%>
	  <%=strTemp%></strong><br>
	  	<%=astrConvertToSem[Integer.parseInt(request.getParameter("semester"))]%> ,
		AY <%=request.getParameter("sy_from")+"-"+request.getParameter("sy_to")%>        </div></td>
    </tr>
    <tr >
      <td height="20" colspan="2" class="thinborderNONE">Course : 
	    <%=request.getParameter("cn")%>
	    <%if(WI.fillTextValue("mn").length()>0){%>
	  (<%=request.getParameter("mn")%>)
	  <%}%>	  </td>
    </tr>
    <tr >
      <td width="34%" class="thinborderNONE">YEAR :<%=astrConvertToYear[Integer.parseInt(request.getParameter("year_level"))]%> </td>
      <td width="66%" height="20" align="right" class="thinborderNONE">Date &amp; time printed: <%=WI.getTodaysDateTime()%>&nbsp;</td>
    </tr>
  </table>
<%
iTotalRows=vRetResult.size() / 4;
iTotalPg = iTotalRows/iRowPerPg ;
if(iTotalRows % iRowPerPg > 0)
	++iTotalPg;
%>
  <table bgcolor="#FFFFFF"  width="100%" border="0" cellspacing="0" cellpadding="0">    
    <tr>
      <td height="25" colspan="3" class="thinborderNONE">
	  Total Student Listed : <%=iTotalRows%></td>
      <td width="30%" align="right" style="font-size:11px;">page 1 of <%=iTotalPg%>&nbsp;</td>
    </tr>
  </table>
<%for(int i=0; i< vRetResult.size();){
++iCurPage;iCurRow = 0;
if(i > 0){//print the page count.%>
  <table bgcolor="#FFFFFF"  width="100%" border="0" cellspacing="0" cellpadding="0">    
    <tr>
      <td height="25" colspan="3" class="thinborderNONE">&nbsp;</td>
      <td width="30%" align="right" style="font-size:11px;">page <%=iCurPage%> of <%=iTotalPg%>&nbsp;</td>
    </tr>
  </table>

<%}%>
  <table bgcolor="#FFFFFF"  width="100%" border="0" cellspacing="0" cellpadding="0" class="thinborder">
    <tr style="font-weight:bold">
      <td width="3%" align="center" class="thinborder" style="font-size:9px">#</td>
      <td width="15%" height="25" align="center" class="thinborder" style="font-size:9px">STUDENT ID</td>
      <td width="30%" align="center" class="thinborder" style="font-size:9px">STUDENT NAME</td>
      <td width="7%" align="center" class="thinborder" style="font-size:9px">GWA</td>
      <td width="30%" align="center" class="thinborder" style="font-size:9px">SUBJECT DEFICIENCY </td>
      <td width="15%" align="center" class="thinborder" style="font-size:9px">SUBJECT NOT TAKEN</td>
    </tr>
<%
for(; i< vRetResult.size(); i += 4){%>
    <tr>
      <td class="thinborder"><%=i/4 + 1%>.</td>
      <td height="25" class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i)%>
      <td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+1)%></td>
      <td class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i+3), "&nbsp;")%></td>
      <td  class="thinborder"><%if(vRetResult.elementAt(i+2) == null) {%>&nbsp;<%}else{%>
	  							<%=WI.getStrValue((String)((Vector)vRetResult.elementAt(i+2)).elementAt(0), "&nbsp;")%><%}%></td>
      <td  class="thinborder"><%if(vRetResult.elementAt(i+2) == null) {%>&nbsp;<%}else{%>
	  							<%=WI.getStrValue((String)((Vector)vRetResult.elementAt(i+2)).elementAt(1), "&nbsp;")%><%}%></td>
    </tr>
<%++iCurRow ;
	if(iCurRow >= iRowPerPg) {
		i += 4;
		break;
	}
} //end for loop%>
  </table>
<%if(iCurPage != iTotalPg){%>
<DIV style="page-break-after:always" >&nbsp;</DIV>
<%}%>

<%}//end of big loop %>  
 <table bgcolor="#FFFFFF"  width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr style="font-weight:bold">
      <td  align="center" style="font-size:14px"><br>
      SUMMARY<br>
      </td>
    </tr>
  </table>
  
 <table bgcolor="#FFFFFF"  width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td width="49%" valign="top">
	  	<table border="0" width="100%" cellpadding="0" cellspacing="0" class="thinborder">
		<tr>
			<td class="thinborder">Sub. Code</td>
			<td class="thinborder">With Deficiency</td>
			<%if(bolShowAll){%>
				<td class="thinborder">Without Deficiency</td>
			<%}else{%>
				<td class="thinborder">Subj. not taken</td>
			<%}%>
		</tr>		
		<%for(int i = 0; i < vSubSummary.size(); i += 6){%>
			<tr>
				<td class="thinborder"><%=vSubSummary.elementAt(i)%></td>
				<td class="thinborder"><%=vSubSummary.elementAt(i + 1)%></td>
				<%if(bolShowAll){%>
					<td class="thinborder"><%=iTotalRows - Integer.parseInt((String)vSubSummary.elementAt(i + 1))%> </td>
				<%}else{%>
					<td class="thinborder"><%=vSubSummary.elementAt(i + 2)%></td>
				<%}%>
			</tr>
		<%}//end of printing sub summary - > even number.%>
		</table>
	  </td>
      <td width="3%">&nbsp;</td>
      <td width="48%" valign="top">
	  	<table border="0" width="100%" cellpadding="0" cellspacing="0" class="thinborder">
		<tr>
			<td class="thinborder">Sub. Code</td>
			<td class="thinborder">With Deficiency</td>
			<%if(bolShowAll){%>
				<td class="thinborder">Without Deficiency</td>
			<%}else{%>
				<td class="thinborder">Subj. not taken</td>
			<%}%>
		</tr>		
		<%for(int i = 3; i < vSubSummary.size(); i += 6){%>
			<tr>
				<td class="thinborder"><%=vSubSummary.elementAt(i)%></td>
				<td class="thinborder"><%=vSubSummary.elementAt(i + 1)%></td>
				<%if(bolShowAll){%>
					<td class="thinborder"><%=iTotalRows - Integer.parseInt((String)vSubSummary.elementAt(i + 1))%></td>
				<%}else{%>
					<td class="thinborder"><%=vSubSummary.elementAt(i + 2)%></td>
				<%}%>
			</tr>
		<%}//end of printing sub summary - > even number.%>
		</table>
	  
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
  <input type="hidden" name="cn" value="<%=WI.fillTextValue("cn")%>">
  <input type="hidden" name="mn" value="<%=WI.fillTextValue("mn")%>">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
