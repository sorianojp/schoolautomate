<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<%@ page language="java" import="utility.*,enrollment.FARemittance ,search.SearchStudent,java.util.Vector " %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
	String strORNumber = null;

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Fee Assessment & Payments-REMITTANCE-Receive Remittance","receive_remittance.jsp");
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
														"Fee Assessment & Payments","REMITTANCE",request.getRemoteAddr(),
														"receive_remittance.jsp");
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
String[] astrDropListEqual = {"Equal to","Starts with","Ends with","Contains"};
String[] astrDropListValEqual = {"equals","starts","ends","contains"};
String[] astrDropListGT = {"Equal to","Less than","More than"};
String[] astrDropListValGT = {"=",">","<"};

double dGrandTotal = 0d;
double dAmount = 0d;

Vector vRetResult = null;
FARemittance faR = new FARemittance(request);

vRetResult = faR.viewAllRemittances(dbOP);

if (vRetResult == null){
	strErrMsg = faR.getErrMsg();
}
%>

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
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript">

function ReloadPage(){
	this.SubmitOnce("form");
}

function PrintPage(){
<% if (WI.fillTextValue("type_").length() > 0) 
		strTemp = "4";
	else strTemp  = "2"; %>
    document.getElementById('myTable1').deleteRow(<%=strTemp%>);
	
	alert("Please click OK to print this page.");
	window.print();
	
}
</script>
</head>
<body >
<% if (strErrMsg !=null) {%>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;  <strong><font size="3"><%=WI.getStrValue(strErrMsg)%></font></strong>
<%}%>
<form name="form_" method="post" action="viewall_remittance_print.jsp">
 <% if(vRetResult != null && vRetResult.size() > 0){%> 
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" id="myTable1">
    <tr> 
      <td colspan="3"><div align="center"><font size="2"> <strong><%=SchoolInformation.getSchoolName(dbOP,true,false)%></strong><br>
          <font size="1"><%=SchoolInformation.getAddressLine1(dbOP,false,false)%></font> </font><br>
          <%=SchoolInformation.getInfo1(dbOP,false,false)%></div>
        &nbsp;</td>
    </tr>
    <% if (WI.fillTextValue("type_").length() > 0){%>
    <tr> 
      <td width="9%">&nbsp;</td>
      <td width="51%">Remittance Type :: <strong><%=WI.getStrValue((String)vRetResult.elementAt(18))%></strong></td>
      <td width="40%" height="25">Account Name ::<strong> <%=WI.getStrValue((String)vRetResult.elementAt(0))%> </strong></td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td>College/Office :: <strong> 
        <%
	  	strTemp = (String)vRetResult.elementAt(16);
		if (strTemp == null){
			strTemp = (String)vRetResult.elementAt(2);
		}else{
			strTemp += WI.getStrValue((String)vRetResult.elementAt(2)," / ","","");
		}
	  %>
        <%=strTemp%> </strong></td>
      <td height="25">In - Charge :: <strong> <%=WI.getStrValue((String)vRetResult.elementAt(19))%> </strong></td>
    </tr>
    <%}// do not show if remittance type is mixture %>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25" align="right"><strong>&nbsp;<a href="javascript:PrintPage()"><img src="../../../images/print.gif" border="0"></a></strong><font size="1"> 
        click to print&nbsp;&nbsp;</font></td>
    </tr>
    <tr> 
      <td height="25" colspan="3" class="thinborderALL"><div align="center"><strong><font color="#000000">LIST 
          OF REMITTANCES </font></strong></div></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="2" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr align="center"> 
      <% if (WI.fillTextValue("_date").length() > 0){%>
      <td width="8%" class="thinborder"><strong><font size="1">DATE</font></strong></td>
      <%}%>
      <td width="11%" height="25" class="thinborder"><strong><font size="1">OR 
        NUMBER </font></strong></td>
      <% if (WI.fillTextValue("_office").length() > 0){%>
      <td width="18%" class="thinborder"><strong><font size="1">COLLEGE :: OFFICE</font></strong></td>
      <%}%>
      <td width="17%" class="thinborder"><strong><font size="1">REMITTED BY </font></strong></td>
      <% if (WI.fillTextValue("_description").length() > 0) {%>
      <td width="20%" class="thinborder"><strong><font size="1">DESCRIPTION</font></strong></td>
      <%}%>
      <% if (WI.fillTextValue("_teller").length() > 0) {%>
      <td width="13%" class="thinborder"><strong><font size="1">RECEIVED BY</font></strong></td>
      <%}%>
      <td width="13%" class="thinborder"><strong><font size="1">AMOUNT</font></strong></td>

    </tr>
    <% 
	for (int i = 0 ; i < vRetResult.size(); i+=20) {
		dAmount = Double.parseDouble((String)vRetResult.elementAt(i+6));
		dGrandTotal +=dAmount;
	
	%>
    <tr align="center"> 
      <% if (WI.fillTextValue("_date").length() > 0){%>
      <td class="thinborder">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i+7))%></td>
      <%}%>
      <td height="25" class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+8)%></td>
      <%if (WI.fillTextValue("_office").length() > 0) {
		strTemp = (String)vRetResult.elementAt(i+2);
		if (strTemp != null){
			strTemp = WI.getStrValue((String)vRetResult.elementAt(i+16),"", "::","") + strTemp;
		}else{
			strTemp = (String)vRetResult.elementAt(i+16);
		}%>
      <td class="thinborder">&nbsp;<%=strTemp%></td>		
      <%}%>
      <td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+9)%></td>
      <% if (WI.fillTextValue("_description").length() > 0){%>
      <td class="thinborder">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i+13))%></td>
      <%}%>
      <% if (WI.fillTextValue("_teller").length() > 0) {%>
      <td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+14)%></td>
      <%}%>
      <td class="thinborder"><div align="right">&nbsp;<%=CommonUtil.formatFloat(dAmount,true)%></div></td>

    </tr>
    <%}//end for loop%>
  </table>
  <table width="100%">
    <tr> 
      <td align="right"><font size="2"><strong>Grand Total ::: <%=CommonUtil.formatFloat(dGrandTotal,true)%></strong></font></td>
    </tr>
  </table>
  <%} // end vRetResult != null%>
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
