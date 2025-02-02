<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Daily cash collection page.</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript">
function PrintPg() {
	document.bgColor = "#FFFFFF";
   	document.getElementById('myADTable1').deleteRow(0);
   	document.getElementById('myADTable1').deleteRow(0);

   	document.getElementById('myADTable2').deleteRow(0);
   	document.getElementById('myADTable2').deleteRow(0);

   	document.getElementById('myADTable3').deleteRow(0);
   	document.getElementById('myADTable3').deleteRow(0);

   	alert("Click OK to print this page");
	window.print();//called to remove rows, make bk white and call print.
}
function MapGrant() {
	var strSemester = "";
	if(document.form_.semester.selectedIndex > 0)
		strSemester = document.form_.semester[document.form_.semester.selectedIndex].value;
		
	var loadPg = "./scholarship_map_grant.jsp?sy_from="+document.form_.sy_from.value+"&semester="+strSemester+"&sy_to="+document.form_.sy_to.value;
	var win=window.open(loadPg,"myfile",'dependent=no,width=800,height=450,top=20,left=20,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
</script>
<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*,EnrlReport.FeeExtraction,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	WebInterface WI  = new WebInterface(request);
	String strErrMsg = null;
	String strTemp   = null;


//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Fee Assessment & Payments-REPORTS(scholarship-summary)","scholarship_summary.jsp");
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
														"Fee Assessment & Payments","Reports",request.getRemoteAddr(),
														null);
if(iAccessLevel == 0)
	iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"Executive Management System","ENROLLMENT",request.getRemoteAddr(),
														null);

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

String strSchCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchCode == null)
	strSchCode = "";

//get different grant here.
FeeExtraction feeEx = new FeeExtraction();
if(WI.fillTextValue("show_basic").equals("1"))
	feeEx.setBasic(true);

	Vector vGeneralGrant  = null;
	Vector vAthleteGrant  = null;
	Vector vAcademicGrant = null;
	Vector vNonAcademic   = null;
	
Vector vRetResult = feeEx.getScholarshipSummary(dbOP, request);
if(vRetResult == null)
	strErrMsg = feeEx.getErrMsg();
else {
	vGeneralGrant  = (Vector)vRetResult.remove(0);
	vAthleteGrant  = (Vector)vRetResult.remove(0);
	vAcademicGrant = (Vector)vRetResult.remove(0);
	vNonAcademic   = (Vector)vRetResult.remove(0);
}


%>

<form name="form_" method="post" action="./scholarship_summary.jsp">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" id="myADTable1">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="2" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF"><strong>::::
          SCHOLARSHIP SUMMARY REPORT ::::</strong></font></div></td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td height="25" width="2%">&nbsp;</td>
	  <td><strong><font size="3"><%=WI.getStrValue(strErrMsg)%></font></strong></td>
    </tr>
  </table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" id="myADTable2">
    <tr>
      <td height="25">&nbsp;</td>
      <td width="20%" height="25">School year /Term</td>
      <td height="25"> <%
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
	  readonly="yes"> <select name="semester">
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
        </select></td>
      <td height="25"><a href="javascript:MapGrant();"><font size="3">Map Grant Name</font></a></td>
    </tr>

<%if(strSchCode.startsWith("UI") || strSchCode.startsWith("AUF")){
strTemp = WI.fillTextValue("show_basic");
if(strTemp.equals("1"))
	strTemp = " checked";
else	
	strTemp = "";
%>   <tr>
      <td height="25">&nbsp;</td>
      <td height="25">
	  <input type="radio" name="show_basic" value="1" <%=strTemp%>> Show Grade School 
	  </td>
      <td height="25">
<%
if(strTemp.length() == 0) 
	strTemp = " checked";
else
	strTemp = "";
%>
	  	  <input type="radio" name="show_basic" value="0" <%=strTemp%>> Show College 
	  </td>
      <td height="25">&nbsp;</td>
    </tr>
<%}%>
    <tr>
      <td width="2%" height="25" class="thinborderBOTTOM">&nbsp;</td>
      <td height="25" colspan="2" class="thinborderBOTTOM">
	  <input type="checkbox" name="cleanup" value="1">
        <font color="#0000FF"><strong>Recompute ?(it will slow down the process)
        </strong></font>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
        <input type="image" src="../../../images/refresh.gif">      </td>
      <td width="31%" class="thinborderBOTTOM">&nbsp; <%if(vRetResult != null) {%> <a href="javascript:PrintPg();"><img src="../../../images/print.gif" border="0"></a>
        <font size="1">click to print</font> <%}%> </td>
    </tr>
  </table>

