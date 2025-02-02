<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>PAYROLL: SET ADDITIONAL MONTH PAY PARAMETERS : NUMBER OF MONTHS FOR ADDITIONAL MONTH PAY PAGE</title>
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
	font-size: 10px;
    }
	TD.thinborderBOTTOM{
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;
    }
-->
</style>
</head>
<%@ page language="java" import="utility.*,java.util.Vector,payroll.PayrollConfig" %>
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = "";
	String strTemp = null;
//add security here.



try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Payroll-CONFIGURATION-Set Additional Month  Pay Parameters","set_num_of_mths_pay.jsp");
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
														"Payroll","CONFIGURATION",request.getRemoteAddr(),
														"set_num_of_mths_pay.jsp");
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

//end of authenticaion code.
Vector vRetResult = null;
Vector vEditInfo = null;

PayrollConfig pr = new PayrollConfig();

String strPrepareToEdit = WI.fillTextValue("prepareToEdit");
String strPageAction = WI.fillTextValue("page_action");

if (strPageAction.length() > 0){
	if (strPageAction.compareTo("0")==0) {
		if (pr.operateOnMonthPayComp(dbOP,request,0) != null){
			strErrMsg = "  Item removed successfully ";
		}else{
			strErrMsg = pr.getErrMsg();
		}
	}else if(strPageAction.compareTo("1") == 0){
		if (pr.operateOnMonthPayComp(dbOP,request,1) != null){
			strErrMsg = " Item posted successfully ";
		}else{
			strErrMsg = pr.getErrMsg();
		}
	}else if(strPageAction.compareTo("2") == 0){
		if (pr.operateOnMonthPayComp(dbOP,request,2) != null){
			strErrMsg = " Item updated successfully ";
			strPrepareToEdit = "";
		}else{
			strErrMsg = pr.getErrMsg();
		}
	}
}
if (strPrepareToEdit.length() > 0){
	vEditInfo = pr.operateOnMonthPayComp(dbOP,request,3);
	if (vEditInfo == null)
		strErrMsg = pr.getErrMsg();
}

vRetResult = pr.operateOnMonthPayComp(dbOP,request,4);
if (vRetResult != null && strErrMsg == null){
	strErrMsg = pr.getErrMsg();	
}

String[] astrTypeLabel = {"Basic Salary","Gross Salary","Net Salary",""};
String[] astrOBI = {"Benefit", "Incentive", "Overtime",""};
%>
<body onLoad="javascript:window.print();">
<form action="./set_items_included_comp_adtl_pay.jsp" method="post" name="form_" id="form_">
  <% if (vRetResult != null) {  %>
  <table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF">
    <tr> 
      <td height="25" colspan="4"><div align="center"><font size="2"><strong><%=SchoolInformation.getSchoolName(dbOP,true,false)%></strong><br>
          </font><%=SchoolInformation.getAddressLine1(dbOP,false,false)%><br>
          <%=SchoolInformation.getInfo1(dbOP,false,false)%> </div></td>
    </tr>
    <tr> 
      <td height="25" colspan="4">&nbsp;</td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF" class="thinborder">
    <tr> 
      <td height="25" colspan="2" class="thinborder"><div align="center"><strong>LIST 
          OF ITEMS INCLUDED IN THE COMPUTATION OF ADDITIONAL MONTH PAY</strong></div></td>
    </tr>
    <tr> 
      <td width="42" class="thinborder">&nbsp;</td>
      <td width="642" height="27" class="thinborderBOTTOM"><strong><font size="1">ITEMS</font></strong></td>
    </tr>
    <%  int j = 0 ; boolean bolShowHeaders = true;
	for (int i = 0; i < vRetResult.size(); i+=6 ){
		if ((String)vRetResult.elementAt(i+1) != null){
			bolShowHeaders = true; 	j = i;
		}
	if (bolShowHeaders) {
%>
    <tr> 
      <td height="25" colspan="2" class="thinborder">&nbsp; 
        <% for (;j < vRetResult.size(); j+=6){
		if (vRetResult.elementAt(j+1) != null && j != i){	
			bolShowHeaders = false;
			break;
	    }else{%>
        <font color="#0000FF"><strong><%=WI.getStrValue((String)vRetResult.elementAt(j+1), ""," :: " ,"")/*year*/%><%=astrTypeLabel[Integer.parseInt(WI.getStrValue((String)vRetResult.elementAt(j+2),"3"))]/* salary type*/%></strong> 
        </font>
        <%}//end if else  inner loop
	}// end innner for loop 
	bolShowHeaders = false;
	%></td>
    </tr>
    <%} //end bolShowHeaders%>
    <tr> 
      <td class="thinborder">&nbsp;</td>
      <td height="25" class="thinborderBOTTOM"> ++ 
        <% strTemp =(String)vRetResult.elementAt(i+5);
	   	if (strTemp == null)
			strTemp = astrOBI[Integer.parseInt(WI.getStrValue((String)vRetResult.elementAt(i+3),"3"))]/* O B I */ + WI.getStrValue((String)vRetResult.elementAt(i+5)," (",")","")/*sub - type*/;
		if (strTemp.length() == 0)
			strTemp = "(" + astrTypeLabel[Integer.parseInt(WI.getStrValue((String)vRetResult.elementAt(i+2),"3"))] + " only)";%> <%=strTemp%></td>
    </tr>
    <% } //end for int i = 0 loop%>
  </table>
<%} //  vRetResult != null %>
<input type="hidden" name="page_action">
<input type="hidden" name="info_index" value="<%=WI.fillTextValue("info_index")%>">
<input type="hidden" name="print_page">
</form>
</body>
</html>
<%
	dbOP.cleanUP();
%>