<%@ page language="java" import="utility.*,java.util.Vector,hr.HRManageList,hr.HRStatsReports" %>
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
	document.getElementById('footer').deleteRow(0);
	document.getElementById('header').deleteRow(0);
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
Vector vRetResult = null;

HRStatsReports hrStat = new HRStatsReports(request);
boolean bolForceWriteMF = false; // force to write M / F if all employees are part time!

if ( WI.fillTextValue("show_list").equals("1")){
	vRetResult = hrStat.getFacultyListingPerCollege(dbOP);
	if(vRetResult == null)
		strErrMsg = hrStat.getErrMsg();
	
}

%>
<form action="./hr_faculty_listing_per_college.jsp" method="post" name="form_" >
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr>
	  <% strTemp = WI.fillTextValue("cut_off_date");
	  	 if (strTemp.length() == 0)
		 	strTemp = WI.getTodaysDate(1);
		  else
		  	strTemp = WI.formatDate(strTemp, 6);
	   %>  	
      <td height="25" colspan="4" ><div align="center"><strong>FACULTY LISTING as of <%=strTemp%> </strong></div></td>
    </tr>
  </table>

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
	   %>  		  
	  
      <td width="17%"><input name="cut_off_date" type="text" class="textbox" 
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  value="<%=strTemp%>" size="10" maxlength="10">
	  <a href="javascript:show_calendar('form_.cut_off_date');" 
	  	title="Click to select date" onMouseOver="window.status='Select date';return true;"
		onMouseOut="window.status='';return true;"><img src="../../../../images/calendar_new.gif" border="0"></a>	  </td>
      <td width="65%"><a href="javascript:showList()"%><img src="../../../../images/form_proceed.gif" width="81" height="21" border="0"></a></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td class="fontsize11">College</td>
      <td colspan="2" class="fontsize11">
        <select name="college_index">
		<option value=""> ALL</option>
		<%=dbOP.loadCombo("c_index","c_name"," from college  where is_del = 0 order by c_name",
							WI.fillTextValue("college_index"), false)%>
        </select>      </td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td colspan="3" valign="bottom" class="fontsize11">&nbsp;</td>
    </tr>
  </table>
  
 <% 
 	String strCurrentCollege= null;
	String strPTFT = "";
	String strCurrentTenure = "";
	String strGender = "";
	boolean bolIncremented  = false;
 	if (vRetResult != null && vRetResult.size() > 1) {
	Vector vTemp = (Vector)vRetResult.elementAt(0);
	
	
 	int iIndex = -1;
	boolean bolShowCollege = false;
	int k = 0;
	String[] astrPTFT = {"","Full-time", "Part-time","Part-time"};
	int iCtr = 0;
	
 	for (int i  =1 ; i < vRetResult.size();) {
	
//		if (i==1){
//			// set all starting items
//			strCurrentCollege = (String)vRetResult.elementAt(i);
//			strPTFT = (String)vRetResult.elementAt(i+1);
//			strCurrentTenure = (String)vRetResult.elementAt(i+2);
//		}
	
		bolIncremented = false;
		bolShowCollege = true;

		strCurrentCollege = (String)vRetResult.elementAt(i);
 %>
  <table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF">
<%	
	for (; i < vRetResult.size(); ){

		bolIncremented = false;
		if (!strCurrentCollege.equals((String)vRetResult.elementAt(i))) 
			break;
		
		strPTFT = (String)vRetResult.elementAt(i+2);
		strCurrentTenure = WI.getStrValue((String)vRetResult.elementAt(i+3));

	if (bolShowCollege){%> 
	  <tr>
	  	<td colspan="2"> 
			<strong>&nbsp;<%=strCurrentCollege.toUpperCase()%> 
			<%if (vTemp!= null && vTemp.size() > 0) {%> 
			(<%=(String)vTemp.elementAt(k+5)%>) <%}%>   </strong></td>	
	  </tr>
	  <tr>
	  	<td colspan="2">&nbsp;  </td>	
	  </tr>
<%  bolShowCollege = false; k +=6; }
	for (; i < vRetResult.size(); ){
	
		if (!strCurrentCollege.equals((String)vRetResult.elementAt(i)) ||
			!strPTFT.equals((String)vRetResult.elementAt(i+2)) || 
			!strCurrentTenure.equals(WI.getStrValue((String)vRetResult.elementAt(i+3))))
			break;
			
			strGender = (String)vRetResult.elementAt(i+5);
%> 
	  <tr>
	  	<td colspan="2"> 
			<strong>&nbsp;<%=astrPTFT[Integer.parseInt(WI.getStrValue(strPTFT,"1"))]%>, 
				<%=strCurrentTenure%> 
				<% if (vTemp != null && vTemp.size() > 0){%> 
				(<%=(String)vTemp.elementAt(k+5)%>) <%}%> </strong>
		</td>
	  </tr>
	  <tr>
	  	<td colspan="2"> &nbsp; </strong>
		</td>
	  </tr>	  
<%	k +=6; %>
	  <tr>
	  	
	  	<td width="50%" valign="top"> 
			<% if (i < vRetResult.size() &&
				 ((String)vRetResult.elementAt(i+5)).equals("0") &&
				 strCurrentCollege.equals((String)vRetResult.elementAt(i)) && 
				 strPTFT.equals((String)vRetResult.elementAt(i+2)) && 
				 strCurrentTenure.equals(WI.getStrValue((String)vRetResult.elementAt(i+3)))) {
				 
				 iCtr = 1;
			%>
			<table border="0" cellpadding="0" cellspacing="0" width="100%">
				<tr>
				<td colspan="2" ><strong>&nbsp;&nbsp;Male 
				<% if (vTemp != null && vTemp.size() > 0){%> 
				(<%=(String)vTemp.elementAt(k+5)%>) <%}%> </strong></td>
				</tr>
				<tr>
				<td colspan="2" >&nbsp;&nbsp;</td>
				</tr>

			<%  k+= 6;
			 while( i < vRetResult.size() &&
				  ((String)vRetResult.elementAt(i+5)).equals("0") &&
				  strCurrentCollege.equals((String)vRetResult.elementAt(i)) && 
				  strPTFT.equals((String)vRetResult.elementAt(i+2)) && 
				  strCurrentTenure.equals(WI.getStrValue((String)vRetResult.elementAt(i+3)))) {
				  
				  strTemp = (String)vRetResult.elementAt(i+6);
				  
				  strTemp += WI.getStrValue((String)vRetResult.elementAt(i+7),
				  	"(", WI.getStrValue((String)vRetResult.elementAt(i+8),",","","") + ")","");
			%>
				<tr>
				  <td width="8%"><%=iCtr++%></td>
					<td width="92%"><%=strTemp%></td>
				</tr>
			<%	i+=9;bolIncremented = true;
			  } // end while loop%>

		  </table>	
			<%}else{ %>
				&nbsp;
			<%}%>
		</td>
	  	<td width="50%" valign="top"> 
			<% if (i < vRetResult.size() &&
				 ((String)vRetResult.elementAt(i+5)).equals("1") &&
				 strCurrentCollege.equals((String)vRetResult.elementAt(i)) && 
				 strPTFT.equals((String)vRetResult.elementAt(i+2)) && 
				 strCurrentTenure.equals(WI.getStrValue((String)vRetResult.elementAt(i+3)))) {
				 
				 iCtr = 1;
			%>
			<table border="0" cellpadding="0" cellspacing="0" width="100%">
				<tr>
				<td colspan="2" ><strong>&nbsp;&nbsp;Female 
				<% if(vTemp != null && vTemp.size() > 0){%> 
				(<%=(String)vTemp.elementAt(k+5)%>) <%}%> </strong></td>
				</tr>
				<tr>
				<td colspan="2" >&nbsp;&nbsp;</td>
				</tr>
			
			<%  k+= 6;
			 while( i < vRetResult.size() &&
				  ((String)vRetResult.elementAt(i+5)).equals("1") &&
				  strCurrentCollege.equals((String)vRetResult.elementAt(i)) && 
				  strPTFT.equals((String)vRetResult.elementAt(i+2)) && 
				  strCurrentTenure.equals(WI.getStrValue((String)vRetResult.elementAt(i+3)))) {
			
				  strTemp = (String)vRetResult.elementAt(i+6);
				  
				  strTemp += WI.getStrValue((String)vRetResult.elementAt(i+7),
				  	"(", WI.getStrValue((String)vRetResult.elementAt(i+8),",","","") + ")","");
			%>
				<tr>
					<td width="8%"><%=iCtr++%></td>
					<td width="92%"><%=strTemp%></td>
				</tr>
			<%	i+=9;bolIncremented = true; 	
			
			  } // end while loop%>

		  </table>	
			<%}else{ %>
				&nbsp;
			<%}%>
		</td>
	  </tr>
	 <tr>	  	
	  	<td width="50%" valign="top">&nbsp;</td>
	  	<td width="50%" valign="top">&nbsp;</td>
    </tr>	  
<%  
   }
  }
%> 	
	<tr>
	  	<td colspan="2">&nbsp;  </td>	
    </tr>
  </table>
 <% 

   } // end outer for loop %>
 
 <%} // end vRetResult != null  %>
 
  <table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF" id="footer">
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