<%@ page language="java" import="utility.*, java.util.Vector,java.util.Calendar"%>
<%
String[] strColorScheme = CommonUtil.getColorScheme(5);
//strColorScheme is never null. it has value always.
WebInterface WI = new WebInterface(request);
String strErrMsg = null;
DBOperation dbOP = null;
String strTemp = null;
String strSchCode = WI.getStrValue((String)request.getSession(false).getAttribute("school_code"));	

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

String[] astrPTFT = {"Part-Time", "Full-Time"};
String[] astrMonth ={"January", "February", "March", "April", "May", "June",
					  "July", "August", "September", "October", "November", "December"};
String strLeaveCredits = null;
					  
Vector vServiceRec = null;

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
		vServiceRec = new hr.HRInfoServiceRecord().operateOnCurrentSR(dbOP, request, 4);
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
	document.form_.show_name.value="1";	
	document.form_.format_date.value = "10";		
	document.form_.do_not_get_incentives.value = "1";			
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

<form name="form_" method="post" action="./hr_certification_service_rcd.jsp">
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
    <td height="58" colspan="3" align="center">	<font size="4">C E R T I F I C A T I O N</font> </td>
  </tr>
  <tr>
    <td colspan="3"> 
			    <font size="3">To 
			    <label id="addressee" 
				onclick="setLabelText('addressee','Addressee ')">
				Whom It May Concern</label>
			    :</font><br /><br /></td>
  </tr>
  <tr>
    <td colspan="3"><font size="3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;This is to certify that <strong>
		<label id="emp_name" 
			onclick="setLabelText('emp_name','Employee Name')">
			<%= WI.getStrValue(strSalutation) + " " + WI.formatName((String)vEmpRec.elementAt(1), (String)vEmpRec.elementAt(2),
						 (String)vEmpRec.elementAt(3), 7)%></label>
        </strong> is employed with Angeles University Foundation with the following service record : </font><br />
<% if (vServiceRec != null && vServiceRec.size() > 1) {%>
	    <table width="100%" border="0" cellspacing="0" cellpadding="0">
          <tr>
            <td height="18">&nbsp;</td>
            <td align="center">&nbsp;</td>
            <td>&nbsp;</td>
          </tr>
          <tr>
            <td width="35%" height="35"><strong><font size="2">Position/Status </font></strong></td>
            <td width="35%" align="center"><strong><font size="2">Unit</font></strong></td>
            <td width="30%"><strong><font size="2">Inclusive Date/s </font></strong></td>
          </tr>
<% for (int i = 1; i < vServiceRec.size() ; i += 31) {%>
          <tr>
            <td height="35" valign="top"><font size="2"><%=(String)vServiceRec.elementAt(i+2)%>
				<%if(strSchCode.startsWith("AUF")){%>
					<br><%=astrPTFT[Integer.parseInt((String)vServiceRec.elementAt(i + 28))]%> <%=(String)vServiceRec.elementAt(i+4)%>
				<%}%></font></td>
		<% strTemp = WI.getStrValue((String)vServiceRec.elementAt(i+6));
			if (strTemp.length() != 0) 
				strTemp +=  WI.getStrValue((String)vServiceRec.elementAt(i+8)," <br>","","");
			else
				strTemp =  WI.getStrValue((String)vServiceRec.elementAt(i+8));
		 %>
            <td valign="top"><font size="2"><%=strTemp%><br />
              <br />
            </font></td>
			<%
				//strTemp 
				//if(strSchCode.startsWith("AUF"))
					
			%>
            <td valign="top">
				<font size="2">&nbsp;<%=(String)vServiceRec.elementAt(i+17)%> <br />
			    to  <%=WI.getStrValue((String)vServiceRec.elementAt(i+18),  " date ")%>				</font></td>
          </tr>
<%}%> 
        </table>
<%}%> 
	    <br />
	   <br />
       <font size="3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
	   	Issued this <%=WI.getTodaysDate(14)%> upon request of 
			<label id="salutation" 
				onclick="setLabelText('salutation','Salutation')">
		<%=WI.getStrValue(strSalutation) + " " + WI.getStrValue((String)vEmpRec.elementAt(3))%>			</label> for 
			<label id="purpose" 
				onclick="setLabelText('purpose','State Purpose')">
				** - click to set purpose - **			</label>.		</font>	  </td>
  </tr>
  <tr>
    <td colspan="2"><div align="right"></div></td>
    <td width="26%">&nbsp;</td>
  </tr>
  <tr>
    <td width="34%" height="42" valign="bottom"><strong>Prepared by: </strong></td>
    <td width="40%" valign="bottom"><strong>Verified by: </strong></td>
    <td valign="bottom"><strong>Noted by : </strong></td>
  </tr>
  <tr>
    <td valign="top"><br />
      <br /><strong><font size="2">
<label id="hr_assist" 
		onclick="setLabelText('hr_assist','HR Assistant')"> 
		JOCELYN Z. MANALANG </label></font> </strong><br />
      <strong>HR Assistant </strong><br /></td>
    <td valign="top"><br />
      <br /><font size="2"><strong>
<label id="Head" 
		onclick="setLabelText('Head','Head, Personnel Services')"> 
		LOURDES G. TOLENTINO </label></strong></font>	  
      <br />
      <strong>Head, Personnel and Employee<br />
      Relations Services </strong></td>
    <td valign="top"><br />
      <br />
        <strong>
<label id="director" 
		onclick="setLabelText('director','HRDC Director')"> 
		<font size="2"><%=CommonUtil.getNameForAMemberType(dbOP,"Director, HR",7)%></font></label><font size="2"><br />Director </font></strong></td>
  </tr>
  <tr>
    <td height="45" colspan="2" valign="bottom"><font size="1">N.B. Valid only for the purpose stated 
	<%if(false && strSchCode.startsWith("AUF")){%>
		<br />AUF-Records-HRDC-PERS-25<br />filepath-schoolbliz/hr management>personnel>certification
	<%}%></font></td>
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
<input type="hidden" name="show_name" value="1" />
<input type="hidden" name="format_date" value="10" />
<input type="hidden" name="do_not_get_incentives" value="1" />
</form>
</body>
</html>
<%
	dbOP.cleanUP();
%>

