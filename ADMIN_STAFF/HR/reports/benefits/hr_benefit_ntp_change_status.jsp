<%@ page language="java" import="utility.*, java.util.Vector,java.util.Calendar"%>
<%
String[] strColorScheme = CommonUtil.getColorScheme(5);
//strColorScheme is never null. it has value always.
WebInterface WI = new WebInterface(request);
String strErrMsg = null;
DBOperation dbOP = null;
String strTemp = null;

try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-HR Management-REPORTS AND STATISTICS-Benefits",
								"hr_benefit_health_prog_letter.jsp");

	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		if(strErrMsg == null)
		strErrMsg = "Error in opening DB Connection.";
		%>

		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		  Error in opening connection </font></p>
		<%
		return;
	}
//authenticate this user.
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,
											(String)request.getSession(false).getAttribute("userId"),
											"HR Management","REPORTS AND STATISTICS",
											request.getRemoteAddr(),"hr_benefit_health_prog_letter.jsp");
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

Vector vEmpRec = null;
String strSalutation = null;
String str2Weeks = null;
String strNextDay = null;
String[] astrMonth ={"January", "February", "March", "April", "May", "June",
					  "July", "August", "September", "October", "November", "December"};
String strHead = null;
String strSelfAssessment = "";

					  
hr.HRBenefitsMgmt bMgt = new hr.HRBenefitsMgmt(request);

if (WI.fillTextValue("show_list").equals("1") && WI.fillTextValue("emp_id").length()  > 0){

	enrollment.Authentication authentication = new enrollment.Authentication();
    vEmpRec = authentication.operateOnBasicInfo(dbOP,request,"0");
	
	
	if (vEmpRec == null || vEmpRec.size()  == 0)	{
		strErrMsg = authentication.getErrMsg();
	}else{
		strSalutation = dbOP.mapOneToOther("hr_info_personal left join hr_preload_salutation " +
								" on (hr_info_personal.salutation_index = " + 
								" hr_preload_salutation.salutation_index)","user_index",
								(String)vEmpRec.elementAt(0),"salutation","");
								
		if ((String)vEmpRec.elementAt(11) != null) {

			strHead = dbOP.mapOneToOther("COLLEGE","c_index",
								(String)vEmpRec.elementAt(11),"DEAN_NAME"," and is_del = 0");
		}else{
			strHead = dbOP.mapOneToOther("department","d_index",
								(String)vEmpRec.elementAt(12),"DH_NAME"," and is_del = 0");
		}
	
	    java.text.SimpleDateFormat dateFormat = new java.text.SimpleDateFormat("MM/dd/yyyy");
	    java.util.Date date = null;
		java.util.Date date2 = null;
    	try {
	        date = dateFormat.parse((String)vEmpRec.elementAt(6));
	        date2 = dateFormat.parse(WI.getTodaysDate(1));
    	}
	    catch(java.text.ParseException pExp)
    	{
	       strErrMsg = " No record of Date of Employment";
	       pExp.getMessage();
    	}


		if (strErrMsg == null) {
		    Calendar calendar = Calendar.getInstance();

		    if (date != null)
			      calendar.setTime(date);
		
			calendar.add(Calendar.MONTH,3);
			strNextDay = astrMonth[calendar.get(Calendar.MONTH)] + " " 
						+ calendar.get(Calendar.DAY_OF_MONTH) + ", " + 
						calendar.get(Calendar.YEAR);


			if (date2  != null){
				calendar.setTime(date2);
				
			calendar.add(Calendar.DAY_OF_MONTH,5);
			str2Weeks = astrMonth[calendar.get(Calendar.MONTH)] + " " 
						+ calendar.get(Calendar.DAY_OF_MONTH) + ", " + 
						calendar.get(Calendar.YEAR);
						
 			calendar.add(Calendar.DAY_OF_MONTH,5);
			strSelfAssessment = astrMonth[calendar.get(Calendar.MONTH)] + " " 
						+ calendar.get(Calendar.DAY_OF_MONTH) + ", " + 
						calendar.get(Calendar.YEAR);
				

			}
		}	

	}
	
}
%>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css" />
<link href="../../../../css/reportlink.css" rel="stylesheet" type="text/css" />
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
<title>Untitled Document</title>
<style type="text/css">
.bgDynamic {
	background-color:<%=strColorScheme[1]%>
}
.footerDynamic {
	background-color:<%=strColorScheme[2]%>
}

label {
	color: #FF0000;
}
</style>

<script language="Javascript">

function OpenSearch() {
	var pgLoc = "../../../../search/srch_emp.jsp?opner_info=form_.emp_id";
	var win=window.open(pgLoc,"SearchID",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}


function ReloadPage() {
	document.form_.show_list.value="1";
}


function setLabelText(strLabelName, strLabel){
	var strOld = document.getElementById(strLabelName).innerHTML;
	var strNewValue = prompt(strLabel, strOld);
	
	if (strNewValue != null && strNewValue.length > 0)
		document.getElementById(strLabelName).innerHTML = strNewValue;
}


function printPage(){

	document.getElementById("header").deleteRow(0);	
	document.getElementById("header").deleteRow(0);
	document.getElementById("header").deleteRow(0);
	document.getElementById("header").deleteRow(0);	
	document.getElementById("footer").deleteRow(0);
	document.getElementById("footer").deleteRow(0);
	document.getElementById("footer").deleteRow(0);	
	window.print();
	
}




</script>
</head>

<body>

<form name="form_" method="post" action="./hr_benefit_ntp_change_status.jsp">
<table width="100%" border="0" cellspacing="0" cellpadding="0" id="header">
  <tr>
    <td height="25" colspan="4">&nbsp;<%=WI.getStrValue(strErrMsg, 
												"<font size=\"3\" color=\"#FF0000\"><strong>",
												"</strong></font>","")%></td>
  </tr>
  <tr>
    <td width="17%">&nbsp;Employee ID : </td>
    <td width="17%" height="25"><input name="emp_id" type="text" value="<%=WI.fillTextValue("emp_id")%>" size="16" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" /></td>
    <td width="5%"><a href="javascript:OpenSearch();"><img src="../../../../images/search.gif" width="37" height="30" border="0"></a></td>
    <td width="61%"><input type="image" src="../../../../images/form_proceed.gif"  border="0" onClick="ReloadPage()"></td>
  </tr>
  <tr>
    <td height="20" colspan="4"> &nbsp;&nbsp;
		<font style="font-size:11px">Items in <font color="#FF0000">RED</font> are editable for printing purposes only </font></td>
    </tr>
  <tr>
    <td>&nbsp;</td>
    <td height="20">&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
  </tr>  
</table>

  <div align="center">
    <% if (WI.fillTextValue("emp_id").length() > 0 && vEmpRec != null && vEmpRec.size() > 0
	&& strErrMsg  == null) {
//		System.out.println("vEmpRec : " + vEmpRec);
%>
    
    <strong>ANGELES UNIVERSITY FOUNDATION<br />
    Angeles City<br />
    Human Resources Development Center    </strong>
  </div>	
    <table width="95%" border="0" align="center" cellpadding="0" cellspacing="0">
      <tr>
        <td height="46" colspan="3" align="right" valign="top"><br />
          <label id="date_letter" 
				onclick="setLabelText('date_letter','Date of Letter')"> <%=WI.getTodaysDate(6)%></label>        </td>
      </tr>
      <tr>
        <td width="14%" height="25">FOR</td>
        <td width="6%">:</td>
        <td width="80%"><label id="head_name" 
			onclick="setLabelText('head_name','Employee Supervisor Name')">
				<%=strHead.toUpperCase()%></label>
		</td>
      </tr>
      <tr>
        <td height="25">FROM</td>
        <td>:</td>
        <td>Director</td>
      </tr>
      <tr>
        <td height="25">SUBJECT</td>
        <td>:</td>
        <td>
          <label id="emp_name" 
			onclick="setLabelText('emp_name','Employee Name')"><%=WI.getStrValue(strSalutation,""," ","")  + 
				WI.formatName((String)vEmpRec.elementAt(1), (String)vEmpRec.elementAt(2),
				 (String)vEmpRec.elementAt(3), 7)%></label></td>
      </tr>
      <tr>
        <td height="25">RE</td>
        <td>:</td>
        <td><strong>EXPIRATION OF PROBATIONARY CONTRACT </strong></td>
      </tr>
      <tr>
        <td colspan="3" height="25"><hr size="1" /></td>
      </tr>
  </table>

  <table width="95%" border="0" align="center" cellpadding="0" cellspacing="0">
  <tr>
    <td colspan="2">&nbsp;&nbsp;&nbsp;       &nbsp;&nbsp; &nbsp;&nbsp;&nbsp;Please be informed that the current work contract of  
      <u>
      <label id="emp_name_2" 
		onclick="setLabelText('emp_name_2','Employee Name')">
		<%=WI.getStrValue(strSalutation,""," ","")  + 
				WI.formatName((String)vEmpRec.elementAt(1), (String)vEmpRec.elementAt(2),
				 (String)vEmpRec.elementAt(3), 7)%></label></u> 
      who is on <strong><u>Probationary Status</u></strong> will expire on  
       <u><label id="first_day" 
		onclick="setLabelText('first_day','Effective Date')"> 
	  <%=strNextDay%></label> </u>  .<br /> <br />
       &nbsp;&nbsp;&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp;In this connection, please do the necessary recommendation by accomplishing the attached Performance Evaluation Form for the subject personnel and submit the same not later than  
       <u><label id="first_day" 
		onclick="setLabelText('first_day','Last Date of Submission of Form')"> 
	  <%=str2Weeks%></label></u>.<br />
       <br />
       &nbsp;&nbsp;&nbsp;       &nbsp;&nbsp; &nbsp;&nbsp;&nbsp;Thank you for you kind attention. <br />
       <br /></td>
  </tr>
  <tr>
    <td colspan="2">N.B. &nbsp;&nbsp;&nbsp;1. Please refer to the NTP Handbook ( Article IV - Section 1 - 3) for your guide on this matter.<br />
      <br />
&nbsp;&nbsp;&nbsp;       &nbsp;&nbsp; &nbsp;&nbsp;&nbsp;2. The subject personnel should be notified of your recommendation at least one (1) month before the expiration of his/her work contract.<br />
<br />
&nbsp;&nbsp;&nbsp;       &nbsp;&nbsp; &nbsp;&nbsp;&nbsp;3. If recommended for regular status, Self Assessment Test will be on 
       <u><label id="self_assess" 
		onclick="setLabelText('self_assess','Date of Self Assessment Test')"> 
		<%=strSelfAssessment%> </label></u>
	<br />
<br />
&nbsp;&nbsp;&nbsp;       &nbsp;&nbsp; &nbsp;&nbsp;&nbsp;4.&nbsp;The subject personnel should submit an <strong>Accomplishment Report</strong> for the last fiive (5) months of his/her probationary period.<br />
<br />
&nbsp;&nbsp;&nbsp;       &nbsp;&nbsp; &nbsp;&nbsp;&nbsp;5. Lastly, the personnel is required to submit a <strong>Work and Career Development Plan</strong> for two (2) Years. </td>
    </tr>
  <tr>
    <td width="69%" height="67"><br />
        <br />
        <br /></td>
    <td width="31%" valign="bottom"><strong>
<label id="director" 
		onclick="setLabelText('director','HRDC Director')"> 
		<%=CommonUtil.getNameForAMemberType(dbOP,"Director, HR",7 )%></label>
    </strong></td>
  </tr>
  <tr>
    <td height="30"><br />
      <strong>&nbsp;&nbsp;&nbsp;       &nbsp;&nbsp; &nbsp;&nbsp;&nbsp;Noted by:</strong><br />
      <br />
      <br />
      <strong>
 
		&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp;
		<label id="vp_odms" 
		onclick="setLabelText('vp_odms','VP for Organizational Devt')"><%=CommonUtil.getNameForAMemberType(dbOP,"VP, ODMS",7 )%></label></strong><br />
      &nbsp;&nbsp;&nbsp;       &nbsp;&nbsp; &nbsp;&nbsp;&nbsp;VP for Organizational Development<br />
&nbsp;&nbsp;&nbsp;       &nbsp;&nbsp; &nbsp;&nbsp;&nbsp;&amp; Management Systems</td>
    <td>&nbsp;</td>
  </tr>
</table>
<br />
<table width="95%" border="0" align="center" cellpadding="0" cellspacing="0" id="footer">
  <tr>
    <td><hr /></td>
  </tr>
  <tr>
    <td><div align="center">
	<a href="javascript:printPage()"><img src="../../../../images/print.gif" width="58" height="26" border="0" /></a><font size="1">print letter </font></div></td>
  </tr>
  <tr>
    <td height="30"><font size="2"><strong>Note: Set Printer to black / white mode before printing</strong></font></td>
  </tr>
</table>
<%}%>

<input type="hidden" name="show_list" value="<%=WI.fillTextValue("show_list")%>" />
</form>
</body>
</html>
<%
	dbOP.cleanUP();
%>

