<%@ page language="java" import="utility.*,java.util.Vector" %>
<%
String strSchCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchCode == null)
	strSchCode = "";
WebInterface WI = new WebInterface(request);

boolean bolIsBasic = false;
if (WI.fillTextValue("is_basic").equals("1")) 
	bolIsBasic = true;
	
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
<script language="JavaScript">
function printPg() {
	document.getElementById('myADTable1').deleteRow(0);
	document.getElementById('myADTable1').deleteRow(0);

	<%if(!bolIsBasic) {%>
		document.getElementById('myADTable2').deleteRow(0);
		document.getElementById('myADTable2').deleteRow(0);
	<%}%>
	document.getElementById('myADTable2').deleteRow(0);
	document.getElementById('myADTable2').deleteRow(0);
	document.getElementById('myADTable2').deleteRow(0);
	document.getElementById('myADTable2').deleteRow(0);
	document.getElementById('myADTable2').deleteRow(0);
	
	document.getElementById('myADTable3').deleteRow(0);
	
	//delete the dynamic rows.. 
/**
	var obj = document.getElementById('myADTable2');
	var oRows; var iRowCount;
	if(obj) {
		oRows = obj.getElementsByTagName('tr');
		iRowCount = oRows.length;
		for(i = 0; i < iRowCount; ++i)
			obj.deleteRow(0);
	}
	obj = document.getElementById('myADTable3');
	if(obj) {
		oRows = obj.getElementsByTagName('tr');
		iRowCount = oRows.length;
		for(i = 0; i < iRowCount; ++i)
			obj.deleteRow(0);
	}
**/	
	
	alert("Click OK to print this page");
	window.print();//called to remove rows, make bk white and call print.

}
</script>
<body>
<%
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;

