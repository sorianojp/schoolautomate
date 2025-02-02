

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<link href="../../../css/common.css" rel="stylesheet" type="text/css">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
</head>
<script language="javascript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript">
function RefreshPage(){
	document.form_.print_page.value = "";
	document.form_.submit();
}
function PrintPg(){
	document.form_.print_page.value = "1";
	document.form_.submit();
}

function ViewDetail(strInfoIndex){
	var strPerCourse = "0";
	if(document.form_.is_per_course.checked)
		strPerCourse = "1";

	var pgLoc = "./grad_stat_report_detail.jsp?info_index="+strInfoIndex+//c_index or course_index, check the is_per_course
		"&sy_from="+document.form_.sy_from.value+
		"&sy_to="+document.form_.sy_to.value+
		"&semester="+document.form_.semester.value+
		"&graduation_date="+document.form_.graduation_date.value+
		"&is_per_course="+strPerCourse;
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

</script>
<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*,enrollment.GraduationDataReport,
							enrollment.EntranceNGraduationData,java.util.Vector"%>
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strTemp = null;
	String strErrMsg = null;
	
	if(WI.fillTextValue("print_page").length() > 0){%>
		<jsp:forward page="./grad_stat_report_print.jsp"></jsp:forward>
	<%return;}
	
	
	boolean bolIsPerCollege = (WI.getStrValue(WI.fillTextValue("is_per_course"),"0").equals("0"));

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Registrar Management-Graduates","grad_stat_report.jsp");
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
														"Registrar Management","GRADUATES",request.getRemoteAddr(),
														"grad_stat_report.jsp");
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
Vector vRetResult  = null;


int iElemCount = 0;
enrollment.GraduationStatistics gradStat = new enrollment.GraduationStatistics();
if(WI.fillTextValue("sy_from").length() > 0 && WI.fillTextValue("semester").length()  >0){
	vRetResult = gradStat.getGraduationStatReport(dbOP, request, bolIsPerCollege, 0);
	if(vRetResult == null)
		strErrMsg= gradStat.getErrMsg();
	else
		iElemCount = gradStat.getElemCount();
}

%>

<form name="form_" action="grad_stat_report.jsp" method="post">
<table bgcolor="#FFFFFF"  width="100%" border="0" cellspacing="0" cellpadding="0" id="myADTable1">
	<tr bgcolor="#A49A6A">
      <td height="25" colspan="5" align="center" class="style3"><strong class="style3">::::
        STATISTICS OF GRADUATES PER COLLEGE  ::::</strong></td>
    </tr>
    <tr>
      <td height="25" colspan="5">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<strong style="font-size:14px; color:#FF0000"><%=WI.getStrValue(strErrMsg)%></strong>&nbsp;         </td>
      </tr>
	    <tr>
	        <td>&nbsp;</td>
			<%
			strTemp = WI.fillTextValue("is_per_course");
			if(strTemp.equals("1"))
				strErrMsg = "checked";
			else
				strErrMsg = "";
			%>
	        <td colspan="2">
			<input type="checkbox" name="is_per_course" value="1" <%=strErrMsg%>>Check to view Statistics per Course			</td>
        </tr>
	    <tr>
       <td width="3%">&nbsp;</td>      
      <td width="17%">SY-Term</td>
      <td width="80%">
