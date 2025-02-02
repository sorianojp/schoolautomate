<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<style>
body {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 12px;
}
table{
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 12px;
}
td {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 12px;
 }

th {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 12px;
 }
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
<script language="JavaScript" src="../../../../Ajax/ajax.js"></script>
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
	document.getElementById('myADTable2').deleteRow(0);
	document.getElementById('myADTable2').deleteRow(0);

	document.getElementById('myADTable3').deleteRow(0);

	alert("Click OK to print this page");
	window.print();
}
function CallOnLoad() {
	document.all.processing.style.visibility='hidden';
	document.bgColor = "#FFFFFF";
}

function DeleteProj() {
	document.form_.del_projection.value = '1';
	document.all.processing.style.visibility='visible';
	document.bgColor = "#aaaaaa";
	document.form_.submit();
}

//// - all about ajax..
function AjaxMapName(strPos) {
		var strCompleteName;
		strCompleteName = document.form_.stud_id.value;
		if(strCompleteName.length < 2) {
			document.getElementById("coa_info").innerHTML = "";
			return;
		}

		var objCOAInput;
		objCOAInput = document.getElementById("coa_info");

		this.InitXmlHttpObject(objCOAInput, 2);//I want to get innerHTML in this.retObj
  		if(this.xmlHttp == null) {
			alert("Failed to init xmlHttp.");
			return;
		}
		var strURL = "../../../../Ajax/AjaxInterface.jsp?methodRef=2&search_id=1&name_format=4&complete_name="+
			escape(strCompleteName);

		this.processRequest(strURL);
}
function UpdateID(strID, strUserIndex) {
	/** do not do anything **/
	document.form_.stud_id.value = strID;
	document.form_.submit();
}
function UpdateName(strFName, strMName, strLName) {
	//var strName = strLName.toUpperCase() +", "+strFName+" "+strMName.charAt(0);
	//document.form_.charge_to_name.value = strName;
}
function UpdateNameFormat(strName) {
	document.getElementById("coa_info").innerHTML = "";
}

</script>
<body topmargin="0" bottommargin="0" onLoad="CallOnLoad();" bgcolor="#DDDDDD">
<div id="processing" style="position:absolute; top:0px; left:0px; width:250px; height:50px;  visibility:visible">
<table cellpadding=0 cellspacing=0 border=0 Width=100% Height=100% align=Center class="thinborderALL">
      <tr>
            <td align="center" class="v10blancong" bgcolor="#FFCC66">
			<p style="font-size:12px; font-weight:bold; font-family:Verdana, Arial, Helvetica, sans-serif"> Processing Request. Please wait...
			<br> <font color='red'>Loading Page</font></p>

			<img src="../../../../Ajax/ajax-loader2.gif"></td>
      </tr>
</table>
</div>
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
enrollment.ReportEnrollment reportEnrl= new enrollment.ReportEnrollment();
Vector vRetResult = new Vector();


String strPmtSchedule = "select pmt_sch_index from fa_pmt_schedule where exam_name like 'final%' and is_valid = 1";
strPmtSchedule = dbOP.getResultOfAQuery(strPmtSchedule, 0);

if(WI.fillTextValue("del_projection").length() > 0) {
	dbOP.executeUpdateWithTrans("update FA_FEE_HISTORY_PROJECTED_COL_RUNDATE set IS_RUNNING = 0, TO_PROCESS = 0", null, null, false);
}

if(WI.fillTextValue("show_result").length() > 0 && WI.fillTextValue("sy_from").length() > 0 && WI.fillTextValue("pmt_schedule").length() > 0) {
	request.setAttribute("print_clearance", "1");

	vRetResult = RFA.getPeriodicalExamBalance(dbOP, request);
	if(vRetResult == null)
		strErrMsg = RFA.getErrMsg();
}

///get here graduation fee Information.
Vector vGraduationFeeInfo = new Vector();
int iIndexOf = 0;
if(vRetResult != null && vRetResult.size() > 0) {
	String strSQLQuery = null;
	String strSYIndex  = null;
	strSQLQuery = "select sy_index from fa_schyr where sy_from = "+WI.fillTextValue("sy_from");
	strSYIndex = dbOP.getResultOfAQuery(strSQLQuery, 0);
	if(strSYIndex != null) {
		strSQLQuery = "select othsch_fee_index from fa_oth_sch_fee where sy_index = "+strSYIndex+" and fee_name in ('Graduation Fee', 'Alumni fee') and is_valid = 1";
		java.sql.ResultSet rs = dbOP.executeQuery(strSQLQuery);
		strSQLQuery = null;
		while(rs.next()) {
			if(strSQLQuery == null)
				strSQLQuery = rs.getString(1);
			else
				strSQLQuery = strSQLQuery + ","+rs.getString(1);
		}
		rs.close();
		if(strSQLQuery != null) {
			strSQLQuery = "select user_index, sum(amount * no_of_units) from fa_stud_payable where is_valid = 1 and sy_from = "+WI.fillTextValue("sy_from")+
							" and semester = "+WI.fillTextValue("semester")+" and payable_type = 0 and reference_index in ("+strSQLQuery+") group by user_index";
			rs = dbOP.executeQuery(strSQLQuery);
			while(rs.next()) {
				vGraduationFeeInfo.addElement(rs.getString(1));
				vGraduationFeeInfo.addElement(CommonUtil.formatFloat(rs.getDouble(2), true));
			}
			rs.close();
		}
	}
}