//authenticate this user.
	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("FEE ASSESSMENT & PAYMENTS-REPORTS"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("FEE ASSESSMENT & PAYMENTS"),"0"));
		}
	}
	if(iAccessLevel == -1)//for fatal error.
	{
		request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		request.getSession(false).setAttribute("errorMessage","You are already logged out. Please login again.");
		response.sendRedirect("../../../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0)//NOT AUTHORIZED.
	{
		response.sendRedirect("../../../../commfile/unauthorized_page.jsp");
		return;
	}

//add security here.
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
Vector vRetResult = null;
enrollment.ReportFeeAssessment RFA = new enrollment.ReportFeeAssessment();
if(WI.fillTextValue("sy_from").length() > 0) {
	vRetResult = RFA.getSemestralRemark(dbOP, request);
	if(vRetResult == null)
		strErrMsg = RFA.getErrMsg();
}
//System.out.println(vStudentNotAllowed);
%>

<form name="form_" action="./auf_semestral_remark.jsp" method="post" onSubmit="SubmitOnceButton(this);">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" id="myADTable1">
    <tr bgcolor="#A49A6A"> 
      <td height="25" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF" ><strong>:::: 
          SEMESTRAL REMARK LISTING PAGE ::::</strong></font></div></td>
    </tr>
    <tr> 
      <td height="25" >&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<font size="3"><b><%=WI.getStrValue(strErrMsg)%></b></font></td>
    </tr>
  </table>
	
  <table width="100%" border="0" cellpadding="0" cellspacing="0" id="myADTable2">
    <tr> 
      <td width="33" height="25">&nbsp;</td>
      <td>SY/TERM</td>
      <td> 
<%
strTemp = WI.fillTextValue("sy_from");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
%> 
	<input name="sy_from" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp='DisplaySYTo("form_","sy_from","sy_to")'>
        to 
<%
strTemp = WI.fillTextValue("sy_to");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_to");
%> 
	<input name="sy_to" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  readonly="yes"> <select name="semester">
          <option value="0">Summer</option>
<%
strTemp = WI.fillTextValue("semester");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sem");
if(strTemp.equals("1"))
	strErrMsg = "selected";
else	
	strErrMsg = "";
%>
        <option value="1" <%=strErrMsg%>>1st Sem</option>
<%
if(strTemp.equals("2"))
	strErrMsg = "selected";
else	
	strErrMsg = "";
%>
          <option value="2" <%=strErrMsg%>>2nd Sem</option>
<%
if(strTemp.equals("3"))
	strErrMsg = "selected";
else	
	strErrMsg = "";
%>
          <option value="3" <%=strErrMsg%>>3rd Sem</option>
        </select>
<%
if(bolIsBasic)
	strTemp = " checked";
else	
	strTemp = "";
%>
	<input type="checkbox" onClick="document.form_.submit();" name="is_basic" <%=strTemp%> value="1">
	<font style="font-size:9px; font-weight:bold; color:#0000FF">Show  Basic Ledger Remarks</font></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>Student ID </td>
      <td>
	  <input name="stud_id" type="text" value="<%=WI.fillTextValue("stud_id")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
	  </td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>Last Name </td>
      <td>
	  <input name="lname" type="text" value="<%=WI.fillTextValue("lname")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
	  </td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>First Name </td>
      <td>
	  <input name="fname" type="text" value="<%=WI.fillTextValue("fname")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
	  </td>
    </tr>
<%if(!bolIsBasic) {%>
    <tr> 
      <td height="25">&nbsp;</td>
      <td> Course </td>
      <td><select name="course" style="font-size:10px;">
          <option value="">Select Any</option>
<%
strTemp = " from course_offered where IS_DEL=0 AND IS_VALID=1 order by course_name asc";
%>
          <%=dbOP.loadCombo("course_index","course_name",strTemp, request.getParameter("course_index"), false)%> 
        </select></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td width="112"> Year level </td>
      <td width="696"><select name="year_level" onChange="ReloadPage()">
          <option value="">ALL</option>
<%
strTemp = request.getParameter("year_level");
if(strTemp == null) 
	strTemp = "";
	for(int i = 1; i < 7; ++i) {
		if(strTemp.equals(Integer.toString(i)))
			strErrMsg = "selected";
		else
			strErrMsg = "";
%>
          <option value="<%=i%>" <%=strErrMsg%>><%=i%></option>
<%}%>
        </select></td>
    </tr>
<%}%>
    <tr> 
      <td height="25">&nbsp;</td>
      <td style="font-size:9px;" align="right"><select name="max_row_pg">
<%
int iRowsPerPg = Integer.parseInt(WI.getStrValue(WI.fillTextValue("max_row_pg"), "40"));
	for(int i = 35; i < 60; ++i) {
		if(i == iRowsPerPg)
			strTemp = " selected";
		else	
			strTemp = "";%>	  
	  <option value="<%=i%>" <%=strTemp%>><%=i%></option>
	<%}%>  
	  </select> Rows/Pg
	  </td>
      <td> 
	  <input type="submit" name="1" value="&nbsp;&nbsp;Show Result&nbsp;&nbsp;" 
	  	style="font-size:11px; height:28px;border: 1px solid #FF0000;">
	  <font size="1">click to display student list with semestral remark.</font></td>
  </table>
    <table width="100%" border="0" cellpadding="0" cellspacing="0" id="myADTable3">
		<tr>
			<td align="right" style="font-size:9px"><a href="javascript:printPg();"><img src="../../../../images/print.gif" border="0"></a>
			click to print report</td>
		</tr>
	</table>
<%
if(vRetResult != null && vRetResult.size() > 0){
String[] astrSemester = {"Summer","1st Semester","2nd Semester","3rd Semester"};

int iCurRow = 0; int iCount = 0;
while(vRetResult.size() > 0) {
iCurRow = 0;%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
	<tr>
		<td align="center"><font style="font-weight:bold; font-size:16px;">Angeles University Foundation </font><br>
		List of Status of Students <br>
		<%=astrSemester[Integer.parseInt(WI.fillTextValue("semester"))]%>, A.Y. <%=WI.fillTextValue("sy_from")%>-<%=WI.fillTextValue("sy_to")%>
		</td>
	</tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" class="thinborder">
    <tr bgcolor="#ffff99" align="center" style="font-weight:bold;" class="thinborder"> 
      <td height="25" class="thinborder" width="5%">Count</td>
      <td class="thinborder" width="12%">Student ID </td>
      <td class="thinborder" width="18%">Student Name </td>
      <td class="thinborder" width="15%">Course - Yr </td>
      <td class="thinborder" width="50%">Remark</td>
    </tr>
<%while(vRetResult.size() > 0) {
	++iCurRow;
	if(iCurRow > iRowsPerPg)	
		break;
	vRetResult.remove(0);
%>
    <tr> 
      <td class="thinborder"><%=++iCount%>.</td>
      <td class="thinborder"><%=vRetResult.remove(0)%></td>
      <td height="25" class="thinborder"><%=vRetResult.remove(0)%></td>
      <td class="thinborder">
<%if(bolIsBasic) {
	vRetResult.remove(0);vRetResult.remove(0);
	strTemp = dbOP.getBasicEducationLevel(Integer.parseInt((String)vRetResult.remove(0)));
}
else {
	strTemp = (String)vRetResult.remove(0);//course code.
	strErrMsg = (String)vRetResult.remove(0);//major_code
	if(strErrMsg != null)
		strTemp = strTemp +"/"+strErrMsg;
	strErrMsg = (String)vRetResult.remove(0);//year level
	if(strErrMsg != null)
		strTemp = strTemp + " - "+strErrMsg;
}
%>  
	  <%=strTemp%></td>
      <td class="thinborder"><%=vRetResult.remove(0)%></td>
    </tr>
<%}%>
  </table>
<%}//outer for loop for page break.

}//end of vRetResult display.

%>

</form>

</body>
</html>
<%
dbOP.cleanUP();
%>