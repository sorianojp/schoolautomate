<%@ page language="java" import="utility.*,java.util.Vector,payroll.PRMiscEarnings" %>
<%
boolean bolIsSchool = false;
if( (new CommonUtil().getIsSchool(null)).equals("1"))
	bolIsSchool = true;
String[] strColorScheme = CommonUtil.getColorScheme(6);
//strColorScheme is never null. it has value always.
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<style type="text/css">
<!--

  TABLE.thinborder {
    border-top: solid 1px #000000;
    border-right: solid 1px #000000;
		font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
		font-size: 10px;	
  }

  TD.thinborder {
    border-left: solid 1px #000000;
    border-bottom: solid 1px #000000;
		font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
		font-size: 9px;
  }
-->
.bgDynamic {
	background-color:<%=strColorScheme[1]%>
}
.footerDynamic {
	background-color:<%=strColorScheme[2]%>
}
</style>
</head>
<body onLoad="javascript:window.print();">
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
//add security here.

try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Payroll-MISC EARNINGS-Post Earnings","view_print_posted.jsp");

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
														"view_print_posted.jsp");
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
PRMiscEarnings prd = new PRMiscEarnings(request);
boolean bolPageBreak  = false;
int i = 0;


	vRetResult = prd.searchMiscEarnings(dbOP);
	if (vRetResult != null) {	
	int iMaxRecPerPage = Integer.parseInt(WI.getStrValue(WI.fillTextValue("num_rec_page"),"20"));
	int iCount = 1;
	int iNumRec = 0;//System.out.println(vRetResult);
	int iIncr   = 1;
	 for (;iNumRec < vRetResult.size();){
%>
<form name="form_">
<table width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr>
    <td align="center"><font size="2"><strong><%=SchoolInformation.getSchoolName(dbOP,true,false)%></strong><br>
        <%=SchoolInformation.getAddressLine1(dbOP,false,false)%></font></td>
  </tr>
  <tr>
    <td align="center">&nbsp;</td>
  </tr>
</table>
  <table width="100%" border="0" cellpadding="1" cellspacing="0"  bgcolor="#FFFFFF" class="thinborder" id="search1">
    <tr> 
			<%
				if(WI.fillTextValue("is_posted").equals("0"))
					strTemp = "LIST OF POSTED MISC. EARNINGS";
				else
					strTemp = "LIST OF RELEASED MISC. EARNINGS";
			%>
      <td height="26" colspan="7" align="center" class="thinborder"><strong><%=strTemp%></strong></td>
    </tr>
    <tr> 
      <td width="10%" height="26" align="center" class="thinborder"><strong>EMPLOYEE ID</strong></td>
      <td width="18%" align="center" class="thinborder"><strong>EMPLOYEE NAME</strong></td>
      <td width="20%" align="center" class="thinborder"><strong> DEPARTMENT / OFFICE</strong></td>
      <td width="17%" align="center" class="thinborder"><strong>EARNING NAME</strong></td>
      <td width="10%" align="center" class="thinborder"><strong>AMOUNT</strong></td>
      <td align="center" class="thinborder"><strong>DATE POSTED</strong></td>
			<%if(WI.fillTextValue("is_posted").equals("0"))
					strTemp = "POSTED BY";
				else
					strTemp = "BALANCE";
			%>
      <td align="center" class="thinborder"><strong><%=strTemp%></strong></td>
    </tr>
    <% String strTemp2 = null;
		for(iCount = 1; iNumRec<vRetResult.size(); iNumRec+=18,++iIncr, ++iCount){
		i = iNumRec;
		if (iCount > iMaxRecPerPage){
			bolPageBreak = true;
			break;
		}
		else 
			bolPageBreak = false;			
	  %>		
    <tr> 
      <td height="25" class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i)%></td>
      <td class="thinborder">&nbsp;<%=WI.formatName((String)vRetResult.elementAt(i+1),(String)vRetResult.elementAt(i+2),(String)vRetResult.elementAt(i+3),4)%></td>
      <%
	strTemp2 = (String)vRetResult.elementAt(i+5);
	if (strTemp2 == null)
		strTemp2 = (String)vRetResult.elementAt(i+7);
	else
		strTemp2 += WI.getStrValue((String)vRetResult.elementAt(i+7)," :: ","","");
		
%>
      <td class="thinborder">&nbsp;<%=strTemp2%></td>
      <td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+10)%></td>
			<%
				strTemp = (String)vRetResult.elementAt(i+13);
				strTemp = CommonUtil.formatFloat(strTemp, true);
			%>
      <td align="right" class="thinborder"><%=strTemp%>&nbsp;</td>
      <td width="11%" class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+14)%></td>
			<%if(WI.fillTextValue("is_posted").equals("0")){
					strTemp = (String)vRetResult.elementAt(i+15);
					strTemp2 = "left";
				}else{
					strTemp = (String)vRetResult.elementAt(i+17);
					strTemp = CommonUtil.formatFloat(strTemp, true);
					strTemp2 = "right";
				}
			%>
      <td width="8%" align="<%=strTemp2%>" class="thinborder">&nbsp;<%=strTemp%>&nbsp;</td>
    </tr>
    <%} //end for loop%>
  </table>
 
 <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
     <tr> 
      <td height="26">&nbsp;</td>
    </tr>
</table> 
  <%if (bolPageBreak){%>
<DIV style="page-break-before:always" >&nbsp;</DIV>
<%}//page break ony if it is not last page.

	} //end for (iNumRec < vRetResult.size()
} //end end upper most if (vRetResult !=null)%>

</form>
</body>
</html>
<%
dbOP.cleanUP();
%>