%>
<form action="./clearance_account_slip.jsp" method="post" name="form_" onSubmit="SubmitOnceButton(this);">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" id='myADTable1'>
    <tr>
      <td width="100%" height="25" align="center" class="thinborderBOTTOM"><strong>:::: Account Slip (Clearance) ::::</strong></td>
    </tr>
    <tr >
      <td height="25">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<font size="3"><b><%=WI.getStrValue(strErrMsg)%></b></font></td>
    </tr>
  </table>

	<table  width="100%" border="0" cellspacing="0" cellpadding="0" id='myADTable2'>
    <tr>
      <td width="2%" height="25">&nbsp;</td>
      <td width="13%">SY/TERM</td>
      <td width="47%"> <%
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
        <option value="1" <%=strErrMsg%>>1st Term</option>
 <%
if(strTemp.equals("2"))
	strErrMsg = " selected";
else
	strErrMsg ="";
%>
       <option value="2" <%=strErrMsg%>>2nd Term</option>
<%
if(strTemp.equals("3"))
	strErrMsg = " selected";
else
	strErrMsg ="";
%>
          <option value="3" <%=strErrMsg%>>3rd Term</option>
        </select>	 </td>
      <td>&nbsp;</td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>College</td>
      <td colspan="2">
      <%strTemp = WI.fillTextValue("c_index");%>
      <select name="c_index">
          <%=dbOP.loadCombo("c_index","c_name"," from college where IS_DEL=0 order by c_name asc",
		  		WI.fillTextValue("c_index"), false)%> </select>	  </td>
      </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>Student ID (print one) </td>
      <td colspan="2">
	  	<input name="stud_id" type="text" size="24" maxlength="24" value="<%=WI.fillTextValue("stud_id")%>" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" onKeyUp="AjaxMapName('1');">	  </td>
    </tr>
    <tr>
      <td height="25"></td>
      <td colspan="3"><label id="coa_info" style="font-size:11px; font-weight:bold; color:#0000FF"></label></td>
      </tr>
<!--
    <tr>
      <td height="25">&nbsp;</td>
      <td>Course</td>
      <td colspan="2">
	<%if (strTemp==null || strTemp.length()==0 )
		strTemp = " from course_offered where is_del = 0 and is_valid = 1 order by course_name asc";
	else
		strTemp = " from course_offered where is_del = 0 and is_valid = 1 and c_index = "+strTemp+
		" order by course_name asc";

	String strTemp2 = WI.fillTextValue("course_index");%>
      <select name="course_index" onChange="ReloadPage();">
          <option value="">All</option>
          <%=dbOP.loadCombo("course_index","course_name",strTemp, strTemp2, false)%>
        </select>	  </td>
      </tr>
-->
    <tr>
      <td height="25">&nbsp;</td>
      <td >&nbsp;</td>
      <td>
      	<input type="submit" name="_" value="Show Result" onClick="document.form_.show_result.value='1'">	  </td>
      <td width="38%">&nbsp;</td>
    </tr>
  </table>
