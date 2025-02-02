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
								"hr_certification.jsp");

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
											request.getRemoteAddr(),"hr_certification.jsp");
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
String strLeaveCredits = null;
					  
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

	    java.text.SimpleDateFormat dateFormat = new java.text.SimpleDateFormat("MM/dd/yyyy");
	    java.util.Date date = null;
    	try {
			if ((String)vEmpRec.elementAt(6) != null) 
		        date = dateFormat.parse((String)vEmpRec.elementAt(6));
			else
		       strErrMsg = " No record of Date of Employment";				
    	}
	    catch(java.text.ParseException pExp)
    	{
	       strErrMsg = " No record of Date of Employment";
	       pExp.getMessage();
    	}

	    Calendar calendar = Calendar.getInstance();

	    if (date != null){
		      calendar.setTime(date);
	
			calendar.add(Calendar.YEAR,3);
			strNextDay = astrMonth[calendar.get(Calendar.MONTH)] + " " 
						+ calendar.get(Calendar.DAY_OF_MONTH) + ", " + 
						calendar.get(Calendar.YEAR);

			calendar.add(Calendar.DAY_OF_MONTH,14);
			str2Weeks = astrMonth[calendar.get(Calendar.MONTH)] + " " 
						+ calendar.get(Calendar.DAY_OF_MONTH) + ", " + 
						calendar.get(Calendar.YEAR);
		}else{	
			strNextDay =" (no record)";
			str2Weeks =" (no record)";			
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
<title>HR Certification</title>
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

<form name="form_" method="post" action="./hr_certification.jsp">
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
    <td width="61%"><input type="image" src="../../../../images/form_proceed.gif" width="81" height="21" border="0" onClick="ReloadPage()"></td>
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

<% if (vEmpRec != null && vEmpRec.size() > 0) {%> 
<table width="95%" border="0" align="center" cellpadding="0" cellspacing="0">
  <tr>
    <td height="58" colspan="2" align="center">	<font size="4">C E R T I F I C A T I O N</font> </td>
  </tr>
  <tr>
    <td colspan="2"> 
			    <font size="3">To 
			    <label id="addressee" 
				onclick="setLabelText('addressee','Addressee ')">
				Whom It May Concern</label>
			    :</font><br /><br /></td>
  </tr>
  <tr>
    <td colspan="2"><font size="3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;This is to certify that <strong>
		<label id="emp_name" 
			onclick="setLabelText('emp_name','Employee Name')">
			<%= WI.getStrValue(strSalutation) + " " + 
				WI.formatName((String)vEmpRec.elementAt(1), (String)vEmpRec.elementAt(2),
						 (String)vEmpRec.elementAt(3), 7)%></label>
        </strong> is employed with Angeles University Foundation since
<% if ((String)vEmpRec.elementAt(6) != null) 
	strTemp = WI.formatDate((String)vEmpRec.elementAt(6),6);
  else 
  	strTemp = "(No record)";%>
		<strong><label id="date_employment" 
			onclick="setLabelText('date_employment','Date of Employment')">		
		 <%=strTemp%> to date </label></strong>.  &nbsp;
		 
		<%	
		 if (WI.getStrValue((String)vEmpRec.elementAt(4)).equals("0")) {%> 
		 He  <%}else{%> She <%}%> 
		 is presently the 
			 
         <strong>
         <% 
	strTemp = (String)vEmpRec.elementAt(13);
	if (strTemp == null)
		strTemp = (String)vEmpRec.elementAt(14);
		
	if (strTemp == null)
		strTemp = "(No Record)";
%>
			<label id="emp_position" 
				onclick="setLabelText('emp_position','Employee Position')">
				<%=(String)vEmpRec.elementAt(15)%> of the <%=strTemp%></label>
         </strong>.</font><br />
	   <br />
	   <br />
       <font size="3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
	   	Issued this <%=WI.getTodaysDate(14)%> upon request of 
			<label id="salutation" 
				onclick="setLabelText('salutation','Salutation')">
		<%=WI.getStrValue(strSalutation) + " " + WI.getStrValue((String)vEmpRec.elementAt(3))%>
			</label> for 
			<label id="purpose" 
				onclick="setLabelText('purpose','State Purpose')">
				** - click to set purpose - **
			</label>.
		</font>
		</td>
  </tr>
  <tr>
    <td width="65%"><div align="right"></div></td>
    <td width="35%">&nbsp;</td>
  </tr>
  <tr>
    <td>&nbsp;</td>
    <td align="center"><br />
        <br />
        <br />
        <br />
        <strong><font size="3">
<label id="director" 
		onclick="setLabelText('director','HRDC Director')"> 
		<%=CommonUtil.getNameForAMemberType(dbOP,"Director, HR",7)%></label></font>
<font size="3"><br />
      Director </font></strong></td>
  </tr>
  <tr>
    <td height="45" valign="bottom"><font size="1">N.B. Valid only for the purpose stated </font></td>
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
