<%@ page language="java" import="utility.*,Accounting.JvCD,java.util.Vector" %>
<%
	WebInterface WI  = new WebInterface(request);
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<style type="text/css">
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
	font-size: 10px;
    }

</style>
</head>

<body onLoad="<%if(WI.fillTextValue("print_stat").length()==0){%>window.print();<%}%>" topmargin="0" bottommargin="0" leftmargin="0" rightmargin="0">
<%
	DBOperation dbOP = null;

	String strTemp   = null;
	String strErrMsg = null; String strSaveNotAllowedMsg = null;
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Accounting-Transaction","jv_ar_student.jsp");
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
	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ACCOUNTING-TRANSACTION"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ACCOUNTING"),"0"));
		}
	}

if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
	request.getSession(false).setAttribute("errorMessage","You are already logged out. Please login again.");
	response.sendRedirect("../../../../commfile/fatal_error.jsp");
	return;
}
else if(iAccessLevel == 0)//NOT AUTHORIZED.
{
	dbOP.cleanUP();
	response.sendRedirect("../../../../commfile/unauthorized_page.jsp");
	return;
}

//end of authenticaion code.

String strJVNumber = null;
JvCD jvCD = new JvCD();
Vector vRetResult = null;

///view detail. 
vRetResult = jvCD.operateOnJVDetailEntry(dbOP, request, 4);
if(vRetResult == null) 
	strErrMsg = jvCD.getErrMsg();
	

if(strErrMsg != null) {
%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#FFFFFF">
      <td style="font-size:14px; color:#0000FF; font-weight:bold">&nbsp;&nbsp;<%=WI.getStrValue(strErrMsg)%></td>
    </tr>
  </table>
<%
	dbOP.cleanUP();
	return;
}
String strJVDate = null;
boolean bolIsCD  = false;
java.sql.ResultSet rs = dbOP.executeQuery("select JV_DATE,IS_CD from ac_jv where jv_number='"+
	WI.fillTextValue("jv_number")+"'");
rs.next();
strJVDate = ConversionTable.convertMMDDYYYY(rs.getDate(1));
if(rs.getInt(2) == 1)
	bolIsCD = true;
rs.close();

%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr >
      <td width="67%" height="25"><div align="center"><font size="2">
      <strong><%=SchoolInformation.getSchoolName(dbOP,true,false)%></strong><br>
        <font size="1"><%=SchoolInformation.getAddressLine1(dbOP,false,false)%></font></font><br>
        <!--TIN - 004-005-307-000-NON-VAT-->
        Accounting Office</div></td>
      <td width="33%" valign="top">JV Number : <%=WI.fillTextValue("jv_number")%><br>
	  JV Date : <%=strJVDate%><br>
	  <font size="1">Date and time Printed : <%=WI.getTodaysDateTime()%></font>	  </td>
    </tr>
</table>
	
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="25" valign="bottom" style="font-size:16px; font-weight:bold" align="center">Supporting Document for A/R FS, A/R Student or A/R Other Details </td>
    </tr>
    <tr> 
      <td height="9"><hr size="1"></td>
    </tr>
  </table>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
<%
Vector vMainJV = (Vector)vRetResult.remove(0);//remove main information. i do not need here.
Vector vJVDetail = null;
//System.out.println(bolIsCD);
boolean bolDoesnotMatch = false; boolean bolPrinted = false;
for(int i =0; i < vMainJV.size(); i += 7){
if(vRetResult.size() == 0) 
	break;
if(!vRetResult.elementAt(0).equals(vMainJV.elementAt(i)))
	continue;
if(vMainJV.elementAt(i + 6).equals("0"))
	bolDoesnotMatch = true;
else	
	bolDoesnotMatch = false;
vRetResult.removeElementAt(0);//remove JV_CREDIT_INDEX
vJVDetail = (Vector)vRetResult.remove(0);
%>
    <tr<%if(bolDoesnotMatch && !bolIsCD){%> bgcolor="#FF0000"<%}%>> 
      <td height="25" width="2%" style="font-size:11px; font-weight:bold;"><%=vMainJV.elementAt(i + 4)%>.</td>
      <td width="58%" style="font-size:11px; font-weight:bold;"><%=vMainJV.elementAt(i + 2)%></td>
      <td width="5%" style="font-size:11px; font-weight:bold;">&nbsp;</td>
      <td width="15%" style="font-size:11px; font-weight:bold;"><%=vMainJV.elementAt(i + 1)%></td>
      <td width="3%" style="font-size:11px; font-weight:bold;"><%if(vMainJV.elementAt(i + 5).equals("0")){%>D<%}else{%>C<%}%></td>
      <td width="17%" align="right" style="font-size:11px; font-weight:bold;"><%=CommonUtil.formatFloat((String)vMainJV.elementAt(i + 3),true)%></td>
    </tr>
<%for(int p =1;p < vJVDetail.size(); p += 7){%>
    <tr> 
      <td colspan="2"><%=vJVDetail.elementAt(p + 1)%>&nbsp; 
	  <%=WI.getStrValue(vJVDetail.elementAt(p + 2))%>
	  <%=WI.getStrValue((String)vJVDetail.elementAt(p + 3)," - ","","")%>
	  </td>
      <td><%=vJVDetail.elementAt(p + 6)%></td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td align="right"><%=vJVDetail.elementAt(p + 4)%></td>
    </tr>
<%}//end of vJVDetail%>
    <tr> 
      <td height="9" colspan="6"><hr size="1"></td>
    </tr>
<%}//end of vMainJV%>
</table>

</body>
</html>
<%
dbOP.cleanUP();
%>