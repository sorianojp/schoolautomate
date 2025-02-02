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
								"Admin/staff-REPORTS AND STATISTICS-Education","hr_jr_sr_demo_12_wrk_exp.jsp");

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
														"hr_jr_sr_demo_12_wrk_exp.jsp");
if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
	request.getSession(false).setAttribute("errorMessage",comUtil.getErrMsg());
	response.sendRedirect("../../../../commfile/fatal_error.jsp");
	return;
}
else if(iAccessLevel == 0)//NOT AUTHORIZED.
{
	dbOP.cleanUP();
	response.sendRedirect("../../../../commfile/unauthorized_page.jsp");
	return;
}
Vector vRetResult = null;
Vector vInnerResult = null;

HRStatsReports hrStat = new HRStatsReports(request);

if (WI.fillTextValue("show_results").compareTo("1") == 0){
	vRetResult = hrStat.getJrSrEQLoSWrkExp(dbOP);
	if(vRetResult == null)
		strErrMsg = hrStat.getErrMsg();		
}


%>
<form action="./hr_jr_sr_demo_12_wrk_exp.jsp" method="post" name="form_" >
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
      <td width="19%">Emp. Classification</td>
      <td width="15%"> <select name="emp_catg">
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
      <td width="64%"><select name="is_teaching">
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
      </select></td>
    </tr>
    <tr>
      <td height="18">&nbsp;</td>
      <td>&nbsp;</td>
      <td colspan="2">&nbsp;</td>
    </tr>
    <tr>
      <td height="24">&nbsp;</td>
      <td>Cut Off Date </td>
      <td colspan="2">
        <input name="cut_off_date" type="text" class="textbox" id="cut_off_date" value="<%=WI.fillTextValue("cut_off_date")%>" size="10" maxlength="10">
      <a href="javascript:show_calendar('form_.cut_off_date');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../../images/calendar_new.gif" width="20" height="16" border="0"></a>&nbsp;&nbsp;<a href="javascript:ShowResults()"%><img src="../../../../images/form_proceed.gif" width="81" height="21" border="0"></a></td>
    </tr>
  </table>
<% if (vRetResult != null && vRetResult.size() > 0) {%>

  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">

    <tr> 
      <td height="25" colspan="2" bgcolor="#B9B292"><div align="center"><strong><font color="#FFFFFF">SEARCH 
          RESULT</font></strong></div></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="2" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr> 
      <td width="21%" height="25"  class="thinborder"> <div align="center"><strong>Name</strong></div></td>
      <td width="14%"  class="thinborder"><strong>Position</strong></td>
      <td width="27%"  class="thinborder"><div align="center"><strong>Educ. Qualification</strong></div></td>
	  
	  <% strTemp = WI.fillTextValue("cut_off_date");
	  	 if( strTemp.length() ==0) 
		 	strTemp = WI.getTodaysDate(10);
	  %> 
	  
      <td width="17%" class="thinborder"><p align="center"><strong>Length of Service at AUF<br>
      as of <%=strTemp%></strong></p>
      </td>

      <td width="21%" class="thinborder"><div align="center"><strong>Prev. Work Experience<br> 
        (outside 
        AUF)</strong></div></td>

    </tr>
    <% 	int k = 0;
		for (int i=0; i < vRetResult.size(); i+=10){ %>
    <tr> 
      <td height="25" valign="top" class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+1)%></td>
	  <% strTemp = (String)vRetResult.elementAt(i+3);
	  	if (strTemp == null)
			strTemp = (String)vRetResult.elementAt(i+5); %> 
      <td valign="top" class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+2) + ", " + strTemp%></td>
      <td valign="top" class="thinborder">&nbsp;
	  <% vInnerResult = (Vector)vRetResult.elementAt(i+7);
//	  		System.out.println(vInnerResult);
	  	if (vInnerResult != null && vInnerResult.size() > 0){ 
			for (k = 0; k < vInnerResult.size(); k+=11){
				strTemp ="";
				if ((String)vInnerResult.elementAt(k+10) != null  && 
					((String)vInnerResult.elementAt(k+10)).equals("1"))
				strTemp = "(Complete Acad. Req)";
				
				strTemp += WI.getStrValue((String)vInnerResult.elementAt(k+3))
				  		+ WI.getStrValue((String)vInnerResult.elementAt(k+8)," - ","","")
				 		+ WI.getStrValue((String)vInnerResult.elementAt(k+9),"(",")","")
						+ WI.getStrValue((String)vInnerResult.elementAt(k+7),"(",")","")
						+ WI.getStrValue((String)vInnerResult.elementAt(k+1),"<br>","",""); 
						
				if (k != 0) 
					strTemp = "<br><br> " + strTemp;
	  %> <%=strTemp%>
	  <%}
	   } 
	  %>	  </td>
      <td valign="top" class="thinborder">&nbsp;
	  				<%=WI.getStrValue((String)vRetResult.elementAt(i+8))%>
	  </td>
      <td valign="top" class="thinborder">
	  <% vInnerResult = (Vector)vRetResult.elementAt(i+9);
//	  		System.out.println(vInnerResult);
	  	if (vInnerResult != null && vInnerResult.size() > 0){ 
			for (k = 0; k < vInnerResult.size(); k+=4){
				strTemp = WI.getStrValue((String)vInnerResult.elementAt(k))
				  		+ WI.getStrValue((String)vInnerResult.elementAt(k+1),", ","",""); 
						
				if (k != 0) 
					strTemp = "<br><br> " + strTemp;
	  %> 
	  		<%=strTemp%>
	  <%}
	   } 
	  %> &nbsp;	  </td>
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