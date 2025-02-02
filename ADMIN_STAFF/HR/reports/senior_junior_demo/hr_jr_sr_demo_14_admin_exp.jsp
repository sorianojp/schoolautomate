<%@ page language="java" import="utility.*,java.util.Vector,hr.HRManageList,hr.HRStatsReports" %>
<%
String[] strColorScheme = CommonUtil.getColorScheme(5);
//strColorScheme is never null. it has value always.
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Search Student</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<style type="text/css">
.fontsize10{
	font-size:11px;
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
	document.form_.print_page.value=1;
	
}

function ShowResults(){
	document.form_.show_results.value ="1";
	this.SubmitOnce("form_");
}
function ReloadPage(){
	this.SubmitOnce("form_");
}

function showList(){
	document.form_.reloadPage.value = "1";
	document.form_.print_page.value = "";
	this.SubmitOnce("form_");
}

</script>

<body bgcolor="#663300" class="bgDynamic">
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
	int iSearchResult = 0;
	
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
Vector vInnerResult = null;

HRStatsReports hrStat = new HRStatsReports(request);

if (WI.fillTextValue("show_results").compareTo("1") == 0){
	vRetResult = hrStat.getJrSrAdminExp(dbOP);
	if(vRetResult == null)
		strErrMsg = hrStat.getErrMsg();		
}


%>
<form action="./hr_jr_sr_demo_14_admin_exp.jsp" method="post" name="form_" >
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A" class="footerDynamic"> 
      <td height="25"><div align="center"><font color="#FFFFFF"><strong>:::: 
          JUNIOR AND SENIOR STAFF PROFILE::::</strong></font></div></td>
    </tr>
    <tr >
      <td height="25" bgcolor="#FFFFFF">&nbsp;<%=WI.getStrValue(strErrMsg,"<strong><font size=\"3\" color=\"#FF0000\">","</font></strong>","")%></td>
    </tr>
  </table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="2%" height="22">&nbsp;</td>
      <td width="14%">Emp. Classification</td>
      <td width="13%"> <select name="emp_catg">
          <option value="">ALL</option>
          <% strTemp = WI.fillTextValue("emp_catg");
			if (strTemp.compareTo("1") ==0) { %>
          <option value="1" selected> Junior Staff</option>
          <%}else{%>
          <option value="1"> Junior Staff</option>
          <%}if (strTemp.compareTo("2") == 0) { %>
          <option value="2" selected> Senior Staff</option>
          <%}else{%>
          <option value="2"> Senior Staff</option>
          <%}%>
      </select></td>
      <td width="71%"><select name="is_teaching">
        <option value=""> ALL </option>
        <% strTemp = WI.fillTextValue("is_teaching");
			if (strTemp.equals("0")) { %>
        <option value="0" selected> NTP</option>
        <%}else{%>
        <option value="0"> NTP </option>
        <%}if (strTemp.equals("1")) { %>
        <option value="1" selected> Academic</option>
        <%}else{%>
        <option value="1"> Academic</option>
        <%}%>
      </select>
      <a href="javascript:ShowResults()"%><img src="../../../../images/form_proceed.gif" width="81" height="21" border="0"></a></td>
    </tr>
    <tr>
      <td height="24">&nbsp;</td>
      <td>Inclusive Date </td>
	  <% 
	  	strTemp = WI.fillTextValue("cut_off_date");
		if (strTemp.length()  == 0) 
			strTemp = WI.getTodaysDate(1);
	  %>
      <td colspan="2"><input name="cut_off_date" type= "text"  class="textbox" 
		   onFocus="style.backgroundColor='#D3EBFF'" 
		   onBlur="style.backgroundColor='white';AllowOnlyIntegerExtn('form_','cut_off_date','/')" 
		   onKeyUp="AllowOnlyIntegerExtn('form_','cut_off_date','/')" value ="<%=strTemp%>" size="10" maxlength="10">
        <a href="javascript:show_calendar('form_.cut_off_date');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../../images/calendar_new.gif" width="20" height="16" border="0"></a></td>
    </tr>
  </table>