<!------------------- display report here ------------------------->
<%if(vRetResult != null) {
String[] astrConvertTerm = {"Summer","1st Semester","2nd Semester","3rd Semester"};%>
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <tr>
      <td colspan="3"><div align="center"> <font size="2"> <strong><%=SchoolInformation.getSchoolName(dbOP,true,false)%></strong><br>
          <font size="1"><%=SchoolInformation.getAddressLine1(dbOP,false,false)%></font></font></div></td>
    </tr>
    <tr>
      <td colspan="3"><div align="center"></div></td>
    </tr>
    <tr>
      <td height="20" colspan="3" valign="top"><div align="center"><strong>SUMMARY
          OF SCHOLARSHIP GRANTS AND DISCOUNTS<br>
		  <%=astrConvertTerm[Integer.parseInt(WI.fillTextValue("semester"))]%>&nbsp;&nbsp; AY :
		  <%=WI.fillTextValue("sy_from")%> - <%=WI.fillTextValue("sy_to")%>
          </strong></div></td>
    </tr>
    <tr valign="bottom">
      <td width="42%" height="24">&nbsp;</td>
      <td width="35%" height="24" align="right">Date and time printed : </td>
      <td width="23%" height="24">&nbsp;<%=WI.getTodaysDateTime()%></td>
    </tr>
  </table>
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <tr>
      <td height="10" colspan="3">&nbsp;</td>
    </tr>
    <tr>
      <td width="69%" height="24"><div align="center"><strong><font size="1">CLASSIFICATION</font></strong></div></td>
      <td width="12%"><div align="right"><strong><font size="1">NOS</font></strong></div></td>
      <td width="19%"><div align="right"><strong><font size="1">AMOUNT</font></strong></div></td>
    </tr>
  </table>
<%
double dTempDiscount = 0d;
double dTempNoOfStud = 0d;
if(vGeneralGrant != null && vGeneralGrant.size() > 0) {%>
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
<%for(int i = 0; i < vGeneralGrant.size(); i += 3){%>
    <tr>
      <td width="69%" height="24"><div align="left"><%=(String)vGeneralGrant.elementAt(i)%></div></td>
      <td width="12%"><div align="right"><%=(String)vGeneralGrant.elementAt(i + 2)%></div></td>
      <td width="19%"><div align="right"><%=CommonUtil.formatFloat(((Double)vGeneralGrant.elementAt(i + 1)).doubleValue(),true)%></div></td>
    </tr>
<%}%>
  </table>
  <%}//show only if vGeneralGrant is not null.

if(vAthleteGrant != null && vAthleteGrant.size() > 0) {%>
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <tr>
      <td width="69%" height="24">ATHLETES:</td>
      <td width="12%"><div align="right"></div></td>
      <td width="19%"><div align="right"></div></td>
    </tr>
    <tr>
      <td width="69%" height="24" valign="top" align="right">
	  <table width="95%" cellpadding="0" cellspacing="0" border="0">
<%for(int i = 2; i < vAthleteGrant.size(); i += 3){%>
	  	<tr>
			<td width="46%"><%=(String)vAthleteGrant.elementAt(i)%></td>
			<td width="15%" align="right"><%=(String)vAthleteGrant.elementAt(i + 2)%></td>
			<td width="32%" align="right"><%=CommonUtil.formatFloat(((Double)vAthleteGrant.elementAt(i + 1)).doubleValue(),true)%></td>
			<td width="7%">&nbsp;</td>
		</tr>
<%}%>
	  </table>
	  </td>
      <td width="12%" valign="bottom"><div align="right"><%=(String)vAthleteGrant.elementAt(0)%></div></td>
      <td width="19%" valign="bottom"><div align="right"><%=CommonUtil.formatFloat(((Double)vAthleteGrant.elementAt(1)).doubleValue(),true)%></div></td>
    </tr>
  </table>
  <%}//show only if vAthleteGrant is not null.
if(vAcademicGrant != null && vAcademicGrant.size() > 0) {%>
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <tr>
      <td width="69%" height="24">ACADEMIC SCHOLARS:</td>
      <td width="12%"><div align="right"></div></td>
      <td width="19%"><div align="right"></div></td>
    </tr>
    <tr>
      <td width="69%" height="24" valign="top" align="right">
	  <table width="95%" cellpadding="0" cellspacing="0" border="0">
<%for(int i = 2; i < vAcademicGrant.size(); i += 3){%>
	  	<tr>
			<td width="46%"><%=(String)vAcademicGrant.elementAt(i)%></td>
			<td width="15%" align="right"><%=(String)vAcademicGrant.elementAt(i + 2)%></td>
			<td width="32%" align="right"><%=CommonUtil.formatFloat(((Double)vAcademicGrant.elementAt(i + 1)).doubleValue(),true)%></td>
			<td width="7%">&nbsp;</td>
		</tr>
<%}%>
	  </table>
	  </td>
      <td width="12%" valign="bottom"><div align="right"><%=(String)vAcademicGrant.elementAt(0)%></div></td>
      <td width="19%" valign="bottom"><div align="right"><%=CommonUtil.formatFloat(((Double)vAcademicGrant.elementAt(1)).doubleValue(),true)%></div></td>
    </tr>
  </table>
  <%}//show only if vAcademicGrant is not null.
if(vNonAcademic != null && vNonAcademic.size() > 0) {%>
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <tr>
      <td width="69%" height="24">NON-ACADEMIC SCHOLARS:</td>
      <td width="12%"><div align="right"></div></td>
      <td width="19%"><div align="right"></div></td>
    </tr>
    <tr>
      <td width="69%" height="24" valign="top" align="right">
	  <table width="95%" cellpadding="0" cellspacing="0" border="0">
<%for(int i = 2; i < vNonAcademic.size(); i += 3){%>
	  	<tr>
			<td width="46%"><%=(String)vNonAcademic.elementAt(i)%></td>
			<td width="15%" align="right"><%=(String)vNonAcademic.elementAt(i + 2)%></td>
			<td width="32%" align="right"><%=CommonUtil.formatFloat(((Double)vNonAcademic.elementAt(i + 1)).doubleValue(),true)%></td>
			<td width="7%">&nbsp;</td>
		</tr>
<%}%>
	  </table>
	  </td>
      <td width="12%" valign="bottom"><div align="right"><%=(String)vNonAcademic.elementAt(0)%></div></td>
      <td width="19%" valign="bottom"><div align="right"><%=CommonUtil.formatFloat(((Double)vNonAcademic.elementAt(1)).doubleValue(),true)%></div></td>
    </tr>
  </table>
  <%}//show only if vAcademicGrant is not null.%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="69%" height="24" class="thinborderTOP"><div align="right"><strong>T
          O T A L&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</strong></div></td>
      <td width="12%" class="thinborderTOP"><div align="right"><strong><u><%=(String)vRetResult.elementAt(0)%></u></strong></div></td>
      <td width="19%" class="thinborderTOP"><div align="right"><strong><u><%=CommonUtil.formatFloat(((Double)vRetResult.elementAt(1)).doubleValue(),true)%></u></strong></div></td>
    </tr>
    <tr> <%//System.out.println(request.getSession(false).getAttribute("userId"));
	//System.out.println(CommonUtil.getName(dbOP,(String)request.getSession(false).getAttribute("userId"),1));%>
      <td height="24"><font size="1">Printed by : <%=CommonUtil.getName(dbOP,(String)request.getSession(false).getAttribute("userId"),1)%></font></td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
    <tr>
      <td height="24"><div align="center">Prepared By : </div></td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
  </table>
<%}//////////////////// end of report ////////////////////%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" id="myADTable3">
    <tr>
      <td height="25" colspan="8">&nbsp;</td>
    </tr>
    <tr bgcolor="#B8CDD1">
      <td height="25" colspan="8" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>

</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
