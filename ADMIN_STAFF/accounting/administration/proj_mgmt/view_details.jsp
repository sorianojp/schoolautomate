<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="javascript" src="../../../../jscript/date-picker.js"></script>
<script language="javascript">
function PrintPg() {
	document.getElementById('myADTable1').deleteRow(0);
	document.getElementById('myADTable1').deleteRow(0);
	document.getElementById('myADTable1').deleteRow(0);
	document.getElementById('myADTable1').deleteRow(0);
	document.getElementById('myADTable1').deleteRow(0);
	document.getElementById('myADTable1').deleteRow(0);
	
	alert("Click OK to print this page");
	window.print();
}
</script>
<body onLoad="document.form_.project.focus();">
<%@ page language="java" import="utility.*,Accounting.ProjectManagement,java.util.Vector" %>
<%
	///added code for school/companies.
	boolean bolIsSchool = false;
	if((new CommonUtil().getIsSchool(null)).equals("1"))
		bolIsSchool = true;

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);

	String strErrMsg = null;
	String strTemp = null;

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Accounting-Administration-Project management(view details)","view_details.jsp");
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
														"Accounting","Administration",request.getRemoteAddr(), 
														"view_details.jsp");	
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
	ProjectManagement projMgmt = new ProjectManagement();	
	Vector vRetResult    = null;
	
	if(WI.fillTextValue("project").length() > 0) {
		vRetResult = projMgmt.operateOnCreateProject(dbOP, request, 5);
		if(vRetResult == null)
			strErrMsg = projMgmt.getErrMsg();
	}
	else	
		strErrMsg = "Please enter project code/name.";
			
%>
<form method="post" action="./view_details.jsp" name="form_">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" id="myADTable1">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="5" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF"><strong>::::VIEW PROJECT EXPENSE DETAILS - PROJECT MANAGEMENT PAGE ::::</strong></font></div></td>
    </tr>
    <tr>
      <td height="25" colspan="5" style="font-size:13px; color:#FF0000; font-weight:bold"><a href="main.jsp"><img src="../../../../images/go_back.gif" border="0"></a>
	  &nbsp;&nbsp;
	  <%=WI.getStrValue(strErrMsg)%>	  </td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td colspan="4">Project Name/Code        
      <input name="project" type="text" size="64" maxlength="64" value="<%=WI.fillTextValue("project")%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
      &nbsp;&nbsp;
      <input type="submit" name="12022" value=" Refresh " style="font-size:11px; height:20px;border: 1px solid #FF0000;"
		 onClick="document.form_.preparedToEdit.value='';PageAction('','');">      </td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td colspan="4">Order by : 
<%
strTemp = WI.fillTextValue("order_by");
if(strTemp.startsWith("jv_date"))
	strErrMsg = " checked";
else	
	strErrMsg = "";
%>
      <input name="order_by" type="radio" value="jv_date,account_name"<%=strErrMsg%>> Transaction Date 
<%
if(strTemp.startsWith("ACCOUNT_NAME"))
	strErrMsg = " checked";
else	
	strErrMsg = "";
%>
      <input name="order_by" type="radio" value="ACCOUNT_NAME,jv_date"<%=strErrMsg%>> Charged To Account
<%
if(strTemp.length() == 0)
	strErrMsg = " checked";
else	
	strErrMsg = "";
%>
      <input name="order_by" type="radio" value=""<%=strErrMsg%>> Default	  </td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td colspan="4">Filter : Transaction Date : 
	  <input name="date_fr" type="text" size="12" maxlength="12" readonly="yes" value="<%=WI.fillTextValue("date_fr")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
      <a href="javascript:show_calendar('form_.date_fr');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../../images/calendar_new.gif" border="0"></a>
		To 
	  <input name="date_to" type="text" size="12" maxlength="12" readonly="yes" value="<%=WI.fillTextValue("date_to")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
      <a href="javascript:show_calendar('form_.date_to');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../../images/calendar_new.gif" border="0"></a>
	  &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
	  Charge To Account : <input type="text" name="account_no" value="<%=WI.fillTextValue("account_no")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
	  </td>
    </tr>
