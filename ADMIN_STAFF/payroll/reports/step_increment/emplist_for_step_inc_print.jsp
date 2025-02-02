<%@ page language="java" import="utility.*,java.util.Vector,payroll.ReportPayroll" %>
<%
///added code for HR/companies.
boolean bolIsSchool = false;
if( (new CommonUtil().getIsSchool(null)).equals("1"))
	bolIsSchool = true;
String[] strColorScheme = CommonUtil.getColorScheme(6);
//strColorScheme is never null. it has value always.
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Print employee eligible for increment</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<style type="text/css">
    TABLE.thinBorder {
    border-top: solid 1px #000000;
    border-right: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 9px;	
    }
    TD.thinBorder {
    border-bottom: solid 1px #000000;
    border-left: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 9px;	
    }
    }	
</style>

</head>
<script language="JavaScript" src="../../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../../jscript/date-picker.js"></script>
<body onLoad="javascript:window.print();">
<form name="form_">

<%  WebInterface WI = new WebInterface(request);


	DBOperation dbOP = null;
	
	String strErrMsg = null;
	String strTemp = null;
	boolean bolProceed = true;
	String strImgFileExt = null;
	int iSearchResult = 0;
	int i = 0;

//add security here.
	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("PAYROLL-REPORTS"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("PAYROLL"),"0"));
		}
	}
	
	if(iAccessLevel == -1)//for fatal error.
	{
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		request.getSession(false).setAttribute("errorMessage","You are logged out. Please login again.");
		response.sendRedirect("../../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0)//NOT AUTHORIZED.
	{
		response.sendRedirect("../../../commfile/unauthorized_page.jsp");
		return;
	}

	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Payroll-REPORTS-Payroll Summary by status","emplist_for_step_inc.jsp");
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
//end of authenticaion code.

	Vector vRetResult = null;
	ReportPayroll RptPay = new ReportPayroll(request);
	String[] astrPTFT = {"Part-Time", "Full-time"};
	vRetResult = RptPay.getEmplistStepInc(dbOP);
%>
		<%if(vRetResult != null && vRetResult.size() > 0){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="14" align="center"><strong>LIST OF EMPLOYEES ELIGIBLE FOR STEP <%=WI.fillTextValue("step")%> INCREMENT</strong></td>
    </tr>
    <tr>
      <td height="14" align="center">&nbsp;</td>
    </tr>
  </table>  
  <table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF" class="thinBorder">
    <tr> 
      <td  width="8%" height="25" align="center" class="thinBorder" ><strong>EMPLOYEE 
      ID</strong></td>
      <td width="25%" align="center" class="thinBorder"><strong>NAME</strong></td>
      <td width="10%" align="center" class="thinBorder"><strong>EMPLOYMENT STATUS</strong></td>
      <td width="6%" align="center" class="thinBorder"><strong>DOE</strong></td>
      <td width="15%" align="center" class="thinBorder"><strong>SALARY GRADE </strong></td>
      <td width="19%" align="center" class="thinBorder"><strong>LENGTH OF SERVICE </strong></td>
	  <td width="17%" align="center" class="thinBorder"><strong>OPTION</strong></td>
	  <!--
      <td width="10%"><div align="center"><strong><font size="1">SELECT ALL</font><br>
          <input type="checkbox" name="selAll" value="0" onClick="CheckAll();">
          </strong></div></td>
	-->
    </tr>
    <% int iCount = 0;
	   int iMax = 1;
	for(i = 0 ; i < vRetResult.size(); i +=13,iCount++,iMax++){%>
    <tr> 
      <td height="20" class="thinBorder">&nbsp;<%=(String)vRetResult.elementAt(i + 1)%></td>
      <td height="20" class="thinBorder">&nbsp;<%=WI.formatName(((String)vRetResult.elementAt(i+2)).toUpperCase(), (String)vRetResult.elementAt(i+3),
							((String)vRetResult.elementAt(i+4)).toUpperCase(), 4)%></td>
      <%
	  	if(vRetResult.elementAt(i + 8) != null){
			strTemp = (String) vRetResult.elementAt(i + 8);
			strTemp = astrPTFT[Integer.parseInt(strTemp)];
		}else{
			strTemp = "";
		}
	  %>
      <td class="thinBorder">&nbsp;<%=WI.getStrValue(strTemp,"No Service Record")%></td>
      <td class="thinBorder">&nbsp;<%=(String) vRetResult.elementAt(i + 7)%></td>
      <td class="thinBorder">&nbsp;</td>
      <%
	  	if(vRetResult.elementAt(i + 9) != null){
			strTemp = (String) vRetResult.elementAt(i + 9);
		}else{
			strTemp = "";
		}
	  %>
      <td class="thinBorder">&nbsp;<%=WI.getStrValue(strTemp,"No Service Record")%></td>
	  <td class="thinBorder">&nbsp;</td>
	  <!--
      <td> <div align="center">
          <input type="checkbox" name="user_<%=iCount%>" value="1">
          <input type="hidden" name="user_index_<%=iCount%>" value="<%=vRetResult.elementAt(i)%>">
        </div></td>
	  -->
    </tr>
    <%}//end of for loop to display employee information.%>
	<input type="hidden" name="max_display" value="<%=iMax%>">
  </table>  
  <%}%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="94%" height="25">&nbsp;</td>
    </tr>
  </table>    
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>