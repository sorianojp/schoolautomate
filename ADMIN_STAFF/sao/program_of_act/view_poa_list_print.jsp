<%@ page language="java" import="utility.*, java.util.Vector, osaGuidance.ProgramOfActivity"%>
<%
	WebInterface WI = new WebInterface(request);
	String strSchoolCode = (String)request.getSession(false).getAttribute("school_code");
	if(strSchoolCode == null)
		strSchoolCode = "";
	boolean bolIsCIT = strSchoolCode.startsWith("CIT");
	
	String strThemeObj = null;
	if(bolIsCIT)
		strThemeObj = "Theme";
	else
		strThemeObj = "Objective";
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
</head>
<script language="javascript"  src ="../../../jscript/common.js" ></script>
<script language="JavaScript">
function ReloadPage()
{
	this.SubmitOnce('form_');
}
</script>
<%
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;
	String[] astrMonthList = {"January","February","March","April","May","June","July","August",
	"September","October","November","December"};
	String strTempIndex = null;
	boolean bolShowRep = true;
	int iCtr = 0;
	
//add security hehol.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Student Affairs-PROGRAM OF ACTIVTIES","view_poa_list.jsp");
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
														"Student Affairs","PROGRAM OF ACTIVTIES",request.getRemoteAddr(),
														"view_poa_list.jsp");
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

Vector vActivities = null;
Vector vEditInfo = null;

Vector vThemes = new Vector();
Vector vRetResult = new Vector();

ProgramOfActivity POA = new ProgramOfActivity();
if(WI.fillTextValue("sy_from").length() > 0) 
	vActivities = POA.viewPOAList(dbOP, WI.fillTextValue("sy_from"), WI.fillTextValue("sy_to"), WI.fillTextValue("viewType"),
	WI.fillTextValue("date_range_from"),WI.fillTextValue("date_range_to"));
	
		if(vActivities!=null){
		   if(WI.fillTextValue("viewType").equals("2")){
			   vThemes = (Vector)vActivities.remove(0);
			   vRetResult = (Vector) vActivities.remove(0);
		   }
		}	
	
%>
<body bgcolor="#FFFFFF">
<%if (WI.fillTextValue("sy_from").length()>0 && WI.fillTextValue("sy_to").length()>0){%>
<!--
<table width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr>
    <td colspan="2"><div align="center">
        <p><strong><%=SchoolInformation.getSchoolName(dbOP,true,false)%> </strong><br>
          <%=SchoolInformation.getAddressLine1(dbOP,false,false)%>,<%=SchoolInformation.getAddressLine2(dbOP,false,false)%>
          <br><br><br>
          <strong>STUDENT DEVELOPMENT OFFICE</strong><br><br>
		  </div></td>
  </tr>
</table>
-->
<%
if(false)
if (WI.fillTextValue("viewType").equals("0") || WI.fillTextValue("viewType").equals("2")){
    if(WI.fillTextValue("viewType").equals("2")){
	     vActivities =(Vector) vThemes;	
	}
   
	if (vActivities != null && vActivities.size()>0) {%>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellpadding="0" cellspacing="0" class="thinborder">
  	<tr bgcolor="#EDEDED">
  		<td colspan="4" height="20" align="center" class="thinborder"><strong> ::: <%=strThemeObj.toUpperCase()%> PROGRAM OF ACTIVITIES :::</strong></td>
  	</tr>
  		<tr>
  		<td width="7.5%" height="20" align="center" class="thinborder"><strong>ORDER</strong></td>
  		<td width="27.5%" align="left" class="thinborder"><strong>&nbsp;OBJECTIVE</strong></td>
  		<td width="22.5%" align="left" class="thinborder"><strong>&nbsp;DATE</strong></font></td>
  		<td width="42.5%" align="left" class="thinborder"><strong>&nbsp;ACTIVITY</strong></td>
  	</tr>
	<%for (iCtr=0;iCtr<vActivities.size();iCtr+=7){%>
  	<tr>
		<%//if (iCtr >0 && vActivities.elementAt(iCtr+2).equals(vActivities.elementAt(iCtr-5)))
			//bolShowRep = false;
		//else
			//bolShowRep = true;%>
  		<td class="thinborder" height="25" align="center">&nbsp;<%//if (bolShowRep){%>
		<%=(String)vActivities.elementAt(iCtr+1)%><%//}%></td>
  		<td class="thinborder">&nbsp;<%//if (bolShowRep){%><%=(String)vActivities.elementAt(iCtr+3)%><%///}%></td>
  		
		<!--<td class="thinborder">&nbsp;<%//=astrMonthList[Integer.parseInt((String)vActivities.elementAt(iCtr + 4))]%>,
		  <%//=(String)vActivities.elementAt(iCtr + 5)%></td>
		  -->
		  <td class="thinborder">
		  <%=(String) vActivities.elementAt(iCtr+4)%> <%=WI.getStrValue((String)vActivities.elementAt(iCtr+5),"- ","","")%>
		  </td>
  		<td class="thinborder">&nbsp;<%=(String)vActivities.elementAt(iCtr+6)%></td>
  	</tr>
  	<%}%>
  </table>
<%}}if(WI.fillTextValue("viewType").equals("1") || WI.fillTextValue("viewType").equals("2")) {
    if(WI.fillTextValue("viewType").equals("2")){
	   vActivities = null;
	   vActivities = (Vector) vRetResult;
	
	}

if (vActivities!= null && vActivities.size()>0){%>	
<!--<div style="page-break-after:always;">&nbsp;</div>-->
<table width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr>
    <td colspan="2"><div align="center">
        <p><strong><%=SchoolInformation.getSchoolName(dbOP,true,false)%> </strong><br>
          <!-- Martin P. Posadas Avenue, San Carlos City -->
          <%=SchoolInformation.getAddressLine1(dbOP,false,false)%>,<%=SchoolInformation.getAddressLine2(dbOP,false,false)%>
          <!-- Pangasinan 2420 Philippines -->
          <br><br>
          <strong>STUDENT DEVELOPMENT OFFICE</strong>
		  </div></td>
  </tr>
</table>
 <table bgcolor="#FFFFFF" width="100%" border="0" cellpadding="0" cellspacing="0" class="thinborder">
  	<tr bgcolor="#EDEDED">
  		<td colspan="4" height="20" align="center" class="thinborder"><strong> ::: PROGRAM OF ACTIVITIES ::: </strong></td>
  	</tr>
  	<tr>
  		<td width="20%%" height="20" align="center" class="thinborder"><strong>DATE</strong></td>
  		<td width="32.5%%" align="left" class="thinborder"><strong>&nbsp;ACTIVITY</strong></td>
  		<td width="25%" align="left" class="thinborder"><strong>&nbsp;VENUE</strong></font></td>
  		<!--<td width="22.5%" align="left" class="thinborder"><strong>&nbsp;OBJECTIVE</strong></td>-->
  	</tr>
	<%for (iCtr=0;iCtr<vActivities.size();iCtr+=6){%>
  	<tr>
  		<td class="thinborder" height="25" align="center">&nbsp;
  		<%//=astrMonthList[Integer.parseInt((String)vActivities.elementAt(iCtr + 1))]%>
		  <%//=(String)vActivities.elementAt(iCtr + 2)%>
		  <%=(String)vActivities.elementAt(iCtr+1)%> <%=WI.getStrValue((String)vActivities.elementAt(iCtr+2),"- ","","")%>
  		</td>
  		<td class="thinborder">&nbsp;<%=(String)vActivities.elementAt(iCtr+3)%></td>
  		<td class="thinborder">&nbsp;<%=(String)vActivities.elementAt(iCtr + 4)%></td>
  		<!--<td class="thinborder">&nbsp;<%=WI.getStrValue((String)vActivities.elementAt(iCtr+5),"No Objectives")%>
  		<%for (;iCtr<vActivities.size(); iCtr+=6){
  			strTempIndex = (String)vActivities.elementAt(iCtr);
  			if((iCtr+6)<vActivities.size() && strTempIndex.equals((String)vActivities.elementAt(iCtr+6))){%>
			<br>&nbsp;<%=(String)vActivities.elementAt(iCtr+11)%><%} else break;}%>  		
  		</td>-->
  	</tr>
  	<%}%>
  </table>
<%}}%>
<script>window.print();</script>
<%}%>
 
</body>
</html>
<%
dbOP.cleanUP();
%>