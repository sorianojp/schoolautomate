<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<style>
    TABLE.thinborder {
    border-top: solid 1px #000000;
    border-right: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 12px;	
    }
    TD.thinborder {
    border-left: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 12px;
    }
    TD.thinborderBOTTOM {
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 12px;
    }

</style>

</head>
<script language="JavaScript" src="../../../../jscript/common.js"></script>
<script language="JavaScript">
function ReloadPage() {
	document.form_.show_result.value='';
	document.form_.submit();
}
function PrintPage() {
	document.getElementById('myADTable1').deleteRow(0);
	document.getElementById('myADTable1').deleteRow(0);

	document.getElementById('myADTable2').deleteRow(0);
	document.getElementById('myADTable2').deleteRow(0);
	document.getElementById('myADTable2').deleteRow(0);

	document.getElementById('myADTable3').deleteRow(0);

	alert("Click OK to print this page");
	window.print();
}
</script>
<body topmargin="0" bottommargin="0">
<%@ page language="java" import="utility.*, java.util.Vector, java.util.Date"%>
<%
	DBOperation dbOP = null;
	WebInterface WI  = new WebInterface(request);
	String strErrMsg = null;
	String strTemp   = null;

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
		request.getSession(false).setAttribute("errorMessage","Please login to access this page.");
		response.sendRedirect("../../../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0)//NOT AUTHORIZED.
	{
		response.sendRedirect("../../../../commfile/unauthorized_page.jsp");
		return;
	}
	
//add security here.
	try	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Fee Assess & Payment - Reports - Installment Dues.",
								"installment_dues_ul.jsp");
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
String strSchCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchCode == null)
	strSchCode = "";

enrollment.ReportFeeAssessment RFA = new enrollment.ReportFeeAssessment();
Vector vRetResult = new Vector();
Vector vDPInfo = new Vector();
int iIndexOf   = 0; Integer iObj = null; String strDPInfo = null;

if(WI.fillTextValue("show_result").length() > 0 && WI.fillTextValue("sy_from").length() > 0) {
	vRetResult = RFA.getInstallmentDues(dbOP, request);
	if(vRetResult == null)
		strErrMsg = RFA.getErrMsg();
	else	
		vDPInfo = (Vector)vRetResult.remove(0);
		
	//System.out.println(vRetResult);
}

%>
<form action="./installment_dues_ul.jsp" method="post" name="form_" onSubmit="SubmitOnceButton(this);">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" id='myADTable1'>
    <tr>
      <td width="100%" height="25" align="center" class="thinborderBOTTOM"><strong>:::: INSTALLMENT DUES ::::</strong></td>
    </tr>
    <tr >
      <td height="25">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<font size="3"><b><%=WI.getStrValue(strErrMsg)%></b></font></td>
    </tr>
  </table>

	<table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" id='myADTable2'>
<!--
    <tr>
      <td height="25">&nbsp;</td>
      <td colspan="3" style="font-size:11px; font-weight:bold; color:#0000FF">
	  <input type="checkbox" name="is_basic" value="1"<%=strTemp%> onClick="relaunchPage();"> Process Promisory Note for Grade School	  </td>
    </tr>
-->
    <tr> 
      <td width="2%" height="25">&nbsp;</td>
      <td width="13%">SY/TERM</td>
      <td colspan="2"> 
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

	  <select name="semester">
          <option value="0">Summer</option>
<%
strTemp = WI.fillTextValue("semester");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sem");
if(strTemp == null)
	strTemp = "";
if(strTemp.equals("1"))
	strErrMsg = " selected";
else	
	strErrMsg ="";
%>
        <option value="1" <%=strErrMsg%>>1st Sem</option>
 <%
if(strTemp.equals("2"))
	strErrMsg = " selected";
else	
	strErrMsg ="";
%>
       <option value="2" <%=strErrMsg%>>2nd Sem</option>
<%
if(strTemp.equals("3"))
	strErrMsg = " selected";
else	
	strErrMsg ="";
