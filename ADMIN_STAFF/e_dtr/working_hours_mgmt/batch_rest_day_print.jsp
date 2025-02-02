<%@ page language="java" import="utility.*,java.util.Vector, eDTR.RestDays" %>
<%
	WebInterface WI = new WebInterface(request);//to make sure , i call the dynamic opener form name to reload when close window is clicked.
boolean bolIsSchool = false;
if( (new CommonUtil().getIsSchool(null)).equals("1"))
	bolIsSchool = true;
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<%
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;
	String strTemp2 = null;
	String strImgFileExt = null;
//add security here.

try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Payroll-DTR-Post Deductions","batch_rest_day.jsp");

		ReadPropertyFile readPropFile = new ReadPropertyFile();
		strImgFileExt = readPropFile.getImageFileExtn("imgFileUploadExt");

		if(strImgFileExt == null || strImgFileExt.trim().length() ==0)
		{
			strErrMsg = "Image file extension is missing. Please contact school admin.";
			dbOP.cleanUP();
			throw new Exception();
		}
	}
catch(Exception exp)
	{
		exp.printStackTrace();
		if(strErrMsg == null)
			strErrMsg = "Error in opening DB Connection.";
		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3"><%=strErrMsg%></font></p>
		<%
		return;
	}

//authenticate this user.
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"Payroll","DTR",request.getRemoteAddr(),
														"batch_rest_day.jsp");
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
	RestDays rd = new RestDays();
	int i = 0;
	  vRetResult = rd.operateOnRestDayBatch(dbOP,request, 4);
%>
<body>
<form action="batch_rest_day.jsp" method="post" name="form_">
  <% if (vRetResult != null &&  vRetResult.size() > 0) {%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF" class="thinborder">
    <tr> 
      <td height="20" colspan="5" align="center" class="thinborder"><strong>LIST OF EMPLOYEES REST DAY </strong></td>
    </tr>
    <tr>
      <td width="3%" class="thinborder">&nbsp;</td>
      <td width="5%" class="thinborder">&nbsp;</td> 
      <td width="34%" height="23" align="center" class="thinborder"><strong><font size="1">EMPLOYEE NAME </font></strong></td>
      <td width="29%" align="center" class="thinborder"><strong><font size="1">SET REST DAYS </font></strong></td>
    </tr>
    <% 	int iCount = 1;
			Vector vRestDay = null;
			int iRd = 0;
			String strRestDay = null;
			String[] astrWeekDay = {"Sundays", "Mondays", "Tuesdays", "Wednesdays","Thursdays" ,"Fridays", "Saturdays"};
	   for (i = 0; i < vRetResult.size(); i+=8,iCount++){
		 	vRestDay = (Vector)vRetResult.elementAt(i+7);
			strRestDay = null;
		 %>
    <tr>
      <td class="thinborder"><span class="thinborderTOPLEFT">&nbsp;<%=iCount%></span></td>
      <td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+1)%></td> 
			<input type="hidden" name="id_number_<%=iCount%>" value="<%=(String)vRetResult.elementAt(i+1)%>">
      <td height="25" class="thinborder"><font size="1"><strong>&nbsp;&nbsp;<%=WI.formatName((String)vRetResult.elementAt(i+2), (String)vRetResult.elementAt(i+3),
							(String)vRetResult.elementAt(i+4), 4).toUpperCase()%></strong></font></td>
			<input type="hidden" name="user_<%=iCount%>" value="<%=(String)vRetResult.elementAt(i)%>">
			<% 
			if(vRestDay != null && vRestDay.size() > 0){
				for(iRd = 0; iRd < vRestDay.size(); iRd+=4){
					strTemp2 = (String) vRestDay.elementAt(iRd);
					if(strTemp2 != null && strTemp2.length() > 0){
						if(strRestDay == null)
							strRestDay = "Date : " + strTemp2;
						else
							strRestDay += "<br>&nbsp;Date : " + strTemp2;						
					}else{
						strTemp = (String) vRestDay.elementAt(iRd + 1);
						strTemp = astrWeekDay[Integer.parseInt(strTemp)];
						strTemp += ": " + (String) vRestDay.elementAt(iRd + 2) + " - " + WI.getStrValue((String) vRestDay.elementAt(iRd + 3),"Present");
						if(strRestDay == null){
							strRestDay = strTemp;
						}else{
							strRestDay += "<br>&nbsp;" + strTemp;					
						}
					}				
				}
			}
			%>
      <td class="thinborder">&nbsp;<%=WI.getStrValue(strRestDay)%></td>
			<%
				strTemp = WI.fillTextValue("save_"+iCount);
				if(strTemp.equals("1"))
					strTemp = " checked";
				else
					strTemp = "";
			%>
    </tr>
    <%} //end for loop%>
  </table>
<% } // end vRetResult != null && vRetResult.size() > 0 %>
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>