<%
strTemp = WI.fillTextValue("sy_from");
if(strTemp.length() == 0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from");	 
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
</select>	</td>
    </tr>
	    <tr>
	        
	        <td>&nbsp;</td>
			<td height="25">Graduation Date</td>
	        <td>
				<input name="graduation_date" type="text" size="10" maxlength="10" readonly="yes" value="<%=WI.fillTextValue("graduation_date")%>" 
					class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
				<a href="javascript:show_calendar('form_.graduation_date');" title="Click to select date" 
					onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"> 
					<img src="../../../images/calendar_new.gif" border="0"></a>			</td>
        </tr>
	    <tr>
	        <td>&nbsp;</td>
	        <td height="25">&nbsp;</td>
	        <td>
	<a href="javascript:RefreshPage();"><img src="../../../images/refresh.gif" border="0"></a></td>
        </tr>
</table>
<%
if(vRetResult != null && vRetResult.size() > 0){

String strSchName = SchoolInformation.getSchoolName(dbOP,true,false);
String strAddress = SchoolInformation.getAddressLine1(dbOP,false,false);
int iGradCount = 0;
%>


<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" id="myADTable3">
    <tr>
      <td align="right" height="25"><a href="javascript:PrintPg();"><img src="../../../images/print.gif" border="0"></a>
	  <font size="1">Click to print report</font>
	  </td>
    </tr>
    
  </table>

<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
	<tr><td align="center" height="25"><strong><%=strSchName%> </strong>
	<br><%=strAddress%><br>
<%if(!bolIsPerCollege){%>	
	<strong>GRADUATION REPORT</strong><br>
	Graduation Date : <strong><%=WI.formatDate(WI.fillTextValue("graduation_date"), 6)%></strong>
<%}else{%>
	<strong>Office of the Registrar</strong><br>
	Tentative Number of Graduates
<%}%>
	</td>
	</tr>
</table>

<%if(bolIsPerCollege){%>	
<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
	<tr><td height="25" colspan="3"><strong><%=WI.formatDate(WI.fillTextValue("graduation_date"),6)%></strong></td></tr>
	<%
	
	for(int i = 0 ; i < vRetResult.size(); i+=iElemCount){
		iGradCount += Integer.parseInt(WI.getStrValue(vRetResult.elementAt(i+1),"0"));
	%>
	<tr>
		<td width="50%" height="22" style="padding-left:60px;"><%=WI.getStrValue(vRetResult.elementAt(i),"N/A")%></td>
		<td width="20%"><%=WI.getStrValue(vRetResult.elementAt(i+1),"0")%> </td>
	    <td width="30%">
			<a href="javascript:ViewDetail('<%=vRetResult.elementAt(i+2)%>');"><img src="../../../images/view.gif" border="0"></a>
		</td>
	</tr>
	<%}%>
	<tr>
		<td width="50%" height="22" align="right"><strong>Total : &nbsp; &nbsp;</strong></td>
		<td width="20%"><strong><%=iGradCount%></strong></td>
	    <td width="30%">&nbsp;</td>
	</tr>
</table>
<%}else{

int iRowCount = 1;
int iNoOfStudPerPage = 35;

if(WI.fillTextValue("rows_per_pg").length() > 0)
	iNoOfStudPerPage = Integer.parseInt(WI.fillTextValue("rows_per_pg"));			

int iPageCount = 1;
int iTotalStud = (vRetResult.size()/iElemCount);
int iTotalPageCount = iTotalStud/iNoOfStudPerPage;
if(iTotalStud % iNoOfStudPerPage > 0)
	++iTotalPageCount;
boolean bolPageBreak = false;

int iTemp  =0;
int iMaleTot = 0;
int iFemaleTot = 0;
	
%>
<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
	<tr>
		<td width="20%" height="22" align="center" class="thinborderTOPBOTTOM"><strong>Course Code</strong></td>
		<td align="center" class="thinborderTOPBOTTOM"><strong>Course Description</strong></td>
		<td width="10%" align="center" class="thinborderTOPBOTTOM"><strong>Male</strong></td>
		<td width="10%" align="center" class="thinborderTOPBOTTOM"><strong>Female</strong></td>
		<td width="10%" align="center" class="thinborderTOPBOTTOM"><strong>Total</strong></td>
	    <td width="10%" align="center" class="thinborderTOPBOTTOM"><strong>View Detail</strong></td>
	</tr>
	<%
	for(int i = 0; i < vRetResult.size();i+=iElemCount){
	%>
	<tr>
		<td height="22"><%=WI.getStrValue(vRetResult.elementAt(i),"N/A")%></td>
		<td><%=WI.getStrValue(vRetResult.elementAt(i+1),"N/A")%></td>
		<td align="center"><%=WI.getStrValue(vRetResult.elementAt(i+2),"0")%></td>
		<td align="center"><%=WI.getStrValue(vRetResult.elementAt(i+3),"0")%></td>
		<%
		
		iMaleTot += Integer.parseInt(WI.getStrValue(vRetResult.elementAt(i+2),"0"));
		iFemaleTot += Integer.parseInt(WI.getStrValue(vRetResult.elementAt(i+3),"0"));
		iTemp = Integer.parseInt(WI.getStrValue(vRetResult.elementAt(i+2),"0"))+Integer.parseInt(WI.getStrValue(vRetResult.elementAt(i+3),"0"));
		%>
		<td align="center"><%=iTemp%></td>
	    <td align="center"><a href="javascript:ViewDetail('<%=vRetResult.elementAt(i+4)%>');"><img src="../../../images/view.gif" border="0"></a></td>
	</tr>
	<%	
	}%>
	
	<tr>
		<td align="right" colspan="2" class="thinborderTOP" height="22">&nbsp;</td>
		<td align="center" class="thinborderTOP"><strong><%=iMaleTot%></strong></td>
		<td align="center" class="thinborderTOP"><strong><%=iFemaleTot%></strong></td>
		<td align="center" class="thinborderTOP"><strong><%=iFemaleTot+iMaleTot%></strong></td>
	    <td align="center" class="thinborderTOP">&nbsp;</td>
	</tr>
	
</table>

<%
}
}%>
 <table  bgcolor="#999900" width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr>
    <td height="25" bgcolor="#FFFFFF">&nbsp;</td>
  </tr>
  <tr>
    <td height="25" bgcolor="#A49A6A">&nbsp;</td>
  </tr>
</table>
<input type="hidden" name="print_page">
</form>

</body>
</html>
<%
dbOP.cleanUP();
%>