%>
          <option value="3" <%=strErrMsg%>>3rd Sem</option>
        </select>	 </td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>College</td>
      <td width="56%">
      <%strTemp = WI.fillTextValue("c_index");%>
      <select name="c_index">
          <option value="">All</option>
          <%=dbOP.loadCombo("c_index","c_name"," from college where IS_DEL=0 order by c_name asc",
		  		WI.fillTextValue("c_index"), false)%> </select>      </td>
      <td width="29%">
	  Rows Per Page: 
         <select name="rows_per_page">
	<%
	int iRowsPerPage = 0;
	strTemp = request.getParameter("rows_per_page");
	if(strTemp == null)
		strTemp = "18";
	iRowsPerPage = Integer.parseInt(strTemp);
	
	for(int i = 6; i < 20; ++i) {
		if( i == iRowsPerPage)
			strTemp = " selected";
		else
			strTemp = "";
	%>
      <option value="<%=i%>" <%=strTemp%>><%=i%></option>
<%}%>	</select>	  </td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td colspan="2" style="font-size:11px;">
<%
strTemp = WI.fillTextValue("show_con");
if(strTemp.length() == 0)
	strErrMsg = " checked";
else	
	strErrMsg = "";
%>
	  <input type="radio" name="show_con" value="" <%=strErrMsg%>> N/A
<%
if(strTemp.equals("0"))
	strErrMsg = " checked";
else	
	strErrMsg = "";
%>
	  <input type="radio" name="show_con" value="0" <%=strErrMsg%>> Show Only Masteral 
<%
if(strTemp.equals("1"))
	strErrMsg = " checked";
else	
	strErrMsg = "";
%>
	  <input type="radio" name="show_con" value="1" <%=strErrMsg%>> Show Only Doctoral
	  </td>
      <td>&nbsp;</td>
    </tr>
<!--
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Course</td>
      <td>
	<%if (strTemp==null || strTemp.length()==0 )
		strTemp = " from course_offered where is_del = 0 and is_valid = 1 order by course_name asc";
	else
		strTemp = " from course_offered where is_del = 0 and is_valid = 1 and c_index = "+strTemp+
		" order by course_name asc";
		
	String strTemp2 = WI.fillTextValue("course_index");%>
      <select name="course_index" onChange="ReloadPage();">
          <option value="">All</option>
          <%=dbOP.loadCombo("course_index","course_name",strTemp, strTemp2, false)%>
        </select>      
	  </td>
      <td>Year Level: 
      <%strTemp = WI.fillTextValue("yr_lvl");%>
      <select name="yr_lvl">
		<option value="">N/A</option>      
	<%if (strTemp.equals("1")){%>
		<option value="1" selected>1</option>
	<%} else {%>
		<option value="1">1</option>
	<%} if (strTemp.equals("2")){%>
		<option value="2" selected>2</option>
	<%} else {%>
		<option value="2">2</option>
	<%} if (strTemp.equals("3")){%>
		<option value="3" selected>3</option>
	<%} else {%>
		<option value="3">3</option>
	<%} if (strTemp.equals("4")){%>		
		<option value="4" selected>4</option>
	<%} else {%>
		<option value="4">4</option>
	<%} if (strTemp.equals("5")){%>
		<option value="5" selected>5</option>
	<%} else {%>
		<option value="5">5</option>
	<%} if (strTemp.equals("6")){%>
		<option value="6" selected>6</option>
	<%} else {%>
		<option value="6">6</option>
	<%}%>
      </select>      </td>
    </tr>
<%
if(strTemp2.length() > 0) {%>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Major</td>
      <td>
      <select name="major_index">
          <option value="">All</option>
          <%=dbOP.loadCombo("major_index","major_name"," from major where is_del = 0 and course_index = "+strTemp2 + " order by course_code asc", WI.fillTextValue("major_index"), false)%>
        </select>      
	  </td>
      <td>&nbsp;</td>
    </tr>
<%}%>	
-->


    <tr> 
      <td height="25">&nbsp;</td>
      <td >&nbsp;</td>
      <td colspan="2">
      	<input type="submit" name="_" value="Show Result" onClick="document.form_.show_result.value='1'">	  </td>
    </tr>
  </table>
