<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<style type="text/css">
	TABLE.thinborder {
	    border-top: solid 1px #000000;
	    border-right: solid 1px #000000;
		font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
		font-size: 11px;	
    }
	
    TD.thinborder {
	    border-left: solid 1px #000000;
    	border-bottom: solid 1px #000000;
		font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
		font-size: 11px;
    }	
	
</style>
</head>

<body>
<%@ page language="java" import="utility.*,java.util.Vector, eDTR.ReportEDTR, 
                                             eDTR.eDTRUtil, eDTR.WorkingHour" %>
<%
  
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
	String strTemp2 = null;
	String strTemp3 = null;
	boolean bolProceed = true;

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-eDaily Time Record-WORKING HOURS MGMT-View / Delete Working Hours","view_working_hours_print.jsp");
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
														"view_working_hours.jsp");	
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

ReportEDTR RE = new ReportEDTR(request);

int iSearchResult = 0;
String[] astrWeekDays={"Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"}; 
String strWeekDay = null;
vRetResult = RE.getEmployeeWorkingHours(dbOP,true);

if (vRetResult !=null){
	iSearchResult = RE.getSearchCount();
}else{
	strErrMsg = RE.getErrMsg();
}

if (strErrMsg != null) { 
%>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A">
      <td height="25" bgcolor="#FFFFFF">
	  		<strong><font color="#FF0000" size="3">&nbsp;<%=WI.getStrValue(strErrMsg)%></font></strong>      </td>
    </tr>
  </table>
<% }

 if (vRetResult != null && vRetResult.size() > 0) { %> 
  
  <div align="center">
      <strong><%=SchoolInformation.getSchoolName(dbOP,true,false)%><br>
    </strong>      <%=SchoolInformation.getAddressLine1(dbOP,false,false)%></div><br/>
      <br/> 
	 
 
  <table width="100%" border="0" cellpadding="1" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
  
    <tr>
	    <td height="25" colspan="3" align="center" class="thinborder">
		 			<strong>LIST OF WORKING HOURS</strong>		</td>
    </tr>
    <tr align="center">
      <td width="35%" height="25" class="thinborder"><strong>NAME (EMPLOYEE ID)</strong></td>
      <td width="19%" height="25" class="thinborder"><strong>WEEK DAY</strong></td>
      <td width="38%" height="25" class="thinborder"><strong>WORKING HOURS</strong></td>
    </tr>
    <% strTemp2 = null;

  		for(int i = 0 ; i< vRetResult.size(); i+=40){ %>
    <tr>
      <% if (strTemp2 == null){
				strTemp2 = WI.formatName((String)vRetResult.elementAt(i + 1),
					(String)vRetResult.elementAt(i + 2), (String)vRetResult.elementAt(i + 3),4)+
					 " &nbsp;&nbsp; (" +(String)vRetResult.elementAt(i) + " )";

			   }else{
				if(strTemp2.equals((String)vRetResult.elementAt(i))){
					strTemp2 = "&nbsp;";
				}else{
					strTemp2 =WI.formatName((String)vRetResult.elementAt(i + 1),
											(String)vRetResult.elementAt(i + 2), 
											(String)vRetResult.elementAt(i + 3),4)+
					 " &nbsp;&nbsp; (" +(String)vRetResult.elementAt(i) + " )";
				}
  			  }
			%>
      <td class="thinborder"><strong><%=strTemp2%> </strong></td>
      <% 
				strTemp2 = (String)vRetResult.elementAt(i); // set curret ID.. 
				strTemp = (String)vRetResult.elementAt(i+4);
				if (strTemp== null)
					strTemp = (String)vRetResult.elementAt(i+19);
				
				if (strTemp!=null)
					strTemp = astrWeekDays[Integer.parseInt(strTemp)];
				else {
					strTemp = (String)vRetResult.elementAt(i+33);
					if(strTemp == null)
						strTemp = "N/A Weekday";
					else{
						strWeekDay = astrWeekDays[eDTRUtil.getWeekDay(strTemp) - 1];
						strTemp += WI.getStrValue(strWeekDay, " ","","");
 					}
				}
			%>
      <td class="thinborder"><%=strTemp%></td>
      <% 
				strTemp = (String)vRetResult.elementAt(i+18); // flex hours.. 
				if (strTemp== null){
					strTemp =(String)vRetResult.elementAt(i+20);
					if(strTemp!=null){
						strTemp = eDTRUtil.formatTime((String)vRetResult.elementAt(i+20),
							(String)vRetResult.elementAt(i+21),(String)vRetResult.elementAt(i+22));
						strTemp += " - " + eDTRUtil.formatTime((String)vRetResult.elementAt(i+23),
							(String)vRetResult.elementAt(i+24),(String)vRetResult.elementAt(i+25));
						if((String)vRetResult.elementAt(i+26)!=null){
							strTemp += " / " + eDTRUtil.formatTime((String)vRetResult.elementAt(i+26),
								(String)vRetResult.elementAt(i+27),(String)vRetResult.elementAt(i+28));
							strTemp += " - " + eDTRUtil.formatTime((String)vRetResult.elementAt(i+29),
								(String)vRetResult.elementAt(i+30),(String)vRetResult.elementAt(i+31));						
						}
					}else{
						strTemp = eDTRUtil.formatTime((String)vRetResult.elementAt(i+5),
							(String)vRetResult.elementAt(i+6),(String)vRetResult.elementAt(i+7));
						strTemp += " - " +eDTRUtil.formatTime((String)vRetResult.elementAt(i+8),
							(String)vRetResult.elementAt(i+9),(String)vRetResult.elementAt(i+10));
						if ((String)vRetResult.elementAt(i+11)!=null){
							strTemp += " / " +eDTRUtil.formatTime((String)vRetResult.elementAt(i+11),
								(String)vRetResult.elementAt(i+12),(String)vRetResult.elementAt(i+13));
							strTemp += " - " +eDTRUtil.formatTime((String)vRetResult.elementAt(i+14),
								(String)vRetResult.elementAt(i+15),(String)vRetResult.elementAt(i+16));
						}
					}
				}else{
					strTemp += " hours (flex time)";
				}
			%>
      <td class="thinborder"><%=strTemp%></td>
    </tr>
    <%}%>
  </table>
  <div align="right"> <font size="1"><br>
  Printed : <%=WI.getTodaysDate(10)%></font> </div>  
<%}%>
</body>
</html>
<% dbOP.cleanUP(); %>