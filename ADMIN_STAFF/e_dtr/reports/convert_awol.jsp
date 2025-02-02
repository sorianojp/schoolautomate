<%@ page language="java" import="utility.*,java.util.Vector,eDTR.Holidays, eDTR.eDTRUtil, eDTR.ReportEDTR" %>
<%
String[] strColorScheme = CommonUtil.getColorScheme(7);
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Convert Awol</title>
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
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript">
function goToNextSearchPage(){
	ViewRecords();
}	
function ReloadPage()
{
	document.dtr_op.reloadpage.value="1";
	document.dtr_op.viewRecords.value ="0";
	document.dtr_op.submit();
}

function ViewRecords()
{
	document.dtr_op.reloadpage.value="1";
	document.dtr_op.viewRecords.value="1";
	document.dtr_op.submit();
}

function PrintPg() {
	var pgLoc = "../dtr_operations/set_holidays_print.jsp?yyyy_to_view="+
		document.dtr_op.yyyy_to_view.value;
		alert("pgLoc " + pgLoc);
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();

}

</script>
<body bgcolor="#D2AE72" class="bgDynamic">
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
	Vector vRetResult = new Vector();
	String strTemp2 = null;

	

//add security hehol.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-eDaily Time Record-Statistics & Reports -Year Holidays",
								"convert_awol.jsp");
	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		%>
		
<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3"> 
  Error in opening connection </font></p>
		<%
		return;
	}
//authenticate this user.
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"eDaily Time Record","STATISTICS & REPORTS",request.getRemoteAddr(), 
														"convert_awol.jsp");	
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
Holidays hol = new Holidays();
ReportEDTR rprtEDTR = new ReportEDTR(request);
Vector vAwolRec = rprtEDTR.converAWOLToLateOrUT(dbOP, "3590", "2012-10-01" , "2012-12-31");

vRetResult = hol.getHolidays(dbOP, request,null);
if(vRetResult == null)
	strErrMsg = hol.getErrMsg();

strTemp = request.getParameter("dateFrom");
strTemp2 = request.getParameter("dateTo");

/**
if (strTemp!=null && strTemp2!=null && strTemp.length() > 0 && strTemp2.length() > 0){
	strTemp = "(" + strTemp + "-" + strTemp2 +")";	
}
**/

%>
<form action="./convert_awol.jsp" name="dtr_op" >
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A"> s
      <td height="25" align="center" bgcolor="#A49A6A" class="footerDynamic"><font color="#FFFFFF" >
	    <strong>:::: LIST OF  ::::</strong></font></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="25"><%=WI.getStrValue(strErrMsg)%></td>
    </tr>
    
  </table>
	
	
	
	
		<%if(vAwolRec != null && vAwolRec.size() > 0){%>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
  <tr> 
    <td align="right"> 
        <a href="javascript:PrintPg();"><img src="../../../images/print.gif" border="0"></a>
      </td>
  </tr>
</table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr bgcolor="#FFEAEA"> 
      <td height="25" colspan="3" class="thinborder"><p align="center"><strong>AWOL &nbsp;</strong></td>
    </tr>
    <tr> 
      <td width="39%" height="20" class="thinborder"><strong>&nbsp;&nbsp;&nbsp;DATE </strong></td>
      <td width="24%" class="thinborder"><strong>&nbsp;&nbsp;LATE </strong></td>
      <td width="37%" class="thinborder"><strong>&nbsp;&nbspUT</strong></td>
    </tr>
    <% for (int i = 0; i < vAwolRec.size() ; i +=3){
%>
    <tr> 
      <td height="25" class="thinborder">&nbsp;&nbsp;<%=(String)vAwolRec.elementAt(i)%></td>
      <td class="thinborder">&nbsp;&nbsp;<%=(String)vAwolRec.elementAt(i+1)%></td>
      <td class="thinborder">&nbsp;<%=(String)vAwolRec.elementAt(i+2)%></td>
    </tr>
    <% }//end for loop%>

  </table>
	<%}%>
	
	
	
	
	
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#FFFFFF"> 
      <td height="25" >&nbsp;</td>
    </tr>
    <tr bgcolor="#A49A6A" class="footerDynamic"> 
      <td height="25" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
 <input type=hidden name="reloadpage" value="<%=WI.fillTextValue("reloadpage")%>"> 
        <input type=hidden name="viewRecords" value="0">
</form>
</body>
</html>
<% dbOP.cleanUP(); %>