<%@ page language="java" import="utility.*,java.util.Vector,hr.HRManageList,hr.HRBenefitsMgmt,java.util.Date" %>
<%
	String[] strColorScheme = CommonUtil.getColorScheme(5);
//strColorScheme is never null. it has value always.
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
	String strSchCode = WI.getStrValue((String)request.getSession(false).getAttribute("school_code"));
	
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Search Student</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<style>
	.fontsize11 {
		font-size:11px;
	}
	td {
		font-family:Verdana, Arial, Helvetica, sans-serif;
		font-size:11px;
	}
a:link {
	text-decoration: none;
}
</style>
<style type="text/css">
.bgDynamic {
	background-color:<%=strColorScheme[1]%>
}
.footerDynamic {
	background-color:<%=strColorScheme[2]%>
}
</style>
</head>
<script language="JavaScript" src="../../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../../jscript/date-picker.js"></script>
<script language="JavaScript">

function PrintPg()
{
<%if (strSchCode.startsWith("AUF")) { %>
	document.getElementById('footer').deleteRow(1);
<%}%> 

	document.getElementById('header').deleteRow(0);
	document.getElementById('header').deleteRow(0);
	document.getElementById('header').deleteRow(0);
	window.print();
}

function ReloadPage(){
	document.form_.print_page.value="";
	this.SubmitOnce("form_");
}

function showList(){
	document.form_.show_list.value = "1";
	document.form_.print_page.value = "";
	this.SubmitOnce("form_");
}

</script>

<body marginheight="0" >
<%

try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-REPORTS AND STATISTICS-Education","hr_educ_reports.jsp");

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
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"HR Management","REPORTS AND STATISTICS",request.getRemoteAddr(),
														"hr_educ_reports.jsp");
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
Vector vRetResult = null;

HRBenefitsMgmt hrStat = new HRBenefitsMgmt(request);
boolean bolForceWriteMF = false; // force to write M / F if all employees are part time!

if ( WI.fillTextValue("show_list").equals("1")){
	vRetResult = hrStat.getPERAAActuarial(dbOP);
	if(vRetResult == null)
		strErrMsg = hrStat.getErrMsg();
}

%>
<form action="./hr_benefit_peraa_actuarial.jsp" method="post" name="form_" >
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" id="header">
    <tr> 
      <td height="25" colspan="4">&nbsp;<%=WI.getStrValue(strErrMsg,"<strong><font size=\"3\" color=\"#FF0000\">","</font></strong>","")%></td>
    </tr>
    <tr>
      <td width="3%" height="25">&nbsp;</td>
      <td width="15%" class="fontsize11">Date of Reporting </td>

	  <% strTemp = WI.fillTextValue("cut_off_date");
	  	 if (strTemp.length() == 0)
		 	strTemp = WI.getTodaysDate(1);
		
			
		int iIndex = strTemp.indexOf("/");
		String strMonth = null;
		String strYear = null;
		String[] astrMonths = {"JANUARY", "FEBRUARY", "MARCH" , "APRIL", "MAY", "JUNE", 
								"JULY", "AUGUST", "SEPTEMBER", "OCTOBER","NOVEMBER", "DECEMBER"}; 
		
		if (iIndex != -1 && iIndex < 3){
			strMonth = astrMonths[Integer.parseInt(strTemp.substring(0,iIndex)) - 1 ];
			iIndex = strTemp.lastIndexOf("/");
			strYear = strTemp.substring(iIndex+1, strTemp.length());
		}		

		
		
	   %>  		  
	  
      <td width="17%"><input name="cut_off_date" type="text" class="textbox" 
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  value="<%=strTemp%>" size="10" maxlength="4">
	  <a href="javascript:show_calendar('form_.cut_off_date');" 
	  	title="Click to select date" onMouseOver="window.status='Select date';return true;"
		onMouseOut="window.status='';return true;"><img src="../../../../images/calendar_new.gif" border="0"></a>	  </td>
      <td width="65%"><a href="javascript:showList()"%><img src="../../../../images/form_proceed.gif" width="81" height="21" border="0"></a></td>
    </tr>
    <tr>
      <td height="18">&nbsp;</td>
      <td colspan="3" class="fontsize11"><strong>Note : This Report requires entries in the <font color="#FF0000">Service Record</font></strong> </td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td colspan="3" valign="bottom" class="fontsize11">&nbsp;</td>
    </tr>
  </table>
  
 <% if (vRetResult != null && vRetResult.size() > 1) {  %>
  <table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF" class="thinborder">
   <tr>
   <td width="5%" height="25" rowspan="2" class="thinborder"><font size="1">&nbsp;</font></td>
   <td width="30%" rowspan="2" valign="bottom" class="thinborder"><div align="center"><font size="1">Name</font></div></td>
   <td width="6%" rowspan="2" valign="bottom" class="thinborder"><font size="1">Unit</font></td>
   <td width="7%" rowspan="2" valign="bottom" class="thinborder"><font size="1">Emp<br>
     Status</font></td>
   <td width="7%" rowspan="2" valign="bottom" class="thinborder"><font size="1">Gender</font></td>
   <td width="12%" rowspan="2" valign="bottom" class="thinborder"><font size="1">BirthDate</font></td>
   <td width="5%" rowspan="2" valign="bottom" class="thinborder"><div align="center"><font size="1">Age<br> 
     (as of <br>
     <%=strTemp%>)</font></div></td>
   <td width="10%" rowspan="2" valign="bottom" class="thinborder"><font size="1">Date Hired </font></td>
   <td colspan="3" class="thinborder"><div align="center"><font size="1">Length of Service<br>
     ( as of <%=strTemp%>)</font></div></td>
   </tr>
   <tr>
     <td width="5%" class="thinborder"><font size="1">Years</font></td>
     <td width="6%" class="thinborder"><font size="1">Months</font></td>
     <td width="7%" class="thinborder"><font size="1">Days</font></td>
   </tr>
  <% int iCtr = 1;
  	for(int i = 0; i < vRetResult.size() ; i+= 11, iCtr++) {
  %> 
   <tr>
     <td height="20" class="thinborder"><%=iCtr%></td>
     <td class="thinborder"><%=(String)vRetResult.elementAt(i+1)%></td>
     <td class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i+2),"&nbsp;")%></td>
     <td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+4)%></td>
     <td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+3)%></td>
     <td class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i+5),"&nbsp;")%></td>
     <td class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i+6),"&nbsp;")%></td>
	 <% 
	 	if ((Date)vRetResult.elementAt(i+7) != null) 
			strTemp = WI.formatDate((Date)vRetResult.elementAt(i+7),10);
		else
			strTemp = "&nbsp;";
	  %>
     <td class="thinborder"><%=strTemp%></td>
     <td class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i+8),"&nbsp;")%></td>
     <td class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i+9),"&nbsp;")%></td>
     <td class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i+10),"&nbsp;")%></td>
   </tr>
  <%}%> 
  </table>
 <%}  %>

  <table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF" id="footer">
    <tr> 
      <td height="18">&nbsp;</td>
    </tr>
	<% if (vRetResult != null && vRetResult.size() > 1) { %> 
    <tr>
      <td height="25"><div align="center"><a href="javascript:PrintPg()"><img src="../../../../images/print.gif" border="0"></a><font size="1">click to print report</font> </div></td>
    </tr>
	<%}%> 
  </table>
  <input type="hidden" name="print_page" value="0">
  <input type="hidden" name="show_list" value="0">
</form>
</body>
</html>
<%
	dbOP.cleanUP();
%>