<% if (vRetResult != null && vRetResult.size() > 0) {%>

  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">

    <tr> 
      <td height="25" colspan="2" bgcolor="#B9B292"><div align="center"><strong><font color="#FFFFFF">SENIOR AND JUNIOR STAFF ADMINISTRATIVE EXPERIENCE </font></strong></div></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="2" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <% 	int k = 0;
		String strCurrentHeadOffice ="";
       strTemp = WI.fillTextValue("cut_off_date");
	  	 if( strTemp.length() ==0) 
		 	strTemp = WI.getTodaysDate(10);
	
	%> 
    <tr> 
      <td width="16%" height="25"  class="thinborder"> <div align="center"><font size="1">Name</font></div></td>
      <td width="7%"  class="thinborder"><font size="1">Unit </font></td>
      <td width="19%"  class="thinborder"><div align="center"><font size="1">Admin Positions Held </font></div></td>
      <td width="20%"  class="thinborder"><div align="center"><font size="1">Inclusive Date/s</font></div></td>
      <td width="17%"  class="thinborder"><div align="center"><font size="1">Breakdown<br>
        No. of Yrs<br>
        (Admin Exper.)
      </font></div></td>
	  
      <td width="10%" class="thinborder"><font size="1">Total No. of Yrs<br>
      (Admi Exper) </font></td>
      <td width="11%" class="thinborder"><div align="center"><font size="1">AUF- Total Yrs.<br>
        of Service
      </font></div></td>
    </tr>
   <% 
   	Vector vInnerLoop = null;
	String strPositions = "";
	String strIncDate = "";
	String strBreakDown = "";
	k = 0;
   	for (int i=0; i < vRetResult.size(); i+=10){ 
		strPositions = "";
		strIncDate = "";
		strBreakDown = "";
		vInnerLoop = (Vector)vRetResult.elementAt(i+7); 
//		System.out.println("vInnerLoop : " + vInnerLoop);
		if (vInnerLoop != null && vInnerLoop.size() > 0){
			for (k = 0; k < vInnerLoop.size() ; k+= 5)
			if (k==0){
				strPositions = (String)vInnerLoop.elementAt(k) +", " +  (String)vInnerLoop.elementAt(k+1);
				strIncDate = (String)vInnerLoop.elementAt(k+2) +" - " +  (String)vInnerLoop.elementAt(k+3);
				strBreakDown = WI.getStrValue((String)vInnerLoop.elementAt(k+4));
			}else{
				strPositions += "<br>" + (String)vInnerLoop.elementAt(k) +", " +  (String)vInnerLoop.elementAt(k+1);
				strIncDate += "<br>" + (String)vInnerLoop.elementAt(k+2) +
											WI.getStrValue((String)vInnerLoop.elementAt(k+3),"-","","");
				strBreakDown += "<br>" + WI.getStrValue((String)vInnerLoop.elementAt(k+4));
			}
		}
		vInnerLoop = (Vector)vRetResult.elementAt(i+8);		
		if (vInnerLoop != null && vInnerLoop.size() > 0){
			for (k = 0; k < vInnerLoop.size() ; k+= 5){
				if (strPositions.length() == 0)	
					strPositions = (String)vInnerLoop.elementAt(k) +", " 
											+  (String)vInnerLoop.elementAt(k+1);
				else
					strPositions += "<br>" + (String)vInnerLoop.elementAt(k) +", " +  
													(String)vInnerLoop.elementAt(k+1);

				if (strIncDate.length() == 0)
					strIncDate = (String)vInnerLoop.elementAt(k+2) +  
										WI.getStrValue((String)vInnerLoop.elementAt(k+3),"-","","");
				else
					strIncDate += "<br>" + (String)vInnerLoop.elementAt(k+2) +  
											WI.getStrValue((String)vInnerLoop.elementAt(k+3),"-","","- to date");				
			
				if (strBreakDown.length() == 0)
					strBreakDown = WI.getStrValue((String)vInnerLoop.elementAt(k+4));
				else				
					strBreakDown += "<br>" + WI.getStrValue((String)vInnerLoop.elementAt(k+4));
				
			}
		}

	%> 
    <tr> 
      <td height="25" class="thinborder"><font size="1"><%=(String)vRetResult.elementAt(i+1)%></font></td>
	  <% strTemp = (String)vRetResult.elementAt(i+3);
	  	if (strTemp == null)
			strTemp = (String)vRetResult.elementAt(i+5); %> 
	  <td class="thinborder"><font size="1"><%=strTemp%></font></td>
	  <td class="thinborder"><font size="1"><%=strPositions%></font></td>
      <td class="thinborder"><font size="1"><%=strIncDate%></font></td>
      <td class="thinborder"><font size="1"><%=strBreakDown%></font></td>
      <td class="thinborder"><font size="1"><%=WI.getStrValue((String)vRetResult.elementAt(i+6))%></font></td>
      <td class="thinborder"><font size="1"><%=(String)vRetResult.elementAt(i+9)%></font></td>
    </tr>
    <%}// end for loop%>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF">
    <tr> 
      <td height="18">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25">
	<!--
	  <div align="center"><font size="1"><a href="javascript:PrintPg();"> 
          <img src="../../../../images/print.gif" width="58" height="26" border="0"></a>click 
          to print List</font></div>
	--> &nbsp;  
	  </td>
    </tr>
  </table>
<%} //vRetResult != null && vRetResult.size() > 0%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF" id="footer">
    <tr> 
      <td height="25">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25" colspan="3" bgcolor="#A49A6A" class="footerDynamic">&nbsp;</td>
    </tr>
  </table>
  <input type="hidden" name="print_page">
  <input type="hidden" name="reloadPage">
  <input type="hidden" name="show_results" value="0">
</form>
</body>
</html>
<%
	dbOP.cleanUP();
%>