<%if(vRetResult != null && vRetResult.size() > 0) {%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" id='myADTable3'>
    <tr align="right">
      <td height="25" style="font-size:9px;"><a href="javascript:PrintPage();"><img src="../../../../images/print.gif" border="0"></a>Print Report</td>
    </tr>
  </table>
<%
String strTodaysDateTime = WI.getTodaysDateTime();
String[] astrConvertTerm = {"Summer","1st Term","2nd Term","3rd Term"};
int iStudCount = 1;
String strAdmSlipNo = null;

String strSYFrom = WI.fillTextValue("sy_from");
String strSemester = WI.fillTextValue("semester");

String strGraduationFee = null;

while(vRetResult.size() > 0) {
if(iStudCount > 1) {
%>
	<DIV style="page-break-before:always" >&nbsp;</DIV>
<%}%>
<!--<br>-->
<%
while(vRetResult.size() > 0){
	//get admission slip number here.
	strAdmSlipNo = reportEnrl.autoGenAdmSlipNum(dbOP, (String)vRetResult.elementAt(0),strPmtSchedule, strSYFrom, strSemester,
                            (String)request.getSession(false).getAttribute("userIndex"));
	iIndexOf = vGraduationFeeInfo.indexOf((String)vRetResult.elementAt(0));
	if(iIndexOf == -1)
		strGraduationFee = null;
	else
		strGraduationFee = "Graduation Fee: "+vGraduationFeeInfo.elementAt(iIndexOf + 1);
%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr align="center">
      <td height="25" style="font-size:14px; font-weight:bold"><%=SchoolInformation.getSchoolName(dbOP,true,false)%><br>
	  <font size="1" style="font-weight:normal"><%=SchoolInformation.getAddressLine1(dbOP,false,false)%><%=WI.getStrValue(SchoolInformation.getAddressLine2(dbOP,false,false),",","","")%></font></td>
    </tr>
    <tr>
      <td height="25" align="center" style="font-weight:bold" class="thinborderBOTTOM">A C C O U N T &nbsp;&nbsp;S L I P
	  <br>
	  <%=WI.fillTextValue("sy_from")+" - "+WI.fillTextValue("sy_to")%>, <%=astrConvertTerm[Integer.parseInt(WI.fillTextValue("semester"))]%>
	  </td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
  	<tr>
		<td width="50%">
			<table width="100%" cellpadding="0" cellspacing="0">
				<tr>
					<td width="25%" height="18">No: </td>
					<td><%=WI.getStrValue(strAdmSlipNo,"&nbsp;")%></td>
				</tr>
				<tr>
					<td width="25%" height="18">ID No: </td>
					<td><%=vRetResult.elementAt(1)%></td>
				</tr>
				<tr>
					<td width="25%" height="18">Name </td>
					<td><%=vRetResult.elementAt(2)%></td>
				</tr>
				<tr>
					<td width="25%" height="18">Course </td>
					<td><%=vRetResult.elementAt(3)%><%=WI.getStrValue((String)vRetResult.elementAt(4), "-","","")%>
	  					<%=WI.getStrValue((String)vRetResult.elementAt(5), "-","","")%></td><!--course-major-yr-->
				</tr>
				<tr>
					<td width="25%" height="18">Balance </td>
					<td>
						<%
							strTemp = WI.getStrValue(vRetResult.elementAt(7), "&nbsp;");
							if(strTemp.startsWith("-") || strTemp.startsWith("0."))
								strTemp = "***PAID***";
						%>
						<%=strTemp%>
						<%if(strGraduationFee != null) {%>
							&nbsp;<%=strGraduationFee%>
						<%}%>
					</td>
				</tr>
				<%
					vRetResult.remove(0);vRetResult.remove(0);vRetResult.remove(0);vRetResult.remove(0);
					vRetResult.remove(0);vRetResult.remove(0);vRetResult.remove(0);vRetResult.remove(0);vRetResult.remove(0);vRetResult.remove(0);
				%>
				<tr>
					<td colspan="2" height="18">&nbsp;</td>
				</tr>
				<tr>
					<td colspan="2" valign="top" height="21"> &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Certified Correct: </td>
				</tr>
				<tr>
					<td colspan="2" align="center">
					<!--ETHEL ANGELA J. DIZON<br>School Accountant-->
					<img src="../uc_school_accountant.jpg" width="311" height="37">					</td>
				</tr>
			</table>
		</td>
		<td width="2%">&nbsp;</td>
		<td width="48%" valign="top">
		<div align="center">C L E A R A N C E </div>
		Signature of Clearing Officer <br><br>
		<table width="100%" cellpadding="0" cellspacing="0" border="0">
			<tr>
				<td width="44%" height="18">________ Registrar </td>
				<td width="56%">_______ Property Head </td>
			</tr>
			<tr>
				<td height="18">________ Librarian</td>
				<td>&nbsp;</td>
			</tr>
			<tr>
			  <td>&nbsp;</td>
			  <td>&nbsp;</td>
		  </tr>
			<tr align="center">
			  <td colspan="2" valign="bottom" height="30">_________________</td>
		  </tr>
			<tr align="center">
			  <td colspan="2">Dean Of College </td>
		  </tr>
		</table>

		</td>
	</tr>
  </table>
  <table width="100%" cellpadding="0" cellspacing="0">
  	<tr>
		<td align="center"><hr size="1">
		<!--------------------------------------------------------------------------------------------------------------------------------></td>
	</tr>
  	<tr>
		<td class="thinborderNONE" align="center">*** TAMPERED ACCOUNT SLIP WILL BE DEALT WITH ACCORDINGLY ***</td>
	</tr>
  	<tr>
		<td align="center"><hr size="1">
		<!--------------------------------------------------------------------------------------------------------------------------------></td>
	</tr>
  </table>

<%
	if(iStudCount++ %4 == 0)
		break;
	else{%>
		<br><br><br>
	<%}

}//this is while condition.. %>


<%}//end of outer while loop..

	}//end of if condition.%>
<input type="hidden" name="show_result" value="<%=WI.fillTextValue("show_result")%>">
<input type="hidden" name="pmt_schedule" value="<%=strPmtSchedule%>">
<input type="hidden" name="del_projection">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
