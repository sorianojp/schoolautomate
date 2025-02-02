<%
String strSchCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchCode == null)
	strSchCode = "";

%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>DAILY CASH COLLECTION DETAILED REPORT</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<style type="text/css">
<!--
body {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 9px;
}

td {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 9px;
 }

th {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 9px;
 }


    TABLE.thinborder {
    border-top: solid 1px #000000;
    border-right: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 9px;
    }

    TD.thinborder {
    border-left: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 9px;
    }

-->
</style>
</head>
<%@ page language="java" import="utility.*,EnrlReport.DailyCashCollection,enrollment.Authentication,java.util.Vector" %>
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String[] astrConvertGender = {"Male","Female"};
	String strTemp = null;

	Vector vTuitionFee       = null;
	Vector vSchFacDeposit   = null;
	Vector vRemittance      = null;
	int i = 0;

	double dSubTotalCash  = 0d;
	double dSubTotalCheck = 0d;
	double dSubTotalCA    = 0d;//cash advance
	double dSubTotalCC    = 0d;//credit card.. 

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Fee Assessment & Payments-REPORTS","daily_cash_col.jsp");
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
														"Fee Assessment & Payments","Reports",request.getRemoteAddr(),
														"daily_cash_col.jsp");
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
Vector vEmployeeInfo = null;
Authentication auth = new Authentication();
DailyCashCollection DC = new DailyCashCollection();
Vector[] vCollectionInfo = null;

vEmployeeInfo = auth.operateOnBasicInfo(dbOP, request,"0");
if(vEmployeeInfo == null)
	strErrMsg = auth.getErrMsg();
else if(WI.fillTextValue("date_of_col").length() > 0 && WI.fillTextValue("teller_index").length() > 0)
{
	vCollectionInfo  = DC.viewDailyCashCollectionDtlsPerTeller(dbOP,request.getParameter("date_of_col"),request.getParameter("teller_index"),request);
	if(vCollectionInfo == null)
		strErrMsg = DC.getErrMsg();
}

if(vCollectionInfo != null)
{
	vTuitionFee      = vCollectionInfo[0];
	vSchFacDeposit   = vCollectionInfo[1];
	vRemittance      = vCollectionInfo[2];
}

%>

<body >
<table width="100%" border="0" cellpadding="0" cellspacing="0">
  <tr>
    <td height="20" colspan="2" ><div align="center">
	<font size="2">
      <strong><%=SchoolInformation.getSchoolName(dbOP,true,false)%></strong><br>
        <font size="1"><%=SchoolInformation.getAddressLine1(dbOP,false,true)%></font></font></div></td>
  </tr>
  <tr >
    <td height="20" colspan="2" ><div align="center">DAILY CASH COLLECTION DETAILED
        REPORT</div></td>
  </tr>
  <tr >
    <td height="20" colspan="2" ><div align="center">DATE : <strong><%=WI.fillTextValue("date_of_col")%></strong></div></td>
  </tr>
</table>
<%
if(strErrMsg != null){%>
<table width="100%" cellpadding="0" cellspacing="0">
 <tr>
	<td><font size="3">Error in processing : <%=strErrMsg%></font>
	</td>
 </tr>
</table>
<%return;
}%>

<table width="100%" border="0" cellpadding="0" cellspacing="0">
  <tr >
    <td width="48%" height="20" >Teller ID:<strong> <%=WI.fillTextValue("emp_id")%></strong></td>
    <td width="52%" height="20" >&nbsp;</td>
  </tr>
  <tr >
    <td height="20" >Name of Teller : <strong><%=WI.formatName((String)vEmployeeInfo.elementAt(1),(String)vEmployeeInfo.elementAt(2),(String)vEmployeeInfo.elementAt(3),1)%></strong></td>
    <td height="20" ><div align="right">&nbsp;Date/ Time Printed : <%=WI.getTodaysDateTime()%></div></td>
  </tr>
</table>
<%

boolean bolIsCancelled = false;//only for cldh.. 
boolean bolIsCLDH      = strSchCode.startsWith("CLDH");
String strStrikeThru   = null;//strike thru' if OR is cancelled.