<%if(vRetResult != null && vRetResult.size() > 0) {
String[] astrConvertTerm = {"Summer", "1st Sem", "2nd Sem","3rd Sem"};
double dRunningExpense = Double.parseDouble((String)vRetResult.elementAt(11));
Vector vChargeDtls = projMgmt.viewProjectExpense(dbOP, (String)vRetResult.elementAt(0),dRunningExpense, request);
String strProjectCostAsOfNow = null;
if(vChargeDtls != null)
	strProjectCostAsOfNow = (String)vChargeDtls.remove(0);
else	
	strProjectCostAsOfNow = projMgmt.getErrMsg();
	
%>    
    <tr>
      <td height="10" colspan="5"><hr size=1></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td align="right" style="font-size:9px;"><a href="javascript:PrintPg();"><img src="../../../../images/print.gif" border="0"></a> Print report</td>
    </tr>
    <tr>
      <td height="25" colspan="5" align="center">
	  <font size="2">
      	<strong><%=SchoolInformation.getSchoolName(dbOP,true,false)%></strong><br>
        <font size="1"><%=SchoolInformation.getAddressLine1(dbOP,false,false)%></font></font>	  </td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>Project Code </td>
      <td><%=vRetResult.elementAt(1)%></td>
      <td>&nbsp;</td>
      <td align="right" style="font-size:9px;"><label id="print_button"></label></td>
    </tr>
    <tr>
      <td width="2%" height="25">&nbsp;</td>
      <td width="14%">Project Name</td>
      <td width="41%"><%=vRetResult.elementAt(2)%></td>
      <td width="13%">Approved by</td>
      <td width="30%"><%=vRetResult.elementAt(8)%></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">Project Date </td>
      <td><%=vRetResult.elementAt(3)%><%=WI.getStrValue((String)vRetResult.elementAt(4), " - ",""," - till date")%></td>
      <td> Approved Budget</td>
      <td><%=CommonUtil.formatFloat((String)vRetResult.elementAt(9), true)%></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25"><%if(bolIsSchool){%>SY/ Term<%}else{%>Year<%}%></td>
      <td><%=vRetResult.elementAt(6)%><%if(bolIsSchool){%>, <%=astrConvertTerm[Integer.parseInt((String)vRetResult.elementAt(7))]%><%}%></td>
      <td>Status: </td>
<%
strTemp = (String)vRetResult.elementAt(5);
if(strTemp.equals("1"))
	strTemp = "On going";
else if(strTemp.equals("2"))
	strTemp = " Completed";
else
	strTemp = " Closed";
%>     <td><%=strTemp%></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">Project Expense Account : </td>
      <td><label><%=vRetResult.elementAt( 12)%> : <%=vRetResult.elementAt(13)%> </label></td>
      <td>Total Expense  </td>
      <td><%=strProjectCostAsOfNow%></td>
    </tr>
  </table>
<%if(vChargeDtls != null && vChargeDtls.size() > 0) {%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr>
      <td height="25" colspan="6" align="center" style="font-size:11px; font-weight:bold" class="thinborder">Project Expense Detail</td>
    </tr>
    <tr style="font-weight:bold;" align="center">
      <td width="8%" class="thinborder">Transaction Date</td>
      <td width="14%" class="thinborder">Payee Name </td>
      <td width="8%"  height="25" class="thinborder">Voucher Reference </td>
      <td width="27%" class="thinborder">Charged to account</td>
      <td width="35%" class="thinborder">Particular/Explanation</td>
      <td width="8%" class="thinborder">Amount</td>
    </tr>
    <%for(int i = 0; i < vChargeDtls.size(); i += 9){%>
		<tr>
		  <td class="thinborder"><%=vChargeDtls.elementAt(i + 2)%></td>
		  <td class="thinborder"><%=vChargeDtls.elementAt(i + 8)%></td>
		  <td class="thinborder"><%=vChargeDtls.elementAt(i + 6)%></td>
		  <td class="thinborder">(<%=vChargeDtls.elementAt(i)%>) <%=vChargeDtls.elementAt(i + 1)%></td>
<%
//format explanation
String strCharAt = null; String strBankCode = ""; int iIndexOf = 0;
strTemp  = WI.getStrValue(vChargeDtls.elementAt(i + 7), "&nbsp;");
iIndexOf = strTemp.toLowerCase().indexOf("check #"); //iIndexOf = -1;
	//get bank code.

	while(iIndexOf > 0) {
		strCharAt = String.valueOf(strTemp.charAt(--iIndexOf));
		if(strCharAt.trim().length() == 0) {
			if(strBankCode.length() > 0)
				break;
			continue;
		}
		strBankCode = strCharAt + strBankCode;
	}
strBankCode = "";
if(iIndexOf > 0) 
	strTemp = strTemp.substring(0,iIndexOf);
	
//I have to format strTemp
if(strTemp == null)
	strTemp = "";
else	
	strTemp = strTemp.replaceAll("\n","<br>");
%>
		  <td  height="25" class="thinborder"><%=strTemp%></td>
		  <td class="thinborder" align="right"><%=vChargeDtls.elementAt(i + 3)%></td>
		</tr>
	<%}if(dRunningExpense > 0d){%>
    <tr style="font-weight:bold">
      <td height="25" colspan="6" class="thinborder" align="right">Beginning Balance (encoded) :: &nbsp;&nbsp;<%=CommonUtil.formatFloat(dRunningExpense, true)%></td>
    </tr>
	<%}%>
    <tr style="font-weight:bold">
      <td height="25" colspan="6" class="thinborder" align="right">Total Expense as of Today :: &nbsp;&nbsp;<%=strProjectCostAsOfNow%></td>
    </tr>
  </table>
<%}//show only if vChargeDtls is not null
}//show only if vRetResutl is not null %>  
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>