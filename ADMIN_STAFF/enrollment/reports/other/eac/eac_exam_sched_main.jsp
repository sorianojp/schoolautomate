<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../../css/tabStyle.css" rel="stylesheet" type="text/css">
<link href="../../../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../../../jscript/date-picker.js"></script>
<script language="javascript">
function PrintPage() {
	document.bgColor = "#FFFFFF";
	
	document.getElementById('myADTable1').deleteRow(0);
	
	document.getElementById('myADTable2').deleteRow(0);
	document.getElementById('myADTable2').deleteRow(0);
	
	document.getElementById('myADTable3').deleteRow(0);
	document.getElementById('myADTable3').deleteRow(0);
	document.getElementById('myADTable3').deleteRow(0);
	document.getElementById('myADTable3').deleteRow(0);

	alert("Click OK to print this page");
	window.print();//called to remove rows, make bk white and call print.
}
function PrintAttendanceSheet() {
		var pgLoc = "./print_batch.jsp?sy_from="+document.form_.sy_from.value+"&pmt_schedule="+
		document.form_.pmt_schedule[document.form_.pmt_schedule.selectedIndex].value+"&semester="+
		document.form_.semester[document.form_.semester.selectedIndex].value+"&font_size="+document.form_.font_size[document.form_.font_size.selectedIndex].value;	
		var win=window.open(pgLoc,"UpdateLocation",'width=1000,height=900,top=100,left=30,scrollbars=yes,toolbar=no,location=no,directories=no,status=yes,menubar=no');
		win.focus();
}	
</script>
<%@ page language="java" import="utility.*,java.util.Vector, enrollment.EACExamSchedule" %>
<%
	DBOperation dbOP  = null;
	WebInterface WI   = new WebInterface(request);
	Vector vRetResult = null;
	String strErrMsg  = null;
	String strTemp    = null;

	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ENROLLMENT-REPORTS"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ENROLLMENT"),"0"));
		}
		//may be called from registrar.
	}
	if(iAccessLevel == -1)//for fatal error.
	{
		request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		request.getSession(false).setAttribute("errorMessage","You are already logged out. Please login again.");
		response.sendRedirect("../../../../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0)//NOT AUTHORIZED.
	{
		response.sendRedirect("../../../../../commfile/unauthorized_page.jsp");
		return;
	}
	try
	{
		dbOP = new DBOperation();
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
	

EACExamSchedule EES = new EACExamSchedule();
if(WI.fillTextValue("sy_from").length() > 0)
	vRetResult = EES.getScheduleSummary(dbOP, request);

String strExamName = null;
if(vRetResult != null && vRetResult.size() > 0) {
	strExamName = "select exam_name from fa_pmt_schedule where pmt_sch_index = "+WI.fillTextValue("pmt_schedule");
	strExamName = dbOP.getResultOfAQuery(strExamName, 0);
}




%>
<body>
<form name="form_" method="post" action="eac_exam_sched_main.jsp">
  <table border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" id="myADTable1">
    <tr> 
      <td height="25" colspan="2">
	  <jsp:include page="./inc.jsp?pgIndex=1"></jsp:include>
	  </td>
    </tr>
  </table>
	<table width="100%" border="0" cellpadding="0" cellspacing="0" id="myADTable2">
    <tr bgcolor="#A49A6A"> 
      <td width="100%" height="25" align="center"><font color="#FFFFFF" size="2"><strong>:::: EAXM SCHEDULE MAIN PAGE ::::</strong></font></td>
    </tr>    
		<tr bgcolor="#FFFFFF">
      <td height="25"><font size="1">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<font size="3"><%=WI.getStrValue(strErrMsg,"")%></font></font></td>
    </tr>	
  </table>
  
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" id="myADTable3">		
	<tr>
	  <td width="2%" height="25">&nbsp;</td>
	  <td width="17%" >SY From/Term </td>
	  <td width="81%" >
<%
strTemp = WI.fillTextValue("sy_from");
if(strTemp.length() == 0) 
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
%>
			<input name="sy_from" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;">
	  - 
<%
strTemp = WI.fillTextValue("semester");
if(strTemp.length() == 0) 
	strTemp = (String)request.getSession(false).getAttribute("cur_sem");
%> <select name="semester">
   <option value="0">Summer</option>
<%
if(strTemp.compareTo("1") ==0)
	strErrMsg = " selected";
else	
	strErrMsg = "";
%>
          <option value="1"<%=strErrMsg%>>1st Sem</option>
<%
if(strTemp.compareTo("2") ==0)
	strErrMsg = " selected";
else	
	strErrMsg = "";
%>
          <option value="2"<%=strErrMsg%>>2nd Sem</option>
<%
if(strTemp.compareTo("3") ==0)
	strErrMsg = " selected";
else	
	strErrMsg = "";
%>
          <option value="3"<%=strErrMsg%>>3rd Sem</option>
        </select>			</td>
	</tr>
	<tr>
	  <td height="25">&nbsp;</td>
	  <td >Exam Name  </td>
	  <td ><select name="pmt_schedule" >
        <%=dbOP.loadCombo("pmt_sch_index","exam_name"," from fa_pmt_schedule where is_valid=1 order by exam_period_order", WI.fillTextValue("pmt_schedule"), false)%>
      </select></td>
	</tr>
	<tr>
	  <td >&nbsp;</td>
	  <td >
	  <select name="lines_per_pg">
	  	<%
		int iRowsPerPg = Integer.parseInt(WI.getStrValue(WI.fillTextValue("lines_per_pg"), "50"));
		for(int i = 45; i < 65; ++i) {
			if(i == iRowsPerPg)
				strTemp = "selected";
			else	
				strTemp = "";
		%><option value="<%=i%>" <%=strTemp%>><%=i%></option>
		<%}%>
	  </select> 
	  - Rows Per page	  </td>
	  <td >
		  <input type="button" name="update" value=" Show List " style="font-size:11px; height:26px;border: 1px solid #FF0000;" onClick="document.form_.submit()" />	  </td>
	  </tr>
<%if(vRetResult != null && vRetResult.size() > 0) {%>
	<tr>
	  <td >&nbsp;</td>
	  <td >&nbsp;</td>
	  <td align="right" style="font-size:9px;">
	  <select name="font_size">
<%
strTemp = WI.fillTextValue("font_size");
if(strTemp.length() == 0)
	strTemp = "11";
for(int i = 9; i < 14; ++i) {
	if(strTemp.equals(Integer.toString(i)))
		strErrMsg = " selected";
	else	
		strErrMsg = "";
%>
	<option value="<%=i%>" <%=strErrMsg%>><%=i%></option>	  
<%}%>
	  </select> Font Size
	  &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
	  
	  <a href="javascript:PrintAttendanceSheet();"><img src="../../../../../images/print.gif" border="0"></a>Print Attendance Sheet(all)
	  
	  &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
	  <a href="javascript:PrintPage();"><img src="../../../../../images/print.gif" border="0"></a>
	  Print this page</td>
    </tr>
<%}%>
  </table>
<%if(vRetResult != null && vRetResult.size() > 0) {
int i = 0; int iRowCount = 0;
Vector vDate = (Vector)vRetResult.remove(0);

String[] astrConvertTerm = {"SUMMER","FIRST SEMESTER","SECOND SEMESTER","THIRD SEMESTER"};

String strDate = null;
while(vDate.size() > 0){
if(i >= vRetResult.size())
	break;
	
	if(i > 0) {%>
		<DIV style="page-break-before:always" >&nbsp;</DIV>
	<%}
strDate = (String)vDate.elementAt(0);
iRowCount = 1;
%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
	<tr>
		<td align="center"><font size="3">
					Schedule of <%=strExamName%> Departmental Examination <br>
							<%=astrConvertTerm[Integer.parseInt(WI.fillTextValue("semester"))]%> AY <%=WI.fillTextValue("sy_from")%> - <%=Integer.parseInt(WI.fillTextValue("sy_from")) + 1%>
		</font>		</td>
	</tr>
	<tr>
	  <td style="font-weight:bold; font-size:15px;">Date Of Exam: <%=WI.formatDate(strDate, 2)%></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
	<tr style="font-weight:bold">
		<td width="5%" class="thinborder" height="22">Control Number </td>
		<td width="45%" class="thinborder">Subject Description </td>
		<td width="8%" class="thinborder">Section</td>
		<td width="8%" class="thinborder">Venue</td>
		<td width="12%" class="thinborder">Exam Time </td>
		<td width="5%" class="thinborder">Students Enrolled </td>
	</tr>
<%
for(; i < vRetResult.size(); i += 9){
if(iRowCount++ > iRowsPerPg)
	break;
if(!strDate.equals(vRetResult.elementAt(i + 4))) {
	vDate.remove(0);
	break;
} %>
	<tr>
	  <td class="thinborder" height="22"><%=(String)vRetResult.elementAt(i)%></td>
	  <td class="thinborder"><%=(String)vRetResult.elementAt(i + 2)%></td>
	  <td class="thinborder"><%=(String)vRetResult.elementAt(i + 8)%></td>
	  <td class="thinborder"><%=(String)vRetResult.elementAt(i + 3)%></td>
	  <td class="thinborder"><%=(String)vRetResult.elementAt(i + 5)%> - <%=(String)vRetResult.elementAt(i + 6)%></td>
	  <td class="thinborder"><%=(String)vRetResult.elementAt(i + 7)%></td>
    </tr>
<%}%>
  </table>
<%}//end of while loop of date

}//end of if con.%>
</form>
</body>
</html>

<%
if(dbOP!=null)
	dbOP.cleanUP();
%>