if(vCollectionInfo != null && vCollectionInfo.length > 0){%>
<table bgcolor="#FFFFFF" width="100%" cellspacing="0" cellpadding="0" class="thinborder">
  <tr bgcolor="#CCCCCC">
    <td height="20" colspan="6" class="thinborder"><div align="center"><strong>COLLECTION ACCOUNTED
        AS FOLLOWS</strong></font></div></td>
  </tr>
  <tr>
    <td width="9%" class="thinborder"><div align="center"><font size="1"><strong>TYPE
        OF <br>
        PMT</strong></font></div></td>
    <td width="16%" height="20" class="thinborder"><div align="center"><font size="1"><strong>O.R.
        NUMBER</strong></font></div></td>
    <td width="25%" class="thinborder"><div align="center"><font size="1"><strong>NAME
        OF STUDENT/PAYEE</strong></font></div></td>
    <td width="10%" class="thinborder"><div align="center"><font size="1"><strong>AMOUNT</strong></font></div></td>
    <td width="15%" class="thinborder"><div align="center"><font size="1"><strong>COURSE 
        CODE </strong></font></div></td>
    <td width="25%" class="thinborder"><font size="1"><strong>FEE PARTICULARS</strong></font></td>
  </tr>
  <tr>
    <td height="21" colspan="6" class="thinborder"><font size="1">&nbsp;&nbsp;CASH</font>
    </td>
  </tr>
  <%
if(vTuitionFee != null && vTuitionFee.size() > 0)
{
	for(i = 0; i< vTuitionFee.size(); ++i)
	{
		///to indicate cancelled OR for CLDH.
		if(bolIsCLDH && WI.getStrValue(vTuitionFee.elementAt(i + 3)).equals("0.0")) {
			bolIsCancelled = true;
			strStrikeThru =" style='text-decoration:line-through;'";
		}
		else {	
			bolIsCancelled = false;
			strStrikeThru  = "";
		}

		if( ((String)vTuitionFee.elementAt(i)).compareTo("0") !=0)//not cash, break here.
		{
			i=i+9;
			continue;
		}
		dSubTotalCash += Double.parseDouble((String)vTuitionFee.elementAt(i+3));
	%>
  <tr>
    <td class="thinborder"><font size="1">&nbsp;</font></td>
    <td height="20" class="thinborder"><font size="1">&nbsp;<%=(String)vTuitionFee.elementAt(i+1)%></font></td>
    <td class="thinborder"><font size="1">&nbsp;
      <%if(bolIsCancelled){%>
      <font style="color:#FF0000; font-size:9px; font-weight:bold;">Cancelled</font>
      <%}else{%>
      <font size="1">&nbsp;<%=(String)vTuitionFee.elementAt(i+2)%>
      <%//System.out.println((String)vTuitionFee.elementAt(i+1)+" "+(String)vTuitionFee.elementAt(i+8));%>
      </font>
      <%}%>
</font></td>
    <td class="thinborder">
	<div align="right"><font size="1"><%=CommonUtil.formatFloat((String)vTuitionFee.elementAt(i+3),true)%></font></div></td>
    <td class="thinborder"><font size="1">&nbsp;
      <%if(bolIsCancelled){%>
      &nbsp;
      <%}else{%>
      <font size="1"><%=WI.getStrValue(vTuitionFee.elementAt(i+9),"&nbsp;")%></font>
      <%}%>
</font></td>
    <td class="thinborder"><font size="1"><%=(String)vTuitionFee.elementAt(i+5)%>
      <%
	  if(vTuitionFee.elementAt(i+6) != null){%>
      (<%=(String)vTuitionFee.elementAt(i+6)%>)
      <%}%>
      </font></td>
  </tr>
  <%i = i+9;	}
//I have to remove the entries here.
//for(;i>0;--i)
//	vTuitionFee.removeElementAt(0);
}%>
  <tr>
    <td height="20" colspan="3" class="thinborder"><div align="right"><font size="1">TOTAL
        : Php &nbsp;&nbsp;&nbsp;</font></div></td>
    <td class="thinborder"><div align="right"><font size="1"><%=CommonUtil.formatFloat(dSubTotalCash,true)%>&nbsp;</font></div></td>
    <td class="thinborder"><font size="1">&nbsp;</font></td>
    <td class="thinborder">&nbsp;</td>
  </tr>
  <tr>
    <td height="20" colspan="6" class="thinborder"><font size="1">&nbsp;&nbsp;CHECK</font></td>
  </tr>
  <%
if(vTuitionFee != null && vTuitionFee.size() > 0)
{
	for(i = 0; i< vTuitionFee.size(); ++i)
	{
		if( ((String)vTuitionFee.elementAt(i)).compareTo("1") !=0)//not cash, break here.
		{
			i=i+9;
			continue;
		}

		dSubTotalCheck += Double.parseDouble((String)vTuitionFee.elementAt(i+3));
	%>
  <tr>
    <td class="thinborder"><font size="1">&nbsp;</font></td>
    <td height="20" class="thinborder"><font size="1">&nbsp;<%=(String)vTuitionFee.elementAt(i+1)%></font></td>
    <td class="thinborder"><font size="1">&nbsp;
      <%if(bolIsCancelled){%>
      <font style="color:#FF0000; font-size:9px; font-weight:bold;">Cancelled</font>
      <%}else{%>
      <font size="1">&nbsp;<%=(String)vTuitionFee.elementAt(i+2)%>
      <%//System.out.println((String)vTuitionFee.elementAt(i+1)+" "+(String)vTuitionFee.elementAt(i+8));%>
      </font>
      <%}%>
</font></td>
    <td class="thinborder"><div align="right"><font size="1">&nbsp;<%=CommonUtil.formatFloat((String)vTuitionFee.elementAt(i+3),true)%></font></div></td>
    <td class="thinborder"><font size="1">&nbsp;
      <%if(bolIsCancelled){%>
      &nbsp;
      <%}else{%>
      <font size="1"><%=WI.getStrValue(vTuitionFee.elementAt(i+9),"&nbsp;")%></font>
      <%}%>
</font></td>
    <td class="thinborder"><font size="1"><%=(String)vTuitionFee.elementAt(i+5)%>
      <%
	  if(vTuitionFee.elementAt(i+6) != null){%>
      (<%=(String)vTuitionFee.elementAt(i+6)%>)
      <%}%>
      </font></td>
  </tr>
  <%i = i+9;	}
//I have to remove the entries here.
//for(;i>0;--i)
//	vTuitionFee.removeElementAt(0);
}%>
  <tr>
    <td height="20" colspan="3" class="thinborder"><div align="right"><font size="1">TOTAL
        : Php &nbsp;&nbsp;&nbsp; </font></div></td>
    <td class="thinborder"><div align="right"><font size="1"><%=CommonUtil.formatFloat(dSubTotalCheck,true)%>&nbsp;</font></div></td>
    <td class="thinborder"><font size="1">&nbsp;</font></td>
    <td class="thinborder">&nbsp;</td>
  </tr>
<%if(strSchCode.startsWith("CSA") || strSchCode.startsWith("AUF")){%>
  <tr>
    <td height="20" colspan="6" class="thinborder"><font size="1">&nbsp;&nbsp;CREDIT CARD</font></td>
  </tr>
  <%
if(vTuitionFee != null && vTuitionFee.size() > 0)
{
	for(i = 0; i< vTuitionFee.size(); ++i)
	{
		strTemp = (String)vTuitionFee.elementAt(i);
		if(strTemp.equals("6") || strTemp.equals("7")) {//CC
			//do nothing;
		}
		else {
			i=i+9;
			continue;
		}

		dSubTotalCC += Double.parseDouble((String)vTuitionFee.elementAt(i+3));
	%>
  <tr>
    <td class="thinborder"><font size="1">&nbsp;</font></td>
    <td height="20" class="thinborder"><font size="1">&nbsp;<%=(String)vTuitionFee.elementAt(i+1)%></font></td>
    <td class="thinborder"><font size="1">&nbsp;
      <%if(bolIsCancelled){%>
      <font style="color:#FF0000; font-size:9px; font-weight:bold;">Cancelled</font>
      <%}else{%>
      <font size="1">&nbsp;<%=(String)vTuitionFee.elementAt(i+2)%>
      <%//System.out.println((String)vTuitionFee.elementAt(i+1)+" "+(String)vTuitionFee.elementAt(i+8));%>
      </font>
      <%}%>
</font></td>
    <td class="thinborder"><div align="right"><font size="1">&nbsp;<%=CommonUtil.formatFloat((String)vTuitionFee.elementAt(i+3),true)%></font></div></td>
    <td class="thinborder"><font size="1">&nbsp;
      <%if(bolIsCancelled){%>
      &nbsp;
      <%}else{%>
      <font size="1"><%=WI.getStrValue(vTuitionFee.elementAt(i+9),"&nbsp;")%></font>
      <%}%>
</font></td>
    <td class="thinborder"><font size="1"><%=(String)vTuitionFee.elementAt(i+5)%>
      <%
	  if(vTuitionFee.elementAt(i+6) != null){%>
      (<%=(String)vTuitionFee.elementAt(i+6)%>)
      <%}%>
      </font></td>
  </tr>
  <%i = i+9;	}
//I have to remove the entries here.
//for(;i>0;--i)
//	vTuitionFee.removeElementAt(0);
}%>
  <tr>
    <td height="20" colspan="3" class="thinborder"><div align="right"><font size="1">TOTAL
        : Php &nbsp;&nbsp;&nbsp; </font></div></td>
    <td class="thinborder"><div align="right"><font size="1"><%=CommonUtil.formatFloat(dSubTotalCC,true)%>&nbsp;</font></div></td>
    <td class="thinborder"><font size="1">&nbsp;</font></td>
    <td class="thinborder">&nbsp;</td>
  </tr>
  <tr>
<%}%>
    <td height="20" colspan="6" class="thinborder"><div align="center"></div>
      <font size="1">&nbsp;</font><font size="1">&nbsp;SALARY DEDUCTION</font><font size="1">&nbsp;</font><font size="1">&nbsp;</font></td>
  </tr>
  <%
if(vTuitionFee != null && vTuitionFee.size() > 0)
{
	for(i = 0; i< vTuitionFee.size(); ++i)
	{
		if( ((String)vTuitionFee.elementAt(i)).compareTo("2") !=0)//not cash, break here.
		{
			i=i+9;
			continue;
		}
		dSubTotalCA += Double.parseDouble((String)vTuitionFee.elementAt(i+3));
	%>
  <tr>
    <td class="thinborder"><font size="1">&nbsp;</font></td>
    <td height="20" class="thinborder"><font size="1">&nbsp;<%=(String)vTuitionFee.elementAt(i+1)%></font></td>
    <td class="thinborder"><font size="1">&nbsp;
      <%if(bolIsCancelled){%>
      <font style="color:#FF0000; font-size:9px; font-weight:bold;">Cancelled</font>
      <%}else{%>
      <font size="1">&nbsp;<%=(String)vTuitionFee.elementAt(i+2)%>
      <%//System.out.println((String)vTuitionFee.elementAt(i+1)+" "+(String)vTuitionFee.elementAt(i+8));%>
      </font>
      <%}%>
</font></td>
    <td class="thinborder"><div align="right"><font size="1"><%=CommonUtil.formatFloat((String)vTuitionFee.elementAt(i+3),true)%></font>&nbsp;</div></td>
    <td class="thinborder"><font size="1">&nbsp;
      <%if(bolIsCancelled){%>
      &nbsp;
      <%}else{%>
      <font size="1"><%=WI.getStrValue(vTuitionFee.elementAt(i+9),"&nbsp;")%></font>
      <%}%>
</font></td>
    <td class="thinborder"><font size="1"><%=(String)vTuitionFee.elementAt(i+5)%>
      <%
	  if(vTuitionFee.elementAt(i+6) != null){%>
      (<%=(String)vTuitionFee.elementAt(i+6)%>)
      <%}%>
      </font></td>
  </tr>
  <%i = i+9;	}
//I have to remove the entries here.
//for(;i>0;--i)
//	vTuitionFee.removeElementAt(0);
}%>
  <tr>
    <td height="20" colspan="3" class="thinborder"><div align="right"><font size="1">TOTAL
        : Php &nbsp;&nbsp;&nbsp;</font></div></td>
    <td class="thinborder"><div align="right"><font size="1"><%=CommonUtil.formatFloat(dSubTotalCA,true)%></font>&nbsp;</div></td>
    <td class="thinborder"><font size="1">&nbsp;</font></td>
    <td class="thinborder">&nbsp;</td>
  </tr>
  <tr>
    <td height="20" class="thinborder"><font size="1">&nbsp;</font></td>
    <td height="20" class="thinborder">&nbsp;</td>
    <td height="20" class="thinborder">&nbsp;</td>
    <td height="20" class="thinborder">&nbsp;</td>
    <td height="20" class="thinborder">&nbsp;</td>
    <td height="20" class="thinborder">&nbsp;</td>
  </tr>
  <tr>
    <td height="20"  colspan="3" class="thinborder"><div align="right"><font size="1">TOTAL 
        COLLECTION :Php &nbsp;&nbsp;&nbsp;</font></div></td>
    <td class="thinborder"><font size="1">&nbsp;
	  <%=CommonUtil.formatFloat(dSubTotalCash+dSubTotalCheck+dSubTotalCA+dSubTotalCC,true)%></font></td>
    <td class="thinborder"><font size="1">&nbsp;</font></td>
    <td class="thinborder">&nbsp;</td>
  </tr>
</table>
<script language="JavaScript">
window.print();
</script>
<%
	}//if collection information is not null.
%>
</body>
</html>
