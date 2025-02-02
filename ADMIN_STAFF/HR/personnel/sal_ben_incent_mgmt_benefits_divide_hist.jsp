<%@ page language="java" import="utility.*,java.util.Vector,hr.HRInfoLeave"%>
<%
String[] strColorScheme = CommonUtil.getColorScheme(5);
//strColorScheme is never null. it has value always.
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<style type="text/css">
td{
	font-size: 11px;
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
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
	String strSchCode = WI.getStrValue((String)request.getSession(false).getAttribute("school_code"));

//add security hehol.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-PERSONNEL-Salary/Benefits/Incentives Mgmt","sal_ben_incent_mgmt_benefits_divide_hist.jsp");
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

int iAccessLevel = -1;

if (!strSchCode.startsWith("AUF")){
	iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"HR Management","PERSONNEL",request.getRemoteAddr(),
														"sal_ben_incent_mgmt_benefits_divide_hist.jsp");
}else{
    iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"Payroll","CONFIGURATION",request.getRemoteAddr(),
														"sal_ben_incent_mgmt_benefits_divide_hist.jsp");
}



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
HRInfoLeave hrL = new HRInfoLeave();
vRetResult = hrL.operateOnLeavePerSem(dbOP,request,5);

%>
<body bgcolor="#663300" class="bgDynamic">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="100%" height="25"  bgcolor="#A49A6A" class="footerDynamic"><div align="center"><font color="#FFFFFF" ><strong>:::: 
          BENEFITS MANAGEMENT : LEAVE ASSIGNMENT PER TERM PAGE ::::</strong></font></div></td>
    </tr>
    <tr> 
      <td height="39"><strong>&nbsp;&nbsp;<a href="sal_ben_incent_mgmt_benefits_divide_term.jsp?IS_BENEFIT=0"><img src="../../../images/go_back.gif" border="0" ></a><%=WI.getStrValue(strErrMsg, "<font size=\"3\" color=\"#FF0000\">","</font>","")%></strong>
	  </td>
    </tr>
  </table>
  
<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr> 
    <td width="100%" height="25"> <table width="100%" border="0" align="center"  cellpadding="0" cellspacing="0" class="thinborder">
        <tr bgcolor="#EFFAF1"> 
          <td height="25" colspan="5" align="center" bgcolor="#EFFAF1" class="thinborder"><strong><font size="2">LIST 
            OF LEAVE ASSIGNMENT SETTINGS (OLD RECORDS)</font></strong></td>
        </tr>
        <tr> 
          <td width="24%" height="25" align="center" class="thinborder"><font size="1"><strong>EFFECTIVITY 
            DATE </strong></font></td>
          <td width="17%" height="25" align="center" class="thinborder"><font size="1"><strong> 
            TERM </strong></font></td>
          <td width="24%" height="25" align="center" class="thinborder"><font size="1"><strong>LEAVE</strong></font></td>
          <td width="19%" align="center" class="thinborder"><font size="1"><strong>NO. 
            OF DAYS</strong></font></td>
          <td width="19%" height="25" align="center" class="thinborder"><font size="1"><strong>NO. 
            OF HOURS</strong></font></td>
        </tr>
        <% if (vRetResult == null || vRetResult.size() == 0){%>
        <tr bgcolor="#F7FBF8"> 
          <td height="25" colspan="5" align="center" bgcolor="#F7FBF8" class="thinborder"><strong><font size="2">********* 
            No Active Record *****</font></strong></td>
        </tr>
        <%}else{ 
	
	String[] astrSemester = {"Summer", "1st Sem","2nd Sem","3rd Sem", "ALL "};
	for (int i=0; i < vRetResult.size() ; i+=8) {%>
        <tr> 
          <td height="29" class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+5)%> <%=WI.getStrValue((String)vRetResult.elementAt(i+6)," - ","","")%></td>
          <td class="thinborder">&nbsp;<%=astrSemester[Integer.parseInt(WI.getStrValue((String)vRetResult.elementAt(i+2),"4"))]%></td>
          <td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+7)%></td>
          <td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+3)%></td>
          <td class="thinborder">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i+4))%></td>
        </tr>
        <%}
	}%>
      </table></td>
  </tr>
  <tr> 
    <td height="25">&nbsp;</td>
  </tr>
  <tr>
    <td height="25" bgcolor="#A49A6A" class="footerDynamic">&nbsp;</td>
  </tr>
  <tr> </tr>
</table>
<form>
	<input type="hidden" name="is_benefit" value="0">
</form>
</body>
</html>
<%
	dbOP.cleanUP();
%>
