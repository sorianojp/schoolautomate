<%@ page language="java" import="utility.*,java.util.Vector,payroll.PRLeaveConversion" %>
<%
	WebInterface WI = new WebInterface(request);//to make sure , i call the dynamic opener form name to reload when close window is clicked.
boolean bolIsSchool = false;
if( (new CommonUtil().getIsSchool(null)).equals("1"))
	bolIsSchool = true;
String[] strColorScheme = CommonUtil.getColorScheme(6);
//strColorScheme is never null. it has value always.
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Print Leave Conversion</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../css/tableBorder.css" rel="stylesheet" type="text/css">
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

<%
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;
	String strTemp2 = null;
	boolean bolProceed = true;
	String strImgFileExt = null;
	boolean bolWithSchedule = WI.fillTextValue("with_schedule").equals("1");

try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Payroll-DTR-Leave Conversion(batch)","leave_conversion_batch.jsp");

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
														"leave_conversion_batch.jsp");
if(iAccessLevel == 0){
	iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"Payroll","LEAVE CONVERSION",request.getRemoteAddr(),"leave_conversion_batch.jsp");
}														
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
	Vector vSalaryPeriod 		= null;//detail of salary period.
	PRLeaveConversion prConversion = new PRLeaveConversion();
	int iSearchResult = 0;
	int i = 0;
	String strSchCode = dbOP.getSchoolIndex();
	
	String strWithSched = WI.getStrValue(WI.fillTextValue("with_schedule"),"1");
	String strPayrollPeriod  = null;
	if(bolIsSchool)
		strTemp = "College";
	else
		strTemp = "Division";
	String[] astrSortByName    = {"Employee ID","Firstname","Lastname",strTemp,"Department","Salary Base"};
	String[] astrSortByVal     = {"id_number","user_table.fname","lname","c_name","d_name", "salary_base"};
 
  	  vRetResult = prConversion.operateOnBatchLeaveConversion(dbOP,request, 4);
		if(vRetResult == null)
			strErrMsg = prConversion.getErrMsg();
		else
			iSearchResult = prConversion.getSearchCount();
 
%>
<body onLoad="javscript:window.print();">
<form action="leave_conversion_batch.jsp" method="post" name="form_">
    <% if (vRetResult != null &&  vRetResult.size() > 0) {%>
    <table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF" class="thinborder">
    <tr> 
      <td height="20" colspan="7" align="center" class="thinborder"><strong>LIST OF EMPLOYEES</strong></td>
    </tr>
    <tr>
      <td width="5%" class="thinborder">&nbsp;</td>
      <td width="10%" class="thinborder">&nbsp;</td> 
      <td width="33%" height="23" align="center" class="thinborder"><strong><font size="1">EMPLOYEE NAME</font></strong></td>
      <td width="16%" align="center" class="thinborder"><strong><font size="1">RATE</font></strong></td>
			<%//if(bolWithSchedule){%>
			<%//}%>
      <td width="12%" align="center" class="thinborder"><strong><font size="1">AVAILABLE LEAVE</font></strong></td>
      <td width="12%" align="center" class="thinborder"><strong><font size="1">DAYS TO CONVERT</font></strong></td>
      </tr>
    <% 	int iCount = 1;
	   for (i = 0; i < vRetResult.size(); i+=15,iCount++){		 
		 %>
    <tr>
 
			
		  <td class="thinborder"><span class="thinborderTOPLEFT">&nbsp;<%=iCount%></span></td>
      <td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+1)%></td> 
      <td height="25" class="thinborder"><font size="1"><strong>&nbsp;&nbsp;<%=WI.formatName((String)vRetResult.elementAt(i+2), (String)vRetResult.elementAt(i+3),
							(String)vRetResult.elementAt(i+4), 4).toUpperCase()%></strong></font></td>
			<input type="hidden" name="user_<%=iCount%>" value="<%=(String)vRetResult.elementAt(i)%>">
      <%if((String)vRetResult.elementAt(i + 5)== null || (String)vRetResult.elementAt(i + 6)== null){
					strTemp = " ";			
				}else{
					strTemp = " - ";
				}
			%>
      <td align="right" class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i + 10),"")%>&nbsp;</td>
	 
			<td align="right" class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i + 8),"")%>&nbsp;</td>
		  <%
			strTemp = (String)vRetResult.elementAt(i + 9);
			strTemp = WI.getStrValue(strTemp,"0");
			
			if(Double.parseDouble(strTemp) == 0d)
				strTemp = "";
		%>			
      <td align="center" class="thinborder"><strong> <%=strTemp%> </strong></td>
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