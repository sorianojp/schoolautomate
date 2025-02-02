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
<link href="../../../../css/tableBorder.css" rel="stylesheet" type="text/css" />
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

<form name="form_" method="post" action="./hr_benefit_ntp_change_status_pres.jsp">
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
    ANGELES UNIVERSITY FOUNDATION<br />
Angeles City, Philippines <strong><br />
<br />
<br />
CHANGE OF EMPLOYMENT STATUS<br />
(From Probationary to Regular) </strong></div>	
    <table width="95%" border="0" align="center" cellpadding="0" cellspacing="0">
      <tr>
        <td height="46" align="right" valign="top"><br />
          <label id="date_letter" 
				onclick="setLabelText('date_letter','Date of Letter')"> <%=WI.getTodaysDate(6)%></label>        </td>
      </tr>
      <tr>
        <td height="25">THE PRESIDENT <br />
          Angeles University Foundation </td>
      </tr>
      <tr>
        <td width="14%" height="25">&nbsp;</td>
      </tr>
      <tr>
        <td height="25">SIR: </td>
      </tr>
      <tr>
        <td height="25">&nbsp;</td>
      </tr>
  </table>

  <table width="95%" border="0" align="center" cellpadding="0" cellspacing="0">
  <tr>
    <td height="126" colspan="5">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp;
	<label id="emp_name" 
			onclick="setLabelText('emp_name','Employee Name')">
			<%=WI.getStrValue(strSalutation,""," ","")  + 
				WI.formatName((String)vEmpRec.elementAt(1), (String)vEmpRec.elementAt(2),
				 (String)vEmpRec.elementAt(3), 7)%></label> has satisfactorily completed the (6) months probationary period as 
     <label id="emp_position" 
			onclick="setLabelText('emp_position','Employee Position')">
			<%=(String)vEmpRec.elementAt(15)%></label>
      with the 
<% 
	strTemp = (String)vEmpRec.elementAt(13);
	if (strTemp == null)
		strTemp = (String)vEmpRec.elementAt(14);
%>
			<label id="office" 
				onclick="setLabelText('office','College / Office')">
				<%=strTemp%></label>.<br /> <br />
       &nbsp;&nbsp;&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp;On the basis of his/her performance, we respectfully recommend him/her for a change of status from <strong>PROBATIONARY</strong> to <strong>REGULAR</strong> effective 
       <label id="change_status" 
		onclick="setLabelText('change_status','Effective Date of Change of Status')"> 
	  <%=WI.getTodaysDate(6)%></label>
       .<br />
       <br />
       &nbsp;&nbsp;&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp;Thank you. <br />
       <br /></td>
  </tr>
  <tr>
    <td colspan="5"><hr size="1" /></td>
    </tr>
  <tr>
    <td height="40" colspan="5"><div align="center"><strong>RECOMMENDING APPROVAL </strong></div></td>
    </tr>
  <tr>
    <td height="20" valign="bottom"><em><strong>Non-Teaching Personnel</strong></em></td>
    <td valign="bottom">&nbsp;</td>
    <td valign="bottom">&nbsp;</td>
    <td valign="bottom">&nbsp;</td>
  </tr>
  <tr>
    <td height="20"><em>      Screening Committee</em> </td>
    <td><div align="center"><em>Printed Name</em> </div></td>
    <td>&nbsp;</td>
    <td><div align="center"><em>Signature</em></div></td>
  </tr>
  <tr>
    <td>&nbsp;</td>
    <td valign="bottom">&nbsp;</td>
    <td valign="bottom">&nbsp;</td>
    <td valign="bottom">&nbsp;</td>
  </tr>
  <tr>
    <td width="40%" height="45" valign="bottom"><strong>Dean / Head (Member)</strong></td>
    <td width="32%" valign="bottom" class="thinborderBOTTOM"><font size="2"><label id="head_name" 
			onclick="setLabelText('head_name','Employee Supervisor Name')">
				<%=strHead.toUpperCase()%></label></font></td>
    <td width="4%" valign="bottom">&nbsp;</td>
    <td width="24%" valign="bottom" class="thinborderBOTTOM">&nbsp;</td>
  </tr>
  <tr>
    <td height="45" valign="bottom"><strong> HRDC Director (Member) </strong></td>
    <td valign="bottom" class="thinborderBOTTOM"><font size="2">
      <label id="hrdirector" 
		onclick="setLabelText('hrdirector','HRDC Director')"><%=CommonUtil.getNameForAMemberType(dbOP,"Director, HR",7 )%></label>
    </font></td>
    <td>&nbsp;</td>
    <td class="thinborderBOTTOM">&nbsp;</td>
  </tr>
  <tr>
    <td height="45" valign="bottom"><strong>
      
    VP for Finance (Member) </strong></td>
    <td valign="bottom" class="thinborderBOTTOM">
      <font size="2">
      <label id="vp_finance" 
		onclick="setLabelText('vp_finance','VP for Finance')">
      <%=WI.getStrValue(CommonUtil.getNameForAMemberType(dbOP,"VP, Finance",7 ),"-click here-").toUpperCase()%>      </label>
      </font></td>
    <td>&nbsp;</td>
    <td class="thinborderBOTTOM">&nbsp;</td>
  </tr>
  <tr>
    <td height="60" valign="bottom"><strong>
    AVP for Organizational Development<br />
&amp; Management Systems (Member) </strong></td>
    <td valign="bottom" class="thinborderBOTTOM"><font size="2">
      <label id="avp_odms" 
		onclick="setLabelText('avp_odms','Asst. VP for Organizational Devt')">	
	<%=WI.getStrValue(CommonUtil.getNameForAMemberType(dbOP,"AVP, ODMS",7 ),"-click here-").toUpperCase()%></label></font></td>
    <td>&nbsp;</td>
    <td class="thinborderBOTTOM">&nbsp;</td>
  </tr>
  <tr>
    <td height="60" valign="bottom"><strong>VP for Organizational Development<br />
&amp; Management Systems (Chairman) </strong></td>
    <td valign="bottom" class="thinborderBOTTOM"><font size="2">
      <label id="vp_odms" 
		onclick="setLabelText('vp_odms','VP for Organizational Devt')">
			<%=WI.getStrValue(CommonUtil.getNameForAMemberType(dbOP,"VP, ODMS",7 ),"-click here-").toUpperCase()%></label>
    </font></td>
    <td>&nbsp;</td>
    <td class="thinborderBOTTOM">&nbsp;</td>
  </tr>
  <tr>
    <td height="65" valign="bottom"><div align="right"><strong>Regular Appointment starts on</strong> &nbsp;&nbsp;</div></td>
    <td valign="bottom" class="thinborderBOTTOM">&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
  </tr>
  <tr>
    <td height="63" valign="bottom">&nbsp;</td>
    <td valign="bottom"><strong>APPROVED BY </strong></td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
  </tr>
  <tr>
    <td height="22" valign="bottom">&nbsp;</td>
    <td valign="bottom" >&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
  </tr>
  <tr>
    <td height="45" valign="bottom">&nbsp;</td>
    <td valign="bottom" ><font size="2"><strong>RICARDO P. PAMA </strong></font></td>
    <td>&nbsp;</td>
    <td >&nbsp;</td>
  </tr>
  <tr>
    <td height="45" valign="bottom">&nbsp;</td>
    <td valign="top" >&nbsp;&nbsp;<strong>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;President </strong><br />
      <br />
      ________________<br />
      &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Date</td>
    <td>&nbsp;</td>
    <td >&nbsp;</td>
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