<%if(vRetResult != null && vRetResult.size() > 0) {%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" id='myADTable3'>
    <tr align="right">
      <td height="25" style="font-size:9px;"><a href="javascript:PrintPage();"><img src="../../../../images/print.gif" border="0"></a>Print Report</td>
    </tr>
  </table>
<%
String strTodaysDate = WI.getTodaysDate(1);

Vector vIDsNotProcessed = new Vector();
Vector vScheduleInfo = null;
String strSQLQuery = null;
String strCourseName = null;
String[] astrConvertTerm = {"Summer","1st Sem","2nd Sem","3rd Sem"};
if(WI.fillTextValue("c_index").length() > 0) {
	strSQLQuery = "select c_name from college where c_index = "+WI.fillTextValue("c_index");
	strCourseName = dbOP.getResultOfAQuery(strSQLQuery, 0);
}
/**
if(WI.fillTextValue("major_index").length() > 0) {
	strSQLQuery = "select course_code from major where major_index = "+WI.fillTextValue("major_index");
	strSQLQuery = dbOP.getResultOfAQuery(strSQLQuery, 0);
	if(strSQLQuery != null)
		strCourseName = strCourseName + " - "+strSQLQuery;
}
if(WI.fillTextValue("yr_lvl").length() > 0) 
	strCourseName += " - "+WI.fillTextValue("yr_lvl");
**/
int iStudCount = 1;


double dCurrentCharge = 0d;
double dPreviousBal   = 0d;
double dTotal = 0d;

String strPrelim = null;
String strMidterm = null;
String strSemiFinal = null;
String strFinal = null;

while(vRetResult.size() > 0) {
if(iStudCount > 1) {
%>
	<DIV style="page-break-before:always" >&nbsp;</DIV>
<%}%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr align="center">
      <td height="25" style="font-size:16px; font-weight:bold" colspan="4">UNIVERSITY OF LUZON<br>
	  <font size="1" style="font-weight:normal">Dagupan City</font></td>
    </tr>
    <tr>
      <td width="42%" height="25">College: <%=WI.getStrValue(strCourseName,"&nbsp;")%></td>
      <td width="24%"><strong>Installment Dues</strong></td>
      <td width="18%">SY/Term: <%=WI.fillTextValue("sy_from")+" - "+WI.fillTextValue("sy_to")%>, <%=astrConvertTerm[Integer.parseInt(WI.fillTextValue("semester"))]%> </td>
      <td width="16%" style="font-size:9px;">Date Printed: <%=strTodaysDate%></td>
    </tr>
  </table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" class="thinborder">
    <tr>
      <td width="20%" height="35" class="thinborder">NAME</td>
      <td width="3%" class="thinborder">UNITS</td>
      <td width="6%" class="thinborder">CURRENT CHARGES</td>
      <td width="6%" class="thinborder">PREVIOUS BALANCE</td>
      <td width="6%" class="thinborder">TOTAL</td>
      <td width="9%" class="thinborder">DOWN PAYMENT </td><!--52-->
      <td width="7%" class="thinborder">PRELIM</td>
      <td width="7%" class="thinborder">MIDTERM</td>
      <td width="7%" class="thinborder">SEMI-FINAL</td>
      <td width="7%" class="thinborder">FINAL</td>
      <td width="5%" class="thinborder">TOTAL PAYMENTS</td>
      <td width="4%" class="thinborder">PREVIOUS BALANCE</td>
      <td width="5%" class="thinborder">CURRENT BALANCE</td>
      <td width="8%" class="thinborder">TOTAL</td><!--52-->
    </tr>
	<%
	while(vRetResult.size() > 0){
	//get downpayment information.
	strDPInfo = null;
	iObj = new Integer((String)vRetResult.elementAt(0));
	
	iIndexOf = vDPInfo.indexOf(iObj);
	if(iIndexOf == -1)	
		strDPInfo = null;
	else {
		strDPInfo = "OR #: "+(String)vDPInfo.elementAt(iIndexOf + 1)+"<br>"+
		"Date: "+(String)vDPInfo.elementAt(iIndexOf + 3)+"<br>"+
		"Amount: "+(String)vDPInfo.elementAt(iIndexOf + 2);
		vDPInfo.remove(iIndexOf);vDPInfo.remove(iIndexOf);vDPInfo.remove(iIndexOf);vDPInfo.remove(iIndexOf);
	}
	
	vScheduleInfo = (Vector) vRetResult.elementAt(5);
	if(vScheduleInfo == null) {
		vIDsNotProcessed.addElement(vRetResult.elementAt(1));
		vRetResult.remove(0);vRetResult.remove(0);vRetResult.remove(0);vRetResult.remove(0);vRetResult.remove(0);vRetResult.remove(0);
		continue;
	}
	//System.out.println(vScheduleInfo);
	//dCurrentCharge = Double.parseDouble(ConversionTable.replaceString((String)vScheduleInfo.elementAt(0), ",",""));
	//dPreviousBal   = Double.parseDouble(ConversionTable.replaceString((String)vScheduleInfo.elementAt(1), ",",""));
	dCurrentCharge = ((Float)vScheduleInfo.elementAt(0)).doubleValue();
	dPreviousBal   = ((Float)vScheduleInfo.elementAt(1)).doubleValue();
	dTotal = dCurrentCharge + dPreviousBal;
	
	strPrelim = null;
	strMidterm = null;
	strSemiFinal = null;
	strFinal = null;

	  strTemp = (String)vScheduleInfo.elementAt(5);
	  if(strTemp != null && strTemp.toLowerCase().startsWith("pre")) {
	  	strPrelim = CommonUtil.formatFloat((String)vScheduleInfo.elementAt(7), true);
		vScheduleInfo.remove(5);vScheduleInfo.remove(5);vScheduleInfo.remove(5);
	  }
	  if(vScheduleInfo.size() > 6) {
		  strTemp = (String)vScheduleInfo.elementAt(5);
		  if(strTemp != null && strTemp.toLowerCase().startsWith("mid")) {
			strMidterm = CommonUtil.formatFloat((String)vScheduleInfo.elementAt(7), true);
			vScheduleInfo.remove(5);vScheduleInfo.remove(5);vScheduleInfo.remove(5);
		  }
	  }
	  if(vScheduleInfo.size() > 6) {
		  strTemp = (String)vScheduleInfo.elementAt(5);
		  if(strTemp != null && strTemp.toLowerCase().startsWith("semi")) {
			strSemiFinal = CommonUtil.formatFloat((String)vScheduleInfo.elementAt(7), true);
			vScheduleInfo.remove(5);vScheduleInfo.remove(5);vScheduleInfo.remove(5);
		  }
	  }
	  if(vScheduleInfo.size() > 6) {
		  strTemp = (String)vScheduleInfo.elementAt(5);
		  if(strTemp != null && strTemp.toLowerCase().startsWith("final")) {
			strFinal = CommonUtil.formatFloat((String)vScheduleInfo.elementAt(7), true);
			vScheduleInfo.remove(5);vScheduleInfo.remove(5);vScheduleInfo.remove(5);
		  }
	  }
	
	%>
    <tr>
      <td height="50" class="thinborder"><%=iStudCount++%>. <%=vRetResult.elementAt(2)%><br>(<%=vRetResult.elementAt(1)%>)</td>
      <td class="thinborder"><%=vRetResult.elementAt(4)%></td>
      <td class="thinborder"><%=CommonUtil.formatFloat(dTotal - dPreviousBal, true)%></td>
      <td class="thinborder"><%=CommonUtil.formatFloat(dPreviousBal, true)%></td>
      <td class="thinborder"><%=CommonUtil.formatFloat(dTotal, true)%></td>
      <td class="thinborder"><%=WI.getStrValue(strDPInfo, "&nbsp;")%></td>
      <td class="thinborder"><%=WI.getStrValue(strPrelim, "&nbsp;")%></td>
      <td class="thinborder"><%=WI.getStrValue(strMidterm, "&nbsp;")%></td>
      <td class="thinborder"><%=WI.getStrValue(strSemiFinal, "&nbsp;")%></td>
      <td class="thinborder"><%=WI.getStrValue(strFinal, "&nbsp;")%></td>
      <td class="thinborder">&nbsp;</td>
      <td class="thinborder">&nbsp;</td>
      <td class="thinborder">&nbsp;</td>
      <td class="thinborder">&nbsp;</td>
    </tr>
	<%
	vRetResult.remove(0);vRetResult.remove(0);vRetResult.remove(0);vRetResult.remove(0);vRetResult.remove(0);vRetResult.remove(0);
	if( (iStudCount-1) %iRowsPerPage == 0) 
		break;
	}%>
  </table>

<%}//end of outer while loop.. 

	}//end of if condition.
if(vIDsNotProcessed.size() > 0) {%>

	<font style="font-weight:bold; font-size:18px; color:#FF0000">IDs Failed to Process: <%=vIDsNotProcessed%><br> Check ledger of Student and run this report again after applying possible fix.</font>

<%}%>
<input type="hidden" name="show_result" value="<%=WI.fillTextValue("show_result")%>">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>