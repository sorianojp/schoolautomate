<%@ page language="java" import="utility.*,java.util.Vector,payroll.PRMiscEarnings" %>
<%
///added code for HR/companies.
boolean bolIsSchool = false;
if( (new CommonUtil().getIsSchool(null)).equals("1"))
	bolIsSchool = true;
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<style type="text/css">
<!--
body {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 12px;
}
table{
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
}
td {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
 }

th {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
 }


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

-->
</style>
</head>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>

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
								"Admin/staff-Payroll-MISC EARNINGS-Post Earnings","post_ded.jsp");

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
														"Payroll","MISC EARNINGS",request.getRemoteAddr(),
														"post_ded.jsp");
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
Vector vPersonalDetails = null;
Vector vRetResult = null;

PRMiscEarnings prd = new PRMiscEarnings(request);

if (WI.fillTextValue("emp_id").length() > 0) {
    enrollment.Authentication authentication = new enrollment.Authentication();
    vPersonalDetails = authentication.operateOnBasicInfo(dbOP,request,"0");
	
	if (vPersonalDetails == null || vPersonalDetails.size()==0){
		strErrMsg = authentication.getErrMsg();
		vPersonalDetails = null;
	}	
}

%>
<body onLoad="javascript:window.print();">
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="23"><div align="center"><font size="2"><strong><%=SchoolInformation.getSchoolName(dbOP,true,false)%></strong><br>
          <%=SchoolInformation.getAddressLine1(dbOP,false,false)%><br>
          <%=SchoolInformation.getInfo1(dbOP,false,false)%> </font></div></td>
    </tr>
    <tr> 
      <td width="36" height="23">&nbsp;&nbsp;<strong> <%=WI.getStrValue(strErrMsg,"")%></strong></td>
    </tr>
    <tr> 
      <td height="10"><hr size="1"></td>
    </tr>
</table>
 <input name="emp_id" type="hidden" class="textbox" value="<%=WI.fillTextValue("emp_id")%>">
<% if (WI.fillTextValue("emp_id").length() > 0 && vPersonalDetails!=null && vPersonalDetails.size() > 0){ %>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td width="5%" height="29">&nbsp;</td>
      <td width="45%">Employee Name : <strong><%=WI.formatName((String)vPersonalDetails.elementAt(1), (String)vPersonalDetails.elementAt(2),
							(String)vPersonalDetails.elementAt(3), 4)%></strong></td>
      <td width="50%" height="29">Employee ID :<strong><%=WI.fillTextValue("emp_id")%></strong> 
      </td>
    </tr>
    <tr> 
      <td height="29">&nbsp;</td>
      <%
	strTemp = (String)vPersonalDetails.elementAt(13);
	if (strTemp == null){
		strTemp = WI.getStrValue((String)vPersonalDetails.elementAt(14));
	}else{
		strTemp += WI.getStrValue((String)vPersonalDetails.elementAt(14)," :: ","","");
	}
%>
      <td height="29" colspan="2"><%if(bolIsSchool){%>College<%}else{%>Division<%}%>/Office : <strong><%=strTemp%></strong></td>
    </tr>
    <tr> 
      <td height="29">&nbsp;</td>
      <td>Employment Type/Position : <strong><%=(String)vPersonalDetails.elementAt(15)%> 
        </strong></td>
      <td height="29">Employment Status : <strong><%=(String)vPersonalDetails.elementAt(16)%> 
        </strong></td>
    </tr>
    <tr> 
      <td height="25" colspan="3">&nbsp;</td>
    </tr>
  </table>
<% vRetResult = prd.operateOnMiscEarnings(dbOP,4);
	if (vRetResult != null &&  vRetResult.size() > 0) {%>
<table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF" class="thinborder">
  <tr>
    <td height="26" colspan="6" class="thinborder"><div align="center"><strong>LIST
      OF POSTED MISCELLANEOUS EARNINGS</strong></div></td>
  </tr>
  <tr>
    <td width="18%" class="thinborder"><div align="center"><strong><font size="1">EARNING NAME</font></strong></div></td>
    <td width="15%" height="28" class="thinborder"><div align="center"><font size="1"><strong>RELEASE DATE</strong></font></div></td>
    <td width="13%" class="thinborder"><div align="center"><font size="1"><strong>AMOUNT</strong></font></div></td>
    <td width="13%" class="thinborder"><div align="center"><font size="1"><strong>RECEIVABLE BALANCE</strong></font></div></td>
    <td class="thinborder"><div align="center"><font size="1"><strong>DATE POSTED</strong></font></div></td>
    <td class="thinborder"><div align="center"><font size="1"><strong>REMARKS</strong></font></div></td>
  </tr>
  <% for (int i = 0; i < vRetResult.size(); i+=15){%>
  <tr>
    <td height="25" valign="top" class="thinborder"><font size="1">&nbsp;<%=(String)vRetResult.elementAt(i+1)%></font></td>
    <td valign="top" class="thinborder"><font size="1">&nbsp;<%=(String)vRetResult.elementAt(i+2)%></font></td>
    <%
	  	strTemp = (String)vRetResult.elementAt(i+3);
	  %>
    <td valign="top" class="thinborder"><div align="right"><font size="1"><%=CommonUtil.formatFloat(strTemp,true)%>&nbsp;</font></div></td>
    <%
	  	strTemp = (String)vRetResult.elementAt(i+4);
	  %>
    <td valign="top" class="thinborder"><div align="right"><font size="1"><%=CommonUtil.formatFloat(strTemp,true)%>&nbsp;</font></div></td>
    <td width="14%" valign="top" class="thinborder"><div align="center"><font size="1"><%=(String)vRetResult.elementAt(i+5)%></font></div></td>
    <td width="27%" valign="top" class="thinborder"><font size="1">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i+7),"")%></font></td>
  </tr>
  <%} //end for loop%>
</table>
<% } // end vRetResult != null && vRetResult.size() > 0
}// end if Employee ID is null %>
</body>
</html>
<%
dbOP.cleanUP();
%>