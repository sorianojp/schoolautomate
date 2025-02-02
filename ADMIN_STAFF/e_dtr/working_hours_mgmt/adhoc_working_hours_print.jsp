<%@ page language="java" import="utility.*,java.util.Vector, eDTR.WorkingHour, 
                                             eDTR.eDTRUtil, eDTR.WorkingHour" %>

<%
///added code for HR/companies.
boolean bolIsSchool = false;
if( (new ReadPropertyFile().getImageFileExtn("IS_SCHOOL","1")).equals("1"))
	bolIsSchool = true;
	String[] strColorScheme = CommonUtil.getColorScheme(7);

%>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<style type="text/css">
.bgDynamic {
	background-color:<%=strColorScheme[1]%>
}
.footerDynamic {
	background-color:<%=strColorScheme[2]%>
}
</style>
</head> 
<body onLoad="javascrip:window.print();">
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = "";
	String strTemp = null;
	String strTemp2 = null;
	String strTemp3 = null;
	boolean bolProceed = true;

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-eDaily Time Record-WORKING HOURS MGMT-View Working hours","adhoc_working_hours.jsp");
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
//authenticate this user.
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"eDaily Time Record","WORKING HOURS MGMT",request.getRemoteAddr(), 
														"adhoc_working_hours.jsp");	
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

//end of authenticaion code.
Vector vRetResult = null;
if ((WI.fillTextValue("info_index").length()>0) && (WI.fillTextValue("page_action").equals("1"))){
	WorkingHour WH = new WorkingHour();

	if (!WH.deleteEmpWorkingHour(dbOP,request))
		strErrMsg = WH.getErrMsg();
}

WorkingHour wHour = new WorkingHour();
Vector vEmpOldTime = null;

int iSearchResult = 0;
String[] astrWeekDays = {"Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"}; 
String strWeekDay = null;
String[] astrDateOption = {"ALL", "Specific Dates only", "Started within specified range", "Ended within specified range", "Current Valid Only"}; 

vRetResult = wHour.getAdhocWorkSchedules(dbOP, request);
if (vRetResult !=null){
	iSearchResult = wHour.getSearchCount();
}else{
	strErrMsg = wHour.getErrMsg();
}


%>
<form name="dtr_op">
  <%  if (vRetResult != null && vRetResult.size() > 0){	 %>
  <table width="100%" border="0" cellpadding="1" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr>
	    <td height="25" colspan="3" align="center" class="thinborder">
		 			<strong>LIST OF WORKING HOURS</strong>		</td>
    </tr>
    <tr align="center">
      <td width="35%" height="25" class="thinborder"><strong>NAME (EMPLOYEE ID)</strong></td>
      <td width="26%" height="25" class="thinborder"><strong>SPECIFIC WORKING HOUR</strong></td>
      <td width="31%" height="25" class="thinborder"><strong>ORIGINAL WORKING HOUR</strong></td>
    </tr>
    <% strTemp2 = null;

  		for(int i = 0 ; i< vRetResult.size(); i+=30){ 
				vEmpOldTime = (Vector)vRetResult.elementAt(i+22);
			%>
    <tr>
      <% if (strTemp2 == null){
				strTemp2 = WI.formatName((String)vRetResult.elementAt(i + 2),
					(String)vRetResult.elementAt(i + 3), (String)vRetResult.elementAt(i + 4),4)+
					 " &nbsp;&nbsp; (" +(String)vRetResult.elementAt(i+1) + " )";

			   }else{				 
						if(strTemp2.equals((String)vRetResult.elementAt(i+1))){
							strTemp2 = "&nbsp;";
						}else{
							strTemp2 =WI.formatName((String)vRetResult.elementAt(i + 2),
													(String)vRetResult.elementAt(i + 3), 
													(String)vRetResult.elementAt(i + 4),4)+
							 " &nbsp;&nbsp; (" +(String)vRetResult.elementAt(i+1) + " )";
						}
  			 }
			%>
      <td class="thinborder"><strong><%=strTemp2%> </strong></td>
      <% 
				strTemp2 = (String)vRetResult.elementAt(i+1); // set curret ID.. 

				strTemp = (String)vRetResult.elementAt(i+19); // flex hours.. 
				if (strTemp == null){

						strTemp = eDTRUtil.formatTime((String)vRetResult.elementAt(i+6),
							(String)vRetResult.elementAt(i+7),(String)vRetResult.elementAt(i+8));
						strTemp += " - " +eDTRUtil.formatTime((String)vRetResult.elementAt(i+9),
							(String)vRetResult.elementAt(i+10),(String)vRetResult.elementAt(i+11));

						if ((String)vRetResult.elementAt(i+12)!=null){
							strTemp += " / " +eDTRUtil.formatTime((String)vRetResult.elementAt(i+12),
								(String)vRetResult.elementAt(i+13),(String)vRetResult.elementAt(i+14));
							strTemp += " - " +eDTRUtil.formatTime((String)vRetResult.elementAt(i+15),
								(String)vRetResult.elementAt(i+16),(String)vRetResult.elementAt(i+17));
						}

				}else{
					strTemp = eDTRUtil.formatTime((String)vRetResult.elementAt(i+6),
						(String)vRetResult.elementAt(i+7),(String)vRetResult.elementAt(i+8));
					strTemp += " - " + eDTRUtil.formatTime((String)vRetResult.elementAt(i+9),
						(String)vRetResult.elementAt(i+10),(String)vRetResult.elementAt(i+11));
					strTemp += " ("+ (String)vRetResult.elementAt(i+19) + " hours flex time)";
				}
				
				if(WI.fillTextValue("show_effective_date").length() > 0){
					strTemp3 = WI.getStrValue((String)vRetResult.elementAt(i+34));
					if(strTemp3.length() > 0)
						strTemp3 += WI.getStrValue((String)vRetResult.elementAt(i+35), " - ",""," - Present");

					strTemp3 = WI.getStrValue(strTemp3,"","<br>","");
					strTemp = strTemp3 + strTemp;
				}
			%>
			<td class="thinborder"><%=strTemp%></td>
			<% 
			strTemp = "";
			if(vEmpOldTime != null && vEmpOldTime.size() > 0){
				strTemp = (String)vEmpOldTime.elementAt(16); // flex hours.. 
				if (strTemp == null){
						strTemp = eDTRUtil.formatTime((String)vEmpOldTime.elementAt(3),
							(String)vEmpOldTime.elementAt(4),(String)vEmpOldTime.elementAt(5));
						strTemp += " - " +eDTRUtil.formatTime((String)vEmpOldTime.elementAt(6),
							(String)vEmpOldTime.elementAt(7),(String)vEmpOldTime.elementAt(8));

						if ((String)vEmpOldTime.elementAt(9)!=null){
							strTemp += " / " +eDTRUtil.formatTime((String)vEmpOldTime.elementAt(9),
								(String)vEmpOldTime.elementAt(10),(String)vEmpOldTime.elementAt(11));
							strTemp += " - " +eDTRUtil.formatTime((String)vEmpOldTime.elementAt(12),
								(String)vEmpOldTime.elementAt(13),(String)vEmpOldTime.elementAt(14));
						}
				}else{
					strTemp = eDTRUtil.formatTime((String)vEmpOldTime.elementAt(3),
						(String)vEmpOldTime.elementAt(4),(String)vEmpOldTime.elementAt(5));
					strTemp += " - " + eDTRUtil.formatTime((String)vEmpOldTime.elementAt(6),
						(String)vEmpOldTime.elementAt(7),(String)vEmpOldTime.elementAt(8));
					strTemp += " ("+ (String)vEmpOldTime.elementAt(16) + " hours flex time)";
				}
			}
			%>
      <td class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
    </tr>
    <%}%>
  </table>
<%}%>
</form>
</body>
</html>
<% dbOP.cleanUP(); %>