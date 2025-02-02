<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>

<script language="JavaScript">
<!--
	function useRecord(strIndex){
	window.opener.document.dtr_op.wh_index.value=strIndex;
	window.opener.document.dtr_op.bTimeIn.value ="0";
	window.opener.focus();
	self.close();
	}
-->
</script>
<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*,java.util.Vector,eDTR.TimeInTimeOut, eDTR.WorkingHour" %>
<%
 
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = "";
	String strTemp = null;
	String strTemp2 = null;
	boolean bolProceed = true;
	String strImgFileExt = null;
//add security here.

	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-eDaily Time Record-Edit Time-in Time-out","wh_update.jsp");
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
														"eDaily Time Record","DTR OPERATIONS",request.getRemoteAddr(), 
														"wh_update.jsp");	
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
	Vector vRetResult =  null;
	String[] astrConvertWeekDay= {"SUNDAY","MONDAY", "TUESDAY", "WEDNESDAY", "THURSDAY", "FRIDAY", "SATURDAY"};	
	String[] astrConverAMPM = {"AM","PM"};

	WorkingHour wh = new WorkingHour();
	double dTemp = 0d;

	vRetResult = wh.getEmployeeWorkingHours(dbOP,request, false, true);	
%>	

<form action="./wh_update.jsp" method="post" name="dtr_op">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A"> 
      <td width="100%" height="25" align="center"><font color="#FFFFFF" ><strong>:::: 
        DTR OPERATIONS - UPDATE WORKING HOUR PAGE ::::</strong></font></td>
    </tr>
    <tr > 
      <td height="25">&nbsp;</td>
    </tr>
  </table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr > 
      <td width="87%" height="25">
	  <table width="90%" border="0" align="center" cellpadding="5" cellspacing="0">
          <% 
	if (vRetResult == null || vRetResult.size()==0) { 
	  	strTemp = "No Recorded Employee Working Hours";
%>
          <tr> 
            <td align="center" colspan=3><font size=2><strong> <%=WI.getStrValue(strTemp)%></strong></font></td>
          </tr>
          <% }else{ %>
          <tr> 
            <td width="17%" height="25" align="center"><strong>WEEK DAY</strong></td>
            <td width="45%" height="25" align="center"><strong>TIME / HOURS</strong></td>
            <td width="20%" height="25" align="center"><strong> USE</strong></td>
          </tr>
          <%
		  	for (int i = 0; i < vRetResult.size(); i+=42){%>
          <tr> 
            <%	
		strTemp = (String)vRetResult.elementAt(i+14);
		if(strTemp.equals("1")){// for flexi
		strTemp2 =(String)vRetResult.elementAt(i+1);
		
		if (strTemp2 == null)
			strTemp2 = "N/A Weekday";
		else  
			strTemp2 = astrConvertWeekDay[Integer.parseInt(strTemp2)];
			
		strTemp = (String)vRetResult.elementAt(i+15);
%>
            <td height="25" bgcolor="#FFFFFF"><font size="1"><%=strTemp2%></font></td>
            <td height="25" bgcolor="#FFFFFF"><font size="1"><strong><%=WI.getStrValue(strTemp)%> hours </strong></font></td>
            <td align="center" bgcolor="#FFFFFF">  
              <a href='javascript:useRecord("<%=WI.getStrValue((String)vRetResult.elementAt(i+31))%>")'>
			  <img src="../../../images/assign.gif" border="0"></a>            </td>
          </tr>
          <%
	}else {
		strTemp = (String)vRetResult.elementAt(i);

		if (strTemp != null){
			strTemp = astrConvertWeekDay[Integer.parseInt((String)vRetResult.elementAt(i+18))];
%>
          <tr> 
            <td height="25"><font size="1"><%=WI.getStrValue(strTemp)%></font></td>
            <%
		strTemp = (String)vRetResult.elementAt(i+19);
		strTemp += ":"  + CommonUtil.formatMinute((String)vRetResult.elementAt(i+20));
		strTemp += " " +(String)vRetResult.elementAt(i+21);
		strTemp += " - ";
		strTemp += (String)vRetResult.elementAt(i+22);
		strTemp += ":"  + CommonUtil.formatMinute((String)vRetResult.elementAt(i+23));
		strTemp += " " + (String)vRetResult.elementAt(i+24);
		if ((String)vRetResult.elementAt(i+25) != null){
			strTemp += " / " + (String)vRetResult.elementAt(i+25);
			strTemp += ":"  + CommonUtil.formatMinute((String)vRetResult.elementAt(i+26));
			strTemp += " " + (String)vRetResult.elementAt(i+27);
			strTemp += " - ";
			strTemp += (String)vRetResult.elementAt(i+28);
			strTemp += ":"  + CommonUtil.formatMinute((String)vRetResult.elementAt(i+29));
			strTemp += " " + (String)vRetResult.elementAt(i+30);
		}	else{
			if(vRetResult.elementAt(i+37) != null && vRetResult.elementAt(i+38) != null){
				dTemp = Double.parseDouble((String)vRetResult.elementAt(i+37));
				strTemp += " [" +wh.convertFloatToTime(dTemp);

				dTemp = Double.parseDouble((String)vRetResult.elementAt(i+38));
				strTemp += " - " +wh.convertFloatToTime(dTemp) + "]";
			}
		}
			if (((String)vRetResult.elementAt(i+32)).compareTo("1") == 0)
				strTemp +="(next day)";
		
%>
            <td height="25"><font size="1"><strong><%=WI.getStrValue(strTemp)%></strong></font></td>
            <td align="center"> <a href='javascript:useRecord("<%=WI.getStrValue((String)vRetResult.elementAt(i+31))%>")'><img src="../../../images/assign.gif" border="0"></a></td>
          </tr>
          <% }else{ 
	
		strTemp = (String)vRetResult.elementAt(i+1);
		
		if (strTemp == null) {
			strTemp = WI.getStrValue((String)vRetResult.elementAt(i+36), "N/A Weekday");
		}else
			strTemp = astrConvertWeekDay[Integer.parseInt(strTemp)];

		strTemp2 = (String)vRetResult.elementAt(i+2);
		strTemp2 += ":"  + CommonUtil.formatMinute((String)vRetResult.elementAt(i+3));
		strTemp2 += " " +(String)vRetResult.elementAt(i+4);
		strTemp2 += " - ";
		strTemp2 += (String)vRetResult.elementAt(i+5);
		strTemp2 += ":"  + CommonUtil.formatMinute((String)vRetResult.elementAt(i+6));
		strTemp2 += " " + (String)vRetResult.elementAt(i+7);
	
		if ((String)vRetResult.elementAt(i+8) !=null){
			strTemp2 += " / " + (String)vRetResult.elementAt(i+8);
			strTemp2 += ":"  + CommonUtil.formatMinute((String)vRetResult.elementAt(i+9));
			strTemp2 += " " + (String)vRetResult.elementAt(i+10);
			strTemp2 += " - ";
			strTemp2 += (String)vRetResult.elementAt(i+11);
			strTemp2 += ":"  + CommonUtil.formatMinute((String)vRetResult.elementAt(i+12));
			strTemp2 += " " + (String)vRetResult.elementAt(i+13);
		}else{
			if(vRetResult.elementAt(i+37) != null && vRetResult.elementAt(i+38) != null){
				dTemp = Double.parseDouble((String)vRetResult.elementAt(i+37));
				strTemp2 = " [" +wh.convertFloatToTime(dTemp);

				dTemp = Double.parseDouble((String)vRetResult.elementAt(i+38));
				strTemp2 += " - " +wh.convertFloatToTime(dTemp) + "]";
			}
		}
		if (((String)vRetResult.elementAt(i+32)).compareTo("1") == 0)
			strTemp2 +=" (next day)";

		
%>
          <tr> 
            <td height="25"><font size="1"><%=strTemp%></font></td>
            <td height="25"><font size="1"><strong><%=WI.getStrValue(strTemp2,"")%></strong></font></td>
            <td align="center"> <a href='javascript:useRecord("<%=WI.getStrValue((String)vRetResult.elementAt(i+31))%>")'><img src="../../../images/assign.gif" border="0"></a></td>
          </tr>
          <%}// end else
   } // end for loop
  } // end if
} %>
        </table></td>
    </tr>
    <tr > 
      <td height="25" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>


<input type="hidden" name="emp_id" value="<%=WI.fillTextValue("emp_id")%>">
<input type="hidden" name="bTimeIn" value="">
<input type="hidden" name="info_index" value="<%= request.getParameter("info_index")%